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
        If ( $_ -match '^(tel:\+|\+)?([0-9]?[-\s]?(\(?[0-9]{3}\)?)[-\s]?([0-9]{3}[-\s]?[0-9]{4})|([0-9][-\s]?){4,20})((x|;ext=)([0-9]{3,8}))?$' ) { $True } else {
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

    #Initialising Counters
    $script:StepsID0, $script:StepsID1 = Get-WriteBetterProgressSteps -Code $($MyInvocation.MyCommand.Definition) -MaxId 1
    $script:ActivityID0 = $($MyInvocation.MyCommand.Name)
    [int]$script:CountID0 = [int]$script:CountID1 = 1
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $ResourceAccounts = $null

    $StatusID0 = 'Information Gathering'
    #region Data gathering
    $CurrentOperationID0 = 'Querying Resource Accounts'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
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
          if ($_.Exception.Message.Contains('RBAC')) {
            Write-Warning -Message 'AzureAd Admin Roles are not assigned, activated or have timed out. Please check your Administrative Roles'
          }
          Write-Error "$($_.Exception.Message)"
          Write-Information "INFO:    Resource Account '$I' - Not found!"
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
      $SearchString = Format-StringForUse "$($PhoneNumber.split(';')[0].split('x')[0])" -SpecialChars 'telx:+() -'
      Write-Verbose -Message "PhoneNumber - Searching for normalised PhoneNumber '$SearchString'"
      $ResourceAccounts = Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue | Where-Object -Property PhoneNumber -Like -Value "*$SearchString*"
    }
    else {
      Write-Information 'INFO:    Resource Account: Listing UserPrincipalName only. To query individual items, please provide Identity'
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
    Write-Verbose -Message "[PROCESS] Processing found Auto Attendants:  $($ResourceAccounts.Count)"
    # Creating new PS Object
    foreach ($ResourceAccount in $ResourceAccounts) {
      [int] $script:CountID0 = 1
      $ActivityID0 = "'$($ResourceAccount.UserPrincipalName)' - '$($ResourceAccount.DisplayName)'"
      $StatusID0 = 'Parsing'
      $CurrentOperationID0 = 'Parsing ApplicationType'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
      # readable Application type
      if ($PSBoundParameters.ContainsKey('ApplicationType')) {
        $ResourceAccountApplicationType = $ApplicationType
      }
      else {
        $ResourceAccountApplicationType = GetApplicationTypeFromAppId $ResourceAccount.ApplicationId
      }

      # Parsing CsOnlineUser
      $CurrentOperationID0 = 'Parsing Online Voice Routing Policy'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
      try {
        #NOTE Call placed without the Identity Switch to make remoting call and receive object in tested format (v2.5.0 and higher)
        #$CsOnlineUser = Get-CsOnlineUser -Identity "$($ResourceAccount.UserPrincipalName)" -WarningAction SilentlyContinue -ErrorAction Stop
        $CsOnlineUser = Get-CsOnlineUser "$($ResourceAccount.UserPrincipalName)" -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: Online Voice Routing Policy FAILED. CsOnlineUser not found" -Verbose
      }


      # Parsing TeamsUserLicense
      $CurrentOperationID0 = 'Parsing License Assignments'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
      $ResourceAccountLicense = Get-AzureAdUserLicense -Identity "$($ResourceAccount.UserPrincipalName)"

      # Phone Number Type
      $CurrentOperationID0 = 'Parsing Online Telephone Numbers (validating Number against Microsoft Calling Plan Numbers)'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
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
      $CurrentOperationID0 = 'Parsing Association'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
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

      Write-Progress -Id 1 -Activity $ActivityID0 -Completed
      Write-Progress -Id 0 -Activity $ActivityID0 -Completed
      Write-Output $ResourceAccountObject
    }
    Write-Progress -Id 0 -Activity $ActivityID0 -Completed

    #endregion
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsResourceAccount
