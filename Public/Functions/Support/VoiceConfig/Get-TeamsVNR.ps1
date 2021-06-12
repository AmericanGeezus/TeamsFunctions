# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Get-TeamsVNR {
  <#
  .SYNOPSIS
    Lists all Normalization Rules for a Tenant Dial Plan
  .DESCRIPTION
    To quickly find Tenant Dial Plans to assign, an Alias-Function to Get-CsTenantDialPlan
  .PARAMETER Identity
    String. Name or part of the Teams Dial Plan.
    If not provided, lists Identities of all Tenant Dial Plans (except "Global")
    If provided without a '*' in the name, an exact match is sought.
  .EXAMPLE
    Get-TeamsVNR
    Returns the Object for all Tenant Dial Plans (except "Global")
    Behaviour like: Get-CsTenantDialPlan, showing only a few Parameters (no Normalization Rules)
  .EXAMPLE
    Get-TeamsVNR -Identity DP-HUN
    Returns Voice Normalisation Rules from the Tenant Dial Plan DP-HUN (provided it exists).
    Behaviour like: (Get-CsTenantDialPlan -Identity "DP-HUN").NormalizationRules
  .EXAMPLE
    Get-TeamsVNR -Filter DP-HUN
    Filters all Tenant Dial Plans that contain the string "DP-HUN" in the Name.
    Returns Tenant Dial Plans if more than 3 results are found.
    Behaviour like: Get-CsTenantDialPlan -Identity "*DP-HUN*"
    Returns Voice Normalisation Rules from the Tenant Dial Plan DP-HUN (provided it exists).
    Behaviour like: (Get-CsTenantDialPlan -Identity "*DP-HUN*").NormalizationRules
  .INPUTS
    None
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Without parameters, it executes the following string:
    Get-CsTenantDialPlan | Where-Object Identity -NE "Global" | Select-Object Name, Pattern, Translation, Description
  .COMPONENT
    SupportingFunction
    VoiceConfiguration
  .FUNCTIONALITY
    Queries Normalization Rules from a Tenant Dial Plan from the Tenant
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_SupportingFunction
  .LINK
    about_VoiceConfiguration
  .LINK
    Get-TeamsTDP
  .LINK
    Get-TeamsVNR
  .LINK
    Get-TeamsIPP
  .LINK
    Get-TeamsCP
  .LINK
    Get-TeamsECP
  .LINK
    Get-TeamsECRP
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
      Write-Warning -Message "More than 3 Tenant Dial Plans found. Displaying Tenant Dial Plan Names only."
      $Filtered = $Filtered | Select-Object Identity, SimpleName, OptimizeDeviceDialing, Description
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
