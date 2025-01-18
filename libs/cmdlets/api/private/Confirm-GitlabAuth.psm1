using module ..\..\..\colorconsole\libs\cmdlets\New-ColorConsole.psm1
# private cmdlet for auth check and confirmation
function confirm-gitlabauth {
    [cmdletbinding()]
    [OutputType('void')]
    param()
    process {
        [console]::write("$($global:_glvigor.logSubRun) => Checking Authentication Status Running •─($(csole -s 'Confirm-GitlabAuth' -c yellow))`n")
        #  if null write error to console then break
        # http _glvigor.auth.httpstatus will not be set if not authenticated see Request-GitLabAuth
        if($null -eq $global:_glvigor.auth.httpstatus) {
            [console]::write("$($global:_glvigor.logsub) Error => $(csole -s 'Not Authenticated, use request-gitlabauth to authenticate' -c red)`n")
            break;
        }
        # !unsure if auth logic will make it here because auth throws if not 200 statis code
        # if $global:_glvigor.auth.httpstatus is not 200 write error to console then break
        elseif($global:_glvigor.auth.httpstatus -eq 404) {
            [console]::write("$($global:_glvigor.logSub) Error => $(csole -s "Unable to establish a connection to:$($global:_glvigor.auth) " -c red)`n")
            break;
        }
        # if auth is successfull and returns a payload with required fields write success to console and continue
        else{
            [console]::write("$($global:_glvigor.logSub) Impersonate $(csole -s "user •─$($global:_glvigor.auth.id)-<👤>-$($global:_glvigor.auth.user)" -c green)`n")
        }
    }
}

$cmdletconfig = @{ 
    function = @('confirm-gitlabauth') 
}

Export-ModuleMember @cmdletconfig