using module ..\..\securestring\undo-securestring.psm1
using module ..\..\colorconsole\libs\cmdlets\New-ColorConsole.psm1
 
<#
.SYNOPSIS
Sends a request to the GitLab API to retrieve issues for a project, this can be futher filtered by passing in -IssueID.

.DESCRIPTION
Sends a request to the GitLab API to retrieve issues for a project, this can be futher filtered by passing in -IssueID.

.PARAMETER ProjectID
The ID of the project for which to retrieve issues.

.PARAMETER IssueID
The ID of the project for which to retrieve issues.

.EXAMPLE
Request-Issue -ProjectID 1 -issueid 2

.Sends a request to retrieve the issues for the  with ID 2 in the project with ID 1.

.EXAMPLE
Request-Issue -ProjectID 1

.Sends a request to retrieve all issues in the project with ID 1.

.EXAMPLE
Search-gitlab -type project -title myrepo | Request-Issue

.Sends a request to retrieve all issues in the project with ID 1.

.EXAMPLE
Search-gitlab -type project -title myrepo | Request-Issue -issueid 2 -raw

.Sends a request to retrieve all issues in the project with ID 1, but only the issue with ID 2 and returns the raw data

.NOTES
Requires authentication via `Request-GitLabAuth`.
#>

function Request-Issue {

    [CmdletBinding()]
    [Alias('glvrqi')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [pscustomobject]$Data,
        [Parameter(Mandatory = $false)]
        [int]$IssueID,
        [Parameter(Mandatory = $false)]
        [int]$ProjectID,
        [Parameter(Mandatory = $false)]
        [validateset('opened', 'closed', 'active', 'all', IgnoreCase = $true)]
        [string]$State,
        [Parameter(Mandatory = $false)]
        [string[]]$labels,
        [Parameter(Mandatory = $false)]
        [string]$Milestone,
        [Parameter(Mandatory = $false)]
        [switch]$Raw
    )

    process {
        # manage opensate covers all logic
        [string]$issue_state
        switch ($State){
            'opened' { $issue_state = '&state=opened' }
            'closed' { $issue_state = '&state=closed' }
            'Active' { $issue_state = '&state=active' }
            'all' { $issue_state = '' }
        }
        # encode labels if not null
        if($labels){
            $labels = $labels -join ','
            $labels = "&labels=$labels".replace(" ","+")
        }else {$labels = ''}

        # encode milestone if not null
        if($Milestone){
            $Milestone = [System.Web.HttpUtility]::UrlEncode($Milestone)
        }
        #-----------
        # Outh block output to console 
        # can add to all cmdlet/api functions
        #-----------
        [console]::write("$($global:_glvigor.log) gitlab issue request`n")
        # Call Request-GitLabAuth if null write error to console then break
        if ($null -eq $global:_glvigor.auth.httpstatus) {
            [console]::write("$($global:_glvigor.logsub) $(csole -s 'error: not authenticated, use request-gitlabauth to authenticate' -c red)`n")
            break;
        }
        # !unsure if auth logic will make it here because auth throws if not 200 statis code
        # if $global:_glvigor.auth.httpstatus is not 200 write error to console then break
        elseif ($global:_glvigor.auth.httpstatus -eq 404) {
            [console]::write("$($global:_glvigor.logsub) $(csole -s 'error: unable to establish a connection' -c red)`n")
            break;
        }
        # if auth is successfull and returns a payload with required fields write success to console and continue
        else {
            $Athenticated_message = $($global:_glvigor.log)
            $Athenticated_message = $Athenticated_message + "$(csole -s " authenticated in as 👤 $($global:_glvigor.auth.user)" -c green)"
            $Athenticated_message = $Athenticated_message + " 🌐-$(csole -s $global:_glvigor.auth.apipath -c Cyan)"
            [console]::write("$Athenticated_message`n")
        }
        #-----------
        # if ($Data -and !$projectid) { $projectid = $data.id}
        try {
            $_gitlab_apikey = $global:_glvigor.auth.apikey | undo-securestring
            #! Note Headers can use a simple hash table or a PSObject as value 
            # !     it does need a System.Collections.Generic.Dictionary[[String],[String]]
            # ?     Unsure what the down sides are to this, will continue to use Generics
            $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $headers.Add("Authorization", "Bearer $_gitlab_apikey")
            $headers.Add("Content-Type", "application/json")

            [console]::write("$($global:_glvigor.logsub) generating request...`n")

            # returns single Issue for that project from -param ProjectID and -param IssueID
            if ($ProjectID -and $IssueID -and !$data -and !$Milestone) {
                $inputsource = csole -s '[param]' -c gray -bg darkcyan
                $log_request_path = $(csole -s "$($global:_glvigor.auth.apipath)/projects/$projectid/issues/$issueid")
                [console]::write("$($global:_glvigor.logsub) fetching issue id: $(csole -s "$IssueID" -c magenta) for project: $(csole -s "$ProjectID" -c magenta)`n")
                [console]::write("$($global:_glvigor.log) $($global:_glvigor.logcmds.api_get)::$inputsource::$log_request_path `n")
                $request_issue = Invoke-RestMethod -uri "$($global:_glvigor.auth.apipath)/projects/$projectid/issues/$issueid" `
                    -Headers $headers `
                    -Method 'GET'
            }
            # returns all Issues for that project from -param ProjectID
            elseif (!$issueid -and $projectid -and !$data -and !$Milestone) {
                $inputsource = csole -s '[param]' -c gray -bg darkcyan
                $log_request_path = $(csole -s "$($global:_glvigor.auth.apipath)/projects/$projectid/issues?$issue_state$labels")
                [console]::write("$($global:_glvigor.logsub) fetching issues for project: $(csole -s "$projectid" -c magenta)`n")
                [console]::write("$($global:_glvigor.logsub) $($global:_glvigor.logcmds.api_get)::$inputsource::$log_request_path `n")
                $request_issue = Invoke-RestMethod -uri "$($global:_glvigor.auth.apipath)/projects/$projectid/issues?$issue_state$labels" `
                    -Headers $headers `
                    -Method 'GET'
            }
            # return single Issue for that project of id specified from piped-object
            # ? can be pipped from Request-Project
            elseif (!$projectid -and $issueid -and $data -and !$Milestone) {
                $inputsource = csole -s '[pipe]' -c gray -bg darkyellow
                $log_request_path = csole -s "$($global:_glvigor.auth.apipath)/projects/$($data.id)/issues/$issueid"
                [console]::write("$($global:_glvigor.logsub) extracting project id from piped-object`n")
                [console]::write("$($global:_glvigor.logsub) fetching issue id: $(csole -s "$IssueID" -c magenta) for project: $(csole -s "$ProjectID" -c magenta)`n")
                [console]::write("$($global:_glvigor.logsub) $($global:_glvigor.logcmds.api_get)::$inputsource::$log_request_path `n")
                $request_issue = Invoke-RestMethod -uri "$($global:_glvigor.auth.apipath)/projects/$($data.id)/issues/$issueid" `
                    -Headers $headers `
                    -Method 'GET'
            }
            # return all Issues for that project and Milestone specified from piped-data
            elseif (!$projectid -and !$issueid -and $data -and $Milestone) {
                $inputsource = csole -s '[pipe]' -c gray -bg darkyellow
                $log_request_path = csole -s "$($global:_glvigor.auth.apipath)/projects/$($data.id)/issues?milestone=$Milestone$issue_state$labels"
                [console]::write("$($global:_glvigor.logsub) extracting project id from piped-object`n")
                [console]::write("$($global:_glvigor.logsub) fetching issues milestone: $(csole -s "$Milestone" -c magenta) for project: $(csole -s "$($data.id)" -c magenta)`n")
                [console]::write("$($global:_glvigor.logsub) $($global:_glvigor.logcmds.api_get)::$inputsource::$log_request_path `n")
                $request_issue = Invoke-RestMethod -uri "$($global:_glvigor.auth.apipath)/projects/$($data.id)/issues?milestone=$Milestone$issue_state$labels" `
                    -Headers $headers `
                    -Method 'GET'
            }
            # retrieve all Issues for that project and Milestone specified
            elseif ($projectid -and !$issueid -and !$data -and $Milestone) {
                $inputsource = csole -s '[param]' -c gray -bg darkyellow
                $log_request_path = csole -s "$($global:_glvigor.auth.apipath)/projects/$($projectid)/issues?milestone=$Milestone$issue_state$labels"
                [console]::write("$($global:_glvigor.logsub) extracting project id from piped-object`n")
                [console]::write("$($global:_glvigor.logsub) fetching issue id: $(csole -s "$IssueID" -c magenta) for project: $(csole -s "$projectid" -c magenta)`n")
                [console]::write("$($global:_glvigor.logsub) $($global:_glvigor.logcmds.api_get)::$inputsource::$log_request_path `n")
                $request_issue = Invoke-RestMethod -uri "$($global:_glvigor.auth.apipath)/projects/$($projectid)/issues?milestone=$Milestone$issue_state$labels" `
                    -Headers $headers `
                    -Method 'GET'
            }
            # retrieve all Issues for that project from piped-data, returns all Issues for that project
            elseif (!$projectid -and !$issueid -and $data -and !$Milestone) {
                $inputsource = csole -s '[pipe]' -c gray -bg darkyellow
                $log_request_path = csole -s "$($global:_glvigor.auth.apipath)/projects/$($data.id)/issues$issue_state$labels"
                [console]::write("$($global:_glvigor.logsub) extracting project id from piped-object`n")
                [console]::write("$($global:_glvigor.logsub) fetching issues for project: $(csole -s "$($data.id)" -c magenta)`n")
                [console]::write("$($global:_glvigor.logsub) $($global:_glvigor.logcmds.api_get)::$inputsource::$log_request_path `n")
                $request_issue = Invoke-RestMethod -uri "$($global:_glvigor.auth.apipath)/projects/$($data.id)/issues?$issue_state$labels" `
                    -Headers $headers `
                    -Method 'GET'
            }
            else {
                [console]::write("$($global:_glvigor.log) error: $(csole -s 'invalid parameters' -c red)`n")
            }

            [console]::writeline("$($global:_glvigor.logsub) $(csole -s 'parsing object...' -c green)`n")
            if ($request_issue.count -eq 0) {
                return [PSCustomObject]@{
                    Message = "$(csole -s "no issues found for project" -c red)"
                }
            }
            else {
                if (!$raw) {
                    #TODO: use cofoge to manipulate psobject and colorconsone or colorizer to format and color
                    return $request_issue | select-object iid, title, state, labels, web_url
                }
                else {
                    return $request_issue
                }
            }
        }
        catch [System.Exception] {
            [console]::write("$($global:_glvigor.logSub)$(csole -s ■ -c red)-error $(csole -s $_.Exception.Message -c red)`n")
        }
    }
}


$cmdletconfig = @{
    function = @("Request-Issue")
    alias    = @("glvrqi")
}

Export-Modulemember @cmdletconfig