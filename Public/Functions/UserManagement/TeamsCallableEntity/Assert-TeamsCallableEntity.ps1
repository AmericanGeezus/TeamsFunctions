# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
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
    This CmdLet does verify User Objects only - Channels are not validated
  .COMPONENT
    UserManagement
    TeamsAutoAttendant
    TeamsCallQueue
  .FUNCTIONALITY
    Verifies whether a User Object is correctly configured to be used for Auto Attendants or Call Queues
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-TeamsCallableEntity.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsCallQueue.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
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

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    try {
      $Object = Get-TeamsUserVoiceConfig -UserPrincipalName "$Identity" -WarningAction SilentlyContinue -InformationAction SilentlyContinue
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
      'ApplicationEndpoint' {
        #Check RA is assigned to CQ/AA
        $CheckLicense = $false
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
      elseif ( $Object.PhoneSystemStatus.Contains('Disabled')) {
        Write-Verbose -Message "Target '$Identity' found and licensed (Disabled) - Trying to enable"
        try {
          Write-Information "TRYING:  Object '$UserPrincipalName' - PhoneSystem License is assigned - ServicePlan PhoneSystem is Disabled - Trying to activate"
          Set-AzureAdLicenseServicePlan -Identity "$($CsUser.UserPrincipalName)" -Enable MCOEV -ErrorAction Stop
          #TEST Waiting for Azure Ad to propagate - is 3s enough time?
          $Seconds = 3
          Write-Information "WAITING: Object '$UserPrincipalName' - PhoneSystem License is assigned and enabled, waiting for AzureAd to Propagate ($Seconds`s)"
          Start-Sleep -Seconds $Seconds
          if (-not (Get-AzureAdUserLicense -Identity "$UserPrincipalName").PhoneSystemStatus.Contains('Success')) {
            throw
          }
        }
        catch {
          $ErrorMessage = "Target '$Identity' found but not licensed correctly (PhoneSystem) - Object could not be enabled"
          if ($Terminate) {
            throw $ErrorMessage
          }
          else {
            Write-Error -Message $ErrorMessage
            return $false
          }
        }
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
      #elseif ( $(Enable-TeamsUserForEnterpriseVoice -Identity "$($Object.UserPrincipalName)" -Force) ) {
      elseif ( $(Enable-TeamsUserForEnterpriseVoice -Object $Object -Force) ) {
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
} #
