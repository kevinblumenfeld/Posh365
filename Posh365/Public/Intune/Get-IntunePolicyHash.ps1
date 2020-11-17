function Get-IntunePolicyHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Policy
    )

    $PropertyHash = @{ }

    foreach ($Item in $Policy.psobject.properties) {
        if ($Item.Name -eq 'CustomSettings') {
            foreach ($Custom in $Item.value) {
                $PropertyHash[$Custom.Name] = @($Custom.value) -ne '' -join '|'
            }
        }
        elseif ($Item.Name -eq 'Settings') {
            foreach ($Custom in $Item.value) {
                $PropertyHash[$Custom.AppConfigKey] = @($Custom.appConfigKeyValue) -ne '' -join '|'
            }
        }
        elseif ($Item.Name -eq 'Assignments') {
            $GroupNameList = [System.Collections.Generic.List[string]]::New()
            foreach ($Group in $Item.Value.Target) {
                try {
                    $GroupName = Get-AADGroup -groupId $Group.groupId | Select-Object -ExpandProperty displayName
                    $GroupNameList.Add($GroupName)
                }
                catch { }
            }
        }
        elseif ($Item.Name -eq 'apps') {
            $PropertyHash['Apps'] = @($Item.value.id) -ne '' -join "`r`n"
        }
        else {
            $PropertyHash[$Item.Name] = @($Item.value) -ne '' -join '|'
        }
    }

    if ($GroupNameList) {
        $PropertyHash['Assignments'] = @($GroupNameList) -ne '' -join "`r`n"
    }

    $PropertyHash
}