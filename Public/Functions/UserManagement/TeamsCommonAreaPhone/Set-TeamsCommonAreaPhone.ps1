# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  24-MAY-2021
# Status:   RC




function Set-TeamsCommonAreaPhone {
  <#
  .SYNOPSIS
    Changes settings for a Common Area Phone
  .DESCRIPTION
    Applies settings relevant to a Common Area Phone.
    This includes DisplayName, UsageLocation, License, IP Phone Policy, Calling Policy and Call Park Policy can be applied.
  .PARAMETER UserPrincipalName
    Required. The UPN for the new CommonAreaPhone. Invalid characters are stripped from the provided string
  .PARAMETER DisplayName
    Optional. The Name it will show up as in Teams. Invalid characters are stripped from the provided string
  .PARAMETER UsageLocation
    Required. Two Digit Country Code of the Location of the entity. Should correspond to the Phone Number.
    Before a License can be assigned, the account needs a Usage Location populated.
  .PARAMETER License
    Optional. Specifies the License to be assigned: PhoneSystem or PhoneSystem_VirtualUser
    If not provided, will default to PhoneSystem_VirtualUser
    Unlicensed Objects can exist, but cannot be assigned a phone number
    PhoneSystem is an add-on license and cannot be assigned on its own. it has therefore been deactivated for now.
  .PARAMETER IPPhonePolicy
    Optional. Adds an IP Phone Policy to the User
  .PARAMETER TeamsCallingPolicy
    Optional. Adds a Calling Policy to the User
  .PARAMETER TeamsCallParkPolicy
    Optional. Adds a Call Park Policy to the User
  .PARAMETER PassThru
    Optional. Displays the Object after execution.
  .EXAMPLE
    Set-TeamsCommonAreaPhone -UserPrincipalName MyLobbyPhone@TenantName.onmicrosoft.com -Displayname "Lobby {Phone}"
    Changes the Object MyLobbyPhone@TenantName.onmicrosoft.com. DisplayName will be normalised to "Lobby Phone" and applied.
  .EXAMPLE
    Set-TeamsCommonAreaPhone -UserPrincipalName MyLobbyPhone@TenantName.onmicrosoft.com -UsageLocation US -License CommonAreaPhone
    Changes the Object MyLobbyPhone@TenantName.onmicrosoft.com. Usage Location is set to 'US' and the CommonAreaPhone License is assigned.
  .EXAMPLE
    Set-TeamsCommonAreaPhone -UserPrincipalName MyLobbyPhone@TenantName.onmicrosoft.com -License Office365E3,PhoneSystem
    Changes the Object MyLobbyPhone@TenantName.onmicrosoft.com. Usage Location is required to be set. Assigns the Office 365 E3 License as well as PhoneSystem
  .EXAMPLE
    Set-TeamsCommonAreaPhone -UserPrincipalName "MyLobbyPhone@TenantName.onmicrosoft.com" -IPPhonePolicy "My IPP" -TeamsCallingPolicy "CallP" -TeamsCallParkPolicy "CallPark" -PassThru
    Applies IPPhonePolicy, TeamsCallingPolicy and TeamsCallParkPolicy to the Common Area Phone
    Displays the Common Area Phone Object afterwards
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Execution requires User Admin Role in Azure AD
    This CmdLet deliberately does not apply a Phone Number to the Object. To do so, please run New-TeamsUserVoiceConfig
    or Set-TeamsUserVoiceConfig. For a full Voice Configuration apply a Calling Plan or Online Voice Routing Policy
    a Phone Number and optionally a Tenant Dial Plan.
    This Script only covers relevant elements for Common Area Phones themselves.
  .COMPONENT
    UserManagement
  .FUNCTIONALITY
    Changes a Common Area Phone in AzureAD for use in Teams
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Set-TeamsCommonAreaPhone.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsUserVoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_UserManagement
  .LINK
    about_TeamsUserVoiceConfiguration
  .LINK
    Get-TeamsCommonAreaPhone
  .LINK
    New-TeamsCommonAreaPhone
  .LINK
    Set-TeamsCommonAreaPhone
  .LINK
    Remove-TeamsCommonAreaPhone
  .LINK
    Find-TeamsUserVoiceConfig
  .LINK
    Get-TeamsUserVoiceConfig
  .LINK
    New-TeamsUserVoiceConfig
  .LINK
    Set-TeamsUserVoiceConfig
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
  [Alias('Set-TeamsCAP')]
  [OutputType([System.Void])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'UPN of the Object to query.')]
    [ValidateScript( {
        If ($_ -match '@') { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Parameter UserPrincipalName must be a valid UPN'
          $false
        }
      })]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'Display Name for this Object')]
    [string]$DisplayName,

    [Parameter(HelpMessage = 'Usage Location to assign')]
    [string]$UsageLocation,

    [Parameter(HelpMessage = 'License to be assigned')]
    [ValidateScript( {
        $LicenseParams = (Get-AzureAdLicense -WarningAction SilentlyContinue -ErrorAction SilentlyContinue).ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $LicenseParams) { return $true } else {
          throw [System.Management.Automation.ValidationMetadataException] "Parameter 'License' - Invalid license string. Supported Parameternames can be found with Get-AzureAdLicense"
          return $false
        }
      })]
    [string]$License,

    [Parameter(HelpMessage = 'IP Phone Policy')]
    [string]$IPPhonePolicy,

    [Parameter(HelpMessage = 'Teams Calling Policy')]
    [string]$TeamsCallingPolicy,

    [Parameter(HelpMessage = 'Teams Call Park Policy')]
    [string]$TeamsCallParkPolicy,

    [Parameter(HelpMessage = 'No output is written by default, Switch PassThru will return changed object')]
    [switch]$PassThru

  ) #param

  begin {
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $Parameters = @{}

    ForEach ($User in $UserPrincipalName) {
      # Initialising counters for Progress bars
      [int]$step = 0
      [int]$sMax = 2
      if ( $DisplayName ) { $sMax++ }
      if ( $UsageLocation ) { $sMax++ }
      if ( $License ) { $sMax = $sMax + 2 }
      if ( $PassThru ) { $sMax++ }

      #region PREPARATION
      $Status = 'Verifying input'
      #region Lookup of UserPrincipalName
      $Operation = 'Querying Object'
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      try {
        #Trying to query the Resource Account
        $CsOnlineUser = (Get-CsOnlineUser -Identity "$User" -WarningAction SilentlyContinue -ErrorAction STOP)
        $CurrentDisplayName = $CsOnlineUser.DisplayName
        Write-Verbose -Message "'$User' Teams Object found: '$CurrentDisplayName'"
        $Parameters += @{ 'ObjectId' = $CsOnlineUser.ObjectId }
      }
      catch {
        # If CsOnlineUser not found, trying AzureAdUser
        try {
          Write-Verbose -Message "'$User' - Querying User Account (AzureAdUser)"
          $AdUser = Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction STOP
          $CsOnlineUser = $AdUser
          $CurrentDisplayName = $AdUser.DisplayName
          Write-Warning -Message "'$User' - found in AzureAd but not in Teams (CsOnlineUser)!"
        }
        catch [Microsoft.Open.AzureAD16.Client.ApiException] {
          Write-Error -Message "'$User' not found in Teams (CsOnlineUser) nor in Azure Ad (AzureAdUser). Please validate UserPrincipalName. Exception message: Resource '$User' does not exist or one of its queried reference-property objects are not present." -Category ObjectNotFound
          continue
        }
        catch {
          Write-Error -Message "'$User' not found. Error encountered: $($_.Exception.Message)" -Category ObjectNotFound
          continue
        }
      }
      #endregion

      #region Normalising $DisplayName
      if ($PSBoundParameters.ContainsKey('DisplayName')) {
        if ($User.IsArray) {
          Write-Warning -Message "'$User' Changing DisplayName for Array input disabled to avoid accidents."
        }
        else {
          $Operation = 'Normalising DisplayName'
          $step++
          Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "$Status - $Operation"
          $Name = Format-StringForUse -InputString $DisplayName -As DisplayName
          Write-Verbose -Message "DisplayName normalised to: '$Name'"
          $Parameters += @{ 'DisplayName' = "$Name" }
        }
      }
      else {
        $Name = $CurrentDisplayName
      }
      #endregion

      #region UsageLocation
      $CurrentUsageLocation = $CsOnlineUser.UsageLocation
      if ($PSBoundParameters.ContainsKey('UsageLocation')) {
        $Operation = 'Parsing UsageLocation'
        $step++
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"

        if ($Usagelocation -eq $CurrentUsageLocation) {
          Write-Verbose -Message "'$Name' Usage Location already set to: $CurrentUsageLocation"
        }
        else {
          Write-Verbose -Message "'$Name' Usage Location will be set to: $Usagelocation"
          $Parameters += @{ 'UsageLocation' = "$UsageLocation" }
        }
      }
      else {
        if ($null -ne $CurrentUsageLocation) {
          Write-Verbose -Message "'$Name' Usage Location currently set to: $CurrentUsageLocation"
        }
        else {
          if ($PSBoundParameters.ContainsKey('License')) {
            Write-Error -Message "'$Name' Usage Location not set!" -Category ObjectNotFound -RecommendedAction 'Please run command again and specify -UsageLocation'# -ErrorAction Stop
            return
          }
          else {
            Write-Warning -Message "'$Name' Usage Location not set! This is a requirement for License assignment and Phone Number"
          }
        }
      }
      #endregion

      #region Current License
      $Operation = 'License Query (current)'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      if ($PSBoundParameters.ContainsKey('License')) {
        $CurrentLicense = $null
        # Determining license Status of Object
        if (Test-TeamsUserLicense -Identity "$UPN" -License CommonAreaPhone) {
          $CurrentLicense = 'CommonAreaPhone'
        }
        elseif (Test-TeamsUserLicense -Identity "$UPN" -ServicePlan TEAMS1) {
          $CurrentLicense = 'Teams'
          #CHECK add validation for PhoneSystem too (only needed when applying a number which we don't do here)
        }
        if ($null -ne $CurrentLicense) {
          Write-Verbose -Message "'$Name ($UPN)' Current License assigned: $CurrentLicense"
        }
        else {
          Write-Verbose -Message "'$Name ($UPN)' Current License assigned: NONE"
        }
      }
      #endregion

      #Common Parameters
      $Parameters += @{ 'ErrorAction' = 'STOP' }
      #endregion


      #region ACTION
      $Status = 'Azure Ad User'
      #region Setting Object
      $Operation = 'Applying Settings'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      try {
        #Trying to create the Common Area Phone
        Write-Verbose -Message "'$Name' Creating Common Area Phone with New-AzureAdUser..."
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          "Function: $($MyInvocation.MyCommand.Name) - Parameters", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }
        if ($PSCmdlet.ShouldProcess("$UPN", 'Set-AzureAdUser')) {
          $null = Set-AzureADUser @Parameters
          $AzureAdUser = Get-AzureADUser -ObjectId $Parameters.ObjectId
        }
        else {
          return
        }
      }
      catch {
        # Catching anything
        throw [System.Management.Automation.SetValueException] "Application of settings failed: $($_.Exception.Message)"
        return
      }
      #endregion

      #region Licensing
      if ($PSBoundParameters.ContainsKey('License')) {
        # Verifying License is available to be assigned
        # Determining available Licenses from Tenant
        $Operation = 'Querying Tenant Licenses'
        $step++
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"
        $TenantLicenses = Get-TeamsTenantLicense

        if ($License -eq $CurrentLicense) {
          #BODGE This does not properly catch Licenses that are already assigned as $CurrentLicense is either CAP or PhoneSystem
          # No action required
          Write-Information "'$Name ($UPN)' License '$License' already assigned."
          $IsLicensed = $true
        }
        # Verifying License is available
        elseif ($License -eq 'CommonAreaPhone') {
          $RemainingCAPLicenses = ($TenantLicenses | Where-Object { $_.SkuPartNumber -eq 'MCOCAP' }).Remaining
          Write-Verbose -Message "INFO: $RemainingCAPLicenses Common Area Phone Licenses remaining"
          if ($RemainingCAPLicenses -lt 1) {
            Write-Error -Message 'ERROR: No free Common Area Phone License remaining in the Tenant.' -ErrorAction Stop
          }
          else {
            try {
              if ($PSCmdlet.ShouldProcess("$UPN", 'Set-TeamsUserLicense -Add CommonAreaPhone')) {
                $null = (Set-TeamsUserLicense -Identity "$UPN" -Add $License -ErrorAction STOP)
                Write-Information "'$Name' License assignment - '$License' SUCCESS"
                $IsLicensed = $true
              }
            }
            catch {
              Write-Error -Message "'$Name' License assignment failed for '$License'"
              Write-Debug $_
            }
          }
          else {
            try {
              if ($PSCmdlet.ShouldProcess("$UPN", "Set-TeamsUserLicense -Add $License")) {
                $null = (Set-TeamsUserLicense -Identity "$UPN" -Add $License -ErrorAction STOP)
                Write-Information "'$Name' License assignment - '$License' SUCCESS"
                $IsLicensed = $true
              }
            }
            catch {
              Write-Error -Message "'$Name' License assignment failed for '$License'"
            }
          }
        }
      }
      #endregion

      #region Policies
      $Operation = 'Applying Policies'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      if ($null -eq $CurrentLicense -and -not $IsLicensed) {
        Write-Error -Message 'Policies can only be assigned to licensed objects.' -Category ResourceUnavailable -RecommendedAction 'Please apply a license before assigning any Policy.'
      }
      else {
        if ($PSBoundParameters.ContainsKey('IPPhonePolicy')) {
          Grant-CsTeamsIPPhonePolicy -Identity $AzureAdUser.ObjectId -PolicyName $IPPhonePolicy
        }

        if ($PSBoundParameters.ContainsKey('TeamsCallingPolicy')) {
          Grant-CsTeamsCallingPolicy -Identity $AzureAdUser.ObjectId -PolicyName $TeamsCallingPolicy
        }

        if ($PSBoundParameters.ContainsKey('TeamsCallParkPolicy')) {
          Grant-CsTeamsCallParkPolicy -Identity $AzureAdUser.ObjectId -PolicyName $TeamsCallParkPolicy
        }
      }
      #endregion
      #endregion

      #region OUTPUT
      if ($PassThru) {
        $Status = 'Validation'
        $Operation = 'Querying Object'
        $step++
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"

        $CommonAreaPhone = $null
        $CommonAreaPhone = Get-TeamsCommonAreaPhone -Identity "$UPN"
        Write-Output $CommonAreaPhone
      }

      Write-Progress -Id 0 -Status 'Complete' -Activity $MyInvocation.MyCommand -Completed
      #endregion

    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsCommonAreaPhone
