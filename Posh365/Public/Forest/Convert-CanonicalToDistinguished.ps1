function Convert-CanonicalToDistinguished {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $CanonicalName
    )
    end {
        $nameTranslate = New-Object -ComObject NameTranslate
        # $nameTranslate.Init(3,  '')
        # To PS2:
        [__ComObject].InvokeMember('Init', 'InvokeMethod', $null, $nameTranslate, @(3, ''), $null, (Get-Culture), $null)
        # Get an identity using the canonicalName
        # $nameTranslate.Set(2, $canonicalName)
        # To PS2:
        [__ComObject].InvokeMember('Set', 'InvokeMethod', $null, $nameTranslate, @(2, $canonicalName), $null, (Get-Culture), $null)
        # Convert the identity to a DistinguishedName
        # $nameTranslate.Get(1)
        # To PS2:
        [__ComObject].InvokeMember('Get', 'InvokeMethod', $null, $nameTranslate, @(1), $null, (Get-Culture), $null)
    }
}
