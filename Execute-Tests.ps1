# Module:   TeamsFunctions
# Function: Test
# Author:		David Eberhardt
# Updated:  11-OCT-2020

# Pester

[CmdletBinding(DefaultParameterSetName = "full")]
param (
  [Parameter(ParameterSetName = "full")]
  [switch]$full,

  [Parameter(ParameterSetName = "individual")]
  [switch]$private,

  [Parameter(ParameterSetName = "individual")]
  [switch]$public

)

begin {
  if (($PSBoundParameters.ContainsKey('private') -or $PSBoundParameters.ContainsKey('public')) -and -not $PSBoundParameters.ContainsKey('full')) {
    $all = $false
  }
  elseif ($PSBoundParameters.ContainsKey('full')) {
    $all = $true
  }
  elseif ($PSBoundParameters.Keys.Count -eq 0) {
    $all = $true
  }

  Import-Module Pester

}

process {
  if ($all) {
    # Run the structure tests
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) - Running Tests against MODULE (Integrity check)" -Verbose
    Invoke-Pester "$PSScriptRoot\TeamsFunctions.Tests.ps1"

  }

  if ($all -or $private) {
    # Run Functional Tests for Private functions
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) - Running Tests against PRIVATE Functions" -Verbose
    $PrivateTests = Get-ChildItem "$PSScriptRoot\Private\Tests" -Include "*.Tests.ps1" -Recurse #| Select-Object -First 1
    Invoke-Pester $PrivateTests.FullName

  }

  if ($all -or $public) {
    # Run Functional Tests for Public functions
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) - Running Tests against PUBLIC Functions" -Verbose
    $PublicTests = Get-ChildItem "$PSScriptRoot\Public\Tests" -Include "*.Tests.ps1" -Recurse #| Select-Object -First 1
    Invoke-Pester $PublicTests.FullName

  }

}

end {

}
