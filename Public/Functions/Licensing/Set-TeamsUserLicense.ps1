# Module:   TeamsFunctions
# Function: Licensing
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   PreLive

function Set-TeamsUserLicense {
  <#
      .SYNOPSIS
      Changes the License of an AzureAD Object
      .DESCRIPTION
      Adds, removes or purges teams related Licenses from an AzureAD Object
      Supports all Licenses listed in $TeamsLicenses, currently: 38 Licenses
      Uses friendly Names for Parameter Values, supports Arrays.
      Calls New-AzureAdLicenseObject from this Module in order to run Set-AzureADUserLicense.
      This will work with ANY AzureAD Object, not just for Teams, but only Licenses relevant to Teams are covered.
      Will verify major Licenses and their exclusivity, but not all.
      Verifies whether the Licenses selected are available on the Tenant before executing
      .PARAMETER Identity
      Required. UserPrincipalName of the Object to be manipulated
      .PARAMETER Add
      Optional. Licenses to be added (main function)
      Accepted Values are listed in $TeamsLicenses.ParameterName
      .PARAMETER Remove
      Optional. Licenses to be removed (alternative function)
      Accepted Values are listed in $TeamsLicenses.ParameterName
      .PARAMETER RemoveAll
      Optional Switch. Removes all licenses currently assigned (intended for replacements)
      .PARAMETER UsageLocation
      Optional String. ISO3166-Alpha2 CountryCode indicating the Country for the User. Required for Licensing
      If required, the script will try to apply the UsageLocation (pending right).
      If not provided, defaults to 'US'
      .EXAMPLE
      Set-TeamsUserLicense -Identity Name@domain.com -Add MS365E5
      Applies the Microsoft 365 E5 License (SPE_E5) to Name@domain.com
      .EXAMPLE
      Set-TeamsUserLicense -Identity Name@domain.com -Add PhoneSystem
      Applies the PhoneSystem Add-on License (MCOEV) to Name@domain.com
      This requires a main license to be present as PhoneSystem is an add-on license
      .EXAMPLE
      Set-TeamsUserLicense -Identity Name@domain.com -Add MS365E3,PhoneSystem
      Set-TeamsUserLicense -Identity Name@domain.com -Add @('MS365E3','PhoneSystem')
      Applies the Microsoft 365 E3 License (SPE_E3) and PhoneSystem Add-on License (MCOEV) to Name@domain.com
      .EXAMPLE
      Set-TeamsUserLicense -Identity Name@domain.com -Add O365E5 -Remove SFBOP2
      Special Case Scenario to replace a specific license with another.
      Replaces Skype for Business Online Plan 2 License (MCOSTANDARD) with the Office 365 E5 License (ENTERPRISEPREMIUM).
      .EXAMPLE
      Set-TeamsUserLicense -Identity Name@domain.com -Add PhoneSystem_VirtualUser -RemoveAll
      Special Case Scenario for Resource Accounts to swap licenses for a Phone System VirtualUser License
      Replaces all Licenses currently on the User Name@domain.com with the Phone System Virtual User (MCOEV_VIRTUALUSER) License
      .EXAMPLE
      Set-TeamsUserLicense -Identity Name@domain.com -Remove PhoneSystem
      Removes the Phone System License from the Object.
      .EXAMPLE
      Set-TeamsUserLicense -Identity Name@domain.com -RemoveAll
      Removes all licenses the Object is currently provisioned for!
      .NOTES
      Many license packages are available, the following Licenses are most predominant:
      # Main License Packages
      - Microsoft 365 E5 License - Microsoft365E5 (SPE_E5)
      - Microsoft 365 E3 License - Microsoft365E3 (SPE_E3)  #NOTE: For Teams EV this requires PhoneSystem as an add-on!
      - Office 365 E5 License - Microsoft365E5 (ENTERPRISEPREMIUM)
      - Office 365 E5 without Audio Conferencing License - Microsoft365E5noAudioConferencing (ENTERPRISEPREMIUM_NOPSTNCONF)  #NOTE: For Teams EV this requires AudioConferencing and PhoneSystem as an add-on!
      - Office 365 E3 License - Microsoft365E3 (ENTERPRISEPACK) #NOTE: For Teams EV this requires PhoneSystem as an add-on!
      - Skype for Business Online (Plan 2) (MCOSTANDARD)   #NOTE: For Teams EV this requires PhoneSystem as an add-on!

      # Add-On Licenses (Require Main License Package from above)
      - Audio Conferencing License - AudioConferencing (MCOMEETADV)
      - Phone System - PhoneSystem (MCOEV)

      # Standalone Licenses (Special)
      - Common Area Phone License (MCOCAP)  #NOTE: Cheaper, but limits the Object to a Common Area Phone (no mailbox)
      - Phone System Virtual User License (PHONESYSTEM_VIRTUALUSER)  #NOTE: Only use for Resource Accounts!

      # Microsoft Calling Plan Licenses
      - Domestic Calling Plan - DomesticCallingPlan (MCOPSTN1)
      - Domestic and International Calling Plan - InternationalCallingPlan (MCOPSTN2)

      # Data in $TeamsLicenses as per Microsoft Docs Article: Published Service Plan IDs for Licensing
      https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference#service-plans-that-cannot-be-assigned-at-the-same-time

      .COMPONENT
      Teams Migration and Enablement. License Assignment
      .ROLE
      Licensing
      .FUNCTIONALITY
      This script changes the AzureAD Object provided by adding or removing Licenses relevant to Teams
      .LINK
      Get-TeamsTenantLicense
      Get-TeamsUserLicense
      Add-TeamsUserLicense (deprecated)
      Test-TeamsUserLicense
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Add')]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string[]]$Identity,

    [Parameter(ParameterSetName = 'Add', Mandatory = $true, HelpMessage = 'License(s) to be added to this Object')]
    [Parameter(ParameterSetName = 'Remove', Mandatory = $false, HelpMessage = 'License(s) to be added to this Object')]
    [Parameter(ParameterSetName = 'RemoveAll', Mandatory = $false, HelpMessage = 'License(s) to be added to this Object')]
    [ValidateScript( {
        if ($_ -in $TeamsLicenses.ParameterName) {
          return $true
        }
        else {
          Write-Host "Parameter 'Add' - Invalid license string. Please specify a ParameterName from `$TeamsLicenses:" -ForegroundColor Red
          Write-Host "$($TeamsLicenses.ParameterName)"
          return $false
        }
      })]
    [Alias('License', 'AddLicense', 'AddLicenses')]
    [string[]]$Add,

    [Parameter(ParameterSetName = 'Remove', Mandatory, HelpMessage = 'License(s) to be removed from this Object')]
    [ValidateScript( {
        if ($_ -in $TeamsLicenses.ParameterName) {
          return $true
        }
        else {
          Write-Host "Parameter 'Remove' - Invalid license string. Please specify a ParameterName from `$TeamsLicenses:" -ForegroundColor Red
          Write-Host "$($TeamsLicenses.ParameterName)"
          return $false
        }
      })]
    [Alias('RemoveLicense', 'RemoveLicenses')]
    [string[]]$Remove,

    [Parameter(ParameterSetName = 'RemoveAll', Mandatory, HelpMessage = 'Switch to indicate that all Licenses should be removed')]
    [Alias('RemoveAllLicenses')]
    [Switch]$RemoveAll,

    [Parameter(HelpMessage = 'Usage Location to be set if not already applied')]
    [string]$UsageLocation = 'US'

  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

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

    #Loading License Array
    $AllLicenses = $null
    $AllLicenses = $TeamsLicenses

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
        Write-Verbose -Message "Validating input for Add and Remove (identifying inconsistencies)" -Verbose

        foreach ($Lic in $Add) {
          if ($Lic -in $Remove) {
            Write-Error -Message "Invalid combination. '$Lic' cannot be added AND removed" -Category LimitsExceeded -RecommendedAction "Please specify only once!" -ErrorAction Stop
          }
        }
      }

      if ($PSBoundParameters.ContainsKey('Add')) {
        Write-Verbose -Message "Validating input for Adding Licenses (identifying inconsistencies)" -Verbose
        #region Disclaimer
        # Checking any other combinations then the verified
        if ( -not ('Microsoft365E3' -in $Add -or 'Office365E5' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add`
              -or 'PhoneSystem' -in $Add -or 'AudioConferencing' -in $Add)) {
          Write-Warning -Message "License combination not verified. Errors due to incompatibilities may occur!"
          Write-Verbose -Message "Please check yourself which Licenses may not be assigned together" -Verbose
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
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
          }
        }

        # Checking combinations for Microsoft365E3
        if ('Microsoft365E3' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Office365E5' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add) {
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
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
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
          }
        }

        # Checking combinations for Office365E5NoAudioConferencing
        if ('Office365E5NoAudioConferencing' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Microsoft365E3' -in $Add -or 'Office365E5' -in $Add `
              -or 'Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add) {
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
          }
        }

        # Checking combinations for Office365E3
        if ('Office365E3' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Office365E5' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'Microsoft365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add) {
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
          }
        }
        #endregion

        #region Skype Online Plan2
        # Checking combinations for SkypeOnlinePlan2
        if ('SkypeOnlinePlan2' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Office365E5' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'Office365E3' -in $Add -or 'Microsoft365E3' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'PhoneSystemVirtualUser' -in $Add) {
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
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
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
          }
        }

        # Checking combinations for PhoneSystemVirtualUser
        if ('PhoneSystemVirtualUser' -in $Add) {
          if ('Microsoft365E5' -in $Add -or 'Office365E5' -in $Add -or 'Office365E5NoAudioConferencing' -in $Add `
              -or 'Office365E3' -in $Add -or 'SkypeOnlinePlan2' -in $Add `
              -or 'CommonAreaPhone' -in $Add -or 'Microsoft365E3' -in $Add) {
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
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
          Write-Error -Message "Invalid combination of Calling Plan Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Calling Plan License!" -ErrorAction Stop
        }
        #endregion
      }

      if ($PSBoundParameters.ContainsKey('Remove')) {
        Write-Verbose -Message "Validating input for Removing (identifying inconsistencies)"
        # No checks needed that aren't captured by the Add and Remove check! - Leaving this here just in case.
        Write-Verbose -Message "NOTE: Currently no checks for Remove Licenses necessary"
      }

      if ($PSBoundParameters.ContainsKey('RemoveAll') -and -not $PSBoundParameters.ContainsKey('Add')) {
        Write-Warning -Message "This will leave the Object without a License!"
        $title = 'Confirm'
        $question = 'Are you sure you want to proceed?'
        $choices = '&Yes', '&No'

        $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
        if ($decision -ne 0) {
          throw "No consent given. Aborting execution!"
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
      Write-Verbose -Message "Querying Licenses from the Tenant" -Verbose
      $TenantLicenses = Get-TeamsTenantLicense -Detailed -ErrorAction STOP
    }
    catch {
      Write-Warning $_
      return
    }
    #endregion

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    foreach ($ID in $Identity) {
      #region Object Verification
      # Querying User
      try {
        $UserObject = Get-AzureADUser -ObjectId "$ID" -WarningAction SilentlyContinue -ErrorAction STOP
      }
      catch {
        Write-Error -Message "User Account not valid" -Category ObjectNotFound -RecommendedAction "Verify UserPrincipalName"
        continue
      }

      # Checking Usage Location is Set
      if ($null -eq $UserObject.UsageLocation) {
        try {
          if ($PSCmdlet.ShouldProcess("$ID", "Set-AzureADUser -UsageLocation $UsageLocation")) {
            Set-AzureADUser -ObjectId $UserObject.ObjectId -UsageLocation $UsageLocation -ErrorAction Stop
            if ($PSBoundParameters.ContainsKey('UsageLocation')) {
              Write-Verbose -Message "User '$ID' UsageLocation set to $UsageLocation" -Verbose
            }
            else {
              Write-Warning -Message "User '$ID' UsageLocation set to $UsageLocation (Default)- Please correct if necessary"
            }
          }
        }
        catch {
          Write-Error -Message "Usage Location not set" -Category InvalidResult -RecommendedAction "Set Usage Location, then try assigning a License again"
          continue
        }
      }
      else {
        Write-Verbose -Message "User '$ID' UsageLocation already set ($UsageLocation)"
      }
      #endregion

      #region License Query from User Object
      $UserLicenses = Get-AzureADUserLicenseDetail -ObjectId $UserObject.ObjectId -WarningAction SilentlyContinue



      #endregion

      Write-Verbose -Message "Processing Licenses"
      #region Add
      if ($PSBoundParameters.ContainsKey('Add')) {
        Write-Verbose -Message "Parsing 'Add'" -Verbose
        try {
          # Creating Array of $AddSkuIds to pass to New-AzureAdLicenseObject
          [System.Collections.ArrayList]$AddSkuIds = @()
          foreach ($AddLic in $Add) {
            $SkuPartNumber = ($AllLicenses | Where-Object ParameterName -EQ $AddLic).('SkuPartNumber')
            $AddSku = ($AllLicenses | Where-Object ParameterName -EQ $AddLic).('SkuId')
            $AddLicName = ($AllLicenses | Where-Object ParameterName -EQ $AddLic).('FriendlyName')

            # Verifying license is available in the Tenant
            if (-not ($SkuPartNumber -in $($TenantLicenses.SkuPartNumber))) {
              Write-Error -Message "Adding License '$AddLicName' - License not found in the Tenant"
              continue
            }
            else {
              $RemainingLics = ($TenantLicenses | Where-Object { $_.SkuPartNumber -eq $SkuPartNumber }).Remaining
              if ($RemainingLics -lt 1) {
                Write-Error -Message "Adding License '$AddLicName' - License found in the Tenant, but no units available"
                continue
              }
              else {
                Write-Verbose -Message "Adding License '$AddLicName' - License found in the Tenant. Free unit available!" -Verbose
              }
            }

            # Verifying user has not already this license assigned
            if ($SkuPartNumber -in $UserLicenses.SkuPartNumber) {
              Write-Warning -Message "Adding License '$AddLicName' - License already assigned to the User, omitting!"
            }
            else {
              Write-Verbose -Message "Adding License '$AddLicName' - License not assigned, adding to list"
              [void]$AddSkuIds.Add("$AddSku")
            }
          }

        }
        catch {
          throw
        }
      }
      #endregion

      #region Remove
      if ($PSBoundParameters.ContainsKey('Remove')) {
        Write-Verbose -Message "Parsing 'Remove'" -Verbose
        try {
          # Creating Array of $RemoveSkuIds to pass to New-AzureAdLicenseObject
          [System.Collections.ArrayList]$RemoveSkuIds = @()
          foreach ($RemoveLic in $Remove) {
            $RemoveSku = ($AllLicenses | Where-Object ParameterName -EQ $RemoveLic).('SkuId')
            $RemoveLicName = ($AllLicenses | Where-Object ParameterName -EQ $RemoveLic).('FriendlyName')
            if ($RemoveSku -in $UserLicenses.SkuId) {
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
        $NewLicenseObjParameters += @{'SkuId' = $AddSkuIds }
      }
      if ($PSBoundParameters.ContainsKey('Remove')) {
        $NewLicenseObjParameters += @{'RemoveSkuId' = $RemoveSkuIds }
      }
      if ($PSBoundParameters.ContainsKey('RemoveAll')) {
        $NewLicenseObjParameters += @{'RemoveSkuId' = $UserLicenses.SkuId }
      }

      $LicenseObject = New-AzureAdLicenseObject @NewLicenseObjParameters
      Write-Verbose -Message "Creating License Object: Done"
      #endregion

      # Executing Assignment
      if ($PSCmdlet.ShouldProcess("$ID", "Set-AzureADUserLicense")) {
        #Assign $LicenseObject to each User
        Write-Verbose -Message "'$ID' - Setting Licenses"
        Set-AzureADUserLicense -ObjectId $ID -AssignedLicenses $LicenseObject
        Write-Verbose -Message "'$ID' - Setting Licenses: Done"
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Set-TeamsUserLicense
