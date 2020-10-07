# Module:   TeamsFunctions
# Function: Support
# Author:		David Eberhardtt
# Updated:  01-JUL-2020
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
		Test-AzureAdGroup -Identity $UPN
		Will Return $TRUE only if the object $UPN is found.
    Will Return $FALSE in any other case, including if there is no Connection to AzureAD!
  .LINK
    Resolve-AzureAdGroupObjectFromName
	#>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, HelpMessage = "This is the Name or UserPrincipalName of the Group")]
    [string]$Identity
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    try {
      $Group2 = Get-AzureADGroup -SearchString "$Identity" -WarningAction SilentlyContinue -ErrorAction STOP
      if ($null -ne $Group2) {
        return $true
      }
      else {
        try {
          $MailNickName = $Identity.Split('@')[0]
          $null = Get-AzureADGroup -SearchString "$MailNickName" -WarningAction SilentlyContinue -ErrorAction STOP
          Write-Verbose "Test-AzureAdGroup found the group with its 'MailNickName'"
          return $true
        }
        catch {
          return $false
        }
      }
    }
    catch {
      try {
        $null = Get-AzureADGroup -ObjectId $Identity -WarningAction SilentlyContinue -ErrorAction STOP
        return $true
      }
      catch {
        return $false
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Test-AzureAdGroup
