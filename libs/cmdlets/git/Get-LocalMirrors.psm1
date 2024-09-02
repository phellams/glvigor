<#
.SYNOPSIS
Calls Get-LocalRemoteConfig and parses git mirror and returns filtered pscustomobject

.DESCRIPTION
Calls Get-LocalRemoteConfig and parses git mirror and returns filtered pscustomobject

.EXAMPLE
Get-LocalMirror

.NOTES
#>

using module ..\..\colorconsole\libs\cmdlets\New-ColorConsole.psm1

function Get-LocalMirrors {
    [cmdletbinding()]
    [outputtype([pscustomobject])]
    [Alias('glvlm')]
    param()
    process {
        try{
            [console]::write("$($global:_glvigor.log) parsing repository mirror configurations`n")
            [console]::write("$($global:_glvigor.logsub)$($global:_glvigor.logcmds.git_config)::($(csole -s 'Get-LocalRemoteConfig' -c blue))`n")
            $LocalMirrors  = Get-LocalRemoteConfig | where-Object { $_.Name -NotLike 'origin*' }
            if ($LocalMirrors.count -eq 0){
                [console]::write("$($global:_glvigor.logSub)$(csole -s ■ -c cyan)-notification $(csole -s 'No mirrors found' -c red)`n")
                break;
            }
        }
        catch [System.Exception] {
            [console]::write("$($global:_glvigor.logSub)$(csole -s ■ -c red)-error $(csole -s $_.Exception.Message -c red)`n")
        }
        return $LocalMirrors
    }
}

$cmdletconfig = @{
    function  = @('Get-LocalMirrors')
    alias     = @('glvlm')
}

Export-Modulemember @cmdletconfig