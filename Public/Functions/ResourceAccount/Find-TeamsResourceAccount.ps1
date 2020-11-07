# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   BETA

function Find-TeamsResourceAccount {
  <#
	.SYNOPSIS
		Finds Resource Accounts from AzureAD
	.DESCRIPTION
		Returns Resource Accounts based on input (Search String).
		This runs Find-CsOnlineApplicationInstance but reformats the Output with friendly names
	.PARAMETER SearchQuery
		Required. Positional. Part of the DisplayName of the Account.
	.PARAMETER AssociatedOnly
		Optional. Considers only associated Resource Accounts
	.PARAMETER UnAssociatedOnly
		Optional. Considers only unassociated Resource Accounts
	.EXAMPLE
		Find-TeamsResourceAccount -SearchQuery "Office"
		Returns all Resource Accounts with "Office" as part of their DisplayName
	.EXAMPLE
		Find-TeamsResourceAccount -SearchQuery "Office" -AssociatedOnly
		Returns all associated Resource Accounts with "Office" as part of their DisplayName
	.EXAMPLE
		Find-TeamsResourceAccount -SearchQuery "Office" -UnAssociatedOnly
		Returns all unassociated Resource Accounts with "Office" as part of their DisplayName
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.NOTES
		CmdLet currently in testing.
		Please feed back any issues to david.eberhardt@outlook.com
	.FUNCTIONALITY
		Returns one or more Resource Accounts
	.LINK
    Get-TeamsResourceAccountAssociation
    New-TeamsResourceAccountAssociation
		Remove-TeamsResourceAccountAssociation
    New-TeamsResourceAccount
    Get-TeamsResourceAccount
    Find-TeamsResourceAccount
    Set-TeamsResourceAccount
    Remove-TeamsResourceAccount
	#>

  [CmdletBinding(DefaultParameterSetName = "Search")]
  [Alias('Find-TeamsRA')]
  [OutputType([System.Object])]
  param (
    [Parameter(Mandatory, Position = 0, ParameterSetName = "Search", HelpMessage = "Part of the DisplayName to be found")]
    [Parameter(Mandatory, Position = 0, ParameterSetName = "AssociatedOnly", HelpMessage = "Part of the DisplayName to be found")]
    [Parameter(Mandatory, Position = 0, ParameterSetName = "UnAssociatedOnly", HelpMessage = "Part of the DisplayName to be found")]
    [ValidateLength(3, 255)]
    [string]$SearchQuery,

    [Parameter(Mandatory, Position = 1, ParameterSetName = "AssociatedOnly", HelpMessage = "Returns only Objects assigned to CQ or AA")]
    [Alias("Assigned", "InUse")]
    [switch]$AssociatedOnly,

    [Parameter(Mandatory, Position = 1, ParameterSetName = "UnAssociatedOnly", HelpMessage = "Returns only Objects not assigned to CQ or AA")]
    [Alias("Unassigned", "Free")]
    [switch]$UnAssociatedOnly
  ) #param

  begin {
    # Caveat - Script in Development
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    Show-FunctionStatus -Level BETA
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

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

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $FoundResourceAccounts = $null
    $ResourceAccounts = $null

    #region Data gathering
    if ($PSBoundParameters.ContainsKey('AssociatedOnly')) {
      Write-Verbose -Message "SearchQuery - Searching for ASSOCIATED Accounts containing '$SearchQuery'" -Verbose
      $FoundResourceAccounts = Find-CsOnlineApplicationInstance -SearchQuery "$SearchQuery" -AssociatedOnly
    }
    elseif ($PSBoundParameters.ContainsKey('UnAssociatedOnly')) {
      Write-Verbose -Message "SearchQuery - Searching for UNASSOCIATED Accounts containing '$SearchQuery'" -Verbose
      $FoundResourceAccounts = Find-CsOnlineApplicationInstance -SearchQuery "$SearchQuery" -UnAssociatedOnly
    }
    else {
      Write-Verbose -Message "SearchQuery - Searching for Accounts containing '$SearchQuery'" -Verbose
      $FoundResourceAccounts = Find-CsOnlineApplicationInstance -SearchQuery "$SearchQuery"
    }

    if ($null -ne $FoundResourceAccounts) {
      # Querying found Accounts against Get-CsOnlineApplicationInstance
      Write-Verbose -Message "Found Resource Accounts. Performing lookup. Please wait..." -Verbose
      [System.Collections.ArrayList]$ResourceAccounts = @()
      foreach ($I in $FoundResourceAccounts) {
        Write-Verbose -Message "Querying Account '$($I.Id)'"
        try {
          $RA = Get-CsOnlineApplicationInstance -Identity $I.Id -WarningAction SilentlyContinue -ErrorAction Stop
          [void]$ResourceAccounts.Add($RA)
        }
        catch {
          Write-ErrorRecord $_
        }
      }
    }
    else {
      # Stop script if no data has been determined
      Write-Verbose -Message "No Data found."
      return
    }
    #endregion


    #region OUTPUT
    # Creating new PS Object
    try {
      Write-Verbose -Message "Parsing Resource Accounts, please wait..." -Verbose
      foreach ($ResourceAccount in $ResourceAccounts) {
        # readable Application type
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: ApplicationType"
        $ResourceAccountApplicationType = GetApplicationTypeFromAppId $ResourceAccount.ApplicationId

        # Resource Account License
        # License
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: License"
        if (Test-TeamsUserLicense -Identity $ResourceAccount.UserPrincipalName -ServicePlan MCOEV) {
          $ResourceAccountLicense = "PhoneSystem (Add-on)"
        }
        elseif (Test-TeamsUserLicense -Identity $ResourceAccount.UserPrincipalName -ServicePlan MCOEV_VIRTUALUSER) {
          $ResourceAccountLicense = "PhoneSystem_VirtualUser"
        }
        else {
          $ResourceAccountLicense = $null
        }

        # Phone Number Type
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: PhoneNumber"
        if ($null -ne $ResourceAccount.PhoneNumber) {
          if ($PhoneNumberIsMSNumber) {
            $ResourceAccountPhoneNumberType = "Microsoft Number"
          }
          else {
            $ResourceAccountPhoneNumberType = "Direct Routing Number"
          }
        }
        else {
          $ResourceAccountPhoneNumberType = $null
        }

        # Usage Location from Object
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: Usage Location"
        $UsageLocation = (Get-AzureADUser -ObjectId "$($ResourceAccount.UserPrincipalName)" -WarningAction SilentlyContinue).UsageLocation

        # Associations
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: Association"
        try {
          $Association = Get-CsOnlineApplicationInstanceAssociation -Identity $ResourceAccount.ObjectId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          $AssocObject = switch ($Association.ConfigurationType) {
            "CallQueue" { Get-CsCallQueue -Identity $Association.ConfigurationId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue }
            "AutoAttendant" { Get-CsAutoAttendant -Identity $Association.ConfigurationId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue }
          }
          $AssociationStatus = Get-CsOnlineApplicationInstanceAssociationStatus -Identity $ResourceAccount.ObjectId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        }
        catch {
          $AssocObject	= $null
        }

        # creating new PS Object (synchronous with Get and Set)
        $ResourceAccountObject = [PSCustomObject][ordered]@{
          UserPrincipalName = $ResourceAccount.UserPrincipalName
          DisplayName       = $ResourceAccount.DisplayName
          UsageLocation     = $UsageLocation
          ApplicationType   = $ResourceAccountApplicationType
          License           = $ResourceAccountLicense
          PhoneNumberType   = $ResourceAccountPhoneNumberType
          PhoneNumber       = $ResourceAccount.PhoneNumber
          AssociatedTo      = $AssocObject.Name
          AssociatedAs      = $Association.ConfigurationType
          AssociationStatus = $AssociationStatus.Status
        }

        Write-Output $ResourceAccountObject

      }
    }
    catch {
      Write-Warning -Message "Object Output could not be determined. Please verify manually with Get-CsOnlineApplicationInstance"
      Write-ErrorRecord $_ #This handles the error message in human readable format.
    }
    #endregion
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Find-TeamsResourceAccount
