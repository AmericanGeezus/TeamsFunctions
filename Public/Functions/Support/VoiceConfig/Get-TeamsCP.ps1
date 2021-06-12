# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-APR-2021
# Status:   Live




function Get-TeamsCP {
  <#
  .SYNOPSIS
    Lists all Teams Calling Policies by Name
  .DESCRIPTION
    To quickly find Teams Calling Policies to assign, an Alias-Function to Get-CsTeamsCallingPolicy
  .PARAMETER Identity
    String. Name or part of the Teams Calling Policy. Can be omitted to list Names of all Policies (including "Global").
    If provided without a '*' in the name, an exact match is sought.
  .EXAMPLE
    Get-TeamsCP
    Returns the Object for all Teams Calling Policies (including "Global")
    Behaviour like: Get-CsTeamsCallingPolicy, showing only a few Parameters
  .EXAMPLE
    Get-TeamsCP -Identity AllowCallingPreventTollBypass
    Returns the Object for the Teams Calling Policy "AllowCallingPreventTollBypass" (provided it exists).
    Behaviour like: Get-CsTeamsCallingPolicy -Identity "AllowCallingPreventTollBypass"
  .EXAMPLE
    Get-TeamsCP -Identity Allow*
    Lists Online Voice Routes with "Allow" in the Name
    Behaviour like: Get-CsTeamsCallingPolicy -Filter "*Allow*"
  .NOTES
    This script is indulging the lazy admin. It behaves like Get-CsOnlineVoiceRoute with a twist:
    If more than three results are found, a reduced set of Parameters are shown for better visibility:
    Get-CsTeamsCallingPolicy | Select-Object Identity, Description, BusyOnBusyEnabledType
  .INPUTS
    None
    System.String
  .OUTPUTS
    System.Object
  .COMPONENT
    SupportingFunction
    VoiceConfiguration
  .FUNCTIONALITY
    Queries Calling Policies by Name
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_SupportingFunction
  .LINK
    about_VoiceConfiguration
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
    Get-TeamsECRP  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Calling Policy')]
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
      Write-Verbose -Message "Finding Teams Calling Policy with Identity '$Identity'"
      if ($Identity -match [regex]::Escape('*')) {
        $Filtered = Get-CsTeamsCallingPolicy -Filter "*$Identity*"
      }
      else {
        $Filtered = Get-CsTeamsCallingPolicy -Identity "$Identity"
      }
    }
    else {
      Write-Verbose -Message 'Finding Teams Calling Policy Names'
      $Filtered = Get-CsTeamsCallingPolicy #| Where-Object Identity -NE 'Global'
    }

    if ( $Filtered.Count -gt 3) {
      $Filtered = $Filtered | Select-Object Identity, Description, BusyOnBusyEnabledType #, AllowPrivateCalling
    }
    return $Filtered | Sort-Object Identity
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsCP
