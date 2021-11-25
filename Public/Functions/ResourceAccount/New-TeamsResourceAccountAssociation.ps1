# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:   David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live




function New-TeamsResourceAccountAssociation {
  <#
  .SYNOPSIS
    Connects one or more Resource Accounts to a single CallQueue or AutoAttendant
  .DESCRIPTION
    Associates one or more existing Resource Accounts to a Call Queue or Auto Attendant
    Resource Account Type is checked against the ApplicationType.
    User is prompted if types do not match
  .PARAMETER UserPrincipalName
    Required. UPN(s) of the Resource Account(s) to be associated to a Call Queue or AutoAttendant
  .PARAMETER CallQueue
    Optional. Specifies the connection to be made to the provided Call Queue Name
  .PARAMETER AutoAttendant
    Optional. Specifies the connection to be made to the provided Auto Attendant Name
  .PARAMETER Force
    Optional. Suppresses Confirmation dialog if -Confirm is not provided
    Used to override prompts for alignment of ApplicationTypes.
    The Resource Account is changed to have the same type as the associated Object (CallQueue or AutoAttendant)!
  .EXAMPLE
    New-TeamsResourceAccountAssociation -UserPrincipalName Account1@domain.com -
    Explanation of what the example does
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Connects multiple Resource Accounts to ONE CallQueue or AutoAttendant
    The Type of the Resource Account has to corellate to the entity connected.
    Parameter Force can be used to change the type of RA to align to the entity if possible.
  .COMPONENT
    TeamsResourceAccount
    TeamsAutoAttendant
    TeamsCallQueue
  .FUNCTIONALITY
    Creates a new Association between an unassociated Resource Account and an Auto Attendant or a Call Queue
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsResourceAccountAssociation.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsResourceAccount.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'CallQueue')]
  [Alias('New-TeamsRAA')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'UPN of the Object to change')]
    [string[]]$UserPrincipalName,

    [Parameter(Mandatory, ParameterSetName = 'CallQueue', ValueFromPipelineByPropertyName, HelpMessage = 'Name of the CallQueue')]
    [string]$CallQueue,

    [Parameter(Mandatory, ParameterSetName = 'AutoAttendant', ValueFromPipelineByPropertyName, HelpMessage = 'Name of the AutoAttendant')]
    [string]$AutoAttendant,

    [Parameter(Mandatory = $false)]
    [switch]$Force
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Asserting MicrosoftTeams Connection
    if ( -not (Assert-MicrosoftTeamsConnection) ) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    #Initialising Counters
    $private:StepsID0, $private:StepsID1 = Get-WriteBetterProgressSteps -Code $($MyInvocation.MyCommand.Definition) -MaxId 1
    $private:ActivityID0 = $($MyInvocation.MyCommand.Name)
    [int] $private:CountID0 = [int] $private:CountID1 = 1

    # Enabling $Confirm to work with $Force
    if ($Force -and -not $Confirm) {
      $ConfirmPreference = 'None'
    }

    #region Determining and Validating Entity
    $StatusID0 = 'Verifying input'
    # Determining $EntityObject
    $CurrentOperationID0 = 'Determining Entity Object'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    try {
      switch ($PSCmdlet.ParameterSetName) {
        'CallQueue' {
          $DesiredType = 'CallQueue'
          $Entity = $CallQueue
          # Querying Call Queue by Name - need Unique Result
          Write-Verbose -Message "Querying Call Queue '$CallQueue'"
          $EntitySearch = Get-CsCallQueue -NameFilter "$CallQueue" -WarningAction SilentlyContinue
        }
        'AutoAttendant' {
          $DesiredType = 'AutoAttendant'
          $Entity = $AutoAttendant
          # Querying Auto Attendant by Name - need Unique Result
          Write-Verbose -Message "Querying Auto Attendant '$AutoAttendant'"
          $EntitySearch = Get-CsAutoAttendant -NameFilter "$AutoAttendant" -WarningAction SilentlyContinue
        }
      }
    }
    catch {
      throw "Cannot determine $DesiredType '$Entity'"
    }
    if ($EntitySearch.Count -gt 1) {
      $EntityObject = $EntitySearch | Where-Object Name -EQ "$Entity"
    }
    else {
      $EntityObject = $EntitySearch
    }

    # Validating Unique result received
    $CurrentOperationID0 = 'Determining Entity Object is unique'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($null -eq $EntityObject) {
      throw [System.Exception]::New("$DesiredType '$Entity' - Not found, please check entity exists with this Name" )
    }
    elseif ($EntityObject -is [Array]) {
      $EntityObject = $EntityObject | Where-Object Name -EQ "$Entity"
      Write-Verbose -Message "'$Entity' - Multiple results found! This script is based on lookup via Name, which requires, for safety reasons, a unique Name to process." -Verbose
      Write-Verbose -Message 'Listing all objects found with the Name. Please use the correct Identity to run New-CsOnlineApplicationInstanceAssociation!' -Verbose
      $EntityObject | Select-Object Identity, Name | Format-Table
      throw [System.Exception]::New("$DesiredType '$Entity' - Multiple Results found! Cannot determine unique result. Please provide GUID or use New-CsOnlineApplicationInstanceAssociation!" )
    }
    else {
      Write-Verbose -Message "$DesiredType '$Entity' - Unique result found: $($EntityObject.Name)"
    }
    #endregion

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    # re-Initialising counters for Progress bars (for Pipeline processing)
    [int] $private:CountID0 = 2

    $StatusID0 = 'Verifying input'
    # Query $UserPrincipalName
    [System.Collections.ArrayList]$Accounts = @()
    $CurrentOperationID0 = 'Processing provided UserPrincipalNames'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    foreach ($UPN in $UserPrincipalName) {
      Write-Verbose -Message "Querying Resource Account '$UPN'"
      try {
        $RAObject = Get-AzureADUser -ObjectId "$UPN" -WarningAction SilentlyContinue -ErrorAction Stop
        $AppInstance = Get-CsOnlineApplicationInstance $RAObject.ObjectId -WarningAction SilentlyContinue -ErrorAction Stop
        [void]$Accounts.Add($AppInstance)
        Write-Verbose "Resource Account found: '$($AppInstance.DisplayName)'"
      }
      catch {
        Write-Error "Resource Account not found: '$UPN'" -Category ObjectNotFound
        continue
      }
    }

    # Breaks the chain if no eligible accounts are found.
    if ( -not $Accounts ) {
      Write-Warning -Message 'No Resource Accounts found eligible for Association. Stopping.'
      return
    }

    $StatusID0 = 'Processing found Resource Accounts'
    $CurrentOperationID0 = ''
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    #TEST WriteProgress error for 150 - Accounts.Count not populating correctly?
    [int] $private:StepsID1 = $StepsID1 * $(if ($Accounts.IsArray) { $Accounts.Count } else { 1 })
    [System.Collections.ArrayList]$ValidatedAccounts = @()
    foreach ($Account in $Accounts) {
      $ActivityID1 = "'$($Account.UserPrincipalName)'"
      $StatusID1 = ''
      $CurrentOperationID1 = 'Querying existing associations'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      $ExistingConnection = $null
      $ExistingConnection = Get-CsOnlineApplicationInstanceAssociation -Identity $Account.ObjectId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      if ($null -eq $ExistingConnection.ConfigurationId) {
        Write-Verbose -Message "'$($Account.UserPrincipalName)' - No assignment found. OK"
      }
      else {
        Write-Error -Message "'$($Account.UserPrincipalName)' - This account cannot be associated as it is already assigned as '$($ExistingConnection.ConfigurationType)'"
        continue
      }

      # Comparing ApplicationType
      $CurrentOperationID1 = 'Validating ApplicationType'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      $ApplicationTypeMatches = ((Get-CsOnlineApplicationInstance -Identity "$($Account.UserPrincipalName)" -WarningAction SilentlyContinue).ApplicationId -eq (GetAppIdFromApplicationType $DesiredType))

      if ( $ApplicationTypeMatches ) {
        Write-Verbose -Message "'$($Account.UserPrincipalName)' - Application type matches '$DesiredType' - OK"
      }
      else {
        if ($PSBoundParameters.ContainsKey('Force')) {
          # Changing Application Type
          try {
            $null = Set-CsOnlineApplicationInstance -Identity $Account.ObjectId -ApplicationId $(GetAppIdFromApplicationType $DesiredType) -ErrorAction Stop
          }
          catch {
            Write-Error -Message "'$($Account.UserPrincipalName)' - Application type does not match and could not be changed! Expected: '$DesiredType' - Please change manually or recreate the Account" -Category InvalidType -RecommendedAction 'Please change manually or recreate the Account'
            continue
          }

          $CurrentOperationID1 = "Application Type is not '$DesiredType' - Waiting for AzureAD (2s)"
          Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
          Start-Sleep -Seconds 2

          $CurrentOperationID1 = "Application Type is not '$DesiredType' - Verifying"
          Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
          if ($DesiredType -ne $(GetApplicationTypeFromAppId (Get-CsOnlineApplicationInstance -Identity "($($Account.ObjectId)" -WarningAction SilentlyContinue).ApplicationId)) {
            Write-Error -Message "'$($Account.UserPrincipalName)' - Application type could not be changed to Desired Type: '$DesiredType'" -Category InvalidType
            continue
          }
          else {
            Write-Information "SUCCESS: Resource Account '$($Account.UserPrincipalName)' - Changing Application Type to '$DesiredType'"
          }
        }
        else {
          Write-Warning -Message "'$($Account.UserPrincipalName)' - Application type does not match! Expected '$DesiredType' - Omitting account. Please change type manually or use -Force switch"
          continue
        }
      }

      [void]$ValidatedAccounts.Add($Account)
      Write-Progress -Id 1 -Activity $ActivityID1 -Completed
    }

    # Processing found accounts
    if ( $ValidatedAccounts ) {
      [int] $private:StepsID1 = $ValidatedAccounts.Count
      $StatusID0 = "Processing $private:StepsID1 validated Resource Accounts"
      $CurrentOperationID0 = ''
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      # Processing Assignment
      foreach ($Account in $ValidatedAccounts) {
        $ErrorEncountered = $null
        $ActivityID1 = "'$($Account.UserPrincipalName)'"
        $StatusID1 = "Assignment to $DesiredType '$($EntityObject.Name)'"
        $CurrentOperationID1 = "Associating '$($Account.UserPrincipalName)' with $DesiredType"
        Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1

        # Creating Splatting Object
        $Parameters = $null
        $Parameters += @{ 'Identities' = $Account.ObjectId }
        $Parameters += @{ 'ConfigurationType' = $DesiredType }
        $Parameters += @{ 'ConfigurationId' = $EntityObject.Identity }
        $Parameters += @{ 'ErrorAction' = 'Stop' }

        # Create CsAutoAttendantCallableEntity
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          "Function: $($MyInvocation.MyCommand.Name): Parameters:", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }

        if ($PSCmdlet.ShouldProcess("$($Account.UserPrincipalName)", 'New-CsOnlineApplicationInstanceAssociation')) {
          #$OperationStatus = New-CsOnlineApplicationInstanceAssociation -Identities $Account.ObjectId -ConfigurationType $DesiredType -ConfigurationId $EntityObject.Identity
          try {
            $OperationStatus = New-CsOnlineApplicationInstanceAssociation @Parameters
          }
          catch {
            $ErrorEncountered = $_
          }
        }

        # Re-query Association Target
        #  Wating for AAD to write the Association Target so that it may be queried correctly
        $CurrentOperationID1 = "Validating association of '$($Account.UserPrincipalName)' with $DesiredType"
        Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
        Start-Sleep -Seconds 2
        $AssociationTarget = switch ($PSCmdlet.ParameterSetName) {
          'CallQueue' {
            Get-CsCallQueue -Identity $OperationStatus.Results.ConfigurationId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          }
          'AutoAttendant' {
            Get-CsAutoAttendant -Identity $OperationStatus.Results.ConfigurationId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          }
        }

        # Output
        $ResourceAccountAssociationObject = $null
        $ResourceAccountAssociationObject = [PSCustomObject][ordered]@{
          UserPrincipalName = $Account.UserPrincipalName
          ConfigurationType = $OperationStatus.Results.ConfigurationType
          Result            = $OperationStatus.Results.Result
          StatusCode        = $OperationStatus.Results.StatusCode
          StatusMessage     = $OperationStatus.Results.Message
          AssociatedTo      = $AssociationTarget.Name
        }

        Write-Progress -Id 1 -Activity $ActivityID1 -Completed
        Write-Progress -Id 0 -Activity $ActivityID0 -Completed
        Write-Output $ResourceAccountAssociationObject

        if ( $ErrorEncountered ) {
          Write-Error -Message "Association of Object failed with exception: $($ErrorEncountered.Exception.Message)" -ErrorAction Stop
        }
      }
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsResourceAccountAssociation
