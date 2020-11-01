# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-NOV-2020
# Status:   RC




function Get-TeamsTDP {
  <#
  .SYNOPSIS
    Lists all Tenant Dial Plans by Name
  .DESCRIPTION
    To quickly find Tenant Dial Plans to assign, an Alias-Function to Get-CsTenantDialPlan
  .PARAMETER Identity
    If provided, acts as an Alias to Get-CsTenantDialPlan, listing one Dial Plan
    If not provided, lists Identities of all Tenant Dial Plans (except "Global")
  .EXAMPLE
    Get-TeamsTDP
    Lists Identities (Names) of all Tenant Dial Plans (except "Global")
  .EXAMPLE
    Get-TeamsTDP -Identity DP-HUN
    Lists Tenant Dial Plan DP-HUN as Get-CsTenantDialPlan does (provided it exists).
  .NOTES
    Without parameters, it executes the following string:
    Get-CsTenantDialPlan | Where-Object Identity -NE "Global" | Select-Object Identity -ExpandProperty Identity
  #>

  [CmdletBinding()]
  param (
    [Parameter(HelpMessage = "Name of the Tenant Dial Plan")]
    [string]$Identity
  )

  begin {
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ($PSBoundParameters.ContainsKey('Identity')) {
      Write-Verbose -Message "Switch Identity: Acting as alias to 'Get-CsTenantDialPlan'"
      Get-CsTenantDialPlan $Identity

    }
    else {
      Write-Verbose -Message "Finding Names for all Tenant Dial Plans"
      Get-CsTenantDialPlan | Where-Object Identity -NE "Global" | Select-Object Identity -ExpandProperty Identity

    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsTDP