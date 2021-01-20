# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
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
    Behaviour like: Get-CsOnlineVoiceRoute -Filter "OVR-EMEA-"
  .NOTES
    This script is indulging the lazy admin. It behaves like Get-CsOnlineVoiceRoute with a twist:
    If more than 3 results are found, behaves like Get-CsOnlineVoiceRoute | Select Identity
    Without any parameters, it lists names only:
    Get-CsOnlineVoiceRoute | Where-Object Identity -NE "LocalRoute"  | Select-Object Name
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Get-TeamsOVP
  .LINK
    Get-TeamsOPU
  .LINK
    Get-TeamsOVR
  .LINK
    Get-TeamsMGW
  .LINK
    Get-TeamsTDP
  .LINK
    Get-TeamsVNR
  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Online Voice Route')]
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
      Write-Verbose -Message "Finding Online Voice Routes with Identity '$Identity'"
      if ($Identity -match [regex]::Escape('*')) {
        $Filtered = Get-CsOnlineVoiceRoute -Filter "*$Identity*"
      }
      else {
        $Filtered = Get-CsOnlineVoiceRoute -Identity "$Identity"
      }

      if ( $Filtered.Count -gt 3) {
        $Filtered | Select-Object Identity
      }
      else {
        $Filtered
      }
    }
    else {
      Write-Verbose -Message 'Finding Voice Route Names'
      Get-CsOnlineVoiceRoute | Where-Object Identity -NE 'LocalRoute' | Select-Object Name
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsOVR