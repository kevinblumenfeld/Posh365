function Import-MailboxCsvDecision {

    [CmdletBinding(DefaultParameterSetName = 'PlaceHolder')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'MailboxCsv')]
        [ValidateNotNullOrEmpty()]
        [string]
        $MailboxCsv,

        [Parameter(Mandatory, ParameterSetName = 'Object')]
        [ValidateNotNullOrEmpty()]
        $Object,

        [Parameter()]
        [switch]
        $NoBatch
    )

    if ($MailboxCSV){
        $DecisionObject = Import-Csv -Path $MailboxCSV
    }
    else {
        $DecisionObject = $Object
    }
    $UserChoiceSplat = @{
        DecisionObject = $DecisionObject
        NoBatch        = $NoBatch
    }

    $UserChoice = Get-UserDecision @UserChoiceSplat
    $UserChoice
}
