# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-APR-2021
# Status:   Live




function Get-TeamsECP {
  <#
  .SYNOPSIS
    Lists all Online Emergency Calling Policies by Name
  .DESCRIPTION
    To quickly find Emergency Calling Policies to assign, an Alias-Function to Get-CsTeamsEmergencyCallingPolicy
  .PARAMETER Identity
    String. Name or part of the Emergency Calling Policy. Can be omitted to list Names of all Policies (including "Global").
    If provided without a '*' in the name, an exact match is sought.
  .EXAMPLE
    Get-TeamsECP
    Returns the Object for all Emergency Calling Policies (including "Global")
    Behaviour like: Get-CsTeamsEmergencyCallingPolicy
  .EXAMPLE
    Get-TeamsECP -Identity ECP-US
    Returns the Object for the Online Voice Route "ECP-US" (provided it exists).
    Behaviour like: Get-CsTeamsEmergencyCallingPolicy -Identity "ECP-US"
  .EXAMPLE
    Get-TeamsECP -Identity ECP-US-*
    Lists Online Voice Routes with "ECP-US-" in the Name
    Behaviour like: Get-CsTeamsEmergencyCallingPolicy -Filter "*ECP-US-*"
  .INPUTS
    None
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    This script is indulging the lazy admin. It behaves like Get-CsOnlineVoiceRoute with a twist:
    If more than three results are found, a reordered set of Parameters are shown for better visibility:
    Get-CsTeamsEmergencyCallingPolicy | Select-Object Identity, Description, NotificationMode, NotificationGroup
  .COMPONENT
    SupportingFunction
    VoiceConfiguration
  .FUNCTIONALITY
    Queries Emergency Calling Policies by Name
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsECP.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsUserVoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_SupportingFunction
  .LINK
    about_TeamsUserVoiceConfiguration
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
  .LINK
    Get-TeamsIPP
  .LINK
    Get-TeamsCP
  .LINK
    Get-TeamsECP
  .LINK
    Get-TeamsECRP
  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Emergency Calling Policy')]
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
      Write-Verbose -Message "Finding Emergency Calling Policy with Identity '$Identity'"
      if ($Identity -match [regex]::Escape('*')) {
        $Filtered = Get-CsTeamsEmergencyCallingPolicy -Filter "*$Identity*"
      }
      else {
        $Filtered = Get-CsTeamsEmergencyCallingPolicy -Identity "$Identity"
      }
    }
    else {
      Write-Verbose -Message 'Finding Emergency Calling Policy Names'
      $Filtered = Get-CsTeamsEmergencyCallingPolicy #| Where-Object Identity -NE 'Global'
    }

    if ( $Filtered.Count -gt 3) {
      $Filtered = $Filtered | Select-Object Identity, Description, NotificationMode, NotificationGroup
    }
    return $Filtered | Sort-Object Identity
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsECP
