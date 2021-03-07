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
    If provided, acts as an Alias to Get-CsTenantDialPlan, listing Normalisation Rules for this Dial Plan
    If not provided, lists Identities of all Tenant Dial Plans (except "Global")
  .PARAMETER Filter
    Searches for all Tenant Dial Plans that contains the string in the Name.
  .EXAMPLE
    Get-TeamsVNR
    Lists Identities (Names) of all Tenant Dial Plans (except "Global")
  .EXAMPLE
    Get-TeamsVNR -Identity DP-HUN
    Lists Tenant Dial Plan DP-HUN as Get-CsTenantDialPlan does.
  .EXAMPLE
    Get-TeamsVNR -Filter DP-HUN
    Lists all Tenant Dials that contain the strign "DP-HUN" in the Name.
  .NOTES
    Without parameters, it executes the following string:
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
    Write-Verbose -Mess"Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ($PSBoundParameters.ContainsKey('Identity')) {
      Write-Verbose -Message "Finding Tenant Dial Plans with Identity '$Identity'"
      if ($Identity -match [regex]::Escape('*')) {
        $Filtered = Get-CsTenantDialPlan -WarningAction SilentlyContinue -Filter "*$Identity*"
      }
      else {
        $Filtered = Get-CsTenantDialPlan -WarningAction SilentlyContinue -Identity "Tag:$Identity"
      }
    }
    else {
      Write-Verbose -Message 'Finding Tenant Dial Plan Names'
      $Filtered = Get-CsTenantDialPlan | Where-Object Identity -NE 'Global' | Sort-Object Identity | Select-Object Identity
    }

    if ( $Filtered.Count -gt 3) {
      $Filtered = $Filtered | Select-Object Identity
      return $Filtered
    }
    else {
      return $Filtered.NormalizationRules | Select-Object Name, Pattern, Translation, Description
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsVNR
