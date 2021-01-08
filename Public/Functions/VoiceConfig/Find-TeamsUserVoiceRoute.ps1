# Module:   TeamsFunctions
# Function: VoiceRouting
# Author:	  David Eberhardt
# Updated:  28-DEC-2020
# Status:   RC


#EXPAND: Make Number an Array?

function Find-TeamsUserVoiceRoute {
  <#
  .SYNOPSIS
    Returns Voice Route for a User and a dialed number
  .DESCRIPTION
    Returns a custom object detailing voice routing information for a User
    If a Dialed Number is provided, also normalises the number and returns the effective Tenant Dial Plan
  .PARAMETER Identity
    Required. Username or UserPrincipalname of the User to query Online Voice Routing Policy and Tenant Dial Plan
    User must have a valid Voice Configuration applied for this script to return a valuable result
  .PARAMETER DialedNumber
    Optional. Number entered in the Dial Pad. If not provided, the first Voice Route will be chosen.
    If provided, number will be normalised and the effective Dial Plan queried. A matching Route will be found for this number will be queried
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
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

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

    #region Defining Output Object
    class TFVoiceRouting {
      [string]$Identity
      [string]$TenantDialPlan
      [string]$DialedNumber
      [string]$EffectiveDialPlan
      [string]$MatchingRule
      [string]$MatchingPattern
      [string]$TranslatedNumber
      [string]$OnlineVoiceRoutingPolicy
      [string]$OnlinePstnUsage
      $MatchedVoiceRoutes #Can be a string or an Object
      [string]$OnlineVoiceRoute
      [string]$OnlinePstnGateway
      [string]$NumberPattern

      TFVoiceRouting(
        [string]$Identity,
        [string]$TenantDialPlan,
        [string]$DialedNumber,
        [string]$EffectiveDialPlan,
        [string]$MatchingRule,
        [string]$MatchingPattern,
        [string]$TranslatedNumber,
        [string]$OnlineVoiceRoutingPolicy,
        [string]$OnlinePstnUsage,
        $MatchedVoiceRoutes,
        [string]$OnlineVoiceRoute,
        [string]$OnlinePstnGateway,
        [string]$NumberPattern
      ) {
        $this.Identity = $Identity
        $this.TenantDialPlan = $TenantDialPlan
        $this.DialedNumber = $DialedNumber
        $this.EffectiveDialPlan = $EffectiveDialPlan
        $this.MatchingRule = $MatchingRule
        $this.MatchingPattern = $MatchingPattern
        $this.TranslatedNumber = $TranslatedNumber
        $this.OnlineVoiceRoutingPolicy = $OnlineVoiceRoutingPolicy
        $this.OnlinePstnUsage = $OnlinePstnUsage
        $this.MatchedVoiceRoutes = $MatchedVoiceRoutes
        $this.OnlineVoiceRoute = $OnlineVoiceRoute
        $this.OnlinePstnGateway = $OnlinePstnGateway
        $this.NumberPattern = $NumberPattern
      }
    }
    #endregion

    if (-not $DialedNumber) {
      Write-Warning -Message "Parameter DialedNumber was not provided, only basic routing path (first match) is shown"
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($Id in $Identity) {
      Write-Verbose -Message "[PROCESS] Processing '$Id'"

      # Query User and prepare object
      try {
        $User = Get-CsOnlineUser -Identity "$Id" -WarningAction SilentlyContinue -ErrorAction Stop
        if ( -not $User ) {
          throw
        }
      }
      catch {
        #throw [System.Data.ObjectNotFoundException]::New("User '$Id' not found")
        Write-Error -Message "User '$Id' not found" -Category ResourceUnavailable
        continue
      }

      # User
      if ( $User ) {
        $UserVoiceRouting = $null
        $UserVoiceRouting = [TFVoiceRouting]::new("", "", "", "", "", "", "", "", "", $null, "", "", "")
        $UserVoiceRouting.Identity = $User.UserPrincipalName
        $UserVoiceRouting.TenantDialPlan = $User.TenantDialPlan
        $UserVoiceRouting.DialedNumber = $DialedNumber
        $UserVoiceRouting.OnlineVoiceRoutingPolicy = $User.OnlineVoiceRoutingPolicy
      }

      # Number
      if ($DialedNumber) {
        # Normalise Number
        #CHECK Normalisation cannot be with StringForUse as it would cut out short dial and other options
        #$NormalisedNumber = Format-StringForUse $DialedNumber -As E164
        #$NormalisedNumber = Format-StringRemoveSpecialCharacter $DialedNumber -SpecialCharacterToKeep "+" # Keep + in case ppl dial E.164

        if ($PSBoundParameters.ContainsKey('Debug')) {
          "Function: $($MyInvocation.MyCommand.Name) - NormalisedNumber", ( $NormalisedNumber | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }

        # Query Effective Tenant Dial Plan
        $EffectiveTDP = Get-CsEffectiveTenantDialPlan -Identity "$Id" | Test-CsEffectiveTenantDialPlan -DialedNumber "$DialedNumber"

        if ($PSBoundParameters.ContainsKey('Debug')) {
          "Function: $($MyInvocation.MyCommand.Name) - EffectiveTDP", ( $EffectiveTDP | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }

        if ( $EffectiveTDP.TranslatedNumber ) {
          Write-Verbose "User '$Id' - Dialed Number '$DialedNumber' translated to '$($EffectiveTDP.TranslatedNumber)'"
          Write-Verbose "User '$Id' - Normalization rule '$($EffectiveTDP.MatchingRule -replace ";", "`n"))"
          $UserVoiceRouting.MatchingRule = $EffectiveTDP.MatchingRule.Name
          $UserVoiceRouting.MatchingPattern = $EffectiveTDP.MatchingRule.Pattern
          $UserVoiceRouting.TranslatedNumber = $EffectiveTDP.TranslatedNumber
          $VoiceRouteNumber = $EffectiveTDP.TranslatedNumber
        }
        else {
          $VoiceRouteNumber = $DialedNumber
        }

        if ($DP.EffectiveTenantDialPlanName -match "_(?<content>.*)_") {
          $UserVoiceRouting.EffectiveDialPlan = $matches.content
        }
      }

      # Voice Routing
      Write-Verbose "User '$Id' - Querying Voice Routing Path with Online Voice Routing Policy '$($User.OnlineVoiceRoutingPolicy)'"

      $OPUs = (Get-CsOnlineVoiceRoutingPolicy -Identity $User.OnlineVoiceRoutingPolicy).OnlinePstnUsages

      if ($OPUs) {
        [System.Collections.ArrayList]$VoiceRoutes = @()
        foreach ($OPU in $OPUs) {
          $VoiceRoutes += Get-CsOnlineVoiceRoute | Where-Object { $_.OnlinePstnUsages -contains $OPU } | Select-Object *, @{label = "PSTNUsage"; Expression = { $OPU } }
        }
        if ($PSBoundParameters.ContainsKey('Debug')) {
          "Function: $($MyInvocation.MyCommand.Name) - VoiceRoutes", ( $VoiceRoutes | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }

        if ($VoiceRoutes) {
          $MatchedVoiceRoutes = $null
          $UsedVoiceRoute = $null
          if ($DialedNumber) {
            $MatchedVoiceRoutes = $VoiceRoutes | Where-Object { $VoiceRouteNumber -match $_.NumberPattern }
            if ( $MatchedVoiceRoutes ) {
              # Selecting PSTN Usage of the first Voice Route
              $UserVoiceRouting.OnlinePstnUsage = $MatchedVoiceRoutes[0].PSTNUsage

              # Populating MatchedVoiceRoutes
              $MatchedVoiceRoutesByPriority = $MatchedVoiceRoutes | Where-Object { $_.PSTNUsage -eq $UserVoiceRouting.OnlinePstnUsage } | Sort-Object Priority
              $UserVoiceRouting.MatchedVoiceRoutes = $MatchedVoiceRoutesByPriority.Name -join (', ')
              #if ( $MatchedVoiceRoutes.Count -gt 1 ) { #TEST This could be used to attach all with .ToString (like AA)  }
              Write-Verbose "OVP '$($User.OnlineVoiceRoutingPolicy)' - OPU '$($UserVoiceRouting.OnlinePstnUsage)' - Matching Voice Route(s): $($UserVoiceRouting.MatchedVoiceRoutes)"

              # Selecting Voice Route
              $UsedVoiceRoute = $MatchedVoiceRoutesByPriority | Select-Object -First 1
            }
            else {
              Write-Warning -Message "OVP '$($User.OnlineVoiceRoutingPolicy)' - No Online Voice Routes have been found matching Number '$($VoiceRouteNumber)'"
            }
          }
          else {
            # Selecting PSTN Usage of the first Voice Route
            $UserVoiceRouting.OnlinePstnUsage = $VoiceRoutes[0].PSTNUsage

            # Selecting first Voice Route
            $UsedVoiceRoute = $VoiceRoutes | Select-Object -First 1
          }

          # Populating Parameters based on selection
          $UserVoiceRouting.OnlineVoiceRoute = $UsedVoiceRoute.Name
          $UserVoiceRouting.NumberPattern = $UsedVoiceRoute.NumberPattern
          $UserVoiceRouting.OnlinePstnGateway = $($UsedVoiceRoute.OnlinePstnGatewayList -join (', '))

        }
        else {
          Write-Warning -Message "OVP '$($User.OnlineVoiceRoutingPolicy)' - No Online Voice Routes have been found"
        }
      }
      else {
        Write-Warning -Message "OVP '$($User.OnlineVoiceRoutingPolicy)' - No Online PSTN Usages have been found"
      }

      Write-Output $UserVoiceRouting
    } #foreach Identity

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Find-TeamsUserVoiceRoute