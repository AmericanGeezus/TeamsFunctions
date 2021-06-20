# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Get-TeamsOVR {
  <#
  .SYNOPSIS
    Lists all Online Voice Routes by Name
  .DESCRIPTION
    To quickly find Online Voice Routes to troubleshoot, an Alias-Function to Get-CsOnlineVoiceRoute
  .PARAMETER Identity
    String. Name or part of the Voice Route. Can be omitted to list Names of all Routes (except "Global").
    If provided without a '*' in the name, an exact match is sought.
  .EXAMPLE
    Get-TeamsOVR
    Returns the Object for all Online Voice Routes (except "LocalRoute")
    Behaviour like: Get-CsOnlineVoiceRoute, if more than 3 results are found, only names are returned
  .EXAMPLE
    Get-TeamsOVR -Identity OVR-EMEA-National
    Returns the Object for the Online Voice Route "OVR-EMEA-National" (provided it exists).
    Behaviour like: Get-CsOnlineVoiceRoute -Identity "OVR-EMEA-National"
  .EXAMPLE
    Get-TeamsOVR -Identity OVR-EMEA-*
    Lists Online Voice Routes with "OVR-EMEA-" in the Name
    Behaviour like: Get-CsOnlineVoiceRoute -Filter "*OVR-EMEA-*"
  .INPUTS
    None
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    This script is indulging the lazy admin. It behaves like Get-CsOnlineVoiceRoute with a twist:
    If more than three results are found, a reduced set of Parameters are shown for better visibility:
    Get-CsOnlineVoiceRoute | Where-Object Identity -NE 'LocalRoute' | Select-Object Identity, Priority, NumberPattern, OnlinePstnGatewayList
  .COMPONENT
    SupportingFunction
    VoiceConfiguration
  .FUNCTIONALITY
    Queries Online Voice Route by Name
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsOVR.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Online Voice Route')]
    [string]$Identity
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ($PSBoundParameters.ContainsKey('Identity')) {
      Write-Verbose -Message "Finding Online Voice Routes with Identity '$Identity'"
      if ($Identity -match [regex]::Escape('*')) {
        $Filtered = Get-CsOnlineVoiceRoute -Filter "*$Identity*"
      }
      else {
        $Filtered = Get-CsOnlineVoiceRoute -Identity "$Identity"
      }
    }
    else {
      Write-Verbose -Message 'Finding Online Voice Route Names'
      $Filtered = Get-CsOnlineVoiceRoute | Where-Object Identity -NE 'LocalRoute'
    }

    if ( $Filtered.Count -gt 3) {
      $Filtered = $Filtered | Select-Object Identity, Priority, NumberPattern, OnlinePstnGatewayList
    }
    return $Filtered | Sort-Object Identity

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsOVR
