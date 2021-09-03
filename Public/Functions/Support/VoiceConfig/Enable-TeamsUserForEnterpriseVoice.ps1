# Module:     TeamsFunctions
# Function:   Teams User Voice Configuration
# Author:     David Eberhardt
# Updated:    01-DEC-2020
# Status:     Live


#TEST Refactoring of CmdLet to handing Object to this Cmdlet and working it with a worker function (like Test-TeamsUVC)

function Enable-TeamsUserForEnterpriseVoice {
  <#
  .SYNOPSIS
    Enables a User for Enterprise Voice
  .DESCRIPTION
    Enables a User for Enterprise Voice and verifies its status
  .PARAMETER UserPrincipalName
    Required for Parameterset UserPrincipalName. UserPrincipalName of the User to be enabled.
  .PARAMETER Object
    Required for Parameterset Object. CsOnlineUser Object passed to the function to reduce query time.
  .PARAMETER Force
    Suppresses confirmation prompt unless -Confirm is used explicitly
  .EXAMPLE
    Enable-TeamsUserForEnterpriseVoice John@domain.com
    Enables John for Enterprise Voice
  .INPUTS
    System.String
  .OUTPUTS
    System.Void - If called directly
    Boolean - If called by another CmdLet
  .NOTES
    Simple helper function to enable and verify a User is enabled for Enterprise Voice
    Returns boolean result and less communication if called by another function
    Can be used providing either the UserPrincipalName or the already queried CsOnlineUser Object
  .COMPONENT
    VoiceConfiguration
  .FUNCTIONALITY
    Enables a User for Enterprise Voice in order to apply a valid Voice Configuration
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Enable-TeamsUserForEnterpriseVoice.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'UserPrincipalName')]
  [Alias('Enable-Ev')]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ParameterSetName = 'Object', ValueFromPipeline)]
    [Object[]]$Object,

    [Parameter(Mandatory, Position = 0, ParameterSetName = 'UserPrincipalName', ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('ObjectId', 'Identity')]
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

    # Preparing Splatting Object
    $parameters = $null
    $Parameters = @{
      'Called' = $Called
      'Force'  = $Force
    }

    #region Worker Function
    function EnableEV ($UserObject, $UserLicense, $Called, $Force) {
      Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
      $Id = $($UserObject.UserPrincipalName)
      Write-Verbose -Message "[PROCESS] Enabling User '$Id' for Enterprise Voice"

      $TeamsModuleVersion = (Get-Module MicrosoftTeams).Version
      if ( $TeamsModuleVersion -gt 2.3.1 -and -not $Called) {
        Write-Warning -Message 'Due to recent changes to Module MicrosoftTeams (v2.5.0 and later), not all functionality could yet be tested, your mileage may vary'
      }

      if ( $UserObject.InterpretedUserType -match 'OnPrem' ) {
        $Message = "User '$Id' is not hosted in Teams!"
        if ($Called) {
          Write-Warning -Message $Message
          #return $false
        }
        else {
          Write-Warning -Message $Message
          #Deactivated as Object is able to be used/enabled even if in Islands mode and Object in Skype!
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
      elseif ( $UserObject.EnterpriseVoiceEnabled -and -not $Force ) {
        if ($Called) {
          return $true
        }
        else {
          Write-Verbose -Message "User '$Id' Enterprise Voice Status: User is already enabled!" -Verbose
          #Enabling HostedVoicemail is done silently (just in case)
          $null = Set-CsUser -Identity $Id -HostedVoiceMail $TRUE -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        }
      }
      else {
        Write-Information "TRYING:  User '$Id' - Enterprise Voice Status: Not enabled, trying to enable"
        try {
          if ($Force -or $PSCmdlet.ShouldProcess("$Id", 'Enabling User for EnterpriseVoice')) {
            $null = Set-CsUser -Identity $Id -EnterpriseVoiceEnabled $TRUE -HostedVoiceMail $TRUE -ErrorAction STOP
            $i = 0
            $iMax = 20
            $Status = 'Enable User For Enterprise Voice'
            $Operation = 'Waiting for Get-CsOnlineUser to return a Result'
            Write-Verbose -Message "$Status - $Operation"
            do {
              if ($i -gt $iMax) {
                Write-Error -Message "User '$Id' - Enterprise Voice Status: FAILED (User status has not changed in the last $iMax Seconds" -Category LimitsExceeded -RecommendedAction 'Please verify Object has been enabled (EnterpriseVoiceEnabled)'
                return $false
              }
              Write-Progress -Id 0 -Activity 'Waiting for Azure Active Directory to return a result. Please wait' `
                -Status $Status -SecondsRemaining $($iMax - $i) -CurrentOperation $Operation -PercentComplete (($i * 100) / $iMax)

              Start-Sleep -Milliseconds 1000
              $i++
            }
            while ( -not $(Get-CsOnlineUser "$($UserObject.UserPrincipalName)" -WarningAction SilentlyContinue).EnterpriseVoiceEnabled )

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
    #endregion
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    switch ($PSCmdlet.ParameterSetName) {
      'UserprincipalName' {
        foreach ($User in $UserPrincipalName) {
          Write-Verbose -Message "[PROCESS] Processing '$User'"
          try {
            #NOTE Call placed without the Identity Switch to make remoting call and receive object in tested format (v2.5.0 and higher)
            #$CsUser = Get-CsOnlineUser -Identity "$User" -WarningAction SilentlyContinue -ErrorAction Stop
            $CsUser = Get-CsOnlineUser "$User" -WarningAction SilentlyContinue -ErrorAction Stop
            $UserLicense = Get-AzureAdUserLicense "$User"
          }
          catch {
            Write-Error "User '$User' not found" -Category ObjectNotFound
            continue
          }
          EnableEV -UserObject $CsUser -UserLicense $UserLicense @Parameters
        }
      }
      'Object' {
        foreach ($O in $Object) {
          Write-Verbose -Message "[PROCESS] Processing provided CsOnlineUser Object for '$($O.UserPrincipalName)'"
          $UserLicense = Get-AzureAdUserLicense "$($O.UserPrincipalName)"
          EnableEV -UserObject $O -UserLicense $UserLicense @Parameters
        }
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Enable-TeamsUserForEnterpriseVoice
