# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  15-DEC-2020
# Status:   Live




function Assert-TeamsCallableEntity {
  <#
	.SYNOPSIS
		Verifies User is ready for Voice Config
  .DESCRIPTION
    Tests whether a the Object can be used as a Callable Entity in Call Queues or Auto Attendant
  .PARAMETER Identity
    Required. UserPrincipalName, Group Name or Tel URI
  .PARAMETER Terminate
    Optional. By default, the Command will not throw terminating errors.
    Using this switch a terminating error is generated.
    Useful for scripting to try/catch and silently treat the received error.
  .EXAMPLE
    Assert-TeamsCallableEntity -Identity Jane@domain.com
    Verifies Jane has a valid PhoneSystem License (Provisioning Status: Success) and is enabled for Enterprise Voice
    Enables Jane for Enterprise Voice if not yet done.
  .INPUTS
    System.String
  .OUTPUTS
    Boolean
  .NOTES
    Returns Boolean Result
  .COMPONENT
    UserManagement
    TeamsAutoAttendant
    TeamsCallQueue
	.FUNCTIONALITY
    Verifies whether a User Object is correctly configured to be used for Auto Attendants or Call Queues
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_UserManagement
  .LINK
    about_TeamsAutoAttendant
  .LINK
    about_TeamsCallQueue
  .LINK
    Assert-TeamsCallableEntity
  .LINK
    Find-TeamsCallableEntity
  .LINK
    Get-TeamsCallableEntity
  .LINK
    New-TeamsCallableEntity
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  Param
  (
    [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'User Principal Name of the user')]
    [Alias('UserPrincipalName', 'GroupName', 'TelUri')]
    [string]$Identity,

    [Parameter(HelpMessage = 'Switch to instruct to throw errors')]
    [switch]$Terminate
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    try {
      $Object = Get-TeamsUserVoiceConfig -UserPrincipalName $Identity
      Write-Verbose -Message "User '$Identity' found"
    }
    catch {
      $ErrorMessage = "Target '$Identity' not found"
      if ($Terminate) {
        throw $ErrorMessage
      }
      else {
        Write-Error -Message $ErrorMessage
        return $false
      }
    }

    switch ($Object.ObjectType) {
      'ResourceAccount' {
        #Check RA is assigned to CQ/AA
        $CheckLicense = $true
        $CheckAssignment = $true
        #Return Object if true, otherwise error
      }
      'User' {
        #Check License and EV-enable if needed
        $CheckLicense = $true
        $CheckEV = $true
      }
      default {
        $ErrorMessage = "Target '$Identity' not a User or Resource Account. No verification done"
        if ($Terminate) {
          throw $ErrorMessage
        }
        else {
          Write-Error -Message $ErrorMessage
          return $false
        }
      }
    }

    # Verification
    if ( $CheckLicense ) {
      if ( $Object.PhoneSystemStatus.Contains('Success')) {
        Write-Verbose -Message "Target '$Identity' found and licensed"
      }
      elseif ( $Object.PhoneSystemStatus.Contains('PendingInput')) {
        Write-Verbose -Message "Target '$Identity' found and licensed (Pending Input)"
      }
      else {
        #TEST whether this works. Might take some time b/c Object cannot be used in 'PendingInput' just yet?
        <#
        try {
          Write-Information "Target '$Identity' found and licensed, but PhoneSystem is disabled. Trying to Enable"
          Set-AzureAdLicenseServicePlan -Identity "$Identity" -Enable MCOEV
          Write-Verbose -Message "Target '$Identity' found and PhoneSystem License applied. Waiting for AzureAd to complete provisioning"
          Start-Sleep -Seconds 2
          $UserLicense = Get-AzureAdUserLicense $Identity
          if ( $UserLicense.PhoneSystemStatus -ne "Success" -or $UserLicense.PhoneSystemStatus -ne "PendingInput") {
            throw
          }
        }
        catch {
          Write-Error -Message "" -RecommendedAction "" -Category  -Exception $_.Exception.Message
          $ErrorMessage = "Target '$Identity' found but not licensed correctly (PhoneSystem) - Service Plan could not be enabled!"
          if ($Terminate) {
            throw $ErrorMessage
          }
          else {
            Write-Error -Message $ErrorMessage
            return $false
          }
        }
        #>
        $ErrorMessage = "Target '$Identity' found but not licensed correctly (PhoneSystem)"
        if ($Terminate) {
          throw $ErrorMessage
        }
        else {
          Write-Error -Message $ErrorMessage
          return $false
        }
      }
    }

    if ( $CheckEV ) {
      if ( $Object.EnterpriseVoiceEnabled ) {
        Write-Verbose -Message "Target '$Identity' found and licensed and enabled for EnterpriseVoice" -Verbose
        return $true
      }
      elseif ( $(Enable-TeamsUserForEnterpriseVoice -Identity $Object.UserPrincipalName -Force) ) {
        Write-Verbose -Message "Target '$Identity' found and licensed and successfully enabled for EnterpriseVoice" -Verbose
        return $true
      }
      else {
        $ErrorMessage = "Target '$Identity' found and licensed, but not enabled for EnterpriseVoice!"
        if ($Terminate) {
          throw $ErrorMessage
        }
        else {
          Write-Error -Message $ErrorMessage
          return $false
        }
      }
    }

    if ( $CheckAssignment ) {
      $RA = Get-TeamsResourceAccount "$Identity"
      if ( $RA.AssociationStatus -ne 'Success' ) {
        Write-Verbose -Message "Target '$Identity' found and correctly assigned"
        return $true
      }
      else {
        $ErrorMessage = "Target '$Identity' found but not assigned to any Call Queue or Auto Attendant"
        if ($Terminate) {
          throw $ErrorMessage
        }
        else {
          Write-Error -Message $ErrorMessage
          return $false
        }
      }
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Assert-TeamsCallableEntity
