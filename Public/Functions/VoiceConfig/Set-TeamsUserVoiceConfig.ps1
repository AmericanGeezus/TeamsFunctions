# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live

#TODO Requirement capture for configuration for OperatorConnect needed


function Set-TeamsUserVoiceConfig {
  <#
  .SYNOPSIS
    Enables a User to consume Voice services in Teams (Pstn breakout)
  .DESCRIPTION
    Enables a User for Direct Routing, Microsoft Callings or for use in Call Queues (EvOnly)
    User requires a Phone System License in any case.
  .PARAMETER UserPrincipalName
    Required. UserPrincipalName (UPN) of the User to change the configuration for
  .PARAMETER DirectRouting
    Optional (Default Parameter Set). Limits the Scope to enable an Object for DirectRouting
  .PARAMETER CallingPlans
    Required for CallingPlans. Limits the Scope to enable an Object for CallingPlans
  .PARAMETER PhoneNumber
    Optional. Phone Number in E.164 format to be assigned to the User.
    For proper configuration a PhoneNumber is required. Without it, the User will not be able to make or receive calls.
    This script does not enforce all Parameters and is intended to validate and configure one or all Parameters.
    For enforced ParameterSet please call New-TeamsUserVoiceConfig
    For DirectRouting, will populate the OnPremLineUri
    For CallingPlans, will populate the TelephoneNumber (must be present in the Tenant)
  .PARAMETER OnlineVoiceRoutingPolicy
    Optional. Required for DirectRouting. Assigns an Online Voice Routing Policy to the User
  .PARAMETER TenantDialPlan
    Optional. Optional for DirectRouting. Assigns a Tenant Dial Plan to the User
  .PARAMETER CallingPlanLicense
    Optional. Optional for CallingPlans. Assigns a Calling Plan License to the User.
    Must be one of the set: InternationalCallingPlan DomesticCallingPlan DomesticCallingPlan120 CommunicationCredits DomesticCallingPlan120b
  .PARAMETER PassThru
    Optional. Displays Object after action.
  .PARAMETER Force
    By default, this script only applies changed elements. Force overwrites configuration regardless of current status.
    Additionally Suppresses confirmation inputs except when $Confirm is explicitly specified
  .PARAMETER WriteErrorLog
    If Errors are encountered, writes log to C:\Temp
  .EXAMPLE
    Set-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -CallingPlans -PhoneNumber "+15551234567" -CallingPlanLicense DomesticCallingPlan
    Provisions John@domain.com for Calling Plans with the Calling Plan License and Phone Number provided
  .EXAMPLE
    Set-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -CallingPlans -PhoneNumber "+15551234567" -WriteErrorLog
    Provisions John@domain.com for Calling Plans with the Phone Number provided (requires Calling Plan License to be assigned already)
    If Errors are encountered, they are written to C:\Temp as well as on screen
  .EXAMPLE
    Set-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -DirectRouting -PhoneNumber "+15551234567" -OnlineVoiceRoutingPolicy "O_VP_AMER"
    Provisions John@domain.com for DirectRouting with the Online Voice Routing Policy and Phone Number provided
  .EXAMPLE
    Set-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -PhoneNumber "+15551234567" -OnlineVoiceRoutingPolicy "O_VP_AMER" -TenantDialPlan "DP-US"
    Provisions John@domain.com for DirectRouting with the Online Voice Routing Policy, Tenant Dial Plan and Phone Number provided
  .EXAMPLE
    Set-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -PhoneNumber "+15551234567" -OnlineVoiceRoutingPolicy "O_VP_AMER"
    Provisions John@domain.com for DirectRouting with the Online Voice Routing Policy and Phone Number provided.
  .INPUTS
    System.String
  .OUTPUTS
    System.Void - Default Behaviour
    System.Object - With Switch PassThru
    System.File - With Switch WriteErrorLog
  .NOTES
    ParameterSet 'DirectRouting' will provision a User to use DirectRouting. Enables User for Enterprise Voice,
    assigns a Number and an Online Voice Routing Policy and optionally also a Tenant Dial Plan. This is the default.
    ParameterSet 'CallingPlans' will provision a User to use Microsoft CallingPlans.
    Enables User for Enterprise Voice and assigns a Microsoft Number (must be found in the Tenant!)
    Optionally can also assign a Calling Plan license prior.
    This script cannot apply PhoneNumbers for OperatorConnect yet
    This script accepts pipeline input as Value (UserPrincipalName) or as Object (UPN, OVP, TDP, PhoneNumber)
    This enables bulk provisioning
  .COMPONENT
    VoiceConfiguration
  .FUNCTIONALITY
    Applying Voice Configuration parameters to a User
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Set-TeamsUserVoiceConfig.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colourful feedback required to emphasise feedback for script executors')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = 'Required for performance. Removed with Disconnect-Me')]
  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'DirectRouting', ConfirmImpact = 'Medium')]
  [Alias('Set-TeamsUVC')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, ValueFromPipeline, HelpMessage = 'UserPrincipalName of the User')]
    [Alias('ObjectId', 'Identity')]
    [string]$UserPrincipalName,

    [Parameter(ParameterSetName = 'DirectRouting', HelpMessage = 'Enables an Object for Direct Routing')]
    [switch]$DirectRouting,

    [Parameter(ParameterSetName = 'DirectRouting', ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Online Voice Routing Policy')]
    [AllowNull()]
    [AllowEmptyString()]
    [Alias('OVP')]
    [string]$OnlineVoiceRoutingPolicy,

    [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Tenant Dial Plan')]
    [AllowNull()]
    [AllowEmptyString()]
    [Alias('TDP')]
    [string]$TenantDialPlan,

    [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'E.164 Number to assign to the Object')]
    [AllowNull()]
    [AllowEmptyString()]
    [Alias('Number', 'LineURI')]
    [string]$PhoneNumber,

    [Parameter(ParameterSetName = 'CallingPlans', Mandatory, HelpMessage = 'Enables an Object for Microsoft Calling Plans')]
    [switch]$CallingPlan,

    [Parameter(ParameterSetName = 'CallingPlans', HelpMessage = 'Calling Plan License to assign to the Object')]
    [ValidateScript( {
        if (-not $global:TeamsFunctionsMSAzureAdLicenses) { $global:TeamsFunctionsMSAzureAdLicenses = Get-AzureAdLicense -WarningAction SilentlyContinue }
        $LicenseParams = ($global:TeamsFunctionsMSAzureAdLicenses | Where-Object LicenseType -EQ 'CallingPlan').ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $LicenseParams) { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] "Parameter 'CallingPlanLicense' must be of the set: $LicenseParams"
        }
      })]
    [ArgumentCompleter( {
        if (-not $global:TeamsFunctionsMSAzureAdLicenses) { $global:TeamsFunctionsMSAzureAdLicenses = Get-AzureAdLicense -WarningAction SilentlyContinue }
        $LicenseParams = ($global:TeamsFunctionsMSAzureAdLicenses | Where-Object LicenseType -EQ 'CallingPlan').ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        $LicenseParams | Sort-Object | ForEach-Object {
          [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "$($LicenseParams.Count) records available")
        }
      })]
    [string[]]$CallingPlanLicense,

    [Parameter(HelpMessage = 'Suppresses confirmation prompt unless -Confirm is used explicitly')]
    [switch]$Force,

    [Parameter(HelpMessage = 'No output is written by default, Switch PassThru will return changed object')]
    [switch]$PassThru,

    [Parameter(HelpMessage = 'Writes a Log File to C:\Temp')]
    [switch]$WriteErrorLog
  ) #param

  begin {
    #break
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Asserting MicrosoftTeams Connection
    if ( -not $script:TFPSST) { $script:TFPSST = Assert-MicrosoftTeamsConnection; if ( -not $script:TFPSST ) { break } }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    #Initialising Counters
    $private:StepsID0, $private:StepsID1 = Get-WriteBetterProgressSteps -Code $($MyInvocation.MyCommand.Definition) -MaxId 1
    $private:ActivityID0 = $($MyInvocation.MyCommand.Name)
    [int] $private:CountID0 = [int] $private:CountID1 = 1

    # Teams Module Caveat
    if ( -not $global:TeamsFunctionsMSTeamsModule) { $global:TeamsFunctionsMSTeamsModule = Get-Module MicrosoftTeams }
    if ( $TeamsFunctionsMSTeamsModule.Version -gt 2.3.1 ) {
      #Write-Warning -Message 'Due to recent changes to Module MicrosoftTeams (v2.5.0 and later), not all functionality could yet be tested, handle with care'
    }

    $RemoveTDP = ( $PSBoundParameters.ContainsKey('TenantDialPlan') -and $null -eq $TenantDialPlan )
    $RemoveOVP = ( $PSBoundParameters.ContainsKey('OnlineVoiceRoutingPolicy') -and $null -eq $OnlineVoiceRoutingPolicy )
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    # Initialising $ErrorLog
    [System.Collections.ArrayList]$ErrorLog = @()

    $ActivityID0 = "'$UserPrincipalName'"
    $StatusID0 = 'Information Gathering'
    #region Querying Identity
    $CurrentOperationID0 = 'Querying User Account (TeamsUserVoiceConfig)'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    try {
      $CsUser = Get-TeamsUserVoiceConfig -UserPrincipalName "$UserPrincipalName" -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
      $IsEVenabled = $CsUser.EnterpriseVoiceEnabled
      $IsPSsuccess = $CsUser.PhoneSystemStatus.Contains('Success')
      $ObjectType = $CsUser.ObjectType
    }
    catch {
      Write-Error "'$UserPrincipalName' not found: $($_.Exception.Message)" -Category ObjectNotFound
      $ErrorLog += $_.Exception.Message
      return $ErrorLog
    }
    #endregion

    $StatusID0 = 'Establishing User Object Readiness'
    #region Establishing User Object Readiness
    $Operation = 'Asserting Callable Entity'
    if ( -not $IsEVenabled -or -not $IsPSsuccess) {
      #if ($Force) {
      $CurrentOperationID0 = "$Operation`: Asserting Callable Entity"
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      try {
        $Assertion = $null
        $Assertion = Assert-TeamsCallableEntity -Identity "$($CsUser.UserPrincipalName)" -Terminate -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
        if ($Assertion) {
          Write-Information "SUCCESS: '$UserPrincipalName' - PhoneSystem License & Status: OK"
          Write-Information "SUCCESS: '$UserPrincipalName' - Enterprise Voice Status: OK"
          $IsEVenabled = $True
        }
        else {
          throw "'$UserPrincipalName' - $Operation`: Error encountered when asserting Entity"
        }
      }
      catch {
        throw "$_"
      }
    }
    else {
      Write-Information "CURRENT: '$UserPrincipalName' - PhoneSystem License & Status: OK"
      Write-Information "CURRENT: '$UserPrincipalName' - Enterprise Voice Status: OK"
    }

    # Pre-empting errors based on Object not being enabled for Enterprise Voice
    if ( -not $IsEVenabled) {
      $ErrorLogMessage = "'$UserPrincipalName' - $Operation`: Could not enable Object. Please investigate. Voice Configuration will not succeed for all entries"
      Write-Error -Message $ErrorLogMessage
      $ErrorLog += $ErrorLogMessage
    }
    #endregion

    #region Checking multiple assignments of PhoneSystem
    $CurrentOperationID0 = 'Checking multiple assignments of PhoneSystem'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ( $CsUser.PhoneSystemStatus.Contains(',')) {
      Write-Warning -Message "'$UserPrincipalName' - $Operation`: Multiple assignments found. Please verify License assignment."
      $UserLic = Get-AzureAdUserLicense -UserPrincipalName "$UserPrincipalName" -WarningAction SilentlyContinue
      Write-Verbose -Message 'All licenses assigned to the User:' -Verbose
      Write-Output $UserLic.Licenses | Select-Object ProductName, SkuPartNumber, LicenseType, IncludesTeams, IncludesPhoneSystem, ServicePlans
    }
    #endregion

    #region Calling Plans - Number verification
    if ( $PSCmdlet.ParameterSetName -eq 'CallingPlans' ) {
      $CurrentOperationID0 = 'Testing Object for Calling Plan License'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      # Validating License assignment
      try {
        if ( -not $CallingPlanLicense ) {
          if ( -not $CsUser.LicensesAssigned.Contains('Calling')) {
            # This could be done with Test-TeamsUserHasCallingPlan
            Write-Progress -Id 0 -Activity $ActivityID0 -Completed
            throw "'$UserPrincipalName' - User is not licensed correctly. Please check License assignment. A Calling Plan License is required"
          }
        }
      }
      catch {
        # Unlicensed
        Write-Progress -Id 0 -Activity $ActivityID0 -Completed
        $ErrorLogMessage = 'User is not licensed (CallingPlan). Please assign a Calling Plan license'
        Write-Error -Message $ErrorLogMessage -Category ResourceUnavailable -RecommendedAction 'Please assign a Calling Plan license' -ErrorAction Stop
        $ErrorLog += $ErrorLogMessage
        $ErrorLog += $_.Exception.Message
        return $ErrorLog
      }

      if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
        $CurrentOperationID0 = 'Parsing Online Telephone Numbers (validating Number against Microsoft Calling Plan Numbers)'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        # Validating Microsoft Number
        $MSNumber = $null
        $MSNumber = ((Format-StringForUse -InputString "$PhoneNumber" -SpecialChars 'tel:+') -split ';')[0]
        $PhoneNumberIsMSNumber = Get-CsOnlineTelephoneNumber -TelephoneNumber $MSNumber -WarningAction SilentlyContinue
        if ($PhoneNumberIsMSNumber) {
          Write-Verbose -Message "Phone Number '$PhoneNumber' found in the Tenant."
        }
        else {
          $ErrorLogMessage = "Phone Number '$PhoneNumber' is not found in the Tenant. Please provide an available number"
          Write-Error -Message $ErrorLogMessage
          $ErrorLog += $ErrorLogMessage
        }
      }
    }
    #endregion

    #region Validating Phone Number Format
    $Operation = 'Phone Number'
    $CurrentOperationID0 = "$Operation`: Querying current assignment"
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    # Querying CurrentPhoneNumber
    try {
      $CurrentPhoneNumber = $CsUser.LineUri
      Write-Verbose -Message "'$UserPrincipalName' - $Operation`: Currently assigned: $CurrentPhoneNumber"
    }
    catch {
      $CurrentPhoneNumber = $null
      Write-Verbose -Message "'$UserPrincipalName' - $Operation`: Currently assigned: NONE"
    }

    if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
      $CurrentOperationID0 = "$Operation`: Validating format"
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      if ( [String]::IsNullOrEmpty($PhoneNumber) ) {
        if ($CurrentPhoneNumber) {
          Write-Verbose -Message "'$UserPrincipalName' - $Operation`: Number is NULL or Empty. The Existing Number '$CurrentPhoneNumber' will be removed"
        }
        else {
          Write-Verbose -Message "'$UserPrincipalName' - $Operation`: Number is NULL or Empty, but no Number is currently assigned. No Action taken"
        }
        $PhoneNumber = $null
      }
      else {
        if ($PhoneNumber -match '^(tel:\+|\+)?([0-9]?[-\s]?(\(?[0-9]{3}\)?)[-\s]?([0-9]{3}[-\s]?[0-9]{4})|[0-9]{8,15})((;ext=)([0-9]{3,8}))?$' ) {
          $E164Number = Format-StringForUse $PhoneNumber -As E164
          $LineUri = Format-StringForUse $PhoneNumber -As LineUri
          if ($CurrentPhoneNumber -eq $LineUri -and -not $force) {
            Write-Verbose -Message "'$UserPrincipalName' - $Operation`: '$LineUri' is already applied"
          }
          else {
            Write-Verbose -Message "'$UserPrincipalName' - $Operation`: '$LineUri' is in a usable format and will be applied"
            # Checking number is free
            Write-Verbose -Message "'$UserPrincipalName' - $Operation`: Finding Number assignments"
            $UserWithThisNumber = Find-TeamsUserVoiceConfig -PhoneNumber $E164Number -WarningAction SilentlyContinue
            $UserWithThisNumberIsSelf = $UserWithThisNumber | Where-Object UserPrincipalName -EQ $UserPrincipalName
            $UserWithThisNumberExceptSelf = $UserWithThisNumber | Where-Object UserPrincipalName -NE $UserPrincipalName
            if ( $UserWithThisNumberIsSelf ) {
              if ($Force) {
                Write-Verbose -Message "'$UserPrincipalName' - $Operation`: Assigned to self, will be reapplied"
              }
              else {
                Write-Information "CURRENT:  '$UserPrincipalName' - $Operation`: Assigned to self, no action taken"
              }
            }
            if ( $UserWithThisNumberExceptSelf ) {
              if ($Force) {
                Write-Warning -Message "'$UserPrincipalName' - $Operation`: '$LineUri' is currently assigned to Object(s): $($UserWithThisNumber.UserPrincipalName -join ','). This assignment will be removed!"
              }
              else {
                Write-Error -Message "'$UserPrincipalName' - $Operation`: '$LineUri' is already assigned to other Object(s): $($UserWithThisNumber.UserPrincipalName -join ',')" -Category NotImplemented -RecommendedAction 'Please specify a different Number or use -Force to re-assign' -ErrorAction Stop
              }
            }
          }
        }
        else {
          Write-Error -Message "'$UserPrincipalName' - $Operation`: '$LineUri' is not in an acceptable format. Multiple formats are available, but preferred is E.164 or LineURI format, with a minimum of 8 digits." -Category InvalidFormat
        }
      }
    }
    else {
      #PhoneNumber is not provided
      if ( -not $CurrentPhoneNumber ) {
        Write-Warning -Message "'$UserPrincipalName' - $Operation`: Not provided or present. User will not be able to use PhoneSystem"
      }
    }
    #endregion
    #endregion

    $StatusID0 = 'Applying Voice Configuration'
    #region Apply Voice Config
    if ($Force -or $PSCmdlet.ShouldProcess("$UserPrincipalName", 'Apply Voice Configuration')) {
      <#
      $Operation = 'Hosted Voicemail'
      $StatusID0 = 'Applying Voice Configuration: Generic'
      #region Generic Configuration
      #region Enable HostedVoicemail
      $CurrentOperationID0 = "$Operation`: Validating Status"
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      switch ( $ObjectType ) {
        'User' {
          if ( -not $CsUser.HostedVoicemail) {
            if ( $Force -or -not $CsUser.HostedVoicemail) {
              try {
                Set-CsUser -Identity "$($CsUser.UserPrincipalName)" -HostedVoiceMail $TRUE -ErrorAction Stop
                Write-Information "SUCCESS: '$UserPrincipalName' - $Operation`: OK"
              }
              catch {
                $ErrorLogMessage = "'$UserPrincipalName' - $Operation`: Failed: '$($_.Exception.Message)'"
                Write-Error -Message $ErrorLogMessage
                $ErrorLog += $ErrorLogMessage
              }
            }
            else {
              Write-Verbose -Message "'$UserPrincipalName' - $Operation` Status: Already enabled" -Verbose
            }
          }
          else {
            Write-Information "CURRENT: '$UserPrincipalName' - $Operation` Status: OK"
          }
        }
        'ApplicationEndpoint' {
          Write-Verbose -Message "'$UserPrincipalName' - $Operation`: Operation not available for Resource Accounts" -Verbose
        }
        default {
          Write-Verbose -Message "'$UserPrincipalName' - $Operation`: Operation not available for ObjectType '$ObjectType'" -Verbose
        }
      }
      #>

      #endregion

      #region Tenant Dial Plan
      $Operation = 'Tenant Dial Plan'
      if ( $PSBoundParameters.ContainsKey('TenantDialPlan') ) {
        if ( $Force -or $RemoveTDP ) {
          $CurrentOperationID0 = "Removing $Operation"
          Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
          try {
            Grant-CsTenantDialPlan -Identity "$($CsUser.UserPrincipalName)" -PolicyName $null -ErrorAction Stop
            Write-Information "SUCCESS: '$UserPrincipalName' - $Operation`: Removed"
          }
          catch {
            $ErrorLogMessage = "'$UserPrincipalName' - $Operation`: Failed: '$($_.Exception.Message)'"
            Write-Error -Message $ErrorLogMessage
            $ErrorLog += $ErrorLogMessage
          }
        }
        if ( $TenantDialPlan ) {
          if ( $Force -or ($CsUser.TenantDialPlan -ne $TenantDialPlan) ) {
            $CurrentOperationID0 = "Applying $Operation"
            Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
            try {
              if ( $ObjectType -eq 'User' ) {
                Grant-CsTenantDialPlan -Identity "$($CsUser.UserPrincipalName)" -PolicyName $TenantDialPlan -ErrorAction Stop
                Write-Information "SUCCESS: '$UserPrincipalName' - $Operation`: OK - '$TenantDialPlan'"
              }
              else {
                Write-Verbose -Message "'$UserPrincipalName' - $Operation`: Operation not available for ObjectType '$ObjectType'" -Verbose
              }
            }
            catch {
              $ErrorLogMessage = "'$UserPrincipalName' - $Operation`: Failed: '$($_.Exception.Message)'"
              Write-Error -Message $ErrorLogMessage
              $ErrorLog += $ErrorLogMessage
            }
          }
          else {
            Write-Verbose -Message "'$UserPrincipalName' - $Operation`: Already assigned" -Verbose
          }
        }
      }
      else {
        if ($CsUser.TenantDialPlan) {
          Write-Information "CURRENT: '$UserPrincipalName' - $Operation`: '$($CsUser.TenantDialPlan)' assigned currently"
        }
        else {
          Write-Verbose -Message "'$UserPrincipalName' - $Operation`: Not provided"
        }
      }
      #endregion
      #endregion

      #region Specific Configuration 1 - OVP or Calling Plan License
      switch ($PSCmdlet.ParameterSetName) {
        'DirectRouting' {
          $StatusID0 = 'Applying Voice Configuration: Provisioning for Direct Routing'
          # Apply $OnlineVoiceRoutingPolicy
          $Operation = 'Online Voice Routing Policy'
          if ( $PSBoundParameters.ContainsKey('OnlineVoiceRoutingPolicy') ) {
            if ( $Force -or $RemoveOVP ) {
              $CurrentOperationID0 = "Removing $Operation"
              Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
              try {
                Grant-CsOnlineVoiceRoutingPolicy -Identity "$($CsUser.UserPrincipalName)" -PolicyName $null -ErrorAction Stop
                Write-Information "SUCCESS: '$UserPrincipalName' - $Operation`: Removed"
              }
              catch {
                $ErrorLogMessage = "'$UserPrincipalName' - $Operation`: Failed: '$($_.Exception.Message)'"
                Write-Error -Message $ErrorLogMessage
                $ErrorLog += $ErrorLogMessage
              }
            }
            if ( $OnlineVoiceRoutingPolicy ) {
              if ( $Force -or ($CsUser.OnlineVoiceRoutingPolicy -ne $OnlineVoiceRoutingPolicy) ) {
                $CurrentOperationID0 = "Applying $Operation"
                Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
                try {
                  Grant-CsOnlineVoiceRoutingPolicy -Identity "$($CsUser.UserPrincipalName)" -PolicyName $OnlineVoiceRoutingPolicy -ErrorAction Stop
                  Write-Information "SUCCESS: '$UserPrincipalName' - $Operation`: OK - '$OnlineVoiceRoutingPolicy'"
                }
                catch {
                  $ErrorLogMessage = "'$UserPrincipalName' - $Operation`: Failed: '$($_.Exception.Message)'"
                  Write-Error -Message $ErrorLogMessage
                  $ErrorLog += $ErrorLogMessage
                }
              }
              else {
                Write-Verbose -Message "'$UserPrincipalName' - $Operation`: Already assigned" -Verbose
              }
            }

          }
          else {
            if ( $CsUser.OnlineVoiceRoutingPolicy ) {
              Write-Information "CURRENT: '$UserPrincipalName' - $Operation`: '$($CsUser.OnlineVoiceRoutingPolicy)' assigned currently"
            }
            else {
              Write-Warning -Message "'$UserPrincipalName' - $Operation`: Not assigned. Object will be able to receive inbound calls, but not make outbound calls!'"
              if ( $ObjectType -eq 'ApplicationEndpoint' ) {
                Write-Verbose -Message 'Resource Accounts only require an Online Voice Routing Policy if the associated Call Queue or Auto Attendant forwards to PSTN' -Verbose
              }
            }
          }
        }
        'OperatorConnect' {
          $StatusID0 = 'Applying Voice Configuration: Provisioning for Operator Connect'
          # OperatorConnect - Requirement capture needed
          <#
          $CurrentOperationID0 = 'Applying Voice Configuration: Operator Connect'
          Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
          #>
        }
        'CallingPlans' {
          $StatusID0 = 'Applying Voice Configuration: Provisioning for Calling Plans'
          # Apply $CallingPlanLicense
          $Operation = 'Calling Plan License'
          $CurrentOperationID0 = "Applying $Operation"
          Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
          if ($CallingPlanLicense) {
            try {
              $null = (Set-TeamsUserLicense -Identity "$UserPrincipalName" -Add $CallingPlanLicense -ErrorAction STOP)
              Write-Information "SUCCESS: '$UserPrincipalName' - $Operation`: OK - '$CallingPlanLicense'"
            }
            catch {
              $ErrorLogMessage = "'$UserPrincipalName' - $Operation`: Failed for '$CallingPlanLicense' with Exception: '$($_.Exception.Message)'"
              Write-Error -Message $ErrorLogMessage
              $ErrorLog += $ErrorLogMessage
            }
            #VALIDATE Waiting period after applying a Calling Plan license? Will Phone Number assignment succeed right away?
            Write-Verbose -Message 'Calling Plan License has been applied, but replication time has not been factored in or tested. Applying a Phone Number may fail. If so, please run command again after a few minutes and feed back duration to TeamsFunctions@outlook.com or via GitHub!' -Verbose
          }
        }
      }
      #endregion

      #region Specific Configuration 2 - Phone Number
      #region Removing number from OTHER Object
      $StatusID0 = 'Applying Voice Configuration: Phone Number'
      if ( $Force -and $PSBoundParameters.ContainsKey('PhoneNumber') -and $UserWithThisNumberExceptSelf ) {
        $CurrentOperationID0 = 'Scavenging Phone Number'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        Write-Warning -Message 'Parameter Force - Scavenging Phone Number from all Objects where number is assigned. Validate carefully'
        foreach ($UserWTN in $UserWithThisNumberExceptSelf) {
          try {
            Write-Verbose -Message "'$UserPrincipalName' - $CurrentOperationID0 FROM '$($UserWTN.UserPrincipalName)'"
            $PhoneNumberExecResult = $null
            $PhoneNumberExecResult = Set-TeamsPhoneNumber -Object $UserWTN -PhoneNumber $null -WarningAction SilentlyContinue -ErrorAction Stop
            if ( $PhoneNumberExecResult ) {
              $StatusMessage = "$($UserWTN.InterpretedVoiceConfigType) Number removed from $($UserWTN.ObjectType)"
              Write-Information "SUCCESS: '$UserPrincipalName' - $CurrentOperationID0`: OK - $StatusMessage"
            }
            else {
              throw
            }
            <#
            if ($UserWTN.InterpretedUserType.Contains('ApplicationInstance')) {
              if ($PSCmdlet.ShouldProcess("$($UserWTN.UserPrincipalName)", 'Set-TeamsUserVoiceConfig')) {
                Set-TeamsResourceAccount -UserPrincipalName $($UserWTN.UserPrincipalName) -PhoneNumber $Null -WarningAction SilentlyContinue -ErrorAction Stop
                Write-Information "SUCCESS: Resource Account '$($UserWTN.UserPrincipalName)' - $CurrentOperationID0`: OK"
              }
            }
            elseif ($UserWTN.InterpretedUserType.Contains('User')) {
              if ($PSCmdlet.ShouldProcess("$($UserWTN.UserPrincipalName)", 'Set-TeamsUserVoiceConfig')) {
                $UserWTN | Set-TeamsUserVoiceConfig -PhoneNumber $Null -WarningAction SilentlyContinue -ErrorAction Stop
                Write-Information "SUCCESS: '$($UserWTN.UserPrincipalName)' - $CurrentOperationID0`: OK"
              }
            }
            else {
              Write-Error -Message "Scavenging Phone Number from $($UserWTN.UserPrincipalName) failed. Object is not a User or a ResourceAccount" -ErrorAction Stop
            }
            #>
          }
          catch {
            Write-Error -Message "Scavenging Phone Number from $($UserWTN.UserPrincipalName) failed with Exception: $($_.Exception.Message)" -ErrorAction Stop
          }
        }
      }
      #endregion

      $CurrentOperationID0 = 'Phone Number'
      if ( $PSBoundParameters.ContainsKey('PhoneNumber')) {
        #region Remove Number from current Object
        if ( $Force -or ([String]::IsNullOrEmpty($PhoneNumber)) ) {
          if ( ([String]::IsNullOrEmpty($PhoneNumber)) ) {
            Write-Warning -Message "'$UserPrincipalName' - PhoneNumber is empty and will be removed. The User will not be able to use PhoneSystem!"
          }
          $CurrentOperationID0 = 'Removing Phone Number'
          Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
          try {
            $PhoneNumberExecResult = $null
            $PhoneNumberExecResult = Set-TeamsPhoneNumber -Object $CsUser -PhoneNumber $null -WarningAction SilentlyContinue -ErrorAction Stop
            if ( $PhoneNumberExecResult ) {
              $StatusMessage = "$(if ($PhoneNumberIsMSNumber) { 'Calling Plan' } else { 'Direct Routing'}) Number removed from $ObjectType"
              Write-Information "SUCCESS: '$UserPrincipalName' - $CurrentOperationID0`: OK - $StatusMessage"
            }
            else {
              throw
            }
            <#
            switch ( $ObjectType ) {
              'User' {
                if ($PhoneNumberIsMSNumber) {
                  # Remove MS Number
                  Set-CsUser -Identity "$($CsUser.UserPrincipalName)" -TelephoneNumber $null -ErrorAction Stop
                  Write-Information "SUCCESS: '$UserPrincipalName' - $CurrentOperationID0`: OK - Calling Plan number removed"
                }
                else {
                  # Remove Direct Routing Number
                  Set-CsUser -Identity "$($CsUser.UserPrincipalName)" -OnPremLineURI $null -ErrorAction Stop
                  Write-Information "SUCCESS: '$UserPrincipalName' - $CurrentOperationID0`: OK - Direct Routing number removed"
                }
              }
              'ApplicationEndpoint' {
                $RAAction = Set-TeamsResourceAccount -UserPrincipalName "$UserPrincipalName" -PhoneNumber $null -PassThru -ErrorAction Stop
                if ( -not $RAAction.PhoneNumber ) {
                  Write-Information "SUCCESS: '$UserPrincipalName' - $CurrentOperationID0`: OK - Number removed from Resource Account"
                }
                else {
                  throw 'Number failed to be unassigned from Resource Account (Operation performed with Set-TeamsResourceAccount)'
                }
              }
              default {
                Write-Verbose -Message "'$UserPrincipalName' - $CurrentOperationID0`: Operation not available for ObjectType '$ObjectType'" -Verbose
              }
            }
            #>
          }
          catch {
            if ($_.Exception.Message.Contains('dirsync')) {
              #TEST Potentially not triggered as information was outsourced to Set-TeamsPhoneNumber
              Write-Warning -Message "'$UserPrincipalName' - $CurrentOperationID0`: Failed: Object needs to be changed in Skype OnPrem. Please run the following CmdLet against Skype"
              Write-Host "Set-CsUser -Identity `"$UserPrincipalName`" -HostedVoiceMail $null -LineUri $null" -ForegroundColor Magenta
            }
            else {
              Write-Verbose -Message "'$UserPrincipalName' - $CurrentOperationID0`: Failed: '$($_.Exception.Message)'" -Verbose
            }
          }
        }
        #endregion

        #region Applying Phone Number
        $CurrentOperationID0 = 'Applying Phone Number'
        if ( -not [String]::IsNullOrEmpty($PhoneNumber) ) {
          Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
          try {
            $PhoneNumberExecResult = $null
            $PhoneNumberExecResult = Set-TeamsPhoneNumber -Object $CsUser -PhoneNumber $PhoneNumber -WarningAction SilentlyContinue -ErrorAction Stop
            if ( $PhoneNumberExecResult ) {
              $StatusMessage = "$(if ($PhoneNumberIsMSNumber) { 'Calling Plan' } else { 'Direct Routing'}) Number assigned to $ObjectType"
              Write-Information "SUCCESS: '$UserPrincipalName' - $CurrentOperationID0`: OK - $StatusMessage"
            }
            else {
              throw
            }
          }
          catch {
            if ($_.Exception.Message.Contains('dirsync')) {
              #TEST Potentially not triggered as information was outsourced to Set-TeamsPhoneNumber
              Write-Warning -Message "'$UserPrincipalName' - $CurrentOperationID0`: Failed: Object needs to be changed in Skype OnPrem. Please run the following CmdLet against Skype"
              Write-Host "Set-CsUser -Identity `"$UserPrincipalName`" -LineUri '$LineUri'" -ForegroundColor Magenta
            }
            else {
              $ErrorLogMessage = "'$UserPrincipalName' - $CurrentOperationID0`: Failed: '$($_.Exception.Message)'"
              Write-Error -Message $ErrorLogMessage
            }
            $ErrorLog += $ErrorLogMessage
          }          <#
          switch ( $ObjectType ) {
            'User' {
              switch ($PSCmdlet.ParameterSetName) {
                'DirectRouting' {
                  # Apply or Remove $PhoneNumber as OnPremLineUri
                  if ( $Force -or $CsUser.OnPremLineURI -ne $LineUri) {
                    #Error Message: Filter failed to return unique result"
                    try {
                      Set-CsUser -Identity "$($CsUser.UserPrincipalName)" -OnPremLineURI $LineUri -ErrorAction Stop
                      Write-Information "SUCCESS: '$UserPrincipalName' - $CurrentOperationID0`: OK - '$LineUri'"
                    }
                    catch {
                      if ($_.Exception.Message.Contains('dirsync')) {
                        Write-Warning -Message "'$UserPrincipalName' - $CurrentOperationID0`: Failed: Object needs to be changed in Skype OnPrem. Please run the following CmdLet against Skype"
                        Write-Host "Set-CsUser -Identity `"$UserPrincipalName`" -LineUri '$LineUri'" -ForegroundColor Magenta
                      }
                      else {
                        $ErrorLogMessage = "'$UserPrincipalName' - $CurrentOperationID0`: Failed: '$($_.Exception.Message)'"
                        Write-Error -Message $ErrorLogMessage
                      }
                      $ErrorLog += $ErrorLogMessage
                    }
                  }
                  else {
                    Write-Verbose -Message "'$UserPrincipalName' - $CurrentOperationID0`: Already assigned" -Verbose
                  }
                }
                'OperatorConnect' {
                  # OperatorConnect - Requirement capture needed
                  <#
                  $CurrentOperationID0 = 'Applying Voice Configuration: Operator Connect'
                  Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
                  #
                }
                'CallingPlans' {
                  # Apply or Remove $PhoneNumber as TelephoneNumber
                  if ( $Force -or $CsUser.TelephoneNumber -ne $E164Number) {
                    try {
                      Set-CsOnlineVoiceUser -Identity "$($CsUser.ObjectId)" -TelephoneNumber $E164Number -ErrorAction Stop
                      Write-Information "SUCCESS: '$UserPrincipalName' - $CurrentOperationID0`: OK - '$E164Number' (Calling Plan Number)"
                    }
                    catch {
                      $ErrorLogMessage = "'$UserPrincipalName' - $CurrentOperationID0 failed: '$($_.Exception.Message)'"
                      Write-Error -Message $ErrorLogMessage
                      $ErrorLog += $ErrorLogMessage
                    }
                  }
                  else {
                    Write-Verbose -Message "'$UserPrincipalName' - $CurrentOperationID0`: Already assigned" -Verbose
                  }
                }
              }
            }
            'ApplicationEndpoint' {
              if ( $Force -or $CsUser.LineUri -ne $LineUri) {
                try {
                  $RAActionAssign = Set-TeamsResourceAccount -UserPrincipalName "$UserPrincipalName" -PhoneNumber $E164Number -PassThru -ErrorAction Stop
                  if ( $RAActionAssign.PhoneNumber ) {
                    Write-Information "SUCCESS: '$UserPrincipalName' - $CurrentOperationID0`: OK - Number assigned to Resource Account"
                  }
                  else {
                    throw 'Number failed to assign to Resource Account (Operation performed with Set-TeamsResourceAccount)'
                  }
                }
                catch {
                  $ErrorLogMessage = "'$UserPrincipalName' - $CurrentOperationID0 failed: '$($_.Exception.Message)'"
                  Write-Error -Message $ErrorLogMessage
                  $ErrorLog += $ErrorLogMessage
                }
              }
            }
            default {
              Write-Verbose -Message "'$UserPrincipalName' - $CurrentOperationID0`: Operation not available for ObjectType '$ObjectType'" -Verbose
            }
          }
          #>
        }
        #endregion
      }
      else {
        Write-Information "CURRENT: '$UserPrincipalName' - $CurrentOperationID0`: '$($CsUser.LineURI)' assigned currently"
      }
      #endregion
    }
    #endregion

    $StatusID0 = 'Validation & Output'
    #region Log & Output
    # Write $ErrorLog
    if ( $WriteErrorLog -and $errorLog) {
      $CurrentOperationID0 = 'Writing ErrorLog'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      $Path = 'C:\Temp'
      $Filename = "$(Get-Date -Format 'yyyy-MM-dd HH')xx - $($MyInvocation.MyCommand) - ERROR.log"
      $LogPath = "$Path\$Filename"

      # Write log entry to $Path
      Write-Verbose -Message "'$UserPrincipalName' - Errors encountered are written to '$Path'"
      "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K') - $($MyInvocation.MyCommand) - $UserPrincipalName" | Out-File -FilePath $LogPath -Append
      $errorLog | Out-File -FilePath $LogPath -Append
    }
    else {
      Write-Verbose -Message "'$UserPrincipalName' - No errors encountered! No log file written."
    }


    # Output
    if ( $PassThru ) {
      # Re-Query Object
      $CurrentOperationID0 = 'Waiting for Office 365 to write the Object'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      Write-Verbose -Message 'Waiting 3-5s for Office 365 to write changes to User Object (Policies might not show up yet)'
      Start-Sleep -Seconds 3
      $UserObjectPost = Get-TeamsUserVoiceConfig -UserPrincipalName $UserPrincipalName -InformationAction SilentlyContinue -WarningAction SilentlyContinue
      if ( $PsCmdlet.ParameterSetName -eq 'DirectRouting' -and $null -eq $UserObjectPost.OnlineVoiceRoutingPolicy) {
        Start-Sleep -Seconds 2
        $UserObjectPost = Get-TeamsUserVoiceConfig -UserPrincipalName $UserPrincipalName -InformationAction SilentlyContinue -WarningAction SilentlyContinue
      }

      if ( $PsCmdlet.ParameterSetName -eq 'DirectRouting' -and $null -eq $UserObjectPost.OnlineVoiceRoutingPolicy) {
        Write-Warning -Message 'Applied Policies take some time to show up on the object. Please verify again with Get-TeamsUserVoiceConfig'
      }
    }
    else {
      $UserObjectPost
    }
    Write-Progress -Id 0 -Activity $ActivityID0 -Completed
    Write-Output $UserObjectPost
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Set-TeamsUserVoiceConfig
