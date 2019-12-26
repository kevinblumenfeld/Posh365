Get-ChildItem -Path "$PSScriptRoot/Public", "$PSScriptRoot/Private" -File -Recurse *.ps1 | ForEach-Object {
    . $_.FullName
}
