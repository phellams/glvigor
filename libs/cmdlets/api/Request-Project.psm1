using module ..\..\securestring\undo-securestring.psm1
using module ..\..\colorconsole\libs\cmdlets\New-ColorConsole.psm1
using module .\private\Confirm-GitLabAuth.psm1
 
<#
.SYNOPSIS
Sends a request to the GitLab API to retrieve a project.

.DESCRIPTION
Sends a request to the GitLab API to retrieve a project.

.PARAMETER ProjectID
The ID of the project for which to retrieve.

.EXAMPLE
Request-Project -ProjectID 1
Sends a request to retrieve the configuration for the mirror with ID 2 in the project with ID 1.

.NOTES
Requires authentication via `Request-GitLabAuth`.
#>

function Request-Project {

    [CmdletBinding()]
    [Alias('glvrp')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ProjectID
    )

    process {
        # call auth check
        confirm-GitLabAuth

        try{
            [console]::write("$($global:_glvigor.log) fetching project id: $(csole -s $projectid -c magenta)`n")
            [console]::write("$($global:_glvigor.logsub) Generating request...`n")
            [console]::write("$($global:_glvigor.logsub) $($global:_glvigor.logcmds.api_get)::$($global:_glvigor.auth.apipath)/projects/$ProjectID`n")
            $_gitlab_apikey = $global:_glvigor.auth.apikey | undo-securestring
            $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $headers.Add("Authorization", "Bearer $_gitlab_apikey")
            $headers.Add("Content-Type", "application/json")
            $request_project = Invoke-RestMethod -uri "$($global:_glvigor.auth.apipath)/projects/$ProjectID"
            [console]::write("$($global:_glvigor.logsub) $(csole -s "project fetched" -c green)`n")
        }catch [system.exception]{
            [console]::write("$($global:_glvigor.logsub) $(csole -s $_.Exception.Message -c red)`n")
        }
        return $request_project
    }
}
