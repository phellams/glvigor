<#
.SYNOPSIS
Sets the local mirror configuration for a repository, supporting both parameters and environment variables.

.DESCRIPTION
This cmdlet sets the local mirror configuration for a repository. It allows configuration via parameters or environment variables.

.PARAMETER Name
The name of the mirror. The default value is 'mirror'.

.PARAMETER Endpoint
The destination instance. Supported values are: `gitlab`, `gitlaben`, `gitea`, `github`. For self-hosted instances, use the `-GiteaHost` and `-GitLabHost` parameters together with the respective endpoint.

.PARAMETER User
The username or group name of the project to mirror.

.PARAMETER APIKey
The API key for the destination instance.

.PARAMETER GiteaHost
The URL of the Gitea instance, e.g., `host.domain`, excluding the protocol.

.PARAMETER GitLabHost
The URL of the GitLab instance, e.g., `host.domain`, excluding the protocol.

.OUTPUTS
None. This cmdlet does not produce any output.

.EXAMPLE
Set-LocalMirrorConfig -Name 'mirror' -Endpoint 'gitlab' -User 'user'

.Configures the local mirror with the name 'mirror', setting 'gitlab' as the destination endpoint and 'user' as the user.

.EXAMPLE
Set-LocalMirrorConfig -Name 'mirror' -Endpoint 'gitlab' -User 'user' -APIKey 'key'

.Configures the local mirror with the name 'mirror', setting 'gitlab' as the destination endpoint, 'user' as the user, and 'key' as the API key.

.LINK

.NOTES
does Not request authentication, but requires git
#>

using module ..\..\colorconsole\libs\cmdlets\New-ColorConsole.psm1

Function Add-LocalMirror {
    [cmdletbinding()]
    [outputtype([void])]
    [Alias('glvalm')]
    param(
        [Parameter(Mandatory = $true)]
        [validateset('github', 'gitlab', 'gitea', 'gitlaben', IgnoreCase = $true)]
        [string]$Endpoint,
        [Parameter(Mandatory = $true)]
        [string]$User,
        [Parameter(Mandatory = $false)]
        [string]$apikey,
        [Parameter(Mandatory = $false)]
        [string]$GiteaHost,
        [Parameter(Mandatory = $false)]
        [string]$GitLabHost,
        [Parameter(Mandatory = $false)]
        [string]$Name
    )
    process {

        try {

            $RepoName = (Get-ItemProperty -Path .\ | select-Object baseName).basename

            [console]::write("$($global:_glvigor.log) starting local mirror configuration for $(csole -s $RepoName -c yellow) `n")

            [console]::write("$($global:_glvigor.logSub) setting: $(csole -s $endpoint -c cyan) as endpoint`n")

            # set default mirror name
            if(!$Name){$name = 'mirror'}else {$name = $Name}

            switch ($Endpoint) {
                "gitlab" {
                    # Predefined
                    $MirrorHost_url = "gitlab.com" 
                } 
                "gitlaben" {
                    # requires -GitLabHost which can be bypassed by using $ENV:GITLAB_HOST
                    if ($GitLabHost) {
                        $MirrorHost_url = $GitLabHost
                    }
                    else {
                        throw 'Gitlab host not set, set with -GitLabHost or $ENV:GITLAB_HOST'
                        break;
                    }
                } 
                "github" {
                    # Predefined
                    $MirrorHost_url = "github.com" 
                }
                "gitea" {
                    if ($GiteaHost) {
                        $MirrorHost_url = $GiteaHost
                    }
                    else {
                        throw 'gitea host not set, set with -GiteaHost or $ENV:GITEA_HOST'
                        break;
                    }
                }
                default { 
                    Throw "no mirror host set for $Endpoint"
                    break;
                }
            }

            if (!$User) {
                if ($null -eq $ENV:GlV_MIRROR_USER -or $ENV:GlV_MIRROR_USER -eq "") {
                    throw 'gitlab user not set, set with $ENV:GlV_MIRROR_USER or -MirrorUser'
                }
                else {
                    $User = $ENV:GlV_MIRROR_USER
                }
            }
            else {

            }
            if (!$APIKey) {
                if ($null -eq $ENV:GLV_MIRROR_APIKEY -or $ENV:GLV_MIRROR_APIKEY -eq "") {
                    throw 'mirror api key not set, set with $ENV:GLV_MIRROR_APIKEY or -APIKey'
                }
                else {
                    $APIKey = $ENV:GLV_MIRROR_APIKEY
                }
            }
        }catch [System.Exception] {
            [console]::write("$($global:_glvigor.logsub)$(csole -s ■ -c red)-error $(csole -s $_.Exception.Message -c red)`n")
        }

        if (Get-Command -Name git) {
            try {

                $repo_string = "https://$user`:$apikey@$MirrorHost_url/$user/$RepoName.git"
                $repo_string_safe = $repo_string.replace($apikey, "*******************")
                [console]::write("$($global:_glvigor.logSub) generating endpoint string: $(csole -s $endpoint -c cyan) -  $(csole -s $repo_string_safe -c cyan)`n")

                $non_origin = Get-localRemoteConfig | Where-Object { $_.Name -ne 'origin' }
                if ($non_origin.Name -contains $name) {
                    throw "mirror '$name' already exists for $RepoName"
                }else{
                    [console]::write($("$($global:_glvigor.logSub)$($global:_glvigor.logcmds.git_config)::($(csole -s "git remote add mirror" -c white))::$repo_string`n"))
                    git remote add $name $repo_string
                    [console]::write($("$($global:_glvigor.logSub)$($global:_glvigor.logcmds.git_config)::($(csole -s "git remote set-url --push mirror" -c white))::$repo_string`n"))
                    git remote set-url --push $name $repo_string
                    [console]::write("$($global:_glvigor.logSub) git remote add mirror complete`n")
                }
            }
            catch {
                [console]::write("$($global:_glvigor.logsub)$(csole -s ■ -c red)-error $(csole -s $_.Exception.Message -c red)`n")
            }
        }
    }
}

$cmdletconfig = @{
    function = @('Add-LocalMirror')
    alias = @('glvalm')
}

Export-modulemember @cmdletconfig