
swop 1

$Manifest = Test-ModuleManifest Teamsfunctions.psd1
$ManifestFunctions = $Manifest.ExportedFunctions | Select-Object Keys -ExpandProperty Keys
$ManifestAliases = $Manifest.ExportedAliases | Select-Object Keys -ExpandProperty Keys
$Functions = Get-ChildItem -Include *.ps1 -Path Public\Functions -Recurse | Select-Object BaseName -ExpandProperty BaseName

$Module = Get-Command -Module Teamsfunctions
$ExportedFunctions = $Module | Where-Object CommandType -EQ "Function" | Select-Object Name -ExpandProperty Name
$ExportedAlias = (Get-Alias | Where-Object Source -EQ TeamsFunctions).Name

#TODO Integrate into Module Tests

# Comparing Aliases to Manifest
$CompareAliasToManifest = Compare-Object $ExportedAlias $ManifestAliases
$CompareAliasToManifest
$CompareAliasToManifest.Count

# Comparing Functions to Manifest
$CompareFunctionsToManifest = Compare-Object $Functions $ManifestFunctions
$CompareFunctionsToManifest
$CompareFunctionsToManifest.Count

# Comparing Functions to Exported Module
$CompareFunctionsToExport = Compare-Object $Functions $ExportedFunctions
$CompareFunctionsToExport
$CompareFunctionsToExport.Count

# Comparing Exported Functions to Manifest
$CompareExportToManifest = Compare-Object $ExportedFunctions $ManifestFunctions
$CompareExportToManifest
$CompareExportToManifest.Count