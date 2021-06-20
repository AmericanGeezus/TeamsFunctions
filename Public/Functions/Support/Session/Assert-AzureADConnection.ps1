# Module:     TeamsFunctions
# Function:   Session
# Author:    David Eberhardt
# Updated:    01-OCT-2020
# Status:     Live




function Assert-AzureADConnection {
  <#
  .SYNOPSIS
    Asserts an established Connection to AzureAD
  .DESCRIPTION
    Tests a connection to AzureAd is established.
  .EXAMPLE
    Assert-AzureADConnection
    Will run Test-AzureADConnection and, if successful, stops.
    If unsuccessful, displays request to create a new session and stops.
  .INPUTS
    None
  .OUTPUTS
    System.Void - If called directly; On-Screen output only
    Boolean - If called by other CmdLets, On-Screen output for the first call only
  .NOTES
    None
  .COMPONENT
    TeamsSession
  .FUNCTIONALITY
    Verifies a Connection to AzureAd is established
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-AzureAdConnection.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colourful feedback required to emphasise feedback for script executors')]
  [CmdletBinding()]
  [OutputType([Boolean])]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

  } #begin

  process {
    if (Test-AzureADConnection) {
      #$TenantDomain = $((Get-AzureADCurrentSessionInfo -WarningAction SilentlyContinue).TenantDomain)
      #Write-Verbose -Message "[ASSERT] AzureAD(v2): Valid session found - Tenant: $TenantDomain"
      if ($stack.length -lt 3) {
        Write-Verbose -Message '[ASSERT] AzureAD(v2) Session Connected'
      }
      return $(if ($Called) { $true })
    }
    else {
      Write-Host '[ASSERT] ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets. (Connect-Me can be used for multiple connections) ' -ForegroundColor Red
      return $(if ($Called) { $false })
    }
  } #process

  end {

  } #end

} #Assert-AzureADConnection
