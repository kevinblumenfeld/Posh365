function Export-GoogleAlias {
    <#
    .SYNOPSIS
    Google's GAM tool exports aliases
    This transforms that data and exports it into an importable format in the Microsoft world

    .DESCRIPTION
    Google's GAM tool exports aliases
    This transforms that data and exports it into an importable format in the Microsoft world

    .PARAMETER MailboxCsv
    Csv of mailboxes and aliases

    .PARAMETER MailboxCsvHeaderOfPrimary
    Defaults to header PrimaryEmail

    .PARAMETER DontImportCsv
    Csv with a list of addresses that you dont want to be imported

    .PARAMETER DontImportCsvHeader
    Defaults to header PrimaryEmail
    This is the "column" header that contains the list of addresses that you dont want to be imported
    Useful when you are importing aliases and you dont want a primary email address to be imported as a secondary

    .PARAMETER DontPrependsmtp
    by default each address is prepended with "smtp:" like so...
    smtp:user@contoso.com

    This switch causes output to be like so...
    user@contoso.com

    .EXAMPLE
    Export-GoogleAlias -MailboxCsv .\Sharedmbx.csv -DontImportCsv .\Sharedmbx.csv -DontPrependsmtp | Export-Csv .\Shared-Aliases.csv -nti -Encoding UTF8

    .NOTES
    General notes
    #>


    param (

        [Parameter(Mandatory)]
        [string] $MailboxCsv,

        [Parameter()]
        [string] $MailboxCsvHeaderOfPrimary = 'PrimaryEmail',

        [Parameter()]
        [string] $DontImportCsv,

        [Parameter()]
        [string] $DontImportCsvHeader = 'PrimaryEmail',

        [Parameter()]
        [switch] $DontPrependsmtp

    )

    $Alias = Import-Csv $MailboxCsv
    $Prop = ($Alias | Select-Object -first 1).psobject.properties.name.where{
        $_ -like 'emails.*.address' -or $_ -like 'aliases.*'
    }
    if (-not $DontPrependsmtp) {
        if ($DontImportCsv) {
            $DontImport = (Import-Csv $DontImportCsv).$DontImportCsvHeader
            foreach ($CurAlias in $Alias) {
                foreach ($CurProp in $Prop) {
                    if ($CurAlias.$CurProp -and -not ($DontImport -contains $CurAlias.$CurProp)) {
                        [PSCustomObject]@{
                            PrimarySmtpAddress = $CurAlias.$MailboxCsvHeaderOfPrimary
                            Alias              = 'smtp:{0}' -f $CurAlias.$CurProp
                        }
                    }
                }
            }
        }
        else {
            foreach ($CurAlias in $Alias) {
                foreach ($CurProp in $Prop) {
                    if ($CurAlias.$CurProp) {
                        [PSCustomObject]@{
                            PrimarySmtpAddress = $CurAlias.$MailboxCsvHeaderOfPrimary
                            Alias              = 'smtp:{0}' -f $CurAlias.$CurProp
                        }
                    }
                }
            }
        }
    }
    else {
        if ($DontImportCsv) {
            $DontImport = (Import-Csv $DontImportCsv).$DontImportCsvHeader
            foreach ($CurAlias in $Alias) {
                foreach ($CurProp in $Prop) {
                    if ($CurAlias.$CurProp -and -not ($DontImport -contains $CurAlias.$CurProp)) {
                        [PSCustomObject]@{
                            PrimarySmtpAddress = $CurAlias.$MailboxCsvHeaderOfPrimary
                            Alias              = $CurAlias.$CurProp
                        }
                    }
                }
            }
        }
        else {
            foreach ($CurAlias in $Alias) {
                foreach ($CurProp in $Prop) {
                    if ($CurAlias.$CurProp) {
                        [PSCustomObject]@{
                            PrimarySmtpAddress = $CurAlias.$MailboxCsvHeaderOfPrimary
                            Alias              = $CurAlias.$CurProp
                        }
                    }
                }
            }
        }
    }
}
