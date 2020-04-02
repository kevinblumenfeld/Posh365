function Switch-AzureADModule {
    param (
        [Parameter()]
        [switch]
        $Preview
    )

    Get-Module 'AzureAD', 'AzureADPreview' -list | ForEach-Object { Remove-Item -Path $_.Path -Force }

    if ($Preview) {
        Install-Module -Name AzureADPreview -Scope CurrentUser -RequiredVersion 2.0.2.85 -AllowPrerelease -Force
        Import-Module -Name AzureADPreview -Force
    }
    else {
        Install-Module -Name AzureAD -Scope CurrentUser -Force
        Import-Module -Name AzureAD -Force
    }
}