# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  15-DEC-2020
# Status:   PreLive


#TODO Make standalone function:
<#
Add CmdLetBindign
Add switch for returning ID, otherwise BOOLEAN
Add Help block
Add CallStack - Return error if called directly, otherwise warnings

#>

function Assert-TeamsCallableEntity {
  <#
	.SYNOPSIS
		Verifies User is ready for Voice Config
  .DESCRIPTION
		Tests whether a specific Module is loaded
  .EXAMPLE
		Test-Module -Module ModuleName
		Will Return $TRUE if the Module 'ModuleName' is loaded
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
        elseif ( $(Enable-TeamsUserForEnterpriseVoice -Identity $Identity.UserPrincipalName -Force) ) {
          Write-Verbose -Message "User '$Identity' found and licensed and successfully enabled for EnterpriseVoice" -Verbose
          return $Object
        }
        else {
          if ( $Called ) {
            Write-Warning -Message "User '$Identity' found and licensed, but not enabled for EnterpriseVoice!"
            return
          }
          else {
            Write-Error -Message "User '$Identity' found and licensed, but not enabled for EnterpriseVoice!" -Category InvalidResult -ErrorAction Stop
          }
        }

      }
      else {
        Write-Warning -Message "User '$Identity' found but not licensed (PhoneSystem)" -Verbose
        return
      }
    }
    catch {
      if ( $Called ) {
        Write-Warning -Message "User '$Identity' not found" -Verbose
        return
      }
      else {
        Write-Error -Message "User '$Identity' not found" -Category ObjectNotFound -ErrorAction Stop
      }
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Assert-TeamsCallableEntity
