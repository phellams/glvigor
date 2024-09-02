
using module ..\..\securestring\undo-securestring.psm1
using module ..\..\colorconsole\libs\cmdlets\New-ColorConsole.psm1
using module .\private\Confirm-GitlabAuth.psm1
 
<#
.SYNOPSIS
Sends a request to the GitLab API to create and issue for a project.

.DESCRIPTION 
Sends a request to the GitLab API to create and issue for a project.

.PARAMETER ProjectID [int]
The ID of the project for which to create the issue.

.PARAMETER ParentIssueID [int]
The ID of the project for which to set the parent issue.

.PARAMETER Description [string]
The description of the issue.

.PARAMETER Title [string]
The title of the issue.

.PARAMETER Type [string]
The type of the issue.

.PARAMETER MilestoneID [int]
The ID of the milestone you would like to assign the issue to.

.PARAMETER AssigneeIDs [int[]]
The Ids of the users you would like to assign the issue to, not for gitlab.com or not CE or EE you require a premium account to use this.
see https://docs.gitlab.com/ee/user/project/issue_assignees.html

.PARAMETER AssigneeID [int]
The Id of the user you would like to assign the issue to.

.PARAMETER labels [string[]]
The labels you would like to assign to the issue.

.PARAMETER Confidential [switch]
Makes the issue confidential.

.PARAMETER DiscussioniD [int]
The discussionID you would like to set for the issue, 

.PARAMETER Raw
if set, returns the raw object instead of the parsed object.

.EXAMPLE
Register-Issue -ProjectID 67 -Title 'my title' -Description 'my description' -Type 'issue' -AssigneeID 56

.EXAMPLE
Register-Issue -ProjectID 67 -Title 'My Issue title'


.NOTES
Requires authentication via `Request-GitLabAuth`.
#>

function Register-Issue {

    [CmdletBinding()]
    [Alias('glvri')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [pscustomobject]$Data,
        [Parameter(Mandatory = $false)]
        [int]$ProjectID,
        [Parameter(Mandatory = $false)]
        [string]$Description,
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [Parameter(Mandatory = $false)]
        [validateset('issue', 'incident', 'task', IgnoreCase = $true)]
        [string]$Type,
        [Parameter(Mandatory = $false)]
        [int]$MilestoneID,
        [Parameter(Mandatory = $false)]
        [string[]]$AssigneeIDs,
        [Parameter(Mandatory = $false)]
        [string]$AssigneeID,
        [Parameter(Mandatory = $false)]
        [string]$labels,
        [Parameter(Mandatory = $false)]
        [switch]$Confidential = $false,
        [Parameter(Mandatory = $false)]
        [int]$DiscussionID
    )

    process {

        confirm-gitlabauth
        
        if ($Data -and !$projectid) { $projectid = $data.id}

        if(!$ProjectID -and !$Data){
            [console]::write("$($global:_glvigor.log) $(csole -s '🐇-glv response: missing project id' -c red)`n")
            [console]::write("$($global:_glvigor.logsub) $(csole -s 'specify by -projectid or -data @{} or from search-gitlab pipeline' -c yellow)")
            break;
        }

        # Set default type to issue ommit -type if creating a issue not a incident or task
        if(!$type){$Type = 'issue'}

        [console]::write("$($global:_glvigor.log) gitlab issue new request to project $(csole -s $ProjectID -c magenta) type $(csole -s $Type -c magenta)`n")
        
        # api payload required fields
        [console]::write("$($global:_glvigor.logSub) initializing post data payload`n")
        # New issue require param specified in the url https://docs.gitlab.com/ee/api/issues.html
        [string]$_payload = ''
        $payload += "&title=$([System.Web.HttpUtility]::UrlEncode($Title))"
        if($Description){
            [console]::write("$($global:_glvigor.logSub) adding «$(csole -s prop -c white -bg blue)»─•description: $(csole -s $Description -c gray)`n")
            $_payload += "&description=$([System.Web.HttpUtility]::UrlEncode($Description))"
        }
        if($MilestoneID){
            [console]::write("$($global:_glvigor.logSub) adding «$(csole -s prop -c white -bg blue)»─•milestone: $(csole -s $MilestoneID -c gray)`n")
            $_payload += "&milestone_id=$MilestoneID"
        }
        if($AssigneeID){
            [console]::write("$($global:_glvigor.logSub) adding «$(csole -s prop -c white -bg blue)»─•assignee: $(csole -s $AssigneeID -c gray)`n")
            $_payload += "&assignee_id=$AssigneeID"
        }
        if($labels){
            [console]::write("$($global:_glvigor.logSub) adding «$(csole -s prop -c white -bg blue)»─•labels: $(csole -s $labels -c gray)`n")
            $_payload += "&labels=$([System.Web.HttpUtility]::UrlEncode($labels))"
        }
        # if($Type){
        #     [console]::write("$($global:_glvigor.logSub) adding «$(csole -s prop -c white -bg blue)»─•type: $(csole -s $Type -c gray)`n")
        #     $_payload += "&type=$([System.Web.HttpUtility]::UrlEncode($Type))"
        # }
        if($Confidential){
            [console]::write("$($global:_glvigor.logSub) adding «$(csole -s prop -c white -bg blue)»─•confidential: $(csole -s $Confidential -c gray)`n")
            $_payload += "&confidential=$Confidential"
        }
        if($DiscussionID){
            [console]::write("$($global:_glvigor.logSub) adding «$(csole -s prop -c white -bg blue)»─•discussion_to_resolve: $(csole -s $DiscussioniD -c gray)`n")
            $_payload += "&discussion_to_resolve=$DiscussionID"
        }

        #-----------
        try {
            [console]::write("$($global:_glvigor.log) sending new payload to project $(csole -s $ProjectID -c magenta) issues`n")
            # undo securestring
            $_gitlab_apikey = $global:_glvigor.auth.apikey | undo-securestring
            $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $headers.Add("Authorization", "Bearer $_gitlab_apikey")
            $headers.Add("Content-Type", "application/json")
            [console]::write("$($global:_glvigor.logsub)$($global:_glvigor.logcmds.api_post)::$($global:_glvigor.auth.apipath)/projects/$(csole -s $ProjectID -c magenta)/issues`n")
            # $issue_reqister = Invoke-RestMethod -Method Post `
            #                                     -Uri "$($global:_glvigor.auth.apipath)/projects/$($projectid)/issues?type=$($type)"
            #                                     -Headers $headers
            #[console]::write("$($global:_glvigor.logsub) successfully created new issue $(csole -s $($issue_reqister.id) -c magenta) for project $(csole -s $ProjectID -c magenta)`n")
            [console]::write("$($global:_glvigor.log) $(csole -s "parsing response..." -c green)`n")
        }
        catch [system.exception] {
            [console]::write("$($global:_glvigor.logsub) $(csole -s $_.Exception.Message -c red)`n")
        }
        return $issue_reqister
    }
}

$cmdletconfig = @{
    function = @("Register-Issue")
    alias    = @("glvri")
}

Export-ModuleMember @cmdletconfig