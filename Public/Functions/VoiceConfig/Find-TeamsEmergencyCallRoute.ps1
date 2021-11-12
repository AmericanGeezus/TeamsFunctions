# Module:   TeamsFunctions
# Function: VoiceRouting
# Author:   David Eberhardt
# Updated:  26-JUN-2021
# Status:   RC




function Find-TeamsEmergencyCallRoute {
  <#
  .SYNOPSIS
    Returns Voice Route for a Site or Subnet and a dialed emergency number
  .DESCRIPTION
    Returns a custom object detailing voice routing information for one or more Sites or Subnets and a dialed Emergency number.
    User information also adds validation for static emergency calling options and validates configuration of the users Tenant Dial Plan.
  .PARAMETER UserPrincipalName
    Optional. Username or UserPrincipalname of the User to query Online Voice Routing Policy and Tenant Dial Plan
    User must have a valid Voice Configuration applied for this script to return a valuable result
    If not provided, only dynamic assignment of Emergency Call Routing Policy (through Network Site) is queried.
  .PARAMETER DialedNumber
    Required. Emergency Number as entered in the Dial Pad. The effective Dial Plan is queried as a start.
    Then, application of an Emergency Call Routing Policy is determined through static (User) or dynamic (Site/Subnet) assignment
    Accepts multiple Numbers to dial - one object is returned for each number dialed and each Site or Subnet provided.
  .PARAMETER NetworkSite
    Required for ParameterSet NetworkSite. Name of a Network Site configured in the Network Topology of the Teams Tenant
    One or more exact names (NetworkSiteId) are required.
  .PARAMETER NetworkSubnet
    Required for ParameterSet NetworkSubnet. Name of a Network Subnet configured in the Network Topology of the Teams Tenant
    One or more exact names (Subnet Id) are required to determine the corresponding Network Site(s). Site is used going forward.
  .EXAMPLE
    Find-TeamsEmergencyCallRoute -NetworkSite Bogota -DialedNumber 112
    Finds the route for an emergency call to 112 for the Site Bogota. Only determines dynamic assignments
  .EXAMPLE
    Find-TeamsEmergencyCallRoute -NetworkSite Bogota -DialedNumber 112 -UserPrincipalName John@domain.com
    Finds the route for an emergency call to 112 for the Site Bogota for the User John@domain.com.
    Determines dynamic assignments (ECRP assigned to Site) as well as static assignments (ECRP assigned to user)
  .EXAMPLE
    Find-TeamsEmergencyCallRoute -NetworkSubnet 10.1.15.0 -DialedNumber 112
    Finds the route for an emergency call to 112 for the Site in which the Subnet 10.1.15.0 is linked in
  .EXAMPLE
    Find-TeamsEmergencyCallRoute -NetworkSubnet Bogota -DialedNumber 112 -UserPrincipalName John@domain.com
    Finds the route for an emergency call to 112 for the Site in which the Subnet 10.1.15.0 is linked in for the User John@domain.com.
    Determines dynamic assignments (ECRP assigned to Site) as well as static assignments (ECRP assigned to user)
  .EXAMPLE
    Find-TeamsEmergencyCallRoute -NetworkSite Bogota,Lima,Quito -DialedNumber 112
    Finds the route for an emergency call to 112 for the Sites Bogota, Lima & Quito.
    Only determines dynamic assignments
  .EXAMPLE
    Find-TeamsEmergencyCallRoute -NetworkSubnet 10.1.15.0,10.1.20.0,10.1.27.0 -DialedNumber 112
    Finds the route for an emergency call to 112 for the Sites each of these subnets are linked in.
    Only determines dynamic assignments
  .EXAMPLE
    Find-TeamsEmergencyCallRoute -NetworkSite Bogota,Lima,Quito -DialedNumber 112 -UserPrincipalName John@domain.com
    Finds the route for an emergency call to 112 for the Sites Bogota, Lima & Quito for the User John@domain.com.
    Determines dynamic assignments (ECRP assigned to Site) as well as static assignments (ECRP assigned to user)
  .EXAMPLE
    Find-TeamsEmergencyCallRoute -NetworkSubnet 10.1.15.0,10.1.20.0,10.1.27.0 -DialedNumber 112 -UserPrincipalName John@domain.com
    Finds the route for an emergency call to 112 for the Sites each of these subnets are linked in for the User John@domain.com.
    Determines dynamic assignments (ECRP assigned to Site) as well as static assignments (ECRP assigned to user)
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    This is an evolution to Find-TeamsUserVoiceRouting, focusing solely on Emergency Services calls.
    Inspired by Test-CsOnlineUserVoiceRouting by Lee Ford - https://www.lee-ford.co.uk

    Emergency Call Routing can be performed multiple ways. This CmdLet tries to determine the effective state for the
    given combination of Dialed Emergency Number
  .COMPONENT
    VoiceConfiguration
  .FUNCTIONALITY
    Voice Routing for Emergency calls and Troubleshooting
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsEmergencyCallRoute.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsUserVoiceRoute.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding( DefaultParametersetName = 'Site' )]
  [Alias('Find-TeamsECR')]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Username(s) to query routing for')]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(Mandatory, ValueFromPipelineByPropertyName, HelpMessage = 'Phone Number to be normalised with the Dial Plan')]
    [Alias('Number')]
    [String]$DialedNumber,

    [Parameter(Mandatory, ParametersetName = 'Site', ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Network Site for the User')]
    [Alias('Site')]
    [String[]]$NetworkSite,

    [Parameter(Mandatory, ParametersetName = 'Subnet', ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Network Subnet for the User')]
    [Alias('Subnet')]
    [String[]]$NetworkSubnet

  )

  begin {
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if ( -not $script:TFPSST) { $script:TFPSST = Assert-MicrosoftTeamsConnection; if ( -not $script:TFPSST ) { break } }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    #region Defining Output Object
    class TFEmergencyVoiceRouting {
      [string]$DialedNumber
      [string]$TenantDialPlan
      [string]$EffectiveDialPlan
      [string]$MatchingRule
      [string]$MatchingPattern
      [string]$TranslatedNumber
      [string]$NetworkSite
      [string]$UserPrincipalName
      [string]$SiteEmergencyCallingPolicy
      [string]$UserEmergencyCallingPolicy
      [string]$EffectiveEmergencyCallingPolicy
      [string]$SiteEmergencyCallRoutingPolicy
      [string]$UserEmergencyCallRoutingPolicy
      [string]$EffectiveEmergencyCallRoutingPolicy
      [string]$OnlineVoiceRoutingPolicy
      [string]$EffectiveEmergencyDialString
      [string]$MatchedEmergencyDialMask
      [string]$NetworkPathTaken
      [string]$OnlinePstnUsage
      $MatchedVoiceRoutes #Can be a string or an Object
      [string]$OnlineVoiceRoute
      [string]$OnlinePstnGateway
      $OnlinePstnGatewayPidfLoSupported #Can be a string or an Object
      [string]$NumberPattern

      TFEmergencyVoiceRouting (
        [string]$DialedNumber,
        [string]$TenantDialPlan,
        [string]$EffectiveDialPlan,
        [string]$MatchingRule,
        [string]$MatchingPattern,
        [string]$TranslatedNumber,
        [string]$NetworkSite,
        [string]$UserPrincipalName,
        [string]$SiteEmergencyCallingPolicy,
        [string]$UserEmergencyCallingPolicy,
        [string]$EffectiveEmergencyCallingPolicy,
        [string]$SiteEmergencyCallRoutingPolicy,
        [string]$UserEmergencyCallRoutingPolicy,
        [string]$EffectiveEmergencyCallRoutingPolicy,
        [string]$OnlineVoiceRoutingPolicy,
        [string]$EffectiveEmergencyDialString,
        [string]$MatchedEmergencyDialMask,
        [string]$NetworkPathTaken,
        [string]$OnlinePstnUsage,
        $MatchedVoiceRoutes,
        [string]$OnlineVoiceRoute,
        [string]$OnlinePstnGateway,
        [bool]$OnlinePstnGatewayPidfLoSupported,
        [string]$NumberPattern

      ) {
        $this.DialedNumber = $DialedNumber
        $this.TenantDialPlan = $TenantDialPlan
        $this.EffectiveDialPlan = $EffectiveDialPlan
        $this.MatchingRule = $MatchingRule
        $this.MatchingPattern = $MatchingPattern
        $this.TranslatedNumber = $TranslatedNumber
        $this.NetworkSite = $NetworkSite
        $this.UserPrincipalName = $UserPrincipalName
        $this.SiteEmergencyCallingPolicy = $SiteEmergencyCallingPolicy
        $this.UserEmergencyCallingPolicy = $UserEmergencyCallingPolicy
        $this.EffectiveEmergencyCallingPolicy = $EffectiveEmergencyCallingPolicy
        $this.SiteEmergencyCallRoutingPolicy = $SiteEmergencyCallRoutingPolicy
        $this.UserEmergencyCallRoutingPolicy = $UserEmergencyCallRoutingPolicy
        $this.EffectiveEmergencyCallRoutingPolicy = $EffectiveEmergencyCallRoutingPolicy
        $this.OnlineVoiceRoutingPolicy = $OnlineVoiceRoutingPolicy
        $this.EffectiveEmergencyDialString = $EffectiveEmergencyDialString
        $this.MatchedEmergencyDialMask = $MatchedEmergencyDialMask
        $this.NetworkPathTaken = $NetworkPathTaken
        $this.OnlinePstnUsage = $OnlinePstnUsage
        $this.MatchedVoiceRoutes = $MatchedVoiceRoutes
        $this.OnlineVoiceRoute = $OnlineVoiceRoute
        $this.OnlinePstnGateway = $OnlinePstnGateway
        $this.OnlinePstnGatewayPidfLoSupported = $OnlinePstnGatewayPidfLoSupported
        $this.NumberPattern = $NumberPattern
      }
    }
    #endregion

    if (-not $UserPrincipalName) {
      Write-Verbose -Message 'Parameter UserPrincipalName was not provided, only dynamic assignment of Emergency Call Routing Policy can be queried'
      $UserPrincipalName = 'John@domain.com'
    }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    #region Preparation - Determining Network Sites from Site Names or Subnet Ids
    [System.Collections.ArrayList]$NetworkSites = @()
    switch ( $PSCmdlet.ParameterSetName ) {
      'Site' {
        Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - NetworkSites"
        foreach ($Site in $NetworkSite) {
          try {
            $SiteObject = $null
            $SiteObject = Get-CsTenantNetworkSite -Identity "$Site" -ErrorAction Stop
            if ( -not $SiteObject ) {
              throw
            }
            else {
              Write-Verbose -Message "$($MyInvocation.MyCommand) - NetworkSites: Site '$($SiteObject.NetworkSiteID)' found"
              $NetworkSites += $SiteObject
            }
          }
          catch {
            Write-Error -Message "Site '$Site' not found" -Category ResourceUnavailable
            continue
          }
        }
      }
      'Subnet' {
        Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - NetworkSubnets"
        foreach ($Subnet in $NetworkSubnet) {
          try {
            $SubnetObject = $null
            $SubnetObject = Get-CsTenantNetworkSubnet -Identity "$Subnet" -ErrorAction Stop
            if ( -not $SubnetObject ) {
              throw
            }
            else {
              Write-Verbose -Message "$($MyInvocation.MyCommand) - NetworkSubnets: Subnet '$($SubnetObject.Identity) found linked to Site '$($SiteObject.NetworkSiteId)'"
              $SiteObject = $null
              $SiteObject = Get-CsTenantNetworkSite -Identity "$($SubnetObject.NetworkSiteId)" -ErrorAction Stop
              Write-Verbose -Message "$($MyInvocation.MyCommand) - NetworkSubnets: Site '$($SiteObject.NetworkSiteId) found"
              $NetworkSites += $SiteObject
            }
          }
          catch {
            Write-Error -Message "Subnet '$Subnet' not found" -Category ResourceUnavailable
            continue
          }
        }
      }
    }

    # Snippets for Scripts - Change $Parameters to what suits your needs
    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
      "Function: $($MyInvocation.MyCommand.Name): Found NetworkSites for provided Sites or Subnets:", ($NetworkSites | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }
    #endregion

    foreach ($Site in $NetworkSites) {
      #region Preparing Object
      Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Preparing Emergency Voice Routing Object"
      $EmergencyCallRoutingObject = $null
      $EmergencyCallRoutingObject = [TFEmergencyVoiceRouting]::new('', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', $null, '', '', $null, '')
      $EmergencyCallRoutingObject.NetworkSite = $Site.NetworkSiteId
      $EmergencyCallRoutingObject.SiteEmergencyCallRoutingPolicy = $Site.EmergencyCallRoutingPolicy
      $EmergencyCallRoutingObject.SiteEmergencyCallingPolicy = $Site.EmergencyCallingPolicy
      $EmergencyCallRoutingObject.NetworkSite = $Site.NetworkSiteId
      #endregion

      Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Processing Site: '$($Site.NetworkSiteId)'"
      foreach ($Number in $DialedNumber) {
        Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Processing Site: '$($Site.NetworkSiteId)' - Number: $Number"
        #region DialedNumber
        # Gently harmonising the Number if entered with unwanted characters (deliberately not using any of the Format-CmdLets)
        if ($Number.contains(' ') -or $Number.contains('(') -or $Number.contains(')') -or $Number.contains('-')) {
          Write-Verbose -Message "User '$UPN' - Number was normalised to remove special characters (parenthesis, dash and space) to allow correct translation"
          $Number = $Number.replace('(', '').replace(')', '').replace('-', '').replace(' ', '')
        }
        elseif ($Number.contains('+')) {
          Write-Warning -Message "User '$UPN' - Number '$Number' - Dialling with a leading plus bypasses the Dial Plan and normalisation!"
        }
        # Validating Number is an Emergency Number
        if ( $Number -notmatch '^(000|1(\d{2})|9(\d{2})|\d{1}11)$' ) {
          Write-Verbose -Message "Number may not be an Emergency Services Number! Number expected to match: '000', '1xx', '9xx' or 'x11' which should cover 95% of all public emergency numbers. This is informational only." -Verbose
        }
        $EmergencyCallRoutingObject.DialedNumber = $Number
        #endregion

        foreach ($UPN in $UserPrincipalName) {
          #region Querying Users and populating related User information
          if ($UPN -eq 'John@domain.com') {
            <# Exit Criteria for "no user provided "#>
            # Populating required Parameters for further queries
            $VoiceRouteNumber = $Number
            Write-Verbose -Message "NetworkSite '$($Site.NetworkSiteId)' - Number used to find Voice Route match: '$VoiceRouteNumber'"
          }
          else {
            Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Processing UserPrincipalName: '$UPN'"
            #region User Information
            try {
              $CsUser = $null
              #NOTE Call placed without the Identity Switch to make remoting call and receive object in tested format (v2.5.0 and higher)
              #$CsUser = Get-CsOnlineUser -Identity "$UPN" -WarningAction SilentlyContinue -ErrorAction Stop
              $CsUser = Get-CsOnlineUser "$UPN" -WarningAction SilentlyContinue -ErrorAction Stop
              if ( -not $CsUser ) {
                throw "User '$UPN' not found"
              }
              if ( -not $CsUser.EnterpriseVoiceEnabled ) {
                throw "User '$($CsUser.UserPrincipalName)' - Found, but not enabled for Enterprise Voice"
              }
            }
            catch {
              Write-Error -Message "$($_.Exception.Message)" -Category ResourceUnavailable
              continue
            }

            # Populating User Information
            Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Processing Site: '$($Site.NetworkSiteId)' - Number: $Number - User: '$($CsUser.UserPrincipalName)'"
            $EmergencyCallRoutingObject.UserPrincipalName = $CsUser.UserPrincipalName
            $EmergencyCallRoutingObject.TenantDialPlan = $CsUser.TenantDialPlan
            $EmergencyCallRoutingObject.OnlineVoiceRoutingPolicy = $CsUser.OnlineVoiceRoutingPolicy
            $EmergencyCallRoutingObject.UserEmergencyCallRoutingPolicy = $CsUser.EmergencyCallRoutingPolicy
            $EmergencyCallRoutingObject.UserEmergencyCallingPolicy = $CsUser.EmergencyCallingPolicy
            #endregion

            #region Query Effective Tenant Dial Plan
            Write-Verbose -Message "User: '$($CsUser.UserPrincipalName)' - Determining Effective DialPlan"
            $EffectiveTDP = Get-CsEffectiveTenantDialPlan -Identity "$($CsUser.UserPrincipalName)"
            $EffectiveTranslation = $EffectiveTDP | Test-CsEffectiveTenantDialPlan -DialedNumber "$Number"
            if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
              "Function: $($MyInvocation.MyCommand.Name) - EffectiveTranslation", ( $EffectiveTranslation | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
            }

            if ( $EffectiveTranslation.TranslatedNumber ) {
              Write-Verbose "User '$($CsUser.UserPrincipalName)' - Dialed Number '$Number' translated to '$($EffectiveTranslation.TranslatedNumber)'"
              Write-Verbose "User '$($CsUser.UserPrincipalName)' - Normalization rule '$($EffectiveTranslation.MatchingRule -replace ';', "`n"))"
              $EmergencyCallRoutingObject.MatchingRule = $EffectiveTranslation.MatchingRule.Name
              $EmergencyCallRoutingObject.MatchingPattern = $EffectiveTranslation.MatchingRule.Pattern
              $EmergencyCallRoutingObject.TranslatedNumber = $EffectiveTranslation.TranslatedNumber
            }
            else {
              $EmergencyCallRoutingObject.TranslatedNumber = $Number
            }
            $VoiceRouteNumber = $EmergencyCallRoutingObject.TranslatedNumber
            Write-Verbose -Message "User: '$($CsUser.UserPrincipalName)' - Number used to find Voice Route match: '$VoiceRouteNumber'"

            if ( $CsUser.TenantDialPlan ) {
              #NOTE In MicrosoftTeams v2.5.0, policies are now nested Objects!
              try {
                $TDP = (Get-CsTenantDialPlan $($CsUser.TenantDialPlan)).NormalizationRules | Where-Object Name -EQ $UserVoiceRouting.MatchingRule -ErrorAction Stop
              }
              catch {
                if ( $CsUser.TenantDialPlan.Name ) {
                  $TDP = (Get-CsTenantDialPlan $($CsUser.TenantDialPlan.Name)).NormalizationRules | Where-Object Name -EQ $UserVoiceRouting.MatchingRule
                }
              }
            }
            $DP = (Get-CsDialPlan $($CsUser.DialPlan)).NormalizationRules | Where-Object Name -EQ $EmergencyCallRoutingObject.MatchingRule
            $EmergencyCallRoutingObject.EffectiveDialPlan = if ( $TDP ) { $CsUser.TenantDialPlan } elseif ( $DP ) { $CsUser.DialPlan } else {}
            #endregion
          }
          #endregion

          #region Determining Effective EmergencyCallRoutingPolicy & EmergencyCallingPolicy
          # Effective Call Routing Policy
          if ( $CsUser.EmergencyCallRoutingPolicy ) {
            $UserECRP = Get-CsTeamsEmergencyCallRoutingPolicy $CsUser.EmergencyCallRoutingPolicy
            if ( $DialedNumber -in $UserECRP.EmergencyNumbers.EmergencyDialMask -or $DialedNumber -in $UserECRP.EmergencyNumbers.EmergencyDialString ) {
              $EmergencyCallRoutingObject.EffectiveEmergencyCallRoutingPolicy = $CsUser.EmergencyCallRoutingPolicy
              $EmergencyCallRoutingObject.NetworkPathTaken = 'UserEmergencyCallRoutingPolicy'
            }
          }
          if ( $Site.EmergencyCallRoutingPolicy ) {
            $SiteECRP = Get-CsTeamsEmergencyCallRoutingPolicy $Site.EmergencyCallRoutingPolicy
            if ( $DialedNumber -in $SiteECRP.EmergencyNumbers.EmergencyDialMask -or $DialedNumber -in $SiteECRP.EmergencyNumbers.EmergencyDialString ) {
              $EmergencyCallRoutingObject.EffectiveEmergencyCallRoutingPolicy = $Site.EmergencyCallRoutingPolicy
            }
          }
          $EmergencyCallRoutingObject.NetworkPathTaken = 'SiteEmergencyCallRoutingPolicy'

          # Effective Calling Policy
          $EmergencyCallRoutingObject.EffectiveEmergencyCallingPolicy = if ( $Site.EmergencyCallingPolicy ) { $Site.EmergencyCallingPolicy }
          elseif ($CsUser.EmergencyCallingPolicy) { $CsUser.EmergencyCallingPolicy } else { $null }
          #endregion

          #region NetworkPathTaken & effective OPU
          $OPUs = $null
          if ( $EmergencyCallRoutingObject.EffectiveEmergencyCallRoutingPolicy ) {
            $EmergencyNumbers = $null
            $EmergencyNumbers = switch ( $EmergencyCallRoutingObject.NetworkPathTaken ) {
              'SiteEmergencyCallRoutingPolicy' { $SiteECRP.EmergencyNumbers }
              'UserEmergencyCallRoutingPolicy' { $UserECRP.EmergencyNumbers }
            }
            $EmergencyNumber = $null
            $EmergencyNumber = $EmergencyNumbers | Where-Object EmergencyDialString -EQ $DialledNumber
            if ( -not $EmergencyNumber ) {
              $EmergencyNumber = $EmergencyNumbers | Where-Object EmergencyDialMask -Like "*$DialledNumber*"
            }
            if ( $EmergencyNumber ) {
              Write-Verbose -Message "Effective Emergency Call Routing Policy '$($EmergencyCallRoutingObject.EffectiveEmergencyCallRoutingPolicy)' - The Number '$Number' is a configured Emergency Services Number"
            }
            else {
              $EmergencyCallRoutingObject.NetworkPathTaken = 'OnlineVoiceRoutingPolicy'
            }

            # Populating EffectiveEmergencyDialString & MatchedEmergencyDialMask
            if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
              "Function: $($MyInvocation.MyCommand.Name): EmergencyNumber:", ($EmergencyNumber | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
            }
            if ( $EmergencyNumber ) {
              $EmergencyCallRoutingObject.EffectiveEmergencyDialString = $EmergencyNumber.EmergencyDialString
              $EmergencyCallRoutingObject.MatchedEmergencyDialMask = $EmergencyNumber.EmergencyDialMask
              $OPUs = $EmergencyNumber.OnlinePstnUsage
            }
            else {
              Write-Verbose 'Effective Emergency Call Routing Policy: None - No match for Emergency Number found'
            }
          }
          else {
            $EmergencyCallRoutingObject.NetworkPathTaken = 'OnlineVoiceRoutingPolicy'
          }

          # Catching ECRP defined, but no match in either Site or User Policy
          if ( $EmergencyCallRoutingObject.NetworkPathTaken -eq 'OnlineVoiceRoutingPolicy' ) {
            if ( $EmergencyCallRoutingObject.OnlineVoiceRoutingPolicy ) {
              $EmergencyCallRoutingObject.NetworkPathTaken = 'OnlineVoiceRoutingPolicy'
              Write-Verbose -Message 'Network Path Taken: OnlineVoiceRoutingPolicy - Emergency Call Routing Policy is not triggered'
              $OPUs = (Get-CsOnlineVoiceRoutingPolicy -Identity $CsUser.OnlineVoiceRoutingPolicy).OnlinePstnUsages
            }
            else {
              if ( $EmergencyCallRoutingObject.UserPrincipalName ) {
                $EmergencyCallRoutingObject.NetworkPathTaken = 'None'
                Write-Verbose -Message 'Network Path Taken: None - User has no OnlineVoiceRoutingPolicy assigned!'
              }
              else {
                $EmergencyCallRoutingObject.NetworkPathTaken = 'Unknown'
                Write-Verbose -Message 'Network Path Taken: Unknown - No User data'
              }
              $OPUs = $null
            }
          }
          #endregion

          #region Voice Routing (dependent on determined NetworkPathTaken)
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

              $MatchedVoiceRoutes = $VoiceRoutes | Where-Object { $VoiceRouteNumber -match $_.NumberPattern }
              if ( $MatchedVoiceRoutes ) {
                # Selecting PSTN Usage of the first Voice Route
                $EmergencyCallRoutingObject.OnlinePstnUsage = $MatchedVoiceRoutes[0].PSTNUsage

                # Populating MatchedVoiceRoutes
                $MatchedVoiceRoutesByPriority = $MatchedVoiceRoutes | Where-Object { $_.PSTNUsage -eq $EmergencyCallRoutingObject.OnlinePstnUsage } | Sort-Object Priority
                $EmergencyCallRoutingObject.MatchedVoiceRoutes = $MatchedVoiceRoutesByPriority.Name -join (', ')
                Write-Verbose "Routing Policy - OPU '$($EmergencyCallRoutingObject.OnlinePstnUsage)' - Matching Voice Route(s): $($EmergencyCallRoutingObject.MatchedVoiceRoutes)"

                # Selecting Voice Route
                $UsedVoiceRoute = $MatchedVoiceRoutesByPriority | Select-Object -First 1
              }
              else {
                Write-Warning -Message "Routing Policy - No Online Voice Routes have been found matching Number '$($VoiceRouteNumber)'"
              }

              # Populating Parameters based on selection
              $EmergencyCallRoutingObject.OnlineVoiceRoute = $UsedVoiceRoute.Name
              $EmergencyCallRoutingObject.NumberPattern = $UsedVoiceRoute.NumberPattern
              $EmergencyCallRoutingObject.OnlinePstnGateway = $($UsedVoiceRoute.OnlinePstnGatewayList -join (', '))

              # Determining PIDF-LO Support
              foreach ($MGW in $UsedVoiceRoute.OnlinePstnGatewayList ) {
                $PidfLoSupported = (Get-CsOnlinePSTNGateway -Identity $MGW).PidfLoSupported
                if (-not $PidfLoSupported) {
                  Write-Warning -Message "Online Pstn Gateway '$MGW': Gateway not configured to transmit PIDF-LO information: The .xml body payload is not sent to the SBC with the location details of the user."
                }
                $OnlinePstnGatewayPidfLoSupported += $PidfLoSupported
              }
              $EmergencyCallRoutingObject.OnlinePstnGatewayPidfLoSupported = $OnlinePstnGatewayPidfLoSupported
            }
            else {
              Write-Warning -Message 'Routing Policy - No Online Voice Routes have been found'
            }
          }
          else {
            Write-Warning -Message 'Routing Policy - No Online PSTN Usages have been found'
          }
          #endregion


          # Output
          Write-Output $EmergencyCallRoutingObject
        } #foreach Users
      } #foreach DialedNumber
    } #foreach NetworkSites
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Find-TeamsEmergencyCallRoute