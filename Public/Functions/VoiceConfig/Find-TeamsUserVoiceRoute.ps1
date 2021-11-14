# Module:   TeamsFunctions
# Function: VoiceRouting
# Author:   David Eberhardt
# Updated:  28-DEC-2020
# Status:   Live

#TODO Refactor to accept User Object for input as well as UPN, then use for parsing for other functions.
#TODO Test performance for Voice Routing only.
#TODO Create separate function for determination of OVP/OPU/OVR - Add to Get-TeamsOVP when called with Identity

function Find-TeamsUserVoiceRoute {
  <#
  .SYNOPSIS
    Returns Voice Route for a User and a dialed number
  .DESCRIPTION
    Returns a custom object detailing voice routing information for a User
    If a Dialed Number is provided, also normalises the number and returns the effective Tenant Dial Plan
  .PARAMETER UserPrincipalName
    Required for Parameterset UserPrincipalName. UserPrincipalName of the User to query.
    User must have a valid Voice Configuration applied for this script to return a valuable result
  .PARAMETER Object
    Required for Parameterset Object. CsOnlineUser Object passed to the function to reduce query time.
    User must have a valid Voice Configuration applied for this script to return a valuable result
  .PARAMETER DialedNumber
    Optional. Number entered in the Dial Pad. If not provided, the first Voice Route will be chosen.
    If provided, number will be normalised and the effective Dial Plan queried. A matching Route will be found for this number will be queried
    Accepts multiple Numbers to dial - one object returned for each number dialed.
  .EXAMPLE
    Find-TeamsUserVoiceRoute -Identity John@domain.com
    Finds the Voice Route any call for this user may take. First match (Voice Route with the highest priority) will be returned
  .EXAMPLE
    Find-TeamsUserVoiceRoute -Identity John@domain.com -DialledNumber "+1(555) 1234-567"
    Finds the Voice Route a call to the normalised Number +15551234567 for this user may take. The matching Voice Route will be returned
  .EXAMPLE
    Find-TeamsUserVoiceRoute -Identity John@domain.com -DialledNumber "911","+1(555) 1234-567"
    Finds the Voice Route a call to 911 and the normalised Number +15551234567 for this user may take. The matching Voice Route will be returned
    Returns one object for each number as they might be routed through different entities
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    This is a slightly more intricate on Voice routing, enabling comparisons for multiple users.
    Based on and inspired by Test-CsOnlineUserVoiceRouting by Lee Ford - https://www.lee-ford.co.uk
  .COMPONENT
    VoiceConfiguration
  .FUNCTIONALITY
    Voice Routing and Troubleshooting
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsUserVoiceRoute.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsEmergencyCallRoute.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(DefaultParameterSetName = 'UserPrincipalName')]
  [Alias('Find-TeamsUVR')]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory, Position = 0, ParameterSetName = 'Object', ValueFromPipeline)]
    [Object[]]$Object,

    [Parameter(Mandatory, Position = 0, ParameterSetName = 'UserPrincipalName', ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Username(s) to query routing for')]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'Phone Number to be normalised with the Dial Plan')]
    [Alias('Number')]
    [String[]]$DialedNumber

  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting MicrosoftTeams Connection
    if ( -not $script:TFPSST) { $script:TFPSST = Assert-MicrosoftTeamsConnection; if ( -not $script:TFPSST ) { break } }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    #TEST whether Class definition can be used in nested functions
    #region Defining Output Object
    class TFVoiceRouting {
      [string]$UserPrincipalName
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
        [string]$UserPrincipalName,
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
        $this.UserPrincipalName = $UserPrincipalName
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

    # Processing DialedNumber
    if (-not $DialedNumber) {
      Write-Warning -Message 'Parameter DialedNumber was not provided, only basic routing path (first match) is shown'
      $DialedNumber = 15551234567890555
    }
    else {
      # Validating whether at least one of the numbers are supplied as a string
      $NumberAsStrings = 0
      foreach ($Number in $DialedNumber) { if ($Number -match '^0') { $NumberAsStrings++ } }
      if ($DialedNumber.Count -gt 1 -and $NumberAsStrings -lt 1) {
        Write-Warning -Message 'Parameter DialedNumber: Powershell converts numbers to integers, leading zeros are stripped if individual numbers are not wrapped in quotation marks'
      }
    }

    # Preparing Splatting Object
    $parameters = $null
    if ($DialedNumber) {
      $Parameters = @{
        'DialedNumber' = $DialedNumber
      }
    }

    #region Worker Function
    function FindVoiceRoute ($UserObject, $DialedNumber) {
      # Setting Preference Variables according to Upstream settings
      if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
      if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
      if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
      if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
      if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

      Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
      $Id = $($UserObject.UserPrincipalName)
      Write-Verbose -Message "[PROCESS] Finding Voice Route for User '$Id'"
      if ( -not $UserObject.EnterpriseVoiceEnabled ) {
        throw "User '$($UserObject.UserPrincipalName)' - Found, but not enabled for Enterprise Voice"
      }

      # Number
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        "Function: $($MyInvocation.MyCommand.Name) - DialedNumber", ( $DialedNumber | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
      }

      foreach ($Number in $DialedNumber) {
        # Populating User Information
        Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Preparing Voice Routing Object"
        $UserVoiceRouting = $null
        $UserVoiceRouting = [TFVoiceRouting]::new('', '', '', '', '', '', '', '', '', $null, '', '', '')
        $UserVoiceRouting.UserPrincipalName = $UserObject.UserPrincipalName
        $UserVoiceRouting.TenantDialPlan = $UserObject.TenantDialPlan
        $UserVoiceRouting.OnlineVoiceRoutingPolicy = $UserObject.OnlineVoiceRoutingPolicy

        # Processing Number related information
        if ($Number -eq 15551234567890555) { <# Exit Criteria for "no number provided "#> } else {
          Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - User: '$($UserObject.UserPrincipalName)' - Number: '$Number'"
          # Gently harmonising the Number if entered with unwanted characters (deliberately not using any of the Format-CmdLets)
          if ($Number.contains(' ') -or $Number.contains('(') -or $Number.contains(')') -or $Number.contains('-')) {
            Write-Verbose -Message "User '$Id' - Number was normalised to remove special characters (parenthesis, dash and space) to allow correct translation"
            $Number = $Number.replace('(', '').replace(')', '').replace('-', '').replace(' ', '')
          }
          elseif ($Number.contains('+')) {
            Write-Warning -Message "User '$Id' - Number '$Number' - Dialling with a leading plus bypasses the Dial Plan and normalisation!"
          }
          $UserVoiceRouting.DialedNumber = $Number

          # Query Effective Tenant Dial Plan
          $EffectiveTDP = Get-CsEffectiveTenantDialPlan -Identity "$Id"
          $EffectiveTranslation = $EffectiveTDP | Test-CsEffectiveTenantDialPlan -DialedNumber "$Number"
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "Function: $($MyInvocation.MyCommand.Name) - EffectiveTranslation", ( $EffectiveTranslation | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
          }

          if ( $EffectiveTranslation.TranslatedNumber ) {
            Write-Verbose "User '$Id' - Dialed Number '$Number' translated to '$($EffectiveTranslation.TranslatedNumber)'"
            Write-Verbose "User '$Id' - Normalization rule '$($EffectiveTranslation.MatchingRule -replace ';', "`n"))"
            $UserVoiceRouting.MatchingRule = $EffectiveTranslation.MatchingRule.Name
            $UserVoiceRouting.MatchingPattern = $EffectiveTranslation.MatchingRule.Pattern
            $UserVoiceRouting.TranslatedNumber = $EffectiveTranslation.TranslatedNumber
          }
          else {
            $UserVoiceRouting.TranslatedNumber = $Number
          }
          $VoiceRouteNumber = $UserVoiceRouting.TranslatedNumber

          if ( $UserObject.TenantDialPlan ) {
            #NOTE In MicrosoftTeams v2.5.0, policies are now nested Objects!
            try {
              $TDP = (Get-CsTenantDialPlan $($UserObject.TenantDialPlan) -ErrorAction Stop).NormalizationRules | Where-Object Name -EQ $UserVoiceRouting.MatchingRule
            }
            catch {
              if ( $UserObject.TenantDialPlan.Name ) {
                $TDP = (Get-CsTenantDialPlan $($UserObject.TenantDialPlan.Name)).NormalizationRules | Where-Object Name -EQ $UserVoiceRouting.MatchingRule
              }
            }
          }
          if ( $UserObject.DialPlan ) {
            $DP = (Get-CsDialPlan $($UserObject.DialPlan)).NormalizationRules | Where-Object Name -EQ $UserVoiceRouting.MatchingRule
          }
          else {
            $DP = (Get-CsDialPlan $($UserObject.UsageLocation)).NormalizationRules | Where-Object Name -EQ $UserVoiceRouting.MatchingRule
          }
          $UserVoiceRouting.EffectiveDialPlan = if ( $TDP ) { $UserObject.TenantDialPlan } elseif ( $DP ) { $UserObject.DialPlan } else {}

          # Warning / Caveat for Emergency Services Numbers
          if ( $Number -match '^(000|1(\d{2})|9(\d{2})|\d{1}11)$' ) {
            Write-Warning -Message 'Emergency Services Number discovered! Route is calculated as-if routed through Online Voice Routing Policy.'
            Write-Information 'INFO:    The actual route for Emergency Services Calls depends on the effective Emergency Call Routing Policy (if any!)'
            <# Commented out as no longer valid:
            # Status of matching Dial Plan
            if ( $UserVoiceRouting.MatchingRule ) {
              Write-Warning 'Effective Dial Plan - The number provided is matched - This bypasses Emergency Call Routing Policies. This call is most likely routed through the Online Voice Routing Policy'
            }
            else {
              Write-Verbose -Message 'Effective Dial Plan - The number provided is not matched - If configured, Emergency Call Routing Policies may be in effect.' -Verbose
            }
            #>
            # Status of (statically assigned) Emergency Call Routing Policy
            if ( $UserObject.EmergencyCallRoutingPolicy ) {
              Write-Verbose -Message "Emergency Call Routing Policy - Policy assigned statically (directly to the User): '$($UserObject.EmergencyCallRoutingPolicy)'" -Verbose
              $EmergencyNumbers = (Get-CsTeamsEmergencyCallRoutingPolicy -Identity "$($UserObject.EmergencyCallRoutingPolicy)").EmergencyNumbers
              if ( $Number -in $EmergencyNumbers.EmergencyDialMask -or $Number -in $EmergencyNumbers.EmergencyDialString ) {
                Write-Verbose -Message "The Number '$Number' is a configured Emergency Services Number in this policy" -Verbose
              }
            }
            else {
              Write-Verbose -Message 'Emergency Call Routing Policy - Not assigned statically (to the User) but may be assigned dynamically (via Subnet)' -Verbose
            }
            Write-Verbose -Message 'This Cmdlet cannot consider make an accurate statement for how this call may be routed without additional information (Network Site). Please run Find-TeamsEmergencyCallRoute for details.' -Verbose
          }
        }

        # Voice Routing
        if ($UserObject.OnlineVoiceRoutingPolicy) {
          Write-Verbose "User '$Id' - Querying Voice Routing Path with Online Voice Routing Policy '$($UserObject.OnlineVoiceRoutingPolicy)'"
          #NOTE In MicrosoftTeams v2.5.0, policies are now nested Objects!
          try {
            $OPUs = (Get-CsOnlineVoiceRoutingPolicy -Identity $UserObject.OnlineVoiceRoutingPolicy -ErrorAction Stop).OnlinePstnUsages
          }
          catch {
            if ( $UserObject.OnlineVoiceRoutingPolicy.Name ) {
              $OPUs = (Get-CsOnlineVoiceRoutingPolicy -Identity $UserObject.OnlineVoiceRoutingPolicy.Name).OnlinePstnUsages
            }
          }

          if ($OPUs) {
            [System.Collections.ArrayList]$VoiceRoutes = @()
            foreach ($OPU in $OPUs) {
              $VoiceRoutes += Get-CsOnlineVoiceRoute | Where-Object { $_.OnlinePstnUsages -contains $OPU } | Select-Object *, @{label = 'PSTNUsage'; Expression = { $OPU } }
            }
            if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
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
                  Write-Verbose "OVP '$($UserObject.OnlineVoiceRoutingPolicy)' - OPU '$($UserVoiceRouting.OnlinePstnUsage)' - Matching Voice Route(s): $($UserVoiceRouting.MatchedVoiceRoutes)"

                  # Selecting Voice Route
                  $UsedVoiceRoute = $MatchedVoiceRoutesByPriority | Select-Object -First 1
                }
                else {
                  Write-Warning -Message "OVP '$($UserObject.OnlineVoiceRoutingPolicy)' - No Online Voice Routes have been found matching Number '$($VoiceRouteNumber)'"
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
              Write-Warning -Message "OVP '$($UserObject.OnlineVoiceRoutingPolicy)' - No Online Voice Routes have been found"
            }
          }
          else {
            Write-Warning -Message "OVP '$($UserObject.OnlineVoiceRoutingPolicy)' - No Online PSTN Usages have been found"
          }
        }
        else {
          Write-Warning -Message "User '$Id' - No OnlineVoiceRoutingPolicy assigned"
        }

        Write-Output $UserVoiceRouting
      } #foreach DialedNumber
    }
    #endregion
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    switch ($PSCmdlet.ParameterSetName) {
      'UserprincipalName' {
        foreach ($User in $UserPrincipalName) {
          Write-Verbose -Message "[PROCESS] Processing '$User'"
          try {
            #NOTE Call placed without the Identity Switch to make remoting call and receive object in tested format (v2.5.0 and higher)
            #$CsUser = Get-CsOnlineUser -Identity "$User" -WarningAction SilentlyContinue -ErrorAction Stop
            $CsUser = Get-CsOnlineUser "$User" -WarningAction SilentlyContinue -ErrorAction Stop
            #$UserLicense = Get-AzureAdUserLicense "$User"
          }
          catch {
            Write-Error "User '$User' not found" -Category ObjectNotFound
            continue
          }
          FindVoiceRoute -UserObject $CsUser @Parameters
        }
      }
      'Object' {
        foreach ($O in $Object) {
          Write-Verbose -Message "[PROCESS] Processing provided CsOnlineUser Object for '$($O.UserPrincipalName)'"
          #$UserLicense = Get-AzureAdUserLicense "$($O.UserPrincipalName)"
          FindVoiceRoute -UserObject $O @Parameters
        }
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Find-TeamsUserVoiceRoute