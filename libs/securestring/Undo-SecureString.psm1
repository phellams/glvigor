using namespace system.runtime.interopservices
<#
.SYNOPSIS
    Unfold a SecureString
.DESCRIPTION
    Unfold a SecureString
.EXAMPLE
    PS C:\> Unfold-SecureString -SecureString $securestring
#>
Function Undo-SecureString{
    [CmdletBinding()]
    [OutputType('string')]
    [Alias('uss')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [SecureString]$SecureString
    )
    process{
        $PointerUM = [Marshal]::SecureStringToBSTR($secureString)
        try {
            $plainText = [Marshal]::PtrToStringBSTR($PointerUM)
        }
        finally {
            # Free the unmanaged memory allocated for the string
            [Marshal]::ZeroFreeBSTR($PointerUM)
        }
        return $plainText
    }
}

$cmdletconfig = @{
    function = @('Undo-SecureString')
    alias = @('uss')
}

Export-ModuleMember @cmdletconfig