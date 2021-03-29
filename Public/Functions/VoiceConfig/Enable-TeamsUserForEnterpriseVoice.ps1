# Module:     TeamsFunctions
# Function:   Teams User Voice Configuration
# Author:     David Eberhardt
# Updated:    01-DEC-2020
# Status:     Live




function Enable-TeamsUserForEnterpriseVoice {
  <#
	.SYNOPSIS
    Enables a User for Enterprise Voice
  .DESCRIPTION
		Enables a User for Enterprise Voice and verifies its status
  .PARAMETER UserPrincipalName
		UserPrincipalName of the User to be enabled.
  .PARAMETER Force
		Suppresses confirmation prompt unless -Confirm is used explicitly
  .EXAMPLE
    Enable-TeamsUserForEnterpriseVoice John@domain.com
    Enables John for Enterprise Voice
  .NOTES
    Simple helper function to enable and verify a User is enabled for Enterprise Voice
    Returns boolean result and less communication if called by another function
  .COMPONENT
    VoiceConfiguration
	.FUNCTIONALITY
    Enables a User for Enterprise Voice in order to apply a valid Voice Configuration
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_VoiceConfiguration
  .LINK
    about_UserManagement
	.LINK
    Set-TeamsUserVoiceConfig
	.LINK
    Enable-TeamsUserForEnterpriseVoice
	#>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('Enable-Ev')]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(HelpMessage = 'Suppresses confirmation prompt unless -Confirm is used explicitly')]
    [switch]$Force
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($Id in $UserPrincipalName) {
      Write-Verbose -Message "[PROCESS] $Id"
      # Querying Identity
      try {
        Write-Verbose -Message "User '$Id' - Querying User Account"
        $UserObject = Get-CsOnlineUser -Identity "$Id" -WarningAction SilentlyContinue
        $UserLicense = Get-AzureAdUserLicense "$Id"
        $IsEVenabled = $UserObject.EnterpriseVoiceEnabled
      }
      catch {
        Write-Error -Message "User '$Id' not found: $($_.Exception.Message)" -Category ObjectNotFound
        continue
      }

      if ( $UserObject.InterpretedUserType -match 'OnPrem' ) {
        $Message = "User '$Id' is not hosted in Teams!"
        #CHECK Deactivated as Object is able to be used/enabled even if in Islands mode and Object in Skype!
        if ($Called) {
          Write-Warning -Message $Message
          #return $false
        }
        else {
          Write-Warning -Message $Message
          #throw [System.InvalidOperationException]::New("$Message")
        }
      }

      if ( $UserObject.InterpretedUserType -notmatch 'User' ) {
        $Message = "Object '$Id' is not a User!"
        if ($Called) {
          Write-Warning -Message $Message
          return $false
        }
        else {
          throw [System.InvalidOperationException]::New("$Message")
        }
      }
      elseif ( -not $UserLicense.PhoneSystem ) {
        $Message = "User '$Id' Enterprise Voice Status: User is not licensed correctly (PhoneSystem required)!"
        if ($Called) {
          Write-Warning -Message $Message
          return $false
        }
        else {
          throw [System.InvalidOperationException]::New("$Message")
        }
        return $(if ($Called) { $false })
      }
      elseif ( -not [string]$UserLicense.PhoneSystemStatus.contains('Success') ) {
        $Message = "User '$Id' Enterprise Voice Status: User is not licensed correctly (PhoneSystem required to be enabled)!"
        if ($Called) {
          Write-Warning -Message $Message
          return $false
        }
        else {
          throw [System.InvalidOperationException]::New("$Message")
        }
      }
      elseif ($IsEVenabled) {
        if ($Called) {
          return $true
        }
        else {
          Write-Verbose -Message "User '$Id' Enterprise Voice Status: User is already enabled!" -Verbose
          #Enabling HostedVoicemail is done silently (just in case)
          $null = Set-CsUser $Id -HostedVoiceMail $TRUE -ErrorAction SilentlyContinue
        }
      }
      else {
        Write-Information "TRYING:  User '$Id' - Enterprise Voice Status: Not enabled, trying to enable"
        try {
          if ($Force -or $PSCmdlet.ShouldProcess("$Id", 'Enabling User for EnterpriseVoice')) {
            $null = Set-CsUser $Id -EnterpriseVoiceEnabled $TRUE -HostedVoiceMail $TRUE -ErrorAction STOP
            $i = 0
            $iMax = 20
            $Status = 'Enable User For Enterprise Voice'
            $Operation = 'Waiting for Get-CsOnlineUser to return a Result'
            Write-Verbose -Message "$Status - $Operation"
            while ( -not $(Get-CsOnlineUser -Identity "$Id" -WarningAction SilentlyContinue).EnterpriseVoiceEnabled) {
              if ($i -gt $iMax) {
                Write-Error -Message "User '$Id' - Enterprise Voice Status: FAILED (User status has not changed in the last $iMax Seconds" -Category LimitsExceeded -RecommendedAction 'Please verify Object has been enabled (EnterpriseVoiceEnabled)'
                return $false
              }
              Write-Progress -Id 0 -Activity 'Waiting for Azure Active Directory to return a result. Please wait' `
                -Status $Status -SecondsRemaining $($iMax - $i) -CurrentOperation $Operation -PercentComplete (($i * 100) / $iMax)

              Start-Sleep -Milliseconds 1000
              $i++
            }

            if ($Called) {
              return $true
            }
            else {
              Write-Verbose -Message "User '$Id' - Enterprise Voice Status: SUCCESS" -Verbose
            }
          }
        }
        catch {
          $Message = "User '$Id' - Error enabling user for Enterprise Voice: $($_.Exception.Message)"
          if ($Called) {
            Write-Warning -Message $Message
            return $false
          }
          else {
            throw $_
          }
        }
      }
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Enable-TeamsUserForEnterpriseVoice
