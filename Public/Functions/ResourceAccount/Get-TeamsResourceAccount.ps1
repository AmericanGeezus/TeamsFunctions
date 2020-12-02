# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   PreLive




function Get-TeamsResourceAccount {
  <#
	.SYNOPSIS
		Returns Resource Accounts from AzureAD
	.DESCRIPTION
		Returns one or more Resource Accounts based on input.
		This runs Get-CsOnlineApplicationInstance but reformats the Output with friendly names
	.PARAMETER Identity
		Required. Positional. One or more UserPrincipalNames to be queried.
	.PARAMETER DisplayName
		Optional. Search parameter. Alternative to Find-TeamsResourceAccount
	.PARAMETER ApplicationType
		Optional. Returns all Call Queues or AutoAttendants
	.PARAMETER PhoneNumber
		Optional. Returns all ResourceAccount with a specific string in the PhoneNumber
	.EXAMPLE
		Get-TeamsResourceAccount
		Returns all Resource Accounts.
		NOTE: Depending on size of the Tenant, this might take a while.
	.EXAMPLE
		Get-TeamsResourceAccount -Identity ResourceAccount@TenantName.onmicrosoft.com
		Returns the Resource Account with the Identity specified, if found.
	.EXAMPLE
		Get-TeamsResourceAccount -DisplayName "Queue"
		Returns all Resource Accounts with "Queue" as part of their Display Name.
		Use Find-TeamsResourceAccount / Find-CsOnlineApplicationInstance for finer search
	.EXAMPLE
		Get-TeamsResourceAccount -ApplicationType AutoAttendant
		Returns all Resource Accounts of the specified ApplicationType.
	.EXAMPLE
		Get-TeamsResourceAccount -PhoneNumber +1555123456
		Returns the Resource Account with the Phone Number specified, if found.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.NOTES
		CmdLet currently in testing.
		Pipeline input possible, though untested. Requires figuring out :)
		Please feed back any issues to david.eberhardt@outlook.com
	.FUNCTIONALITY
		Returns one or more Resource Accounts
  .COMPONENT
    TeamsAutoAttendant
    TeamsCallQueue
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

  [CmdletBinding(DefaultParameterSetName = "Identity")]
  [Alias('Get-TeamsRA')]
  [OutputType([System.Object])]
  param (
    [Parameter(ParameterSetName = "Identity", Position = 0, ValueFromPipelineByPropertyName = $true, HelpMessage = "User Principal Name of the Object.")]
    [Alias("UPN", "UserPrincipalName")]
    [string[]]$Identity,

    [Parameter(ParameterSetName = "DisplayName", Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Searches for AzureAD Object with this Name")]
    [ValidateLength(3, 255)]
    [string]$DisplayName,

    [Parameter(ParameterSetName = "AppType", HelpMessage = "Limits search to specific Types: CallQueue or AutoAttendant")]
    [ValidateSet("CallQueue", "AutoAttendant", "CQ", "AA")]
    [Alias("Type")]
    [string]$ApplicationType,

    [Parameter(ParameterSetName = "Number", ValueFromPipelineByPropertyName = $true, HelpMessage = "Telephone Number of the Object")]
    [ValidateScript( {
        If ($_ -match "^(tel:)?\+?[0-9]{3,4}-?[0-9]{3,4}-?[0-9]{4,5}[0-9]{3,4}((;ext=[0-9]{3,8}))?$") {
          $True
        }
        else {
          Write-Host "Not a valid phone number. Must start with a + and 10 to 15 digits long" -ForegroundColor Red
          $false
        }
      })]
    [Alias("Tel", "Number", "TelephoneNumber")]
    [string]$PhoneNumber
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
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

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = 3

    # Loading all Microsoft Telephone Numbers
    $Operation = "Gathering Phone Numbers from the Tenant"
    Write-Progress -Id 0 -Status "Information Gathering" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message $Operation
    $MSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue | Select-Object Id
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $ResourceAccounts = $null

    #region Data gathering
    $Operation = "Querying Resource Accounts"
    $step++
    Write-Progress -Id 0 -Status "Information Gathering" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message $Operation
    if ($PSBoundParameters.ContainsKey('Identity')) {
      # Default Parameterset
      [System.Collections.ArrayList]$ResourceAccounts = @()
      foreach ($I in $Identity) {
        Write-Verbose -Message "Querying Resource Account with UserPrincipalName '$I'"
        try {
          $RA = Get-CsOnlineApplicationInstance -Identity $I -ErrorAction Stop
          [void]$ResourceAccounts.Add($RA)
        }
        catch {
          Write-Verbose -Message "Not found: '$I'" -Verbose
        }
      }
    }
    elseif ($PSBoundParameters.ContainsKey('DisplayName')) {
      # Minimum Character length is 3
      Write-Verbose -Message "DisplayName - Searching for Accounts with DisplayName '$DisplayName'"
      $ResourceAccounts = Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue | Where-Object -Property DisplayName -Like -Value "*$DisplayName*"
    }
    elseif ($PSBoundParameters.ContainsKey('ApplicationType')) {
      Write-Verbose -Message "ApplicationType - Searching for Accounts with ApplicationType '$ApplicationType'"
      $AppId = GetAppIdFromApplicationType $ApplicationType
      $ResourceAccounts = Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue | Where-Object -Property ApplicationId -EQ -Value $AppId
    }
    elseif ($PSBoundParameters.ContainsKey('PhoneNumber')) {
      Write-Verbose -Message "PhoneNumber - Searching for PhoneNumber '$PhoneNumber'"
      $ResourceAccounts = Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue | Where-Object -Property PhoneNumber -Like -Value "*$PhoneNumber*"
    }
    else {
      Write-Verbose -Message "Listing UserPrincipalName only. To query individual items, please provide Identity" -Verbose
      (Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue).UserPrincipalName
      return
    }

    # Stop script if no data has been determined
    if ($ResourceAccounts.Count -eq 0) {
      Write-Verbose -Message "No Data found."
      return
    }

    #endregion


    #region OUTPUT
    # Creating new PS Object
    $Operation = "Parsing Information for $($ResourceAccounts.Count) Resource Accounts"
    $step++
    Write-Progress -Id 0 -Status "Information Gathering" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message $Operation
    foreach ($ResourceAccount in $ResourceAccounts) {
      # Initialising counters for Progress bars
      [int]$step = 0
      [int]$sMax = 7

      # readable Application type
      $Operation = "Parsing ApplicationType"
      Write-Progress -Id 1 -Status "'$($ResourceAccount.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      if ($PSBoundParameters.ContainsKey('ApplicationType')) {
        $ResourceAccountApplicationType = $ApplicationType
      }
      else {
        $ResourceAccountApplicationType = GetApplicationTypeFromAppId $ResourceAccount.ApplicationId
      }

      # Usage Location from Object
      $Operation = "Parsing Usage Location"
      $step++
      Write-Progress -Id 1 -Status "'$($ResourceAccount.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      $AzureAdUser = Get-AzureADUser -ObjectId "$($ResourceAccount.UserPrincipalName)" -WarningAction SilentlyContinue


      # Parsing CsOnlineUser
      $Operation = "Parsing Online Voice Routing Policy"
      $step++
      Write-Progress -Id 1 -Status "'$($ResourceAccount.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      try {
        $CsOnlineUser = Get-CsOnlineUser -Identity "$($ResourceAccount.UserPrincipalName)" -WarningAction SilentlyContinue -ErrorAction Stop | Select-Object OnlineVoiceRoutingPolicy
      }
      catch {
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: Online Voice Routing Policy FAILED. CsOnlineUser not found" -Verbose
      }


      # Parsing TeamsUserLicense
      $Operation = "Parsing License Assignments"
      $step++
      Write-Progress -Id 1 -Status "'$($ResourceAccount.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      $ResourceAccountLicense = Get-TeamsUserLicense -Identity "$($ResourceAccount.UserPrincipalName)"

      # Phone Number Type
      $Operation = "Parsing PhoneNumber"
      $step++
      Write-Progress -Id 1 -Status "'$($ResourceAccount.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      if ($null -ne $ResourceAccount.PhoneNumber) {
        $MSNumber = $null
        $MSNumber = Format-StringRemoveSpecialCharacter -String $ResourceAccount.PhoneNumber | Format-StringForUse -SpecialChars "tel"
        if ($MSNumber -in $MSTelephoneNumbers) {
          $ResourceAccountPhoneNumberType = "Microsoft Number"
        }
        else {
          $ResourceAccountPhoneNumberType = "Direct Routing Number"
        }
      }
      else {
        $ResourceAccountPhoneNumberType = $null
      }

      # Associations
      $Operation = "Parsing Association"
      $step++
      Write-Progress -Id 1 -Status "'$($ResourceAccount.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      $Association = Get-CsOnlineApplicationInstanceAssociation -Identity $AdUser.ObjectId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      if ( $Association ) {
        $AssociationObject = switch ($Association.ConfigurationType) {
          "CallQueue" { Get-CsCallQueue -Identity $Association.ConfigurationId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue }
          "AutoAttendant" { Get-CsAutoAttendant -Identity $Association.ConfigurationId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue }
        }
        $AssociationStatus = Get-CsOnlineApplicationInstanceAssociationStatus -Identity $ResourceAccount.ObjectId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      }

      # creating new PS Object (synchronous with Get and Set)
      $ResourceAccountObject = [PSCustomObject][ordered]@{
        ObjectId                 = $ResourceAccount.ObjectId
        UserPrincipalName        = $ResourceAccount.UserPrincipalName
        DisplayName              = $ResourceAccount.DisplayName
        ApplicationType          = $ResourceAccountApplicationType
        UsageLocation            = $AzureAdUser.UsageLocation
        License                  = $ResourceAccountLicense.LicensesFriendlyNames
        PhoneNumberType          = $ResourceAccountPhoneNumberType
        PhoneNumber              = $ResourceAccount.PhoneNumber
        OnlineVoiceRoutingPolicy = $CsOnlineUser.OnlineVoiceRoutingPolicy
        AssociatedTo             = $AssociationObject.Name
        AssociatedAs             = $Association.ConfigurationType
        AssociationStatus        = $AssociationStatus.Status
      }

      Write-Progress -Id 1 -Status "Processing '$($ResourceAccount.UserPrincipalName)'" -Activity $MyInvocation.MyCommand -Completed
      Write-Output $ResourceAccountObject
    }

    #endregion
    Write-Progress -Id 0 -Status "Complete" -Activity $MyInvocation.MyCommand -Completed

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsResourceAccount
