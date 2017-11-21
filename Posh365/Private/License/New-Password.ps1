filter New-Password {
    <#
    .SYNOPSIS
        Generate a random password.
    .DESCRIPTION
        Generate a random password.
    .NOTES
        Change log:
            17/03/2017 - Chris Dent - Created.
    #>

    [CmdletBinding()]
    [OutputType([String])]
    param (
        # The length of the password which should be created.
        [Parameter(ValueFromPipeline = $true)]        
        [ValidateRange(8, 255)]
        [Int32]$Length = 10,

        # The character sets the password may contain. A password will contain at least one of each of the characters.
        [String[]]$CharacterSet = ('abcdefghijklmnopqrstuvwxyz',
                                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                                   '0123456789',
                                   '!$%&^.#;'),

        [Int32[]]$CharacterSetCount = (@(1) * $CharacterSet.Count)
    )

    try {
        if ($CharacterSet.Count -ne $CharacterSetCount.Count) {
            throw "The number of items in -CharacterSet needs to match the number of items in -CharacterSetCount"
        }

        $requiredCharLength = ($CharacterSetCount | Measure-Object -Sum).Sum

        if ($requiredCharLength -gt $Length) {
            throw "The sum of characters specified by CharacterSetCount is higher than the desired password length"
        }

        $password = ''

        for ($i = 0; $i -lt $CharacterSet.Count; $i++) {
            for ($j = 0; $j -lt $CharacterSetCount[$i]; $j++) {
                $password += $CharacterSet[$i][(Get-Random -Minimum 0 -Maximum $CharacterSet[$i].Length)]
            }
        }

        $allCharacterSets = $CharacterSet -join ''
        for ($i = $password.Length; $i -lt $Length; $i++) {
            $password += $allCharacterSets[(Get-Random -Minimum 0 -Maximum $allCharacterSets.Length)]
        }

        [String]::Concat(([Char[]]$password | Sort-Object { Get-Random }))
    } catch {
        Write-Error -ErrorRecord $_
    }
}