using module ..\..\..\colorconsole\libs\cmdlets\New-ColorConsole.psm1
# private cmdlet for auth check and confirm
function confirm-gitlabauth {
    [cmdletbinding()]
    [OutputType('void')]
    param()
    process {
        #  if null write error to console then break
        if ($null -eq $global:_glvigor.auth.httpstatus) {
            [console]::write("$($global:_glvigor.logsub)$(csole -s '■-error: not authenticated, use request-gitlabauth to authenticate' -c red)`n")
            break;
        }
        # !unsure if auth logic will make it here because auth throws if not 200 statis code
        # if $global:_glvigor.auth.httpstatus is not 200 write error to console then break
        elseif ($global:_glvigor.auth.httpstatus -eq 404) {
            [console]::write("$($global:_glvigor.logsub)$(csole -s '■-error: unable to establish a connection' -c red)`n")
            break;
        }
        # if auth is successfull and returns a payload with required fields write success to console and continue
        else {
            $Athenticated_message = $($global:_glvigor.log)
            $Athenticated_message = $Athenticated_message + "$(csole -s " authenticated as 👤 $($global:_glvigor.auth.user)" -c green)"
            $Athenticated_message = $Athenticated_message + " 🌐-$(csole -s $global:_glvigor.auth.apipath -c Cyan)"
            [console]::write("$Athenticated_message`n")
        }
    }
}

$cmdletconfig = @{ function = 'confirm-gitlabauth' }

Export-ModuleMember @cmdletconfig