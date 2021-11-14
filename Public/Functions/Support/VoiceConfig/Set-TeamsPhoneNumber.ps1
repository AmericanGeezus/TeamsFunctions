# Module:     TeamsFunctions
# Function:   Teams User Voice Configuration
# Author:     David Eberhardt
# Updated:    14-NOV-2021
# Status:     RC




function Set-TeamsPhoneNumber {
  <#
  .SYNOPSIS
    Applies a Phone Number to a User Object or Resource Account
  .DESCRIPTION
    Applies a Microsoft Calling Plans Number OR a Direct Routing Number to a User or Resource Account
  .PARAMETER UserPrincipalName
    Required for Parameterset UserPrincipalName. UserPrincipalName of the Object to be assigned the PhoneNumber.
    This can be a UPN of a User Account (CsOnlineUser Object) or a Resource Account (CsOnlineApplicationInstance Object)
  .PARAMETER Object
    Required for Parameterset Object. CsOnlineUser Object passed to the function to reduce query time.
    This can be a UPN of a User Account (CsOnlineUser Object) or a Resource Account (CsOnlineApplicationInstance Object)
  .PARAMETER PhoneNumber
    A Microsoft Calling Plans Number or a Direct Routing Number
    Requires the Account to be licensed. Able to enable PhoneSystem and the Account for Enterprise Voice
    Required format is E.164 or LineUri, starting with a '+' and 10-15 digits long.
  .PARAMETER Force
    Suppresses confirmation prompt unless -Confirm is used explicitly
    Scavenges Phone Number from all accounts the PhoneNumber is currently assigned to including the current User
  .EXAMPLE
    Set-TeamsPhoneNumber -UserPrincipalName John@domain.com -PhoneNumber +15551234567
    Applies the Phone Number +1 (555) 1234-567 to the Account John@domain.com
  .INPUTS
    System.String
  .OUTPUTS
    System.Void - If called directly
    Boolean - If called by another CmdLet
  .NOTES
    Simple helper function to assign a Phone Number to any User or Resource Account
    Returns boolean result and less communication if called by another function
    Can be used providing either the UserPrincipalName or the already queried CsOnlineUser Object
  .COMPONENT
    VoiceConfiguration
  .FUNCTIONALITY
    Enables a User for Enterprise Voice in order to apply a valid Voice Configuration
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Set-TeamsPhoneNumber.md
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
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ParameterSetName = 'Object', ValueFromPipeline)]
    [Object[]]$Object,

    [Parameter(Mandatory, Position = 0, ParameterSetName = 'UserPrincipalName', ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(Mandatory, Position = 1, HelpMessage = 'Telephone Number to assign')]
    [ValidateScript( {
        If ($_ -match '^(tel:\+|\+)?([0-9]?[-\s]?(\(?[0-9]{3}\)?)[-\s]?([0-9]{3}[-\s]?[0-9]{4})|[0-9]{8,15})((;ext=)([0-9]{3,8}))?$') { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Not a valid phone number. Must be 8 to 15 digits long'
          $false
        }
      })]
    [Alias('Tel', 'Number', 'TelephoneNumber')]
    [string]$PhoneNumber,

    [Parameter(HelpMessage = 'Suppresses confirmation prompt unless -Confirm is used explicitly')]
    [switch]$Force
  ) #param

  begin {
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if ( -not $script:TFPSST) { $script:TFPSST = Assert-MicrosoftTeamsConnection; if ( -not $script:TFPSST ) { break } }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

    # Preparing Splatting Object
    $parameters = $null
    $Parameters = @{
      'PhoneNumber' = $PhoneNumber
      'Called'      = $Called
      'Force'       = $Force
    }

    #region Worker Functions
    function SetNumber {
      [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
      param(
        [Parameter(Mandatory)]
        [string]$UserPrincipalName,

        [Parameter(Mandatory)]
        [AllowNull()]
        [string]$PhoneNumber,

        [Parameter(Mandatory)]
        [switch]$PhoneNumberIsMSNumber,

        [Parameter(Mandatory)]
        [ValidateSet('User', 'ApplicationInstance')]
        [string]$UserType
      ) #param

      if ( $null -eq $PhoneNumber ) {
        $E164Number = $LineUri = $null
      }
      else {
        $E164Number = Format-StringForUse $PhoneNumber -As E164
        $LineUri = Format-StringForUse $PhoneNumber -As LineUri
      }

      switch ( $UserType ) {
        'User' {
          if ($PhoneNumberIsMSNumber) {
            # Calling Plan Number
            if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-CsUser -Telephonenumber $E164Number")) {
              $null = (Set-CsUser -Identity "$UserPrincipalName" -TelephoneNumber $E164Number -ErrorAction STOP)
            }
          }
          else {
            # Direct Routing Number
            if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-CsUser -OnPremLineURI $LineUri")) {
              $null = (Set-CsUser -Identity "$UserPrincipalName" -OnPremLineURI $LineUri -ErrorAction STOP)
            }
          }
        }
        'ApplicationInstance' {
          if ($PhoneNumberIsMSNumber) {
            # Calling Plan Number (VoiceApplicationInstance)
            if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-CsOnlineVoiceApplicationInstance -Telephonenumber $E164Number")) {
              $null = (Set-CsOnlineVoiceApplicationInstance -Identity "$UserPrincipalName" -TelephoneNumber $E164Number -ErrorAction STOP)
            }
          }
          else {
            # Direct Routing Number (ApplicationInstance)
            if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-CsOnlineApplicationInstance -OnPremPhoneNumber $E164Number")) {
              $null = (Set-CsOnlineApplicationInstance -Identity "$UserPrincipalName" -OnpremPhoneNumber $E164Number -Force -ErrorAction STOP)
            }
          }
        }
      }
    }

    function SetPhoneNumber ($UserObject, $UserLicense, $PhoneNumber, $Called, $Force) {
      Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
      $Id = $($UserObject.UserPrincipalName)
      #region Validating Object
      # Object Location (OnPrem VS Online)
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

      #Determining Object Type
      $UserType = switch -regex ( $UserObject.InterpretedUserType ) {
        'User' { return 'User' }
        'ApplicationInstance' { return 'ApplicationInstance' }
        Default { return $false }
      }

      if ( -not $UserType ) {
        $Message = "Object '$Id' is not a User or an ApplicationInstance!"
        if ($Called) {
          Write-Warning -Message $Message
          return $false
        }
        else {
          throw [System.InvalidOperationException]::New("$Message")
        }
      }
      #endregion

      #region Validating License
      if ( -not $UserLicense.PhoneSystem -or -not $UserLicense.PhoneSystemVirtualUser ) {
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

      if ( -not [string]$UserLicense.PhoneSystemStatus.contains('Success') ) {
        Write-Information "TRYING:  User '$Id' - Phone System: Not enabled, trying to enable"
        Set-AzureAdUserLicenseServicePlan -UserPrincipalName $UserObject.UserPrincipalName -Enable MCOEV
        $i = 0
        $iMax = 60
        Write-Information "INFO:    User '$Id' - Phone System: Enabled; Waiting for AzureAd to write object ($iMax s)"
        $StatusID1 = 'Azure Active Directory is propagating Object. Please wait'
        $CurrentOperationID1 = 'Waiting for Get-AzureAdUserLicense to return a Result'
        Write-Verbose -Message "$StatusID1 - $CurrentOperationID1"
        do {
          if ($i -gt $iMax) {
            Write-Error -Message "Could not find Object in AzureAD in the last $iMax Seconds" -Category ObjectNotFound -RecommendedAction 'Please verify Object has been created (UserPrincipalName); Continue with Set-TeamsResourceAccount'
            return
          }
          Write-Progress -Id 1 -ParentId 0 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -SecondsRemaining $($iMax - $i) -PercentComplete (($i * 100) / $iMax)
          Start-Sleep -Milliseconds 1000
          $i++
          $UserLicense = Get-AzureAdUserLicense "$Id"
        }
        while ( -not [string]$UserLicense.PhoneSystemStatus.contains('Success') )
      }
      #endregion

      #region Enterprise Voice
      if ( -not $UserObject.EnterpriseVoiceEnabled ) {
        Write-Information "TRYING:  User '$Id' - Enterprise Voice: Not enabled, trying to enable"
        $EVenabled = Enable-TeamsUserForEnterpriseVoice -UserPrincipalName $UserObject.UserPrincipalName
      }
      if ( -not $EVenabled ) {
        $Message = "User '$Id' Enterprise Voice: User could not be enabled for Enterprise Voice!"
        if ($Called) {
          Write-Warning -Message $Message
          return $false
        }
        else {
          throw [System.InvalidOperationException]::New("$Message")
        }
      }
      #endregion

      #region Validating Phone Number
      # Querying CurrentPhoneNumber
      try {
        $CurrentPhoneNumber = $CsUser.LineUri
        Write-Verbose -Message "Object '$Id' - Phone Number assigned currently: $CurrentPhoneNumber"
      }
      catch {
        $CurrentPhoneNumber = $null
        Write-Verbose -Message "Object '$Id' - Phone Number assigned currently: NONE"
      }

      if ( [String]::IsNullOrEmpty($PhoneNumber) ) {
        if ($CurrentPhoneNumber) {
          Write-Warning -Message "Object '$Id' - PhoneNumber is NULL or Empty. The Existing Number '$CurrentPhoneNumber' will be removed"
        }
        else {
          Write-Verbose -Message "Object '$Id' - PhoneNumber is NULL or Empty, but no Number is currently assigned. No Action taken"
        }
        $PhoneNumber = $null
      }
      else {
        #Number Type
        Write-Verbose -Message "Object '$Id' - Parsing Online Telephone Numbers (validating Number against Microsoft Calling Plan Numbers)"
        $MSNumber = ((Format-StringForUse -InputString "$PhoneNumber" -SpecialChars 'tel:+') -split ';')[0]
        $PhoneNumberIsMSNumber = Get-CsOnlineTelephoneNumber -TelephoneNumber $MSNumber -WarningAction SilentlyContinue
        Write-Verbose -Message "Provisioning for $(if ( $PhoneNumberIsMSNumber ) { 'Calling Plans' } else { 'Direct Routing'})"

        # Previous assignments
        $UserWithThisNumber = Find-TeamsUserVoiceConfig -PhoneNumber $E164Number -WarningAction SilentlyContinue

        #TEST the resolution for this BODGE: Assumes singular result (also apply to Set-TeamsUVC)
        #if ($UserWithThisNumber -and $UserWithThisNumber.UserPrincipalName -ne $UserPrincipalName) {
        if ($UserWithThisNumber -and $Id -notin $UserWithThisNumber.UserPrincipalName) {
          if ($Force) {
            Write-Warning -Message "Object '$Id' - Number '$LineUri' is currently assigned to User '$($UserWithThisNumber.UserPrincipalName)'. This assignment will be removed!"
          }
          else {
            Write-Error -Message "Object '$Id' - Number '$LineUri' is already assigned to another Object: '$($UserWithThisNumber.UserPrincipalName)'" -Category NotImplemented -RecommendedAction 'Please specify a different Number or use -Force to re-assign' -ErrorAction Stop
          }
        }
      }
      #endregion

      #region ACTION
      # Scavenging Phone Number
      if ( $Force ) {
        Write-Warning -Message 'Parameter Force - Scavenging Phone Number from all Objects where number is assigned. Validate carefully'
        foreach ($UserWTN in $UserWithThisNumber) {
          if ( $Id -ne $($UserWTN.UserPrincipalName) ) {
            Write-Verbose -Message "Object '$($UserWTN.UserPrincipalName)' - Scavenging Phone Number"
            try {
              SetNumber -UserPrincipalName $($UserWTN.UserPrincipalName) -PhoneNumber $null -PhoneNumberIsMSNumber $($UserWtn.InterpretedVoiceConfigType -eq 'CallingPlans') -UserType $UserWTN.ObjectType
            }
            catch {
              $Message = "User '$Id' - Error scavenging Phone Number: $($_.Exception.Message)"
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
      }

      #Removing Phone Number
      if ( $Force -or ([String]::IsNullOrEmpty($PhoneNumber)) ) {
        Write-Verbose -Message "Object '$Id' - Removing Phone Number"
        try {
          SetNumber -UserPrincipalName $Id -PhoneNumber $null -PhoneNumberIsMSNumber $PhoneNumberIsMSNumber -UserType $UserType
        }
        catch {
          $Message = "User '$Id' - Error removing Phone Number: $($_.Exception.Message)"
          if ($Called) {
            Write-Warning -Message $Message
            return $false
          }
          else {
            throw $_
          }
        }
      }

      #Setting Phone Number
      if ( -not ([String]::IsNullOrEmpty($PhoneNumber)) ) {
        Write-Verbose -Message "Object '$Id' - Applying Phone Number"
        try {
          SetNumber -UserPrincipalName $Id -PhoneNumber $PhoneNumber -PhoneNumberIsMSNumber $PhoneNumberIsMSNumber -UserType $UserType
        }
        catch {
          $Message = "User '$Id' - Error applying Phone Number: $($_.Exception.Message)"
          if ($Called) {
            Write-Warning -Message $Message
            return $false
          }
          else {
            throw $_
          }
        }
      }
      #endregion

      # Output
      if ($Called) {
        return $true
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
          SetPhoneNumber -UserObject $CsUser -UserLicense $UserLicense @Parameters
        }
      }
      'Object' {
        foreach ($O in $Object) {
          Write-Verbose -Message "[PROCESS] Processing provided CsOnlineUser Object for '$($O.UserPrincipalName)'"
          $UserLicense = Get-AzureAdUserLicense "$($O.UserPrincipalName)"
          SetPhoneNumber -UserObject $O -UserLicense $UserLicense @Parameters
        }
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Set-TeamsPhoneNumber
