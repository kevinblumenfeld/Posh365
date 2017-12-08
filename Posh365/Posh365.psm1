#.ExternalHelp Posh365-help.xml
# Thank you to https://github.com/ramblingcookiemonster for this module and methodology
# Get public and private function definition files.
$Public = Get-ChildItem $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue
$Private = Get-ChildItem $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue

# Dot source the files
if ($Private) {
    Foreach ($import in @($Public + $Private)) {
        Try {
            . $import.fullname
        }
        Catch {
            Write-Error "Failed to import function $($import.fullname): $_"
        }
    }
}
else {
    Foreach ($import in $Public) {
        Try {
            . $import.fullname
        }
        Catch {
            Write-Error "Failed to import function $($import.fullname): $_"
        }
    }
}
