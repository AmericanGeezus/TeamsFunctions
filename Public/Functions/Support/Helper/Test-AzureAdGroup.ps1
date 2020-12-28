# Module:   TeamsFunctions
# Function: Support
# Author:		David Eberhardt
# Updated:  14-NOV-2020
# Status:   PreLive




function Test-AzureAdGroup {
  <#
	.SYNOPSIS
		Tests whether an Group exists in Azure AD (record found)
	.DESCRIPTION
		Simple lookup - does the Group Object exist - to avoid TRY/CATCH statements for processing
	.PARAMETER Identity
		Mandatory. The Name or User Principal Name (MailNickName) of the Group to test.
	.EXAMPLE
		Test-AzureAdGroup -Identity "My Group"
		Will Return $TRUE only if the object "My Group" is found.
    Will Return $FALSE in any other case
  .LINK
    Find-AzureAdGroup
    Find-AzureAdUser
    Test-AzureAdGroup
    Test-AzureAdUser
    Test-TeamsUser
	#>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = "This is the Name or UserPrincipalName of the Group")]
    [string]$Identity
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    $CallTarget = $null
    $CallTarget = Get-AzureADGroup -SearchString "$Identity" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    $CallTarget = $CallTarget | Where-Object Displayname -EQ "$Id"
    if (-not $CallTarget ) {
      try {
        $CallTarget = Get-AzureADGroup -ObjectId "$Identity" -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        try {
          $MailNickName = $Identity.Split('@')[0]
          $CallTarget = Get-AzureADGroup -SearchString "$MailNickName" -WarningAction SilentlyContinue -ErrorAction STOP
        }
        catch {
          $CallTarget = Get-AzureADGroup | Where-Object Mail -EQ "$Identity" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        }
      }
    }

    if ($CallTarget) {
      return $true
    }
    else {
      return $false
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-AzureAdGroup
