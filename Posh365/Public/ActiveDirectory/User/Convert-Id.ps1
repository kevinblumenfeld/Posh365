function Convert-Id {
    <#
    .SYNOPSIS
    Convert ImmutableID to ObjectGuid OR ObjectGuid to ImmutableID

    .DESCRIPTION
    Convert ImmutableID to ObjectGuid OR ObjectGuid to ImmutableID

    .PARAMETER Id
    Enter an ImmutableID or ObjectGuid

    .EXAMPLE
    Convert-Id -Id 3MK05obeZEm9/xvs8svAFw==

    .EXAMPLE
    Convert-Id -Id e6b4csdc-des6-4d34-bdfe-9adff2cbc017

    .NOTES
    General notes
    #>

    param (
        [Parameter()]
        $Id
    )

    end {
        try {
            $Guid = [GUID]$Id
            $Byte = $Guid.ToByteArray()
            [PSCustomObject]@{
                Object = [system.convert]::ToBase64String($Byte)
                Type   = 'immutableID'
            }
        }
        catch {
            if ($Decoded = [system.convert]::frombase64string($Id)) {
                if ($Guid = [GUID]$Decoded) {
                    [PSCustomObject]@{
                        Object = $Guid.ToString()
                        Type   = 'ObjectGuid'
                    }
                }
                else {
                    Write-Warning "Not an ObjectGuid or ImmutableID"
                }
            }
            else {
                Write-Warning "Not an ObjectGuid or ImmutableID"
            }
        }
    }
}
