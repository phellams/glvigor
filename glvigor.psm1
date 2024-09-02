using module libs\colorconsole\libs\cmdlets\New-ColorConsole.psm1 #api
using module libs\cmdlets\api\Request-GitLabAuth.psm1 #api
using module libs\cmdlets\api\Search-GitLab.psm1 #api
using module libs\cmdlets\api\Request-MirrorConfig.psm1 #api
using module libs\cmdlets\api\Register-MirrorConfig.psm1 #api
using module libs\cmdlets\api\Unregister-MirrorConfig.psm1 #api
using module libs\cmdlets\api\Request-Project.psm1 #api
using module libs\cmdlets\api\Request-Issue.psm1 #api
# using module libs\cmdlets\api\Unregister-Issue.psm1 #api #todo create cmdlets
using module libs\cmdlets\api\Register-Issue.psm1 #api
using module libs\cmdlets\git\Get-LocalRemoteConfig.psm1 #git
using module libs\cmdlets\git\Add-LocalMirror.psm1 #git
using module libs\cmdlets\git\Remove-LocalMirror.psm1 #git
using module libs\cmdlets\git\Get-LocalMirrors.psm1 #git
using module libs\cmdlets\git\Set-GitOrigin.psm1 #git
using module libs\cmdlets\git\Get-GitOrigin.psm1 #git

#! NOTE to self - set api functions to request, register, and unregister
#! NOTE to self - set git functions to get, set, and remove
#? for consistancy

# using module libs\cmdlets\Send-GitLabMirrorConfig.psm1
# using module libs\cmdlets\Request-GitLabMirrorConfig.psm1
# using module libs\cmdlets\Search-Gitlab.psm1
# using module libs\cmdlets\Search-GitLabGroups.psm1
# using module libs\cmdlets\Request-GitLabAuth.psm1
# using module libs\cmdlets\Register-MirrorConfig.psm1
# using module cmdlets\Set-Localmirrorconfig.psm1

# GMM(GitMirrorManager) 
# I like GLVigor

# Enable utf8 encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# api::request mirror config

# request types 
# api::get
# api::post
# api::put/update
# api::delete
# git::command remote, fetch, push

# emojis
# 🚪🦜

# console logo glv
# log message
# log sub message
# log sub with no logo or log indentation
$glv_icon = "$(csole -s g -c white -bg darkcyan)$(csole -s l -c white -bg darkyellow)$(csole -s v -c white -bg darkblue)"
$glviger_n = csole -string "$(csole -s ■╦ -c blue)$glv_icon" -Color yellow
$glviger_s = csole -string " »" -Color green
$glvlt = $glviger_n + $glviger_s # GLViger LogTitle
$glvlt_sub = "$(" " * 1)$(csole -String '╚──────' -Color Green)"
$glvlt_sub_ni = "$(" " * 2)"

$global:_glvigor = @{
    rootpath    = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
    log         = $glvlt
    logSub      = $glvlt_sub
    logsubni    = $glvlt_sub_ni
    auth        = $null
    logcmds     = @{
        api_get     = "$(csole -s '•-' -c green)$(csole -s 'api' -c darkmagenta -bg darkcyan)$('::')$(csole -s 'get' -c green)";
        api_post    = "$(csole -s '•-' -c yellow)$(csole -s 'api' -c darkmagenta -bg darkyellow)$('::')$(csole -s 'post' -c yellow)";
        api_update  = "$(csole -s '•-' -c cyan)$(csole -s 'api' -c darkmagenta -bg yellow)$('::')$(csole -s 'update' -c cyan)";
        api_delete  = "$(csole -s '•-' -c red)$(csole -s 'api' -c darkmagenta -bg darkred)$('::')$(csole -s 'delete' -c red)";
        git_command = "$(csole -s '•-' -c blue)$(csole -s 'git' -c darkmagenta -bg blue)$('::')$(csole -s 'command' -c blue)";
        git_fetch   = "$(csole -s '•-' -c green)$(csole -s 'git' -c darkmagenta -bg green)$('::')$(csole -s 'fetch' -c green)";
        git_push    = "$(csole -s '•-' -c yellow)$(csole -s 'git' -c darkmagenta -bg yellow)$('::')$(csole -s 'push' -c yellow)";
        git_config  = "$(csole -s '•-' -c yellow)$(csole -s 'git' -c black -bg white)$('::')$(csole -s 'cmd' -c white)";
    
    }
}

$moduleconfig = @{
    function = @(
        'Request-GitLabAuth',
        'Search-GitLab',
        'Request-MirrorConfig',
        'Register-MirrorConfig',
        'Unregister-MirrorConfig',
        'Request-Project',
        'Request-Issue',
        'Register-Issue',
        'Get-LocalRemoteConfig',
        'Add-LocalMirror',
        'Remove-LocalMirror',
        'Get-LocalMirrors',
        'Set-GitOrigin',
        'Get-GitOrigin'
    )
    alias = @()
}

Export-ModuleMember @moduleconfig