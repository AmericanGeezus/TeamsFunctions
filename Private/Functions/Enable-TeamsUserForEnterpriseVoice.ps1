# Module:     TeamsFunctions
# Function:   Teams User Voice Configuration
# Author:     David Eberhardt
# Updated:    01-OCT-2020
# Status:     PreLive




function Enable-TeamsUserForEnterpriseVoice {
  <#
	.SYNOPSIS
    Enables a User for Enterprise Voice
  .DESCRIPTION
		Enables a User for Enterprise Voice and verifies its status
  .NOTES
		Simple helper function to enable and verify a User is enabled for Enterprise Voice
	#>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [Parameter(HelpMessage = "Suppresses confirmation prompt unless -Confirm is used explicitly")]
    [switch]$Force
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    $UserObject = Get-CsOnlineUser $Identity -WarningAction SilentlyContinue
    $IsEVenabled = $UserObject.EnterpriseVoiceEnabled
    if ($IsEVenabled) {
      Write-Verbose -Message "User '$Identity' Enterprise Voice Status: User is already enabled!" -Verbose
      return $true
    }
    else {
      Write-Verbose -Message "User '$Identity' Enterprise Voice Status: Not enabled, trying to enable" -Verbose
      try {
        if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Enabling User for EnterpriseVoice")) {
          $null = Set-CsUser $Identity -EnterpriseVoiceEnabled $TRUE -ErrorAction STOP
          $i = 0
          $iMax = 20
          $Status = "Applying License"
          $Operation = "Waiting for Get-AzureAdUserLicenseDetail to return a Result"
          Write-Verbose -Message "$Status - $Operation"
          while ( -not $(Get-CsOnlineUser $Identity -WarningAction SilentlyContinue).EnterpriseVoiceEnabled) {
            if ($i -gt $iMax) {
              Write-Error -Message "User was not enabled for Enterprise Voice in the last $iMax Seconds" -Category LimitsExceeded -RecommendedAction "Please verify Object has been enabled (EnterpriseVoiceEnabled); Continue with Set-TeamsAutoAttendant"
              return
            }
            Write-Progress -Id 0 -Activity "Azure Active Directory is applying License. Please wait" `
              -Status $Status -SecondsRemaining $($iMax - $i) -CurrentOperation $Operation -PercentComplete (($i * 100) / $iMax)

            Start-Sleep -Milliseconds 1000
            $i++
          }

          # re-query status after a little padding (so that the next command can query a correct status)
          Start-Sleep -Milliseconds 3000
          $EVenabled = $(Get-CsOnlineUser $Identity).EnterpriseVoiceEnabled
          Write-Verbose -Message "User '$Identity' Enterprise Voice Status: $EVenabled"
          if ($EVenabled) {
            Write-Verbose -Message "User '$Identity' Enterprise Voice Status: SUCCESS" -Verbose
            return $true
          }
          else {
            Write-Verbose -Message "User '$Identity' Enterprise Voice Status: FAILED" -Verbose
            return $false
          }
        }

      }
      catch {
        Write-Verbose -Message "User '$Identity' Enterprise Voice Status: ERROR" -Verbose
        Write-Error -Message "$($_.Exception.Message)"
        return $false
      }
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Enable-TeamsUserForEnterpriseVoice
