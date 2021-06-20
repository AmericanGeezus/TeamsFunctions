# Module:   TeamsFunctions
# Function: Licensing
# Author:   David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live




function Set-TeamsUserLicense {
  <#
  .SYNOPSIS
    Changes the License of an AzureAD Object
  .DESCRIPTION
    Adds, removes or purges teams related Licenses from an AzureAD Object
    Supports all Licenses listed in Get-AzureAdLicense
    Supports all AzureAD Object that can receive Licenses and not just Teams Licenses
    Will verify major Licenses and their exclusivity, but not all.
    Verifies whether the Licenses selected are available on the Tenant before executing
  .PARAMETER UserPrincipalName
    The UserPrincipalName, ObjectId or Identity of the Object.
  .PARAMETER Add
    Optional. Licenses to be added (main function)
    Accepted Values can be retrieved with Get-AzureAdLicense (Column ParameterName)
  .PARAMETER Remove
    Optional. Licenses to be removed (alternative function)
    Accepted Values can be retrieved with Get-AzureAdLicense (Column ParameterName)
  .PARAMETER RemoveAll
    Optional Switch. Removes all licenses currently assigned (intended for replacements)
  .PARAMETER UsageLocation
    Optional String. ISO3166-Alpha2 CountryCode indicating the Country for the User. Required for Licensing
    If required, the script will try to apply the UsageLocation (pending right).
    If not provided, defaults to 'US'
  .PARAMETER PassThru
    Optional. Displays User License Object after action.
  .EXAMPLE
    Set-TeamsUserLicense -UserPrincipalName Name@domain.com -Add MS365E5
    Applies the Microsoft 365 E5 License (SPE_E5) to Name@domain.com
  .EXAMPLE
    Set-TeamsUserLicense -UserPrincipalName Name@domain.com -Add PhoneSystem
    Applies the PhoneSystem Add-on License (MCOEV) to Name@domain.com
    This requires a main license to be present as PhoneSystem is an add-on license
  .EXAMPLE
    Set-TeamsUserLicense -UserPrincipalName Name@domain.com -Add MS365E3,PhoneSystem
    Set-TeamsUserLicense -UserPrincipalName Name@domain.com -Add @('MS365E3','PhoneSystem')
    Applies the Microsoft 365 E3 License (SPE_E3) and PhoneSystem Add-on License (MCOEV) to Name@domain.com
  .EXAMPLE
    Set-TeamsUserLicense -UserPrincipalName Name@domain.com -Add O365E5 -Remove SFBOP2
    Special Case Scenario to replace a specific license with another.
    Replaces Skype for Business Online Plan 2 License (MCOSTANDARD) with the Office 365 E5 License (ENTERPRISEPREMIUM).
  .EXAMPLE
    Set-TeamsUserLicense -UserPrincipalName Name@domain.com -Add PhoneSystem_VirtualUser -RemoveAll
    Special Case Scenario for Resource Accounts to swap licenses for a Phone System VirtualUser License
    Replaces all Licenses currently on the User Name@domain.com with the Phone System Virtual User (MCOEV_VIRTUALUSER) License
  .EXAMPLE
    Set-TeamsUserLicense -UserPrincipalName Name@domain.com -Remove PhoneSystem
    Removes the Phone System License from the Object.
  .EXAMPLE
    Set-TeamsUserLicense -UserPrincipalName Name@domain.com -RemoveAll
    Removes all licenses the Object is currently provisioned for!
  .NOTES
    Many license packages are available, the following Licenses are most predominant:
    - Main License Packages
      - Microsoft 365 E5 License - Microsoft365E5 (SPE_E5)
      - Microsoft 365 E3 License - Microsoft365E3 (SPE_E3)  #For Teams EV this requires PhoneSystem as an add-on!
      - Office 365 E5 License - Microsoft365E5 (ENTERPRISEPREMIUM)
      - Office 365 E5 without Audio Conferencing License - Microsoft365E5noAudioConferencing (ENTERPRISEPREMIUM_NOPSTNCONF)  #For Teams EV this requires AudioConferencing and PhoneSystem as an add-on!
      - Office 365 E3 License - Microsoft365E3 (ENTERPRISEPACK) #For Teams EV this requires PhoneSystem as an add-on!
      - Skype for Business Online (Plan 2) (MCOSTANDARD)   #For Teams EV this requires PhoneSystem as an add-on!
    - Add-On Licenses (Require Main License Package from above)
      - Audio Conferencing License - AudioConferencing (MCOMEETADV)
      - Phone System - PhoneSystem (MCOEV)
    - Standalone Licenses (Special)
      - Common Area Phone License (MCOCAP)  #Cheaper, but limits the Object to a Common Area Phone (no mailbox)
      - Phone System Virtual User License (PHONESYSTEM_VIRTUALUSER)  #Only use for Resource Accounts!
    - Microsoft Calling Plan Licenses
      - Domestic Calling Plan - DomesticCallingPlan (MCOPSTN1)
      - Domestic and International Calling Plan - InternationalCallingPlan (MCOPSTN2)

    Data in Get-AzureAdLicense as per Microsoft Docs Article: Published Service Plan IDs for Licensing
    https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference#service-plans-that-cannot-be-assigned-at-the-same-time
  .INPUTS
    System.String
  .OUTPUTS
    System.Void - Default Behavior
    System.Object - With Switch PassThru
  .COMPONENT
    Licensing
  .FUNCTIONALITY
    This script changes the AzureAD Object provided by adding or removing Licenses relevant to Teams
    Calls New-AzureAdLicenseObject from this Module in order to run Set-AzureADUserLicense.
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Set-TeamsUserLicense.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Licensing.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_Licensing
  .LINK
    about_UserManagement
  .LINK
    Get-TeamsTenantLicense
  .LINK
    Get-TeamsUserLicense
  .LINK
    Get-TeamsUserLicenseServicePlan
  .LINK
    Set-TeamsUserLicense
  .LINK
    Test-TeamsUserLicense
  .LINK
    Get-AzureAdLicense
  .LINK
    Get-AzureAdLicenseServicePlan
  .LINK
    Enable-AzureAdUserLicenseServicePlan
  .LINK
    Disable-AzureAdUserLicenseServicePlan
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = 'Required for performance. Removed with Disconnect-Me')]
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Add')]
  [OutputType([Void])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(ParameterSetName = 'Add', Mandatory, HelpMessage = 'License(s) to be added to this Object')]
    [Parameter(ParameterSetName = 'Remove', HelpMessage = 'License(s) to be added to this Object')]
    [Parameter(ParameterSetName = 'RemoveAll', HelpMessage = 'License(s) to be added to this Object')]
    [ValidateScript( {
        $LicenseParams = (Get-AzureAdLicense -WarningAction SilentlyContinue -ErrorAction SilentlyContinue).ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $LicenseParams) { return $true } else {
          throw [System.Management.Automation.ValidationMetadataException] "Parameter 'Add' - Invalid license string. Supported Parameternames can be found with Get-AzureAdLicense"
          return $false
        }
      })]
    [Alias('License', 'AddLicense', 'AddLicenses')]
    [string[]]$Add,

    [Parameter(ParameterSetName = 'Remove', Mandatory, HelpMessage = 'License(s) to be removed from this Object')]
    [ValidateScript( {
        $LicenseParams = (Get-AzureAdLicense -WarningAction SilentlyContinue -ErrorAction SilentlyContinue).ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $LicenseParams) { return $true } else {
          throw [System.Management.Automation.ValidationMetadataException] "Parameter 'Remove' - Invalid license string. Supported Parameternames can be found with Get-AzureAdLicense"
          return $false
        }
      })]
    [Alias('RemoveLicense', 'RemoveLicenses')]
    [string[]]$Remove,

    [Parameter(ParameterSetName = 'RemoveAll', Mandatory, HelpMessage = 'Switch to indicate that all Licenses should be removed')]
    [Alias('RemoveAllLicenses')]
    [Switch]$RemoveAll,

    [Parameter(HelpMessage = 'Usage Location to be set if not already applied')]
    [string]$UsageLocation = 'US',

    [Parameter(Mandatory = $false)]
    [switch]$PassThru

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) {
      break
    }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Debug')) {
      $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference')
    }
    else {
      $DebugPreference = 'Continue'
    }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) {
      $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction')
    }
    else {
      $InformationPreference = 'Continue'
    }

    # Loading License Array
    if (-not $global:TeamsFunctionsMSAzureAdLicenses) {
      $global:TeamsFunctionsMSAzureAdLicenses = Get-AzureAdLicense -WarningAction SilentlyContinue
    }

    $AllLicenses = $null
    $AllLicenses = $global:TeamsFunctionsMSAzureAdLicenses

    #region Input verification
    # All Main licenses are mutually exclusive
    # Domestic and International are mutually exclusive
    # Common AreaPhone and PhoneSystemVirtualUser are exclusive
    # AudioConf only for O365E5NoConf, E3 Licenses and SFBOP2
    # PhoneSystem only for E3 Licenses and SFBOP2
    <#
        'Microsoft365E5', 'Microsoft365E3',
        'Office365E5', 'Office365E5NoAudioConferencing', 'Office365E3', 'SkypeOnlinePlan2',
        'AudioConferencing', 'PhoneSystem', 'PhoneSystemVirtualUser', 'CommonAreaPhone'
        'DomesticCallingPlan','InternationalCallingPlan'
    #>
    try {
      if ($PSBoundParameters.ContainsKey('Add') -and $PSBoundParameters.ContainsKey('Remove')) {
        # Check if any are listed in both!
        Write-Verbose -Message 'Validating input for Add and Remove (identifying inconsistencies)'

        foreach ($Lic in $Add) {
          if ($Lic -in $Remove) {
            Write-Error -Message "Invalid combination. '$Lic' cannot be added AND removed" -Category LimitsExceeded -RecommendedAction 'Please specify only once!' -ErrorAction Stop
          }
        }
      }

      if ($PSBoundParameters.ContainsKey('Add')) {
        Write-Verbose -Message 'Validating input for Adding Licenses (identifying inconsistencies)'
        #region Disclaimer
        # Checking any other combinations then the verified
        if ( -not ('Microsoft365E3' -in $Add -or 'Office365E5' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add`
              -or 'PhoneSystem' -in $Add -or 'AudioConferencing' -in $Add)) {
          Write-Warning -Message 'License combination not verified. Errors due to incompatibilities may occur!'
          Write-Information 'TODO: Please check yourself which Licenses may not be assigned together'
        }
        #endregion

        #region Main Licenses
        #region Microsoft 365
        # Checking combinations for Microsoft365E5
        if ('Microsoft365E5' -in $Add) {
          if ('Microsoft365E3' -in $Add -or 'Office365E5' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add`
              -or 'PhoneSystem' -in $Add -or 'AudioConferencing' -in $Add) {
            Write-Error -Message 'Invalid combination of Main Licenses' -Category LimitsExceeded -RecommendedAction 'Please select only one Main License!' -ErrorAction Stop
          }
        }

        # Checking combinations for Microsoft365E3
        if ('Microsoft365E3' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Office365E5' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add) {
            Write-Error -Message 'Invalid combination of Main Licenses' -Category LimitsExceeded -RecommendedAction 'Please select only one Main License!' -ErrorAction Stop
          }
        }
        #endregion

        #region Office 365
        # Checking combinations for Office365E5
        if ('Office365E5' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Microsoft365E3' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add`
              -or 'PhoneSystem' -in $Add -or 'AudioConferencing' -in $Add) {
            Write-Error -Message 'Invalid combination of Main Licenses' -Category LimitsExceeded -RecommendedAction 'Please select only one Main License!' -ErrorAction Stop
          }
        }

        # Checking combinations for Office365E5NoAudioConferencing
        if ('Office365E5NoAudioConferencing' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Microsoft365E3' -in $Add -or 'Office365E5' -in $Add `
              -or 'Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add) {
            Write-Error -Message 'Invalid combination of Main Licenses' -Category LimitsExceeded -RecommendedAction 'Please select only one Main License!' -ErrorAction Stop
          }
        }

        # Checking combinations for Office365E3
        if ('Office365E3' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Office365E5' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'Microsoft365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add) {
            Write-Error -Message 'Invalid combination of Main Licenses' -Category LimitsExceeded -RecommendedAction 'Please select only one Main License!' -ErrorAction Stop
          }
        }
        #endregion

        #region Skype Online Plan2
        # Checking combinations for SkypeOnlinePlan2
        if ('SkypeOnlinePlan2' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Office365E5' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'Office365E3' -in $Add -or 'Microsoft365E3' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add) {
            Write-Error -Message 'Invalid combination of Main Licenses' -Category LimitsExceeded -RecommendedAction 'Please select only one Main License!' -ErrorAction Stop
          }
        }
        #endregion
        #endregion

        #region Standalone Licenses
        # Checking combinations for CommonAreaPhone
        if ('CommonAreaPhone' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Office365E5' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'Microsoft365E3' -in $Add -or 'PhoneSystemVirtualUser' -in $Add) {
            Write-Error -Message 'Invalid combination of Main Licenses' -Category LimitsExceeded -RecommendedAction 'Please select only one Main License!' -ErrorAction Stop
          }
        }

        # Checking combinations for PhoneSystemVirtualUser
        if ('PhoneSystemVirtualUser' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Office365E5' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'Microsoft365E3' -in $Add) {
            Write-Error -Message 'Invalid combination of Main Licenses' -Category LimitsExceeded -RecommendedAction 'Please select only one Main License!' -ErrorAction Stop
          }
        }
        #endregion

        #region Add-on Licenses
        # Checking combinations for PhoneSystem
        if ('PhoneSystem' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Office365E5' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add) {
            Write-Error -Message "Invalid combination. 'PhoneSystem' cannot be added to the Main License specified (already integrated)" -Category LimitsExceeded -RecommendedAction "Please remove 'PhoneSystem'" -ErrorAction Stop
          }
          elseif ('Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add) {
            Write-Verbose -Message "Combination correct. 'PhoneSystem' can be added"
          }
        }

        # Checking combinations for Microsoft365E3
        if ('AudioConferencing' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Office365E5' -in $Add `
              -or 'Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add) {
            Write-Error -Message "Invalid combination. 'AudioConferencing' cannot be added to the Main License specified (already integrated)" -Category LimitsExceeded -RecommendedAction "Please remove 'AudioConferencing'" -ErrorAction Stop
          }
          elseif ('Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add) {
            Write-Verbose -Message "Combination correct. 'AudioConferencing' can be added"
          }
        }
        #endregion

        #region Calling Plans
        # Checking combinations for Calling Plans
        if ('DomesticCallingPlan' -in $Add -and 'InternationalCallingPlan' -in $Add) {
          Write-Error -Message 'Invalid combination of Calling Plan Licenses' -Category LimitsExceeded -RecommendedAction 'Please select only one Calling Plan License!' -ErrorAction Stop
        }
        #endregion
      }

      if ($PSBoundParameters.ContainsKey('Remove')) {
        Write-Verbose -Message 'Validating input for Removing (identifying inconsistencies)'
        # No checks needed that aren't captured by the Add and Remove check! - Leaving this here just in case.
        Write-Verbose -Message 'NOTE: Currently no checks for Remove Licenses necessary'
      }

      if ($PSBoundParameters.ContainsKey('RemoveAll') -and -not $PSBoundParameters.ContainsKey('Add')) {
        Write-Warning -Message 'This will leave the Object without a License!'
        $title = 'Confirm'
        $question = 'Are you sure you want to proceed?'
        $choices = '&Yes', '&No'

        $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
        if ($decision -ne 0) {
          throw 'No consent given. Aborting execution!'
        }
      }

    }
    catch {
      throw
    }

    #endregion

    #region Queries
    # Querying licenses in the Tenant to compare SKUs
    try {
      Write-Verbose -Message 'Querying Licenses from the Tenant'
      $TenantLicenses = Get-TeamsTenantLicense -Detailed -ErrorAction STOP
    }
    catch {
      Write-Warning $_
      return
    }
    #endregion

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($ID in $UserPrincipalName) {
      #region Object Verification
      # Querying User
      try {
        #CHECK Piping with UserPrincipalName, Identity from Get-CsOnlineUser
        $UserObject = Get-AzureADUser -ObjectId "$ID" -WarningAction SilentlyContinue -ErrorAction STOP
        Write-Verbose -Message "[PROCESS] Processing '$($UserObject.UserPrincipalName)'"
      }
      catch {
        Write-Error -Message "User '$ID' - Account not valid" -Category ObjectNotFound -RecommendedAction 'Verify UserPrincipalName'
        continue
      }

      # Checking Usage Location is Set
      if ($null -eq $UserObject.UsageLocation) {
        try {
          if ($PSCmdlet.ShouldProcess("$ID", "Set-AzureADUser -UsageLocation $UsageLocation")) {
            Set-AzureADUser -ObjectId $UserObject.ObjectId -UsageLocation $UsageLocation -ErrorAction Stop
            if ($PSBoundParameters.ContainsKey('UsageLocation')) {
              Write-Verbose -Message "User '$ID' UsageLocation set to $UsageLocation"
            }
            else {
              Write-Warning -Message "User '$ID' UsageLocation set to $UsageLocation (Default)- Please correct if necessary"
            }
          }
        }
        catch {
          Write-Error -Message 'Usage Location not set' -Category InvalidResult -RecommendedAction 'Set Usage Location, then try assigning a License again'
          continue
        }
      }
      else {
        Write-Verbose -Message "User '$ID' UsageLocation already set ($UsageLocation)"
      }

      # License Query from Object
      $ObjectAssignedLicenses = Get-AzureADUserLicenseDetail -ObjectId $UserObject.ObjectId -WarningAction SilentlyContinue
      #endregion

      Write-Verbose -Message 'Processing Licenses'
      #region Add
      if ($PSBoundParameters.ContainsKey('Add')) {
        Write-Verbose -Message "Parsing 'Add'"
        try {
          # Creating Array of $AddSkuIds to pass to New-AzureAdLicenseObject
          [System.Collections.ArrayList]$AddSkuIds = @()
          foreach ($AddLic in $Add) {
            $License = $AllLicenses | Where-Object ParameterName -EQ $AddLic
            if ($PSBoundParameters.ContainsKey('Debug')) {
              "Function: $($MyInvocation.MyCommand.Name): License:", ($License | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
            }
            # Verifying user has not already this license assigned
            if ( $License.SkuPartNumber -in $ObjectAssignedLicenses.SkuPartNumber) {
              Write-Warning -Message "Adding License '$($License.ProductName)' - License already assigned to the User, omitting!"
              continue
            }
            else {
              # Verifying license is available in the Tenant
              if (-not ( $License.SkuPartNumber -in $($TenantLicenses.SkuPartNumber))) {
                Write-Error -Message "Adding License '$($License.ProductName)' - License not found in the Tenant"
                continue
              }
              else {
                $RemainingLicenses = ($TenantLicenses | Where-Object { $_.SkuPartNumber -eq $License.SkuPartNumber }).Remaining
                if ($RemainingLicenses -lt 1) {
                  Write-Error -Message "Adding License '$($License.ProductName)' - License found in the Tenant, but no units available"
                  continue
                }
                else {
                  Write-Verbose -Message "Adding License '$($License.ProductName)' - License found in the Tenant. Free unit available!"
                }
              }
            }
            Write-Verbose -Message "Adding License '$($License.ProductName)' - License not assigned, adding to list"
            [void]$AddSkuIds.Add("$($License.SkuId)")
          }
        }
        catch {
          throw
        }
      }
      #endregion

      #region Remove
      if ($PSBoundParameters.ContainsKey('Remove')) {
        Write-Verbose -Message "Parsing 'Remove'"
        try {
          # Creating Array of $RemoveSkuIds to pass to New-AzureAdLicenseObject
          [System.Collections.ArrayList]$RemoveSkuIds = @()
          foreach ($RemoveLic in $Remove) {
            $RemoveSku = ($AllLicenses | Where-Object ParameterName -EQ $RemoveLic).('SkuId')
            $RemoveLicName = ($AllLicenses | Where-Object ParameterName -EQ $RemoveLic).('ProductName')
            if ($RemoveSku -in $ObjectAssignedLicenses.SkuId) {
              Write-Verbose -Message "Removing License '$RemoveLicName' - License assigned, adding to list"
              [void]$RemoveSkuIds.Add("$RemoveSku")
            }
            else {
              Write-Warning -Message "Removing License '$RemoveLicName' - License not assigned to the User, omitting!"
            }
          }
        }
        catch {
          throw
        }
      }
      #endregion


      #region Creating User specific License Object
      $NewLicenseObjParameters = $null
      if ($PSBoundParameters.ContainsKey('Add')) {
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          "Function: $($MyInvocation.MyCommand.Name): AddSkuIds:", ($AddSkuIds | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }
        $NewLicenseObjParameters += @{'SkuId' = $AddSkuIds }
      }
      if ($PSBoundParameters.ContainsKey('Remove')) {
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          "Function: $($MyInvocation.MyCommand.Name): RemoveSkuId:", ($RemoveSkuId | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }
        $NewLicenseObjParameters += @{'RemoveSkuId' = $RemoveSkuIds }
      }
      if ($PSBoundParameters.ContainsKey('RemoveAll')) {
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          "Function: $($MyInvocation.MyCommand.Name): RemoveSkuId:", ($RemoveSkuId | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }
        $NewLicenseObjParameters += @{'RemoveSkuId' = $ObjectAssignedLicenses.SkuId }
      }

      $LicenseObject = New-AzureAdLicenseObject @NewLicenseObjParameters
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        "Function: $($MyInvocation.MyCommand.Name): LicenseObject:", ($LicenseObject | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
      }
      Write-Verbose -Message 'Creating License Object: Done'
      #endregion

      # Executing Assignment
      if ($PSCmdlet.ShouldProcess("$ID", 'Set-AzureADUserLicense')) {
        #Assign $LicenseObject to each User
        Write-Verbose -Message "'$ID' - Setting Licenses"
        try {
          $null = Set-AzureADUserLicense -ObjectId "$ID" -AssignedLicenses $LicenseObject -ErrorAction Stop
        }
        catch {
          $Exception = $_.Exception.Message
          switch -wildcard ( $Exception ) {
            '*No license changes provided*' {
              Write-Information 'INFO:   No Licenses have changed. Please validate already assigned licenses.'
            }
            '*depends on the service plan(s)*' {
              throw "Set-TeamsUserLicense failed with dependency issue: $Exception"
            }
            '*does not exist or one of its queried reference-property objects are not present*' {
              throw "Set-TeamsUserLicense failed to find the User '$ID'"
            }
            Default {
              throw "Set-TeamsUserLicense failed to run Set-AzureADUserLicense with Exception: $Exception"
            }
          }
        }
        Write-Verbose -Message "'$ID' - Setting Licenses: Done"
      }

      # Output
      if ($PassThru) {
        Get-TeamsUserLicense -Identity "$Identity" -DisplayAll
      }

    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Set-TeamsUserLicense
