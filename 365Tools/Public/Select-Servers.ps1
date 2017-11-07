function Select-Servers {
    param ()
    Select-ADConnectServer
    Select-DomainController
    Select-ExchangeServer
    Select-TargetAddressSuffix
}
    