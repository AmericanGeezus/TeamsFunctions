# Module:   TeamsFunctions
# Function: VoiceRouting
# Author:   David Eberhardt
# Updated:  28-DEC-2020
# Status:   Live

#TODO EXPAND: Make DialedNumber an Array? (ForEach Number, run everything?)


function Find-TeamsUserVoiceRoute {
  <#
  .SYNOPSIS
    Returns Voice Route for a User and a dialed number
  .DESCRIPTION
    Returns a custom object detailing voice routing information for a User
    If a Dialed Number is provided, also normalises the number and returns the effective Tenant Dial Plan
  .PARAMETER UserPrincipalName
    Required. Username or UserPrincipalname of the User to query Online Voice Routing Policy and Tenant Dial Plan
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
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [Alias('Find-TeamsUVR')]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Username(s) to query routing for')]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'Phone Number to be normalised with the Dial Plan')]
    [Alias('Number')]
    [String[]]$DialedNumber

  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

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

    if (-not $DialedNumber) {
      Write-Warning -Message 'Parameter DialedNumber was not provided, only basic routing path (first match) is shown'
      $DialedNumber = 15551234567890555
    }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($Id in $UserPrincipalName) {
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
      $UserVoiceRoutingPrep = $null
      $UserVoiceRoutingPrep = [TFVoiceRouting]::new('', '', '', '', '', '', '', '', '', $null, '', '', '')
      $UserVoiceRoutingPrep.UserPrincipalName = $User.UserPrincipalName
      $UserVoiceRoutingPrep.TenantDialPlan = $User.TenantDialPlan
      $UserVoiceRoutingPrep.OnlineVoiceRoutingPolicy = $User.OnlineVoiceRoutingPolicy

      if ( -not $User.EnterpriseVoiceEnabled ) {
        Write-Warning -Message "User '$Id' - Not enabled for Enterprise Voice"
      }

      # Number
      foreach ($Number in $DialedNumber) {
        Write-Verbose -Message "[PROCESS] Processing '$Id' - Number '$Number'"
        if ($Number -eq 15551234567890555) { <# Exit Criteria for "no number provided "#> } else {
          # Transposing prepared and pre-filled Object from TFVoiceRouting Class
          $UserVoiceRouting = $UserVoiceRoutingPrep

          # Gently harmonising the Number if entered with unwanted characters (deliberately not using any of the Format-CmdLets)
          if ($Number.contains(' ') -or $Number.contains('(') -or $Number.contains(')') -or $Number.contains('-')) {
            Write-Information "User '$Id' - Number was normalised to remove special characters (parenthesis, dash and space) to allow correct translation"
            $Number = $Number.replace('(', '').replace(')', '').replace('-', '').replace(' ', '')
          }
          elseif ($Number.contains('+')) {
            Write-Warning -Message "User '$Id' - Number was dialed with a leading plus, this bypasses the Dial Plan and normalisation!"
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

          if ($EffectiveTDP.EffectiveTenantDialPlanName -match '_(?<content>.*)_') {
            $UserVoiceRouting.EffectiveDialPlan = $matches.content
          }

          # Warning / Caveat for Emergency Services Numbers
          #TEST Warning display and veracity of statements.
          # Alt?: if ( $Number.Contains("911") -or $Number.Contains("112") -or $Number.Contains("000"))
          # Alt?: if ( $Number -eq "911" -or $Number -eq "112" -or $Number -eq "000"))
          # Alt?: if ( '911', '112', '000' -in $Number )
          if ( $Number.matches('911|112|000|1(\d{2})')) {
            Write-Warning -Message "$($MyInvocation.MyCommand) - Emergency Services Number discovered!"
            if ( $UserVoiceRouting.MatchingPattern ) {
              Write-Warning -Message 'Emergency Services Number matched by the Effective Dial Plan. - E-9-1-1 configuration (effective Emergency Call Routing Policy) is most likely bypassed and call potentially routed through OnlineVoiceRoutingPolicy!'
            }
            else {
              Write-Warning -Message 'Emergency Services Number NOT matched by the Effective Dial Plan. - Cmdlet cannot validate configured paths for Emergency Services numbers - Path measured as if routed through OnlineVoiceRoutingPolicy!'
            }
          }
        }

        # Voice Routing
        #TODO Add option to trace EMS calls via ECRP? - would require to establish full E-9-1-1 configuration! Requires Parameter Subnet? Validation of E911 configuration at all?
        if ($User.OnlineVoiceRoutingPolicy) {
          Write-Verbose "User '$Id' - Querying Voice Routing Path with Online Voice Routing Policy '$($User.OnlineVoiceRoutingPolicy)'"
          $OPUs = (Get-CsOnlineVoiceRoutingPolicy -Identity $User.OnlineVoiceRoutingPolicy).OnlinePstnUsages

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
        }
        else {
          Write-Warning -Message "User '$Id' - No OnlineVoiceRoutingPolicy assigned"
        }

        Write-Output $UserVoiceRouting
      } #foreach DialedNumber
    } #foreach Identity

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Find-TeamsUserVoiceRoute