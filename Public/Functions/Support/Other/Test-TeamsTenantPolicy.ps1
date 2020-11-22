# Module:   TeamsFunctions
# Function: Testing
# Author:		David Eberhardt
# Updated:  01-AUG-2020
# Status:   Unmanaged




function Test-TeamsTenantPolicy {
  <#
	.SYNOPSIS
		Tests whether a specific Policy exists in the Teams Tenant
	.DESCRIPTION
		Universal commandlet to test any Policy Object that can be granted to a User
	.PARAMETER Policy
		Mandatory. Name of the Policy Object - Which Policy? (PowerShell Noun of the Get/Grant Command).
	.PARAMETER PolicyName
		Mandatory. Name of the Policy to look up.
	.EXAMPLE
		Test-TeamsPolicy
		Will Return $TRUE only if a the policy was found in the Teams Tenant.
	.NOTES
    This is a crude but universal way of testing it, intended for check of multiple at a time.
    NOTE: Uses Invoke-Expression for the PolicyName provided to from Get-$($PolicyName)
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the Noun of Policy, i.e. 'TeamsUpgradePolicy' of 'Get-TeamsUpgradePolicy'")]
    [Alias("Noun")]
    [string]$Policy,

    [Parameter(Mandatory = $true, HelpMessage = "This is the Name of the Policy to test")]
    [string]$PolicyName
  ) #param

  begin {
    Show-FunctionStatus -Level Unmanaged
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    # Data Gathering
    try {
      $TestCommand = "Get-" + $Policy + " -ErrorAction Stop"
      Invoke-Expression "$TestCommand" -ErrorAction STOP | Out-Null
    }
    catch {
      Write-Warning -Message "Policy Noun '$Policy' is invalid. No such Policy found!"
      return
    }
    finally {
      $Error.clear()
    }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    try {
      $Command = "Get-" + $Policy + " -Identity " + $PolicyName + " -ErrorAction Stop"
      Invoke-Expression "$Command" -ErrorAction STOP | Out-Null
      Return $true
    }
    catch [System.Exception] {
      if ($_.FullyQualifiedErrorId -like "*MissingItem*") {
        Return $False
      }
      else {
        Write-ErrorRecord $_ #This handles the error message in human readable format.
        Return $False
      }
    }
    finally {
      $Error.clear()
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-TeamsTenantPolicy
