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

function Assert-TeamsCallableEntity ($checkId) {
  try {
    $CheckIdObject = Get-TeamsUserVoiceConfig $CheckId
    if ( $CheckIdObject.PhoneSystemStatus.Contains('Success')) {
      Write-Verbose -Message "User '$CheckId' found and licensed"

      if ( $CheckIdObject.EnterpriseVoiceEnabled ) {
        Write-Verbose -Message "User '$CheckId' found and licensed and enabled for EnterpriseVoice"
        return $CheckIdObject.ObjectId
      }

      if ( Enable-TeamsUserForEnterpriseVoice -Identity $CheckId.UserPrincipalName -Force ) {
        Write-Warning -Message "User '$CheckId' found and licensed, but not enabled for EnterpriseVoice!" -Verbose
        return
      }

    }
    else {
      Write-Warning -Message "User '$CheckId' found but not licensed (PhoneSystem)" -Verbose
      return
    }
  }
  catch {
    Write-Warning -Message "User '$CheckId' not found" -Verbose
    return
  }
}