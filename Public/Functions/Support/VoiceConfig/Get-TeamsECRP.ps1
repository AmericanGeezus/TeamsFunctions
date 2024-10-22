﻿# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-APR-2021
# Status:   Live




function Get-TeamsECRP {
  <#
  .SYNOPSIS
    Lists all Emergency Voice Routing Policies by Name
  .DESCRIPTION
    To quickly find Emergency Voice Routing Policies to assign, an Alias-Function to Get-CsTeamsEmergencyCallRoutingPolicy
  .PARAMETER Identity
    String. Name or part of the Voice Routing Policy. Can be omitted to list Names of all Policies (including "Global").
    If provided without a '*' in the name, an exact match is sought.
  .EXAMPLE
    Get-TeamsECRP
    Returns the Object for all Emergency Voice Routing Policies (including "Global")
    Behaviour like: Get-CsTeamsEmergencyCallRoutingPolicy
  .EXAMPLE
    Get-TeamsECRP -Identity ECRP-US
    Returns the Object for the Emergency Voice Route "ECRP-US" (provided it exists).
    Behaviour like: Get-CsTeamsEmergencyCallRoutingPolicy -Identity "ECRP-US"
  .EXAMPLE
    Get-TeamsECRP -Identity ECRP-US-*
    Lists Emergency Voice Routes with "ECRP-US-" in the Name
    Behaviour like: Get-CsTeamsEmergencyCallRoutingPolicy -Filter "*ECRP-US-*"
  .INPUTS
    None
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    If more than three results are found, a reordered set of Parameters are shown for better visibility:
    Get-CsTeamsEmergencyCallRoutingPolicy | Select-Object Identity, Description, AllowEnhancedEmergencyServices, EmergencyNumbers
  .COMPONENT
    SupportingFunction
    VoiceConfiguration
  .FUNCTIONALITY
    Queries Emergency Call Routing Policies by Name
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsECRP.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Emergency Call Routing Policy')]
    [string]$Identity
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting MicrosoftTeams Connection
    if ( -not (Assert-MicrosoftTeamsConnection) ) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ($PSBoundParameters.ContainsKey('Identity')) {
      Write-Verbose -Message "Finding Emergency Call Routing Policy with Identity '$Identity'"
      if ($Identity -match [regex]::Escape('*')) {
        $Filtered = Get-CsTeamsEmergencyCallRoutingPolicy -Filter "*$Identity*"
      }
      else {
        $Filtered = Get-CsTeamsEmergencyCallRoutingPolicy -Identity "$Identity"
      }
    }
    else {
      Write-Verbose -Message 'Finding Emergency Call Routing Policy Names'
      $Filtered = Get-CsTeamsEmergencyCallRoutingPolicy #| Where-Object Identity -NE 'Global'
    }

    if ( $Filtered.Count -gt 3) {
      $Filtered = $Filtered | Select-Object Identity, Description, AllowEnhancedEmergencyServices, EmergencyNumbers
    }
    return $Filtered | Sort-Object Identity
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsECRP
