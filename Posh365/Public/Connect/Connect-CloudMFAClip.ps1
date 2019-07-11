function Connect-CloudMFAClip {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory, Position = 0)]
        $CredFile
    )
    end {
        [System.Management.Automation.PSCredential]$Credential = Import-CliXml -Path $CredFile
        StackPanel {
            Button "Copy UserName" -on_click {
                "TEST" | CLIP
            } -Margin 10 -FontSize 40
            Button "Copy Password" -on_click {
                "TEST" | CLIP
                $window.Close()
            } -Margin 10 -FontSize 40
        } -Show
    }
}
