# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   BETA

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
  .LINK
    Get-TeamsResourceAccountAssociation
    New-TeamsResourceAccountAssociation
		Remove-TeamsResourceAccountAssociation
    New-TeamsResourceAccount
    Get-TeamsResourceAccount
    Set-TeamsResourceAccount
    Remove-TeamsResourceAccount
  #>
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'CallQueue')]
  [Alias('New-TeamsRAAssoc')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN of the Object to change")]
    [string[]]$UserPrincipalName,

    [Parameter(Mandatory = $true, ParameterSetName = 'CallQueue', Position = 1, ValueFromPipelineByPropertyName = $true, HelpMessage = "Name of the CallQueue")]
    [string]$CallQueue,

    [Parameter(Mandatory = $true, ParameterSetName = 'AutoAttendant', Position = 1, ValueFromPipelineByPropertyName = $true, HelpMessage = "Name of the AutoAttendant")]
    [string]$AutoAttendant,

    [Parameter(Mandatory = $false)]
    [switch]$Force
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

    # Enabling $Confirm to work with $Force
    if ($Force -and -not $Confirm) {
      $ConfirmPreference = 'None'
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    # Query $UserPrincipalName
    [System.Collections.ArrayList]$Accounts = @()
    foreach ($UPN in $UserPrincipalName) {
      Write-Verbose -Message "Querying Resource Account '$UPN'"
      try {
        $RAObject = Get-AzureADUser -ObjectId $UPN -WarningAction SilentlyContinue -ErrorAction Stop
        $AppInstance = Get-CsOnlineApplicationInstance $RAObject.ObjectId -WarningAction SilentlyContinue -ErrorAction Stop
        [void]$Accounts.Add($AppInstance)
        Write-Verbose "Resource Account found: '$($AppInstance.DisplayName)'"
      }
      catch {
        Write-Error "Resource Account not found: '$UPN'" -Category ObjectNotFound
        continue
      }
    }

    # Processing found accounts
    if ($null -ne $Accounts) {
      #region Connection to Call Queue
      if ($PSBoundParameters.ContainsKey('CallQueue')) {
        # Querying Call Queue by Name - need Unique Result
        Write-Verbose -Message "Querying Call Queue '$CallQueue'"
        $CallQueueObj = Get-CsCallQueue -NameFilter "$CallQueue" -WarningAction SilentlyContinue
        if ($null -eq $CallQueueObj) {
          Write-Error "Call Queue: '$CallQueue' - Not found" -Category ParserError -RecommendedAction "Please check 'CallQueue' exists with this Name"
          return
        }
        elseif ($CallQueueObj.GetType().BaseType.Name -eq "Array") {
          Write-Verbose -Message "'$CallQueue' - Multiple results found! This script is based on lookup via Name, which requires, for safety reasons, a unique Name to process." -Verbose
          Write-Verbose -Message "Here are all objects found with the Name. Please use the correct Identity to run New-CsOnlineApplicationInstanceAssociation!" -Verbose
          $CallQueueObj | Select-Object Identity, Name | Format-Table
          Write-Error "'$CallQueue' - Multiple Results found! Cannot determine unique result. Please use New-CsOnlineApplicationInstanceAssociation!" -Category ParserError -RecommendedAction "Please use New-CsOnlineApplicationInstanceAssociation!" -ErrorAction Stop
        }
        else {
          Write-Verbose -Message "'$CallQueue' - Unique result found: $($CallQueueObj.Identity)"
        }

        # Processing Call Queue
        Write-Verbose -Message "Processing assignment of all Accounts to Call Queue"
        foreach ($Account in $Accounts) {
          # Query existing connection
          Write-Verbose -Message "'$($Account.UserPrincipalName)' - Querying existing associations"
          $ExistingConnection = $null
          #CHECK Query rather with Get-CsOnlineApplicationInstanceAssociation? - Needs ObjectId though! (replicated from Get-TeamsResourceAccountAssociation)
          #TODO Test Performance of GET-TeamsResourceAccountAssociation VS Get-CsOnlineApplicationInstanceAssociation
          <# Needs testing
          $ExistingConnection = Get-CsOnlineApplicationInstanceAssociation (Get-AzureAdUser -ObjectId $Account.UserPrincipalName) -WarningAction SilentlyContinue
          #>
          $ExistingConnection = Get-TeamsResourceAccountAssociation $Account.UserPrincipalName -WarningAction SilentlyContinue
          if ($null -eq $ExistingConnection.AssociatedTo) {
            Write-Verbose -Message "'$($Account.UserPrincipalName)' - No assignment found. OK"
          }
          else {
            Write-Verbose -Message "'$($Account.UserPrincipalName)' - Existing connections found: Listing all connections. Remove connections or use -Force" -Verbose
            $ExistingConnection
            Write-Error -Message "'$($Account.UserPrincipalName)' - This account is already assigned to $($ExistingConnection.ConfigurationType) '$($ExistingConnection.AssociatedTo)'"
            break
          }

          # Comparing ApplicationType
          if ((Get-TeamsResourceAccount -Identity $Account.UserPrincipalName -WarningAction SilentlyContinue).ApplicationType -eq "CallQueue") {
            Write-Verbose -Message "'$($Account.UserPrincipalName)' - Application type matches Call Queue - OK"
          }
          else {
            if ($PSBoundParameters.ContainsKey('Force')) {
              # Changing Application Type
              Write-Verbose -Message "'$($Account.UserPrincipalName)' - Changing Application Type to 'CallQueue'" -Verbose
              $null = Set-CsOnlineApplicationInstance -Identity $Account.ObjectId -ApplicationId $(GetAppIdFromApplicationType CallQueue)
              Start-Sleep -Seconds 2
              if ("CallQueue" -ne $(GetApplicationTypeFromAppId (Get-CsOnlineApplicationInstance -Identity $Account.ObjectId -WarningAction SilentlyContinue).ApplicationId)) {
                Write-Error -Message "'$($Account.UserPrincipalName)' - Application type could not be changed" -Category InvalidType -ErrorAction Stop
              }
              else {
                Write-Verbose -Message "SUCCESS"
              }
            }
            else {
              Write-Error -Message "'$($Account.UserPrincipalName)' - Application type does not match!" -Category InvalidType -RecommendedAction "Please change manually or use -Force switch" -ErrorAction Stop
            }
          }

          # Establishing Association
          Write-Verbose -Message "'$($Account.UserPrincipalName)' - Assigning to Call Queue: '$CallQueue'"
          if ($PSCmdlet.ShouldProcess("$($Account.UserPrincipalName)", "New-CsOnlineApplicationInstanceAssociation")) {
            $OperationStatus = New-CsOnlineApplicationInstanceAssociation -Identities $Account.ObjectId -ConfigurationType CallQueue -ConfigurationId $CallQueueObj.Identity
          }
        }
        # Re-query Association Target
        #  Wating for AAD to write the Association Target so that it may be queried correctly
        Write-Verbose -Message "'$Name' Waiting for AAD to write object. Waiting for 2s"
        Start-Sleep -Seconds 2

        $AssociationTarget = Get-CsCallQueue -Identity $OperationStatus.Results.ConfigurationId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

      }
      #endregion

      #region Connection to Auto Attendant
      if ($PSBoundParameters.ContainsKey('AutoAttendant')) {
        # Querying Auto Attendant by Name - need Unique Result
        Write-Verbose -Message "Querying Auto Attendant '$AutoAttendant'"
        $AutoAttendantObj = Get-CsAutoAttendant -NameFilter "$AutoAttendant" -WarningAction SilentlyContinue
        if ($null -eq $AutoAttendantObj) {
          Write-Error "Auto Attendant: '$AutoAttendant' - Not found" -Category ParserError -RecommendedAction "Please check 'AutoAttendant' exists with this Name"
          return
        }
        elseif ($AutoAttendantObj.GetType().BaseType.Name -eq "Array") {
          Write-Verbose -Message "'$AutoAttendant' - Multiple results found! This script is based on lookup via Name, which requires, for safety reasons,  a unique Name to process." -Verbose
          Write-Verbose -Message "Here are all objects found with the Name. Please use the correct Identity to run New-CsOnlineApplicationInstanceAssociation!" -Verbose
          $AutoAttendantObj | Select-Object Identity, Name | Format-Table
          Write-Error "'$AutoAttendant' - Multiple Results found! Cannot determine unique result. Please use New-CsOnlineApplicationInstanceAssociation!" -Category ParserError -RecommendedAction "Please use New-CsOnlineApplicationInstanceAssociation!" -ErrorAction Stop
        }
        else {
          Write-Verbose -Message "'$AutoAttendant' - Unique result found: $($AutoAttendantObj.Identity)"
        }

        # Processing Auto Attendant
        Write-Verbose -Message "Processing assignment of all Accounts to Auto Attendant"
        foreach ($Account in $Accounts) {
          # Query existing connection
          Write-Verbose -Message "'$($Account.UserPrincipalName)' - Querying existing associations"
          $ExistingConnection = $null
          $ExistingConnection = Get-TeamsResourceAccountAssociation $Account.UserPrincipalName -WarningAction SilentlyContinue
          if ($null -eq $ExistingConnection.AssociatedTo) {
            Write-Verbose -Message "'$($Account.UserPrincipalName)' - No assignment found. OK"
          }
          else {
            Write-Verbose -Message "'$($Account.UserPrincipalName)' - This account is already assigned to the following entity:" -Verbose
            $ExistingConnection
            Write-Error -Message "'$($Account.UserPrincipalName)' - This account cannot be associated as it is already assigned to $($ExistingConnection.ConfigurationType) '$($ExistingConnection.AssociatedTo)'"
            Continue
          }

          # Comparing ApplicationType
          if ((Get-TeamsResourceAccount -Identity $Account.UserPrincipalName -WarningAction SilentlyContinue).ApplicationType -eq "AutoAttendant") {
            Write-Verbose -Message "'$($Account.UserPrincipalName)' - Application type matches Auto Attendant - OK"
          }
          else {
            if ($PSBoundParameters.ContainsKey('Force')) {
              # Changing Application Type
              Write-Verbose -Message "'$($Account.UserPrincipalName)' - Changing Application Type to 'AutoAttendant'" -Verbose
              $null = Set-CsOnlineApplicationInstance -Identity $Account.ObjectId -ApplicationId $(GetAppIdFromApplicationType AutoAttendant)
              Start-Sleep -Seconds 2
              if ("AutoAttendant" -ne $(GetApplicationTypeFromAppId (Get-CsOnlineApplicationInstance -Identity $Account.ObjectId -WarningAction SilentlyContinue).ApplicationId)) {
                Write-Error -Message "'$($Account.UserPrincipalName)' - Application type could not be changed" -Category InvalidType -ErrorAction Stop
              }
              else {
                Write-Verbose -Message "SUCCESS"
              }
            }
            else {
              Write-Error -Message "'$($Account.UserPrincipalName)' - Application type does not match!" -Category InvalidType -RecommendedAction "Please change manually or use -Force switch"
            }
          }


          # Establishing Association
          Write-Verbose -Message "'$($Account.UserPrincipalName)' - Assigning to Auto Attendant: '$AutoAttendant'"
          if ($PSCmdlet.ShouldProcess("$($Account.UserPrincipalName)", "New-CsOnlineApplicationInstanceAssociation")) {
            $OperationStatus = New-CsOnlineApplicationInstanceAssociation -Identities $Account.ObjectId -ConfigurationType AutoAttendant -ConfigurationId $AutoAttendantObj.Identity
          }
        }
        # Re-query Association Target
        #  Wating for AAD to write the Association Target so that it may be queried correctly
        Write-Verbose -Message "'$Name' Waiting for AAD to write object. Waiting for 2s"
        Start-Sleep -Seconds 2

        $AssociationTarget = Get-CsAutoAttendant -Identity $OperationStatus.Results.ConfigurationId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

      }
      #endregion

      #region Output
      $ResourceAccountAssociationObject = $null
      $ResourceAccountAssociationObject = [PSCustomObject][ordered]@{
        UserPrincipalName = $Accounts.UserPrincipalName
        ConfigurationType = $OperationStatus.Results.ConfigurationType
        Result            = $OperationStatus.Results.Result
        StatusCode        = $OperationStatus.Results.StatusCode
        StatusMessage     = $OperationStatus.Results.Message
        AssociatedTo      = $AssociationTarget.Name

      }
      Write-Output $ResourceAccountAssociationObject
      #endregion

    }
    else {
      Write-Warning -Message "No Accounts found"
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsResourceAccountAssociation
