# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   PreLive

#TODO: Add: Check for PhoneSystem being disabled!


function Get-TeamsUserVoiceConfig {
  <#
	.SYNOPSIS
		Displays Voice Configuration Parameters for one or more Users
	.DESCRIPTION
    Displays Voice Configuration Parameters with different Diagnostic Levels
    ranging from basic Voice Configuration up to Policies, Account Status & DirSync Information
  .PARAMETER Identity
    Required. UserPrincipalName (UPN) of the User
	.PARAMETER DiagnosticLevel
    Optional. Value from 1 to 4. Higher values will display more parameters
    See NOTES below for details.
  .PARAMETER SkipLicenseCheck
    Optional. Will not perform queries against User Licensing to improve performance
	.EXAMPLE
    Get-TeamsUserVoiceConfig -Identity John@domain.com
    Shows Voice Configuration for John with a concise view of Parameters
	.EXAMPLE
    Get-TeamsUserVoiceConfig -Identity John@domain.com -DiagnosticLevel 2
    Shows Voice Configuration for John with a extended list of Parameters (see NOTES)
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    DiagnosticLevel details:
    1 Basic diagnostics for Hybrid Configuration or when moving users from On-prem Skype
    2 Extended diagnostics displaying additional Voice-related Policies
    3 Basic troubleshooting parameters from AzureAD like AccountEnabled, etc.
    4 Extended troubleshooting parameters from AzureAD like LastDirSyncTime
    Parameters are additive, meaning with each DiagnosticLevel more information is displayed

    This script takes a select set of Parameters from AzureAD, Teams & Licensing. For a full parameterset, please run:
    - for AzureAD:    "Find-AzureAdUser $Identity | FL"
    - for Licensing:  "Get-TeamsUserLicense $Identity"
    - for Teams:      "Get-CsOnlineUser $Identity"
	.FUNCTIONALITY
		The functionality that best describes this cmdlet
  .LINK
    Get-TeamsTenantVoiceConfig
    Get-TeamsUserVoiceConfig
    Find-TeamsUserVoiceConfig
    New-TeamsUserVoiceConfig
    Set-TeamsUserVoiceConfig
    Remove-TeamsUserVoiceConfig
    Test-TeamsUserVoiceConfig
  #>

  [CmdletBinding()]
  [Alias('Get-TeamsUVC')]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string[]]$Identity,

    [Parameter(HelpMessage = 'Defines level of Diagnostic Data that are added to the output object')]
    [Alias('DiagLevel', 'Level', 'DL')]
    [ValidateRange(1, 4)]
    [int32]$DiagnosticLevel,

    [Parameter(HelpMessage = 'Improves performance by not performing a License Check on the User')]
    [Alias('SkipLicense', 'SkipLic')]
    [switch]$SkipLicenseCheck
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
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

    foreach ($User in $Identity) {
      #region Information Gathering
      Write-Verbose -Message "[PROCESS] Processing '$User'"
      # Querying Identity
      try {
        $CsUser = Get-CsOnlineUser "$User" -WarningAction SilentlyContinue -ErrorAction Stop

      }
      catch {
        Write-Error -Message "$($_.Exception.Message)" -Category ObjectNotFound
        continue
      }

      # Constructing InterpretedVoiceConfigType
      Write-Verbose -Message "Testing InterpretedVoiceConfigType..."
      if ($CsUser.VoicePolicy -eq "BusinessVoice") {
        Write-Verbose -Message "InterpretedVoiceConfigType is 'CallingPlans' (VoicePolicy found as 'BusinessVoice')"
        $InterpretedVoiceConfigType = "CallingPlans"
      }
      elseif ($CsUser.VoicePolicy -eq "HybridVoice") {
        Write-Verbose -Message "VoicePolicy found as 'HybridVoice'..."
        if ($null -ne $CsUser.VoiceRoutingPolicy -and $null -eq $CsUser.OnlineVoiceRoutingPolicy) {
          Write-Verbose -Message "InterpretedVoiceConfigType is 'SkypeHybridPSTN' (VoiceRoutingPolicy assigned and no OnlineVoiceRoutingPolicy found)"
          $InterpretedVoiceConfigType = "SkypeHybridPSTN"
        }
        else {
          Write-Verbose -Message "InterpretedVoiceConfigType is 'DirectRouting' (VoiceRoutingPolicy not assigned)"
          $InterpretedVoiceConfigType = "DirectRouting"
        }
      }
      else {
        Write-Verbose -Message "InterpretedVoiceConfigType is 'Unknown' (undetermined)"
        $InterpretedVoiceConfigType = "Unknown"
      }

      # Testing ObjectType
      Write-Verbose -Message "Testing ObjectType..."
      <# Alternative Approach - Untested
      try {
        $ObjectType = Get-TeamsObjectType $CsUser.UserPrincipalName -ErrorAction Stop
      }
      catch {
        $ObjectType = "Unknown"
      }
      #>

      <# Alternative Approach: Fastest?
      #CHECK Remove completely as it is part of the InterpretedUserType OR Keep b/c useful?
      if ( "User" -in $CsUser.InterpretedUserType ) {
        Write-Verbose -Message "ObjectType is 'User'"
        $ObjectType = "User"
      }
      elseif ( "ApplicationInstance" -in $CsUser.InterpretedUserType ) {
        Write-Verbose -Message "ObjectType is 'ApplicationInstance'"
        $ObjectType = "ApplicationInstance"
      }
      else {
        Write-Verbose -Message "ObjectType is 'Unknown'"
        $ObjectType = "Unknown"
      }
      #>
      if ( Test-AzureADGroup $CsUser.UserPrincipalName ) {
        #CHECK Can you Query groups this way or would that be pointless (i.E. waste of time? Measure!)
        Write-Verbose -Message "ObjectType is 'Group'"
        $ObjectType = "Group"
      }
      elseif ( Test-TeamsResourceAccount $CsUser.UserPrincipalName ) {
        Write-Verbose -Message "ObjectType is 'ApplicationInstance'"
        $ObjectType = "ApplicationInstance"
      }
      elseif ( Test-AzureADUser $CsUser.UserPrincipalName ) {
        Write-Verbose -Message "ObjectType is 'User'"
        $ObjectType = "User"
      }
      else {
        Write-Verbose -Message "ObjectType is 'Unknown'"
        $ObjectType = "Unknown"
      }
      #endregion


      #region Creating Base Custom Object
      # Adding Basic parameters
      $UserObject = $null
      $UserObject = [PSCustomObject][ordered]@{
        UserPrincipalName          = $CsUser.UserPrincipalName
        SipAddress                 = $CsUser.SipAddress
        ObjectId                   = $CsUser.ObjectId
        HostingProvider            = $CsUser.HostingProvider
        ObjectType                 = $ObjectType
        InterpretedUserType        = $CsUser.InterpretedUserType
        InterpretedVoiceConfigType = $InterpretedVoiceConfigType
        TeamsUpgradeEffectiveMode  = $CsUser.TeamsUpgradeEffectiveMode
        VoicePolicy                = $CsUser.VoicePolicy
        UsageLocation              = $CsUser.UsageLocation
      }

      # Adding Licensing Parameters if not skipped
      if (-not $PSBoundParameters.ContainsKey('SkipLicenseCheck')) {
        # Querying User Licenses
        $CsUserLicense = Get-TeamsUserLicense -Identity "$($CsUser.UserPrincipalName)"
        #TEST Get-TeamsUserLicense was recently expanded to include the PhoneSystemStatus. This could also be used to query this

        # Adding Parameters
        $UserObject | Add-Member -MemberType NoteProperty -Name LicensesAssigned -Value $CsUserLicense.LicensesFriendlyNames
        $UserObject | Add-Member -MemberType NoteProperty -Name CurrentCallingPlan -Value $CsUserLicense.CallingPlan
        $UserObject | Add-Member -MemberType NoteProperty -Name PhoneSystemStatus -Value $CsUserLicense.PhoneSystemStatus
        $UserObject | Add-Member -MemberType NoteProperty -Name PhoneSystem -Value $CsUserLicense.PhoneSystem
      }

      # Adding Provisioning Parameters
      $UserObject | Add-Member -MemberType NoteProperty -Name EnterpriseVoiceEnabled -Value $CsUser.EnterpriseVoiceEnabled
      $UserObject | Add-Member -MemberType NoteProperty -Name HostedVoiceMail -Value $CsUser.HostedVoiceMail
      $UserObject | Add-Member -MemberType NoteProperty -Name TeamsUpgradePolicy -Value $CsUser.TeamsUpgradePolicy
      $UserObject | Add-Member -MemberType NoteProperty -Name OnlineVoiceRoutingPolicy -Value $CsUser.OnlineVoiceRoutingPolicy
      $UserObject | Add-Member -MemberType NoteProperty -Name TenantDialPlan -Value $CsUser.TenantDialPlan
      $UserObject | Add-Member -MemberType NoteProperty -Name TelephoneNumber -Value $CsUser.TelephoneNumber
      $UserObject | Add-Member -MemberType NoteProperty -Name LineURI -Value $CsUser.LineURI
      $UserObject | Add-Member -MemberType NoteProperty -Name OnPremLineURI -Value $CsUser.OnPremLineURI
      #endregion

      #region Adding Diagnostic Parameters
      if ($PSBoundParameters.ContainsKey('DiagnosticLevel')) {
        switch ($DiagnosticLevel) {
          { $PSItem -ge 1 } {
            # Displaying basic diagnostic parameters (Hybrid)
            $UserObject | Add-Member -MemberType NoteProperty -Name OnPremLineURIManuallySet -Value $CsUser.OnPremLineURIManuallySet
            $UserObject | Add-Member -MemberType NoteProperty -Name OnPremEnterPriseVoiceEnabled -Value $CsUser.OnPremEnterPriseVoiceEnabled
            $UserObject | Add-Member -MemberType NoteProperty -Name PrivateLine -Value $CsUser.PrivateLine
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsVoiceRoute -Value $CsUser.TeamsVoiceRoute
            $UserObject | Add-Member -MemberType NoteProperty -Name VoiceRoutingPolicy -Value $CsUser.VoiceRoutingPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsEmergencyCallRoutingPolicy -Value $CsUser.TeamsEmergencyCallRoutingPolicy
          }

          { $PSItem -ge 2 } {
            # Displaying extended diagnostic parameters
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsEmergencyCallingPolicy -Value $CsUser.TeamsEmergencyCallingPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name CallingPolicy -Value $CsUser.CallingPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name CallingLineIdentity -Value $CsUser.CallingLineIdentity
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsIPPhonePolicy -Value $CsUser.TeamsIPPhonePolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsVdiPolicy -Value $CsUser.TeamsVdiPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name OnlineDialOutPolicy -Value $CsUser.OnlineDialOutPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name OnlineAudioConferencingRoutingPolicy -Value $CsUser.OnlineAudioConferencingRoutingPolicy
          }

          { $PSItem -ge 3 } {
            # Querying AD Object (if Diagnostic Level is 3 or higher)
            try {
              $AdUser = Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction Stop
            }
            catch {
              Write-Warning -Message "User '$User' not found in AzureAD. Some data will not be available"
            }

            # Displaying advanced diagnostic parameters
            $UserObject | Add-Member -MemberType NoteProperty -Name AdAccountEnabled -Value $AdUser.AccountEnabled
            $UserObject | Add-Member -MemberType NoteProperty -Name CsAccountEnabled -Value $CsUser.Enabled
            $UserObject | Add-Member -MemberType NoteProperty -Name CsAccountIsValid -Value $CsUser.IsValid
            $UserObject | Add-Member -MemberType NoteProperty -Name CsWhenCreated -Value $CsUser.WhenCreated
            $UserObject | Add-Member -MemberType NoteProperty -Name CsWhenChanged -Value $CsUser.WhenChanged
            $UserObject | Add-Member -MemberType NoteProperty -Name AdObjectType -Value $AdUser.ObjectType
            $UserObject | Add-Member -MemberType NoteProperty -Name AdObjectClass -Value $CsUser.ObjectClass

          }
          { $PSItem -ge 4 } {
            # Displaying all of CsOnlineUser (previously omitted)
            $UserObject | Add-Member -MemberType NoteProperty -Name DirSyncEnabled -Value $AdUser.DirSyncEnabled
            $UserObject | Add-Member -MemberType NoteProperty -Name LastDirSyncTime -Value $AdUser.LastDirSyncTime
            $UserObject | Add-Member -MemberType NoteProperty -Name AdDeletionTimestamp -Value $AdUser.DeletionTimestamp
            $UserObject | Add-Member -MemberType NoteProperty -Name CsSoftDeletionTimestamp -Value $CsUser.SoftDeletionTimestamp
            $UserObject | Add-Member -MemberType NoteProperty -Name CsPendingDeletion -Value $CsUser.PendingDeletion
            $UserObject | Add-Member -MemberType NoteProperty -Name HideFromAddressLists -Value $CsUser.HideFromAddressLists
            $UserObject | Add-Member -MemberType NoteProperty -Name OnPremHideFromAddressLists -Value $CsUser.OnPremHideFromAddressLists
            $UserObject | Add-Member -MemberType NoteProperty -Name OriginatingServer -Value $CsUser.OriginatingServer
            $UserObject | Add-Member -MemberType NoteProperty -Name ServiceInstance -Value $CsUser.ServiceInstance
            $UserObject | Add-Member -MemberType NoteProperty -Name SipProxyAddress -Value $CsUser.SipProxyAddress
          }
        }
      }
      #endregion

      # Output
      Write-Output $UserObject

    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsUserVoiceConfig
