$ModuleManifestName = 'TeamsFunctions.psd1'
$ModuleManifestPath = "\\CONGLOMERATOR\Software\Code\Personal\TeamsFunctions\$ModuleManifestName"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}

