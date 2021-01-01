# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  15-DEC-2020
# Status:   PreLive




function Assert-TeamsCallableEntity {
  <#
	.SYNOPSIS
		Verifies User is ready for Voice Config
  .DESCRIPTION
    Tests whether a the Object can be used as a Callable Entity in Call Queues or Auto Attendant
  .PARAMETER Identity
    UserPrincipalName, Group Name or Tel URI
  .EXAMPLE
    Assert-TeamsCallableEntity -Identity Jane@domain.com
    Verifies Jane has a valid PhoneSystem License (Provisioning Status: Success) and is enabled for Enterprise Voice
    Enables Jane for Enterprise Voice if not yet done.
  .NOTES
    Returns Boolean Result
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  Param
  (
    [Parameter(Mandatory, HelpMessage = "User Principal Name of the user")]
    [string]$Identity,

    [switch]$Terminate
  )

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    try {
      $Object = Get-TeamsUserVoiceConfig $Identity
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
      "ResourceAccount" {
        #Check RA is assigned to CQ/AA
        $CheckLicense = $true
        $CheckAssignment = $true
        #Return Object if true, otherwise error
      }
      "User" {
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
      else {
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
      if ( $RA.AssociationStatus -ne "Success" ) {
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
