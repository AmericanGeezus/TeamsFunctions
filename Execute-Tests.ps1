# Pester
Import-Module Pester

# Move to the folder with your module code and tests
$testsFolder = 'C:\Code\Private\TeamsFunctions'
Set-Location  $testsFolder

# Run the structure tests
Invoke-Pester "$testsFolder\TeamsFunctions.Tests.ps1"

# Add individual tests here
