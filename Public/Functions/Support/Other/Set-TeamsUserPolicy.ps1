# Module:     TeamsFunctions
# Function:   Other
# Author: David Eberhardt
# Updated:    01-JUL-2020
# Status:     PreLive

function Set-TeamsUserPolicy {
  <#
	.SYNOPSIS
		Sets policies on a Teams user
	.DESCRIPTION
		Teams offers the assignment of several policies, to control multiple aspects of the Users experience.
		For example: TeamsUpgrade, Client, Conferencing, External access, Mobility.
		Typically these are assigned using different commands, but
		Set-TeamsUserPolicy allows settings all these with a single command. One or all policy options can
		be used during assignment.
	.PARAMETER Identity
		This is the sign-in address/User Principal Name of the user to configure.
	.PARAMETER TeamsUpgradePolicy
		This is one of the available TeamsUpgradePolicies to assign to the user.
	.PARAMETER ClientPolicy
		This is the Client Policy to assign to the user.
	.PARAMETER ConferencingPolicy
		This is the Conferencing Policy to assign to the user.
	.PARAMETER ExternalAccessPolicy
		This is the External Access Policy to assign to the user.
	.PARAMETER MobilityPolicy
		This is the Mobility Policy to assign to the user.
	.EXAMPLE
		Set-TeamsUserPolicy -Identity John.Doe@contoso.com -ClientPolicy ClientPolicyNoIMURL
		Example 1 will set the user John.Does@contoso.com with a client policy.
	.EXAMPLE
		Set-TeamsUserPolicy -Identity John.Doe@contoso.com -ClientPolicy ClientPolicyNoIMURL -ConferencingPolicy BposSAllModalityNoFT
		Example 2 will set the user John.Does@contoso.com with a client and conferencing policy.
	.EXAMPLE
		Set-TeamsUserPolicy -Identity John.Doe@contoso.com -ClientPolicy ClientPolicyNoIMURL -ConferencingPolicy BposSAllModalityNoFT -ExternalAccessPolicy FederationOnly -MobilityPolicy
		Example 3 will set the user John.Does@contoso.com with a client, conferencing, external access, and mobility policy.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.NOTES
		TeamsUpgrade Policy has been added.
		Multiple other policies are planned to be added to round the function off
	#>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Enter the identity for the user to configure")]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string]$Identity,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$TeamsUpgradePolicy,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$ClientPolicy,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$ConferencingPolicy,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$ExternalAccessPolicy,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$MobilityPolicy
  ) #param

  begin {
    # Caveat - Script in Development
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    Show-FunctionStatus -Level Unmanaged
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

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

    # Get available policies for tenant
    Write-Verbose -Message "Gathering all policies for tenant"
    $tenantTeamsUpgradePolicies = (Get-CsTeamsUpgradePolicy -WarningAction SilentlyContinue).Identity
    $tenantClientPolicies = (Get-CsClientPolicy -WarningAction SilentlyContinue).Identity
    $tenantConferencingPolicies = (Get-CsConferencingPolicy -Include SubscriptionDefaults -WarningAction SilentlyContinue).Identity
    $tenantExternalAccessPolicies = (Get-CsExternalAccessPolicy -WarningAction SilentlyContinue).Identity
    $tenantMobilityPolicies = (Get-CsMobilityPolicy -WarningAction SilentlyContinue).Identity
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    foreach ($ID in $Identity) {
      #User Validation
      #CHECK output options and harmonize!
      # NOTE: Validating users in a try/catch block does not catch the error properly and does not allow for custom outputting of an error message
      if ($null -ne (Get-CsOnlineUser -Identity $ID -WarningAction SilentlyContinue -ErrorAction SilentlyContinue)) {
        #region Teams Upgrade Policy
        if ($PSBoundParameters.ContainsKey("TeamsUpgradePolicy")) {
          # Verify if $TeamsUpgradePolicy is a valid policy to assign
          if ($tenantTeamsUpgradePolicies -icontains "Tag:$TeamsUpgradePolicy") {
            try {
              # Attempt to assign policy
              if ($PSCmdlet.ShouldProcess("$ID", "Grant-TeamsUpgradePolicy -PolicyName $TeamsUpgradePolicy")) {
                Grant-TeamsUpgradePolicy -Identity $ID -PolicyName $TeamsUpgradePolicy -WarningAction SilentlyContinue -ErrorAction STOP
                $output = GetActionOutputObject3 -Name $ID -Property "Teams Upgrade Policy" -Result "Success: $TeamsUpgradePolicy"
              }
            }
            catch {
              $errorMessage = $_
              $output = GetActionOutputObject3 -Name $ID -Property "Teams Upgrade Policy" -Result "Error: $errorMessage"
            }
          }
          else {
            # Output invalid client policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "Teams Upgrade Policy" -Result "Error: $TeamsUpgradePolicy is not valid or does not exist"
          }

          # Output final TeamsUpgradePolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting Teams Upgrade Policy
        #endregion

        #region Client Policy
        if ($PSBoundParameters.ContainsKey("ClientPolicy")) {
          # Verify if $ClientPolicy is a valid policy to assign
          if ($tenantClientPolicies -icontains "Tag:$ClientPolicy") {
            try {
              # Attempt to assign policy
              if ($PSCmdlet.ShouldProcess("$ID", "Grant-CsClientPolicy -PolicyName $ClientPolicy")) {
                Grant-CsClientPolicy -Identity $ID -PolicyName $ClientPolicy -WarningAction SilentlyContinue -ErrorAction STOP
                $output = GetActionOutputObject3 -Name $ID -Property "Client Policy" -Result "Success: $ClientPolicy"
              }
            }
            catch {
              $errorMessage = $_
              $output = GetActionOutputObject3 -Name $ID -Property "Client Policy" -Result "Error: $errorMessage"
            }
          }
          else {
            # Output invalid client policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "Client Policy" -Result "Error: $ClientPolicy is not valid or does not exist"
          }

          # Output final ClientPolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting Client Policy
        #endregion

        #region Conferencing Policy
        if ($PSBoundParameters.ContainsKey("ConferencingPolicy")) {
          # Verify if $ConferencingPolicy is a valid policy to assign
          if ($tenantConferencingPolicies -icontains "Tag:$ConferencingPolicy") {
            try {
              # Attempt to assign policy
              if ($PSCmdlet.ShouldProcess("$ID", "Grant-CsConferencingPolicy -PolicyName $ConferencingPolicy")) {
                Grant-CsConferencingPolicy -Identity $ID -PolicyName $ConferencingPolicy -WarningAction SilentlyContinue -ErrorAction STOP
                $output = GetActionOutputObject3 -Name $ID -Property "Conferencing Policy" -Result "Success: $ConferencingPolicy"
              }
            }
            catch {
              # Output to error log file on policy assignment error
              $errorMessage = $_
              $output = GetActionOutputObject3 -Name $ID -Property "Conferencing Policy" -Result "Error: $errorMessage"
            }
          }
          else {
            # Output invalid conferencing policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "Conferencing Policy" -Result "Error: $ConferencingPolicy is not valid or does not exist"
          }

          # Output final ConferencingPolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting Conferencing Policy
        #endregion

        #region External Access Policy
        if ($PSBoundParameters.ContainsKey("ExternalAccessPolicy")) {
          # Verify if $ExternalAccessPolicy is a valid policy to assign
          if ($tenantExternalAccessPolicies -icontains "Tag:$ExternalAccessPolicy") {
            try {
              # Attempt to assign policy
              if ($PSCmdlet.ShouldProcess("$ID", "Grant-CsExternalAccessPolicy -PolicyName $ExternalAccessPolicy")) {
                Grant-CsExternalAccessPolicy -Identity $ID -PolicyName $ExternalAccessPolicy -WarningAction SilentlyContinue -ErrorAction STOP
                $output = GetActionOutputObject3 -Name $ID -Property "External Access Policy" -Result "Success: $ExternalAccessPolicy"
              }
            }
            catch {
              $errorMessage = $_
              $output = GetActionOutputObject3 -Name $ID -Property "External Access Policy" -Result "Error: $errorMessage"
            }
          }
          else {
            # Output invalid external access policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "External Access Policy" -Result "Error: $ExternalAccessPolicy is not valid or does not exist"
          }

          # Output final ExternalAccessPolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting External Access Policy
        #endregion

        #region Mobility Policy
        if ($PSBoundParameters.ContainsKey("MobilityPolicy")) {
          # Verify if $MobilityPolicy is a valid policy to assign
          if ($tenantMobilityPolicies -icontains "Tag:$MobilityPolicy") {
            try {
              # Attempt to assign policy
              if ($PSCmdlet.ShouldProcess("$ID", "Grant-CsMobilityPolicy -PolicyName $MobilityPolicy")) {
                Grant-CsMobilityPolicy -Identity $ID -PolicyName $MobilityPolicy -WarningAction SilentlyContinue -ErrorAction STOP
                $output = GetActionOutputObject3 -Name $ID -Property "Mobility Policy" -Result "Success: $MobilityPolicy"
              }
            }
            catch {
              $errorMessage = $_
              $output = GetActionOutputObject3 -Name $ID -Property "Mobility Policy" -Result "Error: $errorMessage"
            }
          }
          else {
            # Output invalid external access policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "Mobility Policy" -Result "Error: $MobilityPolicy is not valid or does not exist"
          }

          # Output final MobilityPolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting Mobility Policy
        #endregion
      } # End of setting policies
      else {
        $output = GetActionOutputObject3 -Name $ID -Property "User Validation" -Result "Error: Not a valid Skype user account"
        Write-Output -InputObject $output
      }
    } # End of foreach ($ID in $Identity)
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Set-TeamsUserPolicy
