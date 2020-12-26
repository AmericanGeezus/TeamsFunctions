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
    Assert-TeamsCallableEntity -Identity John@domain.com
    Will Return $TRUE if John has a valid PhoneSystem License (Provisioning Status: Success).
    Enables John for Enterprise Voice if not yet done.
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  Param
  (
    [Parameter(Mandatory, HelpMessage = "User Principal Name of the user")]
    [string]$Identity
  )

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    $Stack = Get-PSCallStack
    $Called = $($Stack.length -ge 3)
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    try {
      $Object = Get-TeamsUserVoiceConfig $Identity
      Write-Verbose -Message "User '$Identity' found"

      if ( $Object.PhoneSystemStatus.Contains('Success')) {
        Write-Verbose -Message "User '$Identity' found and licensed"

        if ( $Object.EnterpriseVoiceEnabled ) {
          Write-Verbose -Message "User '$Identity' found and licensed and enabled for EnterpriseVoice" -Verbose
          return $Object
        }
        elseif ( $(Enable-TeamsUserForEnterpriseVoice -Identity $Object.UserPrincipalName -Force) ) {
          Write-Verbose -Message "User '$Identity' found and licensed and successfully enabled for EnterpriseVoice" -Verbose
          $Object.EnterpriseVoiceEnabled -eq $true
          return $Object
        }
        else {
          if ( -not $Called ) {
            Write-Error -Message "User '$Identity' found and licensed, but not enabled for EnterpriseVoice!" -Category InvalidResult -ErrorAction Stop
          }
          return
        }

      }
      else {
        if ( -not $Called ) {
          Write-Warning -Message "User '$Identity' found but not licensed (PhoneSystem)" -Verbose
        }
        return
      }
    }
    catch {
      if ( -not $Called ) {
        Write-Error -Message "User '$Identity' not found" -Category ObjectNotFound -ErrorAction Stop
      }
      return
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Assert-TeamsCallableEntity
