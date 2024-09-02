using module ..\..\colorconsole\libs\cmdlets\New-ColorConsole.psm1
using module ..\..\securestring\undo-securestring.psm1
using module .\private\Confirm-GitLabAuth.psm1

function Search-Gitlab {
    [cmdletbinding()]
    [OutputType('pscustomobject')]
    [Alias('glvs')]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Title,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [validateSet('projects', 'issues', 'merge_requests', 'milestones', 'snippet_titles', 'users', 'blobs', 'commits', 'notes', 'groups', IgnoreCase = $true)]
        [string]$Type = 'projects',
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$Group,
        [Parameter(Mandatory = $false)]
        [switch]$Raw = $false,
        [Parameter(Mandatory = $false)]
        [string]$Related,
        [Parameter(Mandatory = $false)]
        [switch]$Match = $false
    )
    process{
        if(!$title){$title = ' '}
        #-----------
        # Outh block output to console 
        # can add to all cmdlet/api functions
        #-----------

        [console]::write("$($global:_glvigor.log) Initializing $(csole -s $type -c yellow) search`n")
        Confirm-GitlabAuth

        # Headers
        $apikey = $global:_glvigor.auth.apikey | undo-securestring
        $headers = New-Object "System.Collections.Generic.Dictionary[[string],[string]]"
        $headers.Add("Authorization", "Bearer $apikey")
        $headers.Add("Content-Type", "application/json")

        try {
            [console]::write("$($global:_glvigor.log) search $(csole -s 'Type:' -c green) $type - $(csole -s 'Name:' -c green) '$Title'`n")
            [console]::write("$($global:_glvigor.logsub)$($global:_glvigor.logcmds.api_get)::$(csole -s $global:_glvigor.auth.apipath -c cyan)/search?&scope=$(csole -s $Type -c magenta)&search=$(csole -s $Title -c magenta )`n")
            if(!$Title -and $type -ne 'groups'){
                $response = Invoke-RestMethod "$($global:_glvigor.auth.apipath)/search?&scope=$Type&search=" -Method 'GET' -Headers $headers
            }elseif($title -and $type -eq 'groups'){
                $response = Invoke-RestMethod "$($global:_glvigor.auth.apipath)/groups?/search?&search=" -Method 'GET' -Headers $headers
            }elseif($title -and !$Group ){
                $response = Invoke-RestMethod "$($global:_glvigor.auth.apipath)/search?&scope=$Type&search=$Title" -Method 'GET' -Headers $headers
            }
            else{
                $response = Invoke-RestMethod "$($global:_glvigor.auth.apipath)/groups?/search?&search=$Title" -Method 'GET' -Headers $headers
            }
            [console]::write("$($global:_glvigor.logsub) $(csole -s $response.count -c green) results found matching: $Title `n")
            if($response.count -eq 0){
                [console]::write("$($global:_glvigor.logsub) $(csole -s "no results found matching: $Title" -c red)`n")
            }
            [console]::write("$($global:_glvigor.logsub) parsing response...`n")
        }
        catch {
            [console]::write("$($global:_glvigor.logsub) error: $(csole -s $_.Exception.Message -c red)`n")
        }
        if($null -eq $response -or $response.count -eq 0){
            return [PSCustomObject]@{Response = '201'; Message = "$(csole -s "no results found matching: $Title" -c red)"; }
        }else{
            if(!$raw -and $response.count -gt 0){
                switch ($Type){
                    'projects' { 
                        if($match){
                            return $response | where-object { $_.name -eq $title -or $_.path_with_namespace -eq $title } 
                            | select-object id, name, path_with_namespace, http_url_to_repo
                        }else{
                            return $response | select-object id, name, path_with_namespace, http_url_to_repo
                        }
                    } #* Done
                    'issues' { return $response | where-object { $_.web_url -like "*$Related*" } | select-object id, project_id, title, web_url } #* done
                    'merge_requests' { return $response | where-object { $_.web_url -like "*$Related*" } |select-object project_id, title, web_url } #TODO: change properties to match api return
                    'milestones' { return $response | select-object project_id, title, web_url } #TODO: change properties to match api return
                    'users' { return $response | select-object id, name, web_url } #TODO: change properties to match api return
                    'groups' { return $response | select-object id, name, web_url } #TODO: change properties to match api return
                    default { throw [System.ArgumentOutOfRangeException]::new("Type", $type, "Type must be 'projects', 'issues', 'merge_requests', 'milestones', 'users' or 'groups") }
                }
            }
            return $response
        }

    }

}

$cmdletconfig = @{
    function = @("Search-Gitlab")
    alias    = @("glvs")
}

Export-Modulemember @cmdletconfig