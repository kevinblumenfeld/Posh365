function Switch-AzureADModule {
    param (
        [Parameter()]
        [switch]
        $Preview
    )
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Get-Module 'AzureAD', 'AzureADPreview' -list | ForEach-Object { Remove-Item -Path $_.Path -Force }

    if ($Preview) {
        Install-Module -Name AzureADPreview -Scope CurrentUser -AllowPrerelease -Force
    }
    else {
        Install-Module -Name AzureAD -Scope CurrentUser -Force
    }
}