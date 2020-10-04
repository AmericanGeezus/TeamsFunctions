# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   PreLive

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
    - for AzureAD:    "Get-AzureADUserFromUPN $Identity | FL"
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
    [int32]$DiagnosticLevel
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"

    foreach ($User in $Identity) {
      #region Information Gathering
      Write-Verbose -Message "[PROCESS] Processing '$User'"
      # Querying Identity
      try {
        $AdUser = Get-AzureADUserFromUPN $User -WarningAction SilentlyContinue -ErrorAction Stop
        $CsUser = Get-CsOnlineUser $User -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        Write-Error "User '$User' not found" -Category ObjectNotFound -ErrorAction Stop
      }

      # Querying User Licenses
      $CsUserLicense = Get-TeamsUserLicense $User
      #endregion

      # InterpretedVoiceConfigType
      if ($User.VoicePolicy -eq "BusinessVoice") {
        $InterpretedVoiceConfigType = "CallingPlans"
      }
      elseif ($User.VoicePolicy -eq "HybridVoice") {
        if ($null -ne $User.VoiceRoutingPolicy -and $null -eq $User.OnlineVoiceRoutingPolicy) {
          $InterpretedVoiceConfigType = "SkypeHybridPSTN"
        }
        else {
          $InterpretedVoiceConfigType = "DirectRouting"
        }
      }
      else {
        $InterpretedVoiceConfigType = "Unknown"
      }


      #region Creating Base Custom Object
      $UserObject = $null
      $UserObject = [PSCustomObject][ordered]@{
        UserPrincipalName          = $AdUser.UserPrincipalName
        SipAddress                 = $CsUser.SipAddress
        ObjectId                   = $CsUser.ObjectId
        HostingProvider            = $CsUser.HostingProvider
        InterpretedUserType        = $CsUser.InterpretedUserType
        InterpretedVoiceConfigType = $InterpretedVoiceConfigType
        TeamsUpgradeEffectiveMode  = $CsUser.TeamsUpgradeEffectiveMode
        UsageLocation              = $CsUser.UsageLocation
        LicensesAssigned           = $CsUserLicense.LicensesFriendlyNames
        CurrentCallingPlan         = $CsUserLicense.CallingPlan
        PhoneSystem                = $CsUserLicense.PhoneSystem
        TeamsVoiceRoute            = $CsUser.TeamsVoiceRoute
        EnterpriseVoiceEnabled     = $CsUser.EnterpriseVoiceEnabled
        HostedVoiceMail            = $CsUser.HostedVoiceMail
        OnlineVoiceRoutingPolicy   = $CsUser.OnlineVoiceRoutingPolicy
        TenantDialPlan             = $CsUser.TenantDialPlan
        TelephoneNumber            = $CsUser.TelephoneNumber
        PrivateLine                = $CsUser.PrivateLine
        LineURI                    = $CsUser.LineURI
        OnPremLineURI              = $CsUser.OnPremLineURI

      }
      #endregion

      #region Adding Diagnostic Parameters
      if ($PSBoundParameters.ContainsKey('DiagnosticLevel')) {
        switch ($DiagnosticLevel) {
          { $PSItem -ge 1 } {
            # Displaying basic diagnostic parameters (Hybrid)
            $UserObject | Add-Member -MemberType NoteProperty -Name OnPremLineURIManuallySet -Value $CsUser.OnPremLineURIManuallySet
            $UserObject | Add-Member -MemberType NoteProperty -Name OnPremEnterPriseVoiceEnabled -Value $CsUser.OnPremEnterPriseVoiceEnabled
            $UserObject | Add-Member -MemberType NoteProperty -Name VoicePolicy -Value $CsUser.VoicePolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsUpgradePolicy -Value $CsUser.TeamsUpgradePolicy
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
            # Displaying advanced diagnostic parameters
            $UserObject | Add-Member -MemberType NoteProperty -Name AdAccountEnabled -Value $AdUser.AccountEnabled
            $UserObject | Add-Member -MemberType NoteProperty -Name CsAccountEnabled -Value $CsUser.Enabled
            $UserObject | Add-Member -MemberType NoteProperty -Name CsAccountIsValid -Value $CsUser.IsValid
            $UserObject | Add-Member -MemberType NoteProperty -Name CsWhenCreated -Value $CsUser.WhenCreated
            $UserObject | Add-Member -MemberType NoteProperty -Name CsWhenChanged -Value $CsUser.WhenChanged
            $UserObject | Add-Member -MemberType NoteProperty -Name ObjectType -Value $AdUser.ObjectType
            $UserObject | Add-Member -MemberType NoteProperty -Name ObjectClass -Value $CsUser.ObjectClass

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
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Get-TeamsUserVoiceConfig
