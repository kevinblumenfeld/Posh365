function Start-PostMigrationTasks {


    param (

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        $MailboxCSV,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter()]
        [switch]
        $AddressBookPolicy

    )
    end {

        Connect-Cloud -Tenant $Tenant -ExchangeOnline

        $UserChoice = Get-Decision -MailboxCSV $MailboxCSV

        if ($UserChoice) {
            if ($AddressBookPolicy) {
                $UserChoice | Sync-AddressBookPolicy
            }
        }
    }
}
