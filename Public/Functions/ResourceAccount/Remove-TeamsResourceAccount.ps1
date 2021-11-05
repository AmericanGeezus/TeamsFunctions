# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:   David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live




function Remove-TeamsResourceAccount {
  <#
  .SYNOPSIS
    Removes a Resource Account from AzureAD
  .DESCRIPTION
    This function allows you to remove Resource Accounts (Application Instances) from AzureAD
  .PARAMETER UserPrincipalName
    Required. Identifies the Object being changed
  .PARAMETER PassThru
    Optional. Displays UserPrincipalName of removed objects.
  .PARAMETER Force
    Optional. Will also sever all associations this account has in order to remove it
    If not provided and the Account is connected to a Call Queue or Auto Attendant, an error will be displayed
  .EXAMPLE
    Remove-TeamsResourceAccount -UserPrincipalName "Resource Account@TenantName.onmicrosoft.com"
    Removes a ResourceAccount
    Removes in order: Phone Number, License and Account
  .EXAMPLE
    Remove-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com" -Force
    Removes a ResourceAccount
    Removes in order: Association, Phone Number, License and Account
  .INPUTS
    System.String
  .OUTPUTS
    System.Void - Default Behavior
    System.Object - With Switch PassThru
  .NOTES
    Execution requires User Admin Role in Azure AD
  .FUNCTIONALITY
    Removes a resource Account in AzureAD for use in Teams
  .COMPONENT
    TeamsResourceAccount
    TeamsAutoAttendant
    TeamsCallQueue
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TeamsResourceAccount.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsResourceAccount.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
  [Alias('Remove-TeamsRA')]
  [OutputType([System.Void])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'UPN of the Object to create.')]
    [ValidateScript( {
        if ($_ -match '@' -or $_ -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$') { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Parameter UserPrincipalName must be a valid UPN or ObjectId.'
        }
      })]
    [Alias('Identity', 'ObjectId')]
    [string[]]$UserPrincipalName,

    [Parameter(HelpMessage = 'By default, no output is generated, PassThru will display the Object changed')]
    [switch]$PassThru,

    [Parameter(Mandatory = $false)]
    [switch]$Force
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
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    #Initialising Counters
    $script:StepsID0, $script:StepsID1 = Get-WriteBetterProgressSteps -Code $($MyInvocation.MyCommand.Definition) -MaxId 1
    $script:ActivityID0 = $($MyInvocation.MyCommand.Name)
    [int] $script:CountID0 = [int] $script:CountID1 = 1

    # Caveat - Access rights
    Write-Verbose -Message "This CmdLet requires the Office 365 Admin Role 'User Administrator' to execute Remove-AzureAdUser" -Verbose
    Write-Verbose -Message 'No verification of required admin roles is performed. Use Get-AzureAdAdminRole to determine roles for your account'

    # Enabling $Confirm to work with $Force
    if ($Force -and -not $Confirm) {
      $ConfirmPreference = 'None'
    }

    # Adding Types - Required for License manipulation in Process
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($UPN in $UserPrincipalName) {
      [int] $script:CountID0 = 1
      [int] $script:StepsID0 = $UserPrincipalName.Count
      $StatusID0 = "Processing '$UPN'"
      $CurrentOperationID0 = 'Querying Object'

      #region Lookup of UserPrincipalName
      $CurrentOperationID0 = 'Querying CsOnlineApplicationInstance'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
      try {
        #Trying to query the Resource Account
        $Object = (Get-CsOnlineApplicationInstance -Identity "$UPN" -WarningAction SilentlyContinue -ErrorAction STOP)
        $DisplayName = $Object.DisplayName
      }
      catch {
        # Catching anything
        Write-Warning -Message 'Object not found! Please provide a valid UserPrincipalName of an existing Resource Account'
        continue
      }
      #endregion

      #region Associations
      # Finding all Associations to of this Resource Account to Call Queues or Auto Attendants
      $CurrentOperationID0 = 'Removing Associations to Call Queues or Auto Attendants'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
      $Associations = Get-CsOnlineApplicationInstanceAssociation -Identity "$UPN" -WarningAction SilentlyContinue -ErrorAction Ignore
      if ($Associations.count -eq 0) {
        # Object has no associations
        Write-Verbose -Message "'$DisplayName' - Object does not have any associations"
        $Associations = $null
      }
      else {
        Write-Verbose -Message "'$DisplayName' associations found"
        if ($PSBoundParameters.ContainsKey('Force')) {
          # Removing all Associations to of this Resource Account to Call Queues or Auto Attendants
          # with: Remove-CsOnlineApplicationInstanceAssociation
          if ($PSCmdlet.ShouldProcess("Resource Account Associations ($($Associations.Count))", 'Remove-CsOnlineApplicationInstanceAssociation')) {
            try {
              Write-Verbose -Message 'Trying to remove the Associations of this Resource Account'
              $null = (Remove-CsOnlineApplicationInstanceAssociation $Associations -ErrorAction STOP)
              Write-Verbose -Message 'SUCCESS: Associations removed'
            }
            catch {
              Write-Error -Message 'Associations could not be removed! Please check manually with Remove-CsOnlineApplicationInstanceAssociation' -Category InvalidOperation
              return
            }
          }
        }
        else {
          Write-Error -Message 'Associations detected. Please remove first or use -Force' -Category ResourceExists
          Write-Output $Associations
        }
      }
      #endregion

      #region PhoneNumber
      # Removing Phone Number Assignments
      $CurrentOperationID0 = 'Removing Phone Number Assignments'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
      try {
        if ($null -ne ($Object.TelephoneNumber)) {
          # Remove from VoiceApplicationInstance
          Write-Verbose -Message "'$Name' Removing Microsoft Number"
          $null = (Set-CsOnlineVoiceApplicationInstance -Identity "$UPN" -TelephoneNumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
          Write-Verbose -Message 'SUCCESS'
        }
        if ($null -ne ($Object.OnPremLineURI)) {
          # Remove from ApplicationInstance
          Write-Verbose -Message "'$Name' Removing Direct Routing Number"
          $null = (Set-CsOnlineApplicationInstance -Identity "$UPN" -OnpremPhoneNumber $null -Force -WarningAction SilentlyContinue -ErrorAction STOP)
          Write-Verbose -Message 'SUCCESS'
        }
      }
      catch {
        Write-Error -Message 'Removal of Number failed' -Category NotImplemented -Exception $_.Exception -RecommendedAction 'Try manually with Remove-AzureAdUser'
        return
      }
      #endregion

      #region Licensing
      # Reading User Licenses
      $CurrentOperationID0 = 'Removing License Assignments'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
      try {
        $UserLicenseSkuIDs = (Get-AzureADUserLicenseDetail -ObjectId "$UPN" -ErrorAction STOP -WarningAction SilentlyContinue).SkuId
        if ($null -eq $UserLicenseSkuIDs) {
          Write-Verbose -Message "'$DisplayName' No licenses assigned. OK"
        }
        else {
          $Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
          # This should work:
          Write-Verbose -Message "'$DisplayName' Removing Removing licenses"
          $Licenses.RemoveLicenses = @($UserLicenseSkuIDs)
          Set-AzureADUserLicense -ObjectId $Object.ObjectId -AssignedLicenses $Licenses -ErrorAction STOP
          Write-Verbose -Message 'SUCCESS'
        }
      }
      catch {
        Write-Error -Message 'Removal of Licenses failed' -Category NotImplemented -Exception $_.Exception -RecommendedAction 'Try manually with Set-AzureADUserLicense'
        return
      }
      #endregion

      #region Account Removal
      # Removing AzureAD User
      $CurrentOperationID0 = 'Removing Removing AzureAD Object (AzureAdUser)'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
      if ($Force -or $PSCmdlet.ShouldProcess("Resource Account with DisplayName: '$DisplayName'", 'Remove-AzureADUser')) {
        try {
          $null = (Remove-AzureADUser -ObjectId $UPN -ErrorAction STOP)
          Write-Verbose -Message 'SUCCESS - Object removed from Azure Active Directory'
        }
        catch {
          Write-Error -Message 'Removal failed' -Category NotImplemented -Exception $_.Exception -RecommendedAction 'Try manually with Remove-AzureAdUser'
        }
      }
      else {
        Write-Verbose -Message 'SKIPPED - Object removed not confirmed Azure Active Directory'
      }
      #endregion

      # Output
      Write-Progress -Id 0 -Activity $ActivityID0 -Completed
      if ($PassThru) {
        Write-Output "AzureAdUser '$UserPrincipalName' removed"
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Remove-TeamsResourceAccount
