# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:   David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live




function Get-TeamsResourceAccount {
  <#
  .SYNOPSIS
    Returns Resource Accounts from AzureAD
  .DESCRIPTION
    Returns one or more Resource Accounts based on input.
    This runs Get-CsOnlineApplicationInstance but reformats the Output with friendly names
  .PARAMETER UserPrincipalName
    Default and positional. One or more UserPrincipalNames to be queried.
  .PARAMETER DisplayName
    Optional. Search parameter. Alternative to Find-TeamsResourceAccount
    Use Find-TeamsUserVoiceConfig for more search options
  .PARAMETER ApplicationType
    Optional. Returns all Call Queues or AutoAttendants
  .PARAMETER PhoneNumber
    Optional. Returns all ResourceAccount with a specific string in the PhoneNumber
  .EXAMPLE
    Get-TeamsResourceAccount
    Returns all Resource Accounts.
    Depending on size of the Tenant, this might take a while.
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
    None
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Pipeline input possible
    Running the CmdLet without any input might take a while, depending on size of the Tenant.
  .COMPONENT
    TeamsResourceAccount
    TeamsAutoAttendant
    TeamsCallQueue
  .FUNCTIONALITY
    Returns one or more Resource Accounts from the Tenant
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsResourceAccount.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsResourceAccount.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_TeamsResourceAccount
  .LINK
    Get-TeamsResourceAccountAssociation
  .LINK
    New-TeamsResourceAccountAssociation
  .LINK
    Remove-TeamsResourceAccountAssociation
  .LINK
    New-TeamsResourceAccount
  .LINK
    Get-TeamsResourceAccount
  .LINK
    Find-TeamsResourceAccount
  .LINK
    Set-TeamsResourceAccount
  .LINK
    Remove-TeamsResourceAccount
  #>

  [CmdletBinding(DefaultParameterSetName = 'Identity')]
  [Alias('Get-TeamsRA')]
  [OutputType([System.Object])]
  param (
    [Parameter(Position = 0, ParameterSetName = 'Identity', ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'User Principal Name of the Object.')]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(ParameterSetName = 'DisplayName', ValueFromPipelineByPropertyName, HelpMessage = 'Searches for AzureAD Object with this Name')]
    [ValidateLength(3, 255)]
    [string]$DisplayName,

    [Parameter(ParameterSetName = 'AppType', HelpMessage = 'Limits search to specific Types: CallQueue or AutoAttendant')]
    [ValidateSet('CallQueue', 'AutoAttendant', 'CQ', 'AA')]
    [Alias('Type')]
    [string]$ApplicationType,

    [Parameter(ParameterSetName = 'Number', ValueFromPipelineByPropertyName, HelpMessage = 'Telephone Number of the Object')]
    [ValidateScript( {
        If ($_ -match '^(tel:)?\+?(([0-9]( |-)?)?(\(?[0-9]{3}\)?)( |-)?([0-9]{3}( |-)?[0-9]{4})|([0-9]{4,15}))?((;( |-)?ext=[0-9]{3,8}))?$') { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Not a valid phone number. E.164 format expected, min 4 digits, but multiple formats accepted. Extensions will be stripped'
          $false
        }
      })]
    [Alias('Tel', 'Number', 'TelephoneNumber')]
    [string]$PhoneNumber
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = 2

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $ResourceAccounts = $null

    #region Data gathering
    $Operation = 'Querying Resource Accounts'
    $step++
    Write-Progress -Id 0 -Status 'Information Gathering' -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message $Operation
    if ($PSBoundParameters.ContainsKey('UserPrincipalName')) {
      # Default Parameterset
      [System.Collections.ArrayList]$ResourceAccounts = @()
      foreach ($I in $UserPrincipalName) {
        Write-Verbose -Message "Querying Resource Account with UserPrincipalName '$I'"
        try {
          $RA = Get-CsOnlineApplicationInstance -Identity "$I" -ErrorAction Stop
          [void]$ResourceAccounts.Add($RA)
        }
        catch {
          Write-Information "Resource Account '$I' - Not found!"
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
      $SearchString = Format-StringRemoveSpecialCharacter "$PhoneNumber" | Format-StringForUse -SpecialChars 'tel'
      Write-Verbose -Message "PhoneNumber - Searching for normalised PhoneNumber '$SearchString'"
      $ResourceAccounts = Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue | Where-Object -Property PhoneNumber -Like -Value "*$SearchString*"
    }
    else {
      Write-Information 'Listing UserPrincipalName only. To query individual items, please provide Identity'
      Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue | Select-Object UserPrincipalName
      return
    }

    # Stop script if no data has been determined
    if ($ResourceAccounts.Count -eq 0) {
      Write-Verbose -Message 'No Data found.'
      return
    }

    #endregion


    #region OUTPUT
    # Creating new PS Object
    $Operation = "Parsing Information for $($ResourceAccounts.Count) Resource Accounts"
    $step++
    Write-Progress -Id 0 -Status 'Information Gathering' -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message $Operation
    foreach ($ResourceAccount in $ResourceAccounts) {
      # Initialising counters for Progress bars
      [int]$step = 0
      [int]$sMax = 7

      # readable Application type
      $Operation = 'Parsing ApplicationType'
      Write-Progress -Id 1 -Status "'$($ResourceAccount.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      if ($PSBoundParameters.ContainsKey('ApplicationType')) {
        $ResourceAccountApplicationType = $ApplicationType
      }
      else {
        $ResourceAccountApplicationType = GetApplicationTypeFromAppId $ResourceAccount.ApplicationId
      }

      # Parsing CsOnlineUser
      $Operation = 'Parsing Online Voice Routing Policy'
      $step++
      Write-Progress -Id 1 -Status "'$($ResourceAccount.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      try {
        $CsOnlineUser = Get-CsOnlineUser -Identity "$($ResourceAccount.UserPrincipalName)" -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: Online Voice Routing Policy FAILED. CsOnlineUser not found" -Verbose
      }


      # Parsing TeamsUserLicense
      $Operation = 'Parsing License Assignments'
      $step++
      Write-Progress -Id 1 -Status "'$($ResourceAccount.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      $ResourceAccountLicense = Get-AzureAdUserLicense -Identity "$($ResourceAccount.UserPrincipalName)"

      # Phone Number Type
      $Operation = 'Parsing Online Telephone Numbers (validating Number against Microsoft Calling Plan Numbers)'
      $step++
      Write-Progress -Id 1 -Status "'$($ResourceAccount.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      if ($null -ne $ResourceAccount.PhoneNumber) {
        $MSNumber = $null
        $MSNumber = ((Format-StringForUse -InputString "$($ResourceAccount.PhoneNumber)" -SpecialChars 'tel:+') -split ';')[0]
        $PhoneNumberIsMSNumber = Get-CsOnlineTelephoneNumber -TelephoneNumber $MSNumber -WarningAction SilentlyContinue
        if ($PhoneNumberIsMSNumber) {
          $ResourceAccountPhoneNumberType = 'Microsoft Number'
        }
        else {
          $ResourceAccountPhoneNumberType = 'Direct Routing Number'
        }
      }
      else {
        $ResourceAccountPhoneNumberType = $null
      }

      # Associations
      $Operation = 'Parsing Association'
      $step++
      Write-Progress -Id 1 -Status "'$($ResourceAccount.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      $Association = Get-CsOnlineApplicationInstanceAssociation -Identity $ResourceAccount.ObjectId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      if ( $Association ) {
        $AssociationObject = switch ($Association.ConfigurationType) {
          'CallQueue' { Get-CsCallQueue -Identity $Association.ConfigurationId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue }
          'AutoAttendant' { Get-CsAutoAttendant -Identity $Association.ConfigurationId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue }
        }
        $AssociationStatus = Get-CsOnlineApplicationInstanceAssociationStatus -Identity $ResourceAccount.ObjectId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      }
      else {
        $AssociationObject = $null
        $AssociationStatus = $null
      }

      # creating new PS Object (synchronous with Get and Set)
      $ResourceAccountObject = [PSCustomObject][ordered]@{
        ObjectId                 = $ResourceAccount.ObjectId
        UserPrincipalName        = $ResourceAccount.UserPrincipalName
        DisplayName              = $ResourceAccount.DisplayName
        ApplicationType          = $ResourceAccountApplicationType
        InterpretedUserType      = $CsOnlineUser.InterpretedUserType
        UsageLocation            = $ResourceAccountLicense.UsageLocation
        License                  = $ResourceAccountLicense.Licenses
        PhoneNumberType          = $ResourceAccountPhoneNumberType
        PhoneNumber              = $ResourceAccount.PhoneNumber
        OnlineVoiceRoutingPolicy = $CsOnlineUser.OnlineVoiceRoutingPolicy
        AssociatedTo             = $AssociationObject.Name
        AssociatedAs             = $Association.ConfigurationType
        AssociationStatus        = $AssociationStatus.Status
      }

      Write-Progress -Id 1 -Status "Processing '$($ResourceAccount.UserPrincipalName)'" -Activity $MyInvocation.MyCommand -Completed
      Write-Output $ResourceAccountObject
      Write-Progress -Id 0 -Status 'Information Gathering' -Activity $MyInvocation.MyCommand -Completed
    }
    #endregion
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsResourceAccount
