#region Teams Voice Configuration
<#

# Project "TeamsUserVoiceConfig"

Script Name: Get-TeamsTENANTVoiceConfig
# Ideal to get information about how the Tenant is configured for Voice

# Use Case: OUTPUT - Part 1: Microsoft Calling Plans
# Simple view - Names/states only? / Detailed view + Count ?
# Microsoft Calling Plan Licenses (available, inUse, free)
# Number of Service Numbers (available, inUse, free)
# Number of User Numbers (available, inUse, free)
# TeamsVoiceRoute (?) and other parameters pulled together

# Use Case: OUTPUT - Part 2: Direct Routing
# Simple view - Count only? / Detailed view - Count and Names?

# TenantDialPlans (Count)
# TenantDialPlans (Names, Object)
# VoiceRoutingPolicies (Count)
# VoiceRoutingPolicies (Names, Object)
# VoiceRoutes (Count)
# VoiceRoutes (Names, Matching Patters (for Call Restrictions), Object)
# PSTN Gateways (Count)
# PSTN Gateways (Names, Object)



Script Name: GET-TeamsUserVoiceConfig
# Use Case: Query current Voice Configuration (Basic output, the necessary only)

## Parameters displayed:
SipAddress, ObjectId, TeamsUpgradeEffectiveMode, UsageLocation
# Custom boolean parameter "LicensedForEV" (i.E. has PhoneSystem) - Output from:
# Test-TeamsUserLicense $User -ServicePlan MCOEV
DialPlan, TenantDialPlan, EnterpriseVoiceEnabled
TelephoneNumber, LineURI, OnPremLineURI

## Microsoft Calling Plans
# Calling Plan licenses assigned (boolean for each of the 3-4 Licenses, or Object?)
TeamsVoiceRoute

## Direct Routing
OnlineVoiceRoutingPolicy

# Use Case: Query current Voice Configuration (Diagnose simple issues)
## Basic Diagnostic data
HostingProvider, InterpretedUserType, AccountEnabled (AD), Enabled (Teams), IsValid

# Use Case: Query current Voice Configuration (Diagnose more complex issues)
## Diagnostic data (switch?)
HideFromAddressLists, OnPremHideFromAddressLists, OnPremEnterPriseVoiceEnabled

DirSyncEnabled, LastDirSyncTime (from ADuser), ObjectType, ObjectCategory, WhenCreated, OriginatingServer, Enabled, IsValid

Voice Configuration (Advanced)
  UserPrincipalName,SipAddress,Enabled,TeamsUpgradeEffectiveMode,TeamsUpgradePolicy,HostedVoiceMail,EnterpriseVoiceEnabled,OnPremEnterpriseVoiceEnabled,`
  TelephoneNumber,LineUri,OnPremLineUri,OnPremLineURIManuallySet,DialPlan,TenantDialPlan,VoicePolicy,VoiceRoutingPolicy,OnlineVoiceRoutingPolicy,TeamsVoiceRoute

# Use Case: Policies
Display all Policies in addition to the Name
UserPrincipalName,*Policy*

Script Name: TEST-TeamsUserVoiceConfig
# Use Case: Test current Voice Configuration
Test-TeamsUserVoiceConfig -Identity $UPN -DirectRouting
#TRUE if
# EnterpriseVoiceEnabled (set to TRUE)
# OnlineVoiceRoutingPolicy (not $NULL, i.E populated)
# OnPremLineURI (not $NULL, i.E populated)
($true -eq $User.EnterpriseVoiceEnabled -and $null -ne $User.OnlineVoiceRoutingPolicy -and $null -ne $User.OnPremLineURI)

Test-TeamsUserVoiceConfig -Identity $UPN -CallingPlans
# TRUE if
# License is assigned (DOM or INT)
# TelephoneNumber is populated

Test-TeamsUserVoiceConfig -Identity $UPN -CallingPlans -Partial
# Testing for incomplete removal when switching to ?
# CallingPlans: Licensed, but not necessarily a Phone Number? (precision needed and diff to above!)
# DirectRouting: Licensed (MCOEV), but any of the other things missing? ) Write Output!
# Unclear on how to approach



Script Name: SET-TeamsUserVoiceConfig
# Alternative: NEW-TeamsUserVoiceConfig
# Use Case: Apply Voice Configuration for Microsoft Calling Plans
Set-TeamsUserVoiceConfig -Identity $UPN -CallingPlans -PhoneNumber $Number -License $CallPlanLicense
# Remove potential holdover from previous Calling Plan configuration (Test for Partial Config)
# Enable EnterpriseVoice
# Apply PhoneNumber
# Apply License
# Apply TenantDialPlan (optional!)

# Use Case: Apply Voice Configuration for Direct Routing
Set-TeamsUserVoiceConfig -Identity $UPN -DirectRouting -PhoneNumber $Number -RoutingPolicy $OVP
# Remove potential holdover from previous Calling Plan configuration (Test for Partial Config)
# Enable EnterpriseVoice
# Apply PhoneNumber
# Apply VoiceRoutingPolicy
# Apply TenantDialPlan (optional!)

# Use Case: Apply individual Voice Configuration (like Changing Number only)
Set-TeamsUserVoiceConfig -Identity $UPN -PhoneNumber $Number



Script Name: REMOVE-TeamsUserVoiceConfig
# Use Case: Remove Voice Configuration for Microsoft Calling Plans
Remove-TeamsUserVoiceConfig -Identity $UPN -CallingPlans
# Remove TelephoneNumber
# Remove CallingPlanLicenses (Possible to have a different Confirmpreference per ParameterSet?)
# Remove TenantDialPlan?
# Disable EnterpriseVoice

# Use Case: Remove Voice Configuration for Direct Routing
Remove-TeamsUserVoiceConfig -Identity $UPN -DirectRouting
# Remove OnPremLineURI
# Remove VoiceRoutingPolicy
# Remove TenantDialPlan?
# Disable EnterpriseVoice

# Use Case: Remove Voice Configuration for both scenarios
Remove-TeamsUserVoiceConfig -Identity $UPN
# All of the above. Deprovision completely (except pulling the User License (like E5))
#>
#endregion
