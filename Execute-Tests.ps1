# Pester
Import-Module Pester

# Move to the folder with your module code and tests
$testsFolder = 'C:\PowerShell\Pester-Module\Podcast-NoAgenda'
Set-Location  $testsFolder

# Run the structure tests
Invoke-Pester "$testsFolder\Podcast-NoAgenda.Module.Tests.ps1"

# Add individual tests here