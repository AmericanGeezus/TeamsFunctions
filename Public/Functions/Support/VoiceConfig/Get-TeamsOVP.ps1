﻿# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Get-TeamsOVP {
  <#
  .SYNOPSIS
    Lists all Online Voice Routing Policies by Name
  .DESCRIPTION
    To quickly find Online Voice Routing Policies to assign, an Alias-Function to Get-CsOnlineVoiceRoutingPolicy
  .PARAMETER Identity
    String. Name or part of the Voice Routing Policy. Can be omitted to list Names of all Policies (except "Global").
    If provided without a '*' in the name, an exact match is sought.
  .EXAMPLE
    Get-TeamsOVP
    Returns the Object for all Online Voice Routing Policies (except "Global")
    Behaviour like: Get-CsOnlineVoiceRoutingPolicy, if more than 3 results are found, only names are returned
  .EXAMPLE
    Get-TeamsOVP -Identity OVP-EMEA-National
    Returns the Object for the Online Voice Routing Policy "OVP-EMEA-National" (provided it exists).
    Behaviour like: Get-CsOnlineVoiceRoutingPolicy -Identity "OVP-EMEA-National"
  .EXAMPLE
    Get-TeamsOVP -Identity OVP-EMEA-*
    Lists Online Voice Routes with "OVP-EMEA-" in the Name
    Behaviour like: Get-CsOnlineVoiceRoutingPolicy -Filter "*OVP-EMEA-*"
  .INPUTS
    None
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    This script is indulging the lazy admin. It behaves like Get-CsOnlineVoiceRoutingPolicy with a twist:
    If more than three results are found, a reduced set of Parameters are shown for better visibility:
    Get-CsOnlineVoiceRoutingPolicy | Where-Object Identity -NE 'Global' | Select-Object Identity, Description, OnlinePstnUsages
  .COMPONENT
    SupportingFunction
    VoiceConfiguration
  .FUNCTIONALITY
    Queries Online Voice Routing Policies by Name
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsOVP.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Online Voice Routing Policy')]
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
      Write-Verbose -Message "Finding Online Voice Routing Policy with Identity '$Identity'"
      if ($Identity -match [regex]::Escape('*')) {
        $Filtered = Get-CsOnlineVoiceRoutingPolicy -Filter "*$Identity*"
      }
      else {
        $Filtered = Get-CsOnlineVoiceRoutingPolicy -Identity "$Identity"
      }
    }
    else {
      Write-Verbose -Message 'Finding Online Voice Routing Policy Names'
      $Filtered = Get-CsOnlineVoiceRoutingPolicy | Where-Object Identity -NE 'Global'
    }

    $Filtered = $Filtered | Select-Object Identity, Description, OnlinePstnUsages
    return $Filtered | Sort-Object Identity

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsOVP
