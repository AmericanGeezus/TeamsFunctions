# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Get-TeamsMGW {
  <#
  .SYNOPSIS
    Lists all Online Pstn Gateways by Name
  .DESCRIPTION
    To quickly find Online Pstn Gateways to assign, an Alias-Function to Get-CsOnlineVoiceRoutingPolicy
  .PARAMETER Identity
    String. FQDN or part of the FQDN for a Pstn Gateway. Can be omitted to list Names of all Gateways
    If provided without a '*' in the name, an exact match is sought.
  .EXAMPLE
    Get-TeamsMGW
    Lists Identities (Names) of all Online Pstn Gateways
    Behaviour like: Get-CsOnlineVoiceRoute
  .EXAMPLE
    Get-TeamsMGW -Identity PstnGateway1.domain.com
    Lists Online Pstn Gateway as Get-CsOnlinePstnGateway does (provided it exists).
    Behaviour like: Get-CsOnlineVoiceRoute -Identity "PstnGateway1.domain.com"
  .EXAMPLE
    Get-TeamsOVR -Identity EMEA*
    Lists Online Voice Routes with "EMEA" in the Name
    Behaviour like: Get-CsOnlineVoiceRoute -Filter "*EMEA*"
  .INPUTS
    None
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    This script is indulging the lazy admin. It behaves like Get-CsTeamsCallingPolicy with a twist:
    If more than three results are found, a reduced set of Parameters are shown for better visibility:
    Get-CsOnlinePSTNGateway | Select-Object Identity, SipSignalingPort, Enabled, MediaByPass
  .COMPONENT
    SupportingFunction
    VoiceConfiguration
  .FUNCTIONALITY
    Queries MediaGateways by Name
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsMGW.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Online Pstn Gateway')]
    [string]$Identity
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online: $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ($PSBoundParameters.ContainsKey('Identity')) {
      Write-Verbose -Message "Finding Online Voice Routes with Identity '$Identity'"
      if ($Identity -match [regex]::Escape('*')) {
        $Filtered = Get-CsOnlinePSTNGateway -Filter "*$Identity*"
      }
      else {
        $Filtered = Get-CsOnlinePSTNGateway -Identity "$Identity"
      }
    }
    else {
      Write-Verbose -Message 'Finding Online Pstn Gateway Names'
      $Filtered = Get-CsOnlinePSTNGateway
    }

    if ( $Filtered.Count -gt 3) {
      $Filtered = $Filtered | Select-Object Identity, SipSignalingPort, Enabled, MediaByPass
    }
    return $Filtered | Sort-Object Identity

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsMGW
