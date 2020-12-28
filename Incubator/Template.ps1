# Module:   TeamsFunctions
# Function: VoiceRouting
# Author:	  David Eberhardt
# Updated:  28-DEC-2020
# Status:   Alpha




function Find-TeamsUserVoiceRoute {
  <#
  .SYNOPSIS
    Short description
  .DESCRIPTION
    Long description
  .PARAMETER Identity
    Required. Username or UserPrincipalname of the User to query Online Voice Routing Policy and Tenant Dial Plan
    User must have a valid Voice Configuration applied for this script to return a valuable result
  .PARAMETER DialedNumber
    Optional. If provided, number will be normalised with the effective Dial Plan, then a matching Route will be found for this number
    If not provided, the first Voice Route will be chosen.
  .EXAMPLE
    Find-TeamsUserVoiceRoute -Identity John@domain.com
    Finds the Voice Route any call for this user may take. First match (Voice Route with the highest priority) will be returned
  .EXAMPLE
    Find-TeamsUserVoiceRoute -Identity John@domain.com -DialledNumber "+1(555) 1234-567"
    Finds the Voice Route a call to the normalised Number +15551234567 for this user may take. The matching Voice Route will be returned
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    This is a slightly more intricate on Voice routing, enabling comparisons for multiple users.
    Based on and inspired by Test-CsOnlineUserVoiceRouting by Lee Ford - https://www.lee-ford.co.uk
  .COMPONENT
    VoiceConfig
  .ROLE
    VoiceRouting
  .FUNCTIONALITY
    Voice Routing and Troubleshooting
  .LINK
    Find-TeamsUserVoiceConfig
    Get-TeamsUserVoiceConfig
    Set-TeamsUserVoiceConfig
  #>

  [CmdletBinding()]
  [Alias('Find-TeamsUVR')]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory, Position = 0, HelpMessage = "Username(s) to query routing for")]
    [Alias('Username', 'UserPrincipalName')]
    [string[]]$Identity,

    [Parameter(HelpMessage = "Phone Number to be normalised with the Dial Plan")]
    [Alias('Number')]
    [String]$DialedNumber

  )

  begin {
    Show-FunctionStatus -Level Alpha
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }


  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($Id in $Identity) {
      Write-Verbose -Message "[PROCESS] Processing '$Id'"



    } #foreach Identity

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Find-TeamsUserVoiceRoute