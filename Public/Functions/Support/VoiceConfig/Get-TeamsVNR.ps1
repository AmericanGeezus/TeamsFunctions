# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Get-TeamsVNR {
  <#
  .SYNOPSIS
    Lists all Normalization Rules for a Tenant Dial Plan
  .DESCRIPTION
    To quickly find Tenant Dial Plans to assign, an Alias-Function to Get-CsTenantDialPlan
  .PARAMETER Identity
    String. Name or part of the Tenant Dial Plan. Can be omitted to list Names of all Policies (except "Global").
    If provided without a '*' in the name, an exact match is sought.
  .EXAMPLE
    Get-TeamsVNR
    Lists Identities (Names) of all Tenant Dial Plans (except "Global")
  .EXAMPLE
    Get-TeamsVNR [-Identity] DP-HUN
    Lists Normalization Rules for Tenant Dial Plan DP-HUN as Get-CsTenantDialPlan does.
  .EXAMPLE
    Get-TeamsVNR -Identity DP-HU*
    Lists Normalization Rules for all Tenant Dials that contain the strign "DP-HU*" in the Name.
  .NOTES
    This script is indulging the lazy admin. It behaves like Get-CsTenantDialPlan with a twist:
    If more than 3 results are found, behaves like Get-CsTenantDialPlan | Select Identity
    Without any parameters, it lists names only:
    Get-CsTenantDialPlan | Where-Object Identity -NE "Global" | Select-Object Identity -ExpandProperty Identity
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Get-TeamsTDP
  .LINK
    Get-TeamsVNR
  .LINK
    Get-TeamsOVP
  .LINK
    Get-TeamsOPU
  .LINK
    Get-TeamsOVR
  .LINK
    Get-TeamsMGW
  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Identity', HelpMessage = 'Name of the Tenant Dial Plan')]
    [string]$Identity
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ($PSBoundParameters.ContainsKey('Identity')) {
      Write-Verbose -Message "Finding Tenant Dial Plans with Identity '$Identity'"
      if ($Identity -match [regex]::Escape('*')) {
        $Filtered = Get-CsTenantDialPlan -Filter "*$Identity*"
      }
      else {
        $Filtered = Get-CsTenantDialPlan -Identity "$Identity"
      }

      if ( $Filtered.Count -gt 3) {
        $Filtered | Select-Object Identity
      }
      else {
        $Filtered.NormalizationRules
      }
    }
    else {
      Write-Verbose -Message 'Finding Tenant Dial Plan Names. Please choose one Dial Plan to display Normalisation Rules for.'
      Get-CsTenantDialPlan | Where-Object Identity -NE 'Global' | Select-Object Identity
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsVNR