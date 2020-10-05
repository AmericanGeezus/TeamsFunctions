# Pester
Import-Module Pester

# here
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# Run the structure tests
Invoke-Pester "$here\TeamsFunctions.Tests.ps1"

# Add individual tests here
