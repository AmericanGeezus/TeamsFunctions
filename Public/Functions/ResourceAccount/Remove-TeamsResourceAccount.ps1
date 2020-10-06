# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:		David Eberhardtt
# Updated:  01-OCT-2020
# Status:   PreLive

function Remove-TeamsResourceAccount {
  <#
	.SYNOPSIS
		Removes a Resource Account from AzureAD
	.DESCRIPTION
		This function allows you to remove Resource Accounts (Application Instances) from AzureAD
	.PARAMETER UserPrincipalName
		Required. Identifies the Object being changed
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
    None
	.NOTES
		CmdLet currently in testing.
		Execution requires User Admin Role in Azure AD
		Please feed back any issues to david.eberhardt@outlook.com
	.FUNCTIONALITY
		Removes a resource Account in AzureAD for use in Teams
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

  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
  [Alias('Remove-TeamsRA')]
  [OutputType([System.Void])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN of the Object to create.")]
    [ValidateScript( {
        If ($_ -match '@') {
          $True
        }
        else {
          Write-Host "Must be a valid UPN" -ForegroundColor Red
          $false
        }
      })]
    [Alias("Identity", "ObjectId")]
    [string]$UserPrincipalName,

    [Parameter(Mandatory = $false)]
    [switch]$Force
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    # Caveat - Access rights
    Write-Verbose -Message "This Script requires the executor to have access to AzureAD and rights to execute Remove-AzureAdUser" -Verbose
    Write-Verbose -Message "No verification of required admin roles is performed. Use Get-AzureAdAssignedAdminRoles to determine roles for your account"

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

    # Adding Types - Required for License manipulation in Process
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    #region Lookup of UserPrincipalName
    try {
      #Trying to query the Resource Account
      Write-Verbose -Message "Processing: $UserPrincipalName"
      $Object = (Get-CsOnlineApplicationInstance -Identity $UserPrincipalName -WarningAction SilentlyContinue -ErrorAction STOP)
      $DisplayName = $Object.DisplayName
    }
    catch {
      # Catching anything
      Write-Warning -Message "Object not found! Please provide a valid UserPrincipalName of an existing Resource Account"
      return
    }
    #endregion

    #region Associations
    # Finding all Associations to of this Resource Account to Call Queues or Auto Attendants
    Write-Verbose -Message "Processing: '$DisplayName' Associations to Call Queues or Auto Attendants"
    $Associations = Get-CsOnlineApplicationInstanceAssociation -Identity $UserPrincipalName -WarningAction SilentlyContinue -ErrorAction Ignore
    if ($Associations.count -eq 0) {
      # Object has no associations
      Write-Verbose -Message "'$DisplayName' Object does not have any associations"
      $Associations = $null
    }
    else {
      Write-Verbose -Message "'$DisplayName' associations found"
      if ($PSBoundParameters.ContainsKey("Force")) {
        # Removing all Associations to of this Resource Account to Call Queues or Auto Attendants
        # with: Remove-CsOnlineApplicationInstanceAssociation
        if ($PSCmdlet.ShouldProcess("Resource Account Associations ($($Associations.Count))", 'Remove-CsOnlineApplicationInstanceAssociation')) {
          try {
            Write-Verbose -Message "Trying to remove the Associations of this Resource Account"
            $null = (Remove-CsOnlineApplicationInstanceAssociation $Associations -ErrorAction STOP)
            Write-Verbose -Message "SUCCESS: Associations removed"
          }
          catch {
            Write-Error -Message "Associations could not be removed! Please check manually with Remove-CsOnlineApplicationInstanceAssociation" -Category InvalidOperation
            Write-ErrorRecord $_ #This handles the error message in human readable format.
            return
          }
        }
      }
      else {
        Write-Error -Message "Associations detected. Please remove first or use -Force" -Category ResourceExists
        Write-Output $Associations
      }
    }
    #endregion

    #region PhoneNumber
    # Removing Phone Number Assignments
    Write-Verbose -Message "Processing: '$DisplayName' Phone Number Assignments"
    try {
      if ($null -ne ($Object.TelephoneNumber)) {
        # Remove from VoiceApplicationInstance
        Write-Verbose -Message "'$Name' Removing Microsoft Number"
        $null = (Set-CsOnlineVoiceApplicationInstance -Identity $UserPrincipalName -Telephonenumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
        Write-Verbose -Message "SUCCESS"
      }
      if ($null -ne ($Object.OnPremLineURI)) {
        # Remove from ApplicationInstance
        Write-Verbose -Message "'$Name' Removing Direct Routing Number"
        $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -OnPremPhoneNumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
        Write-Verbose -Message "SUCCESS"
      }
    }
    catch {
      Write-Error -Message "Removal of Number failed" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Remove-AzureAdUser"
      Write-ErrorRecord $_ #This handles the error message in human readable format.
      return
    }
    #endregion

    #region Licensing
    # Reading User Licenses
    Write-Verbose -Message "Processing: '$DisplayName' Phone Number Assignments"
    try {
      $UserLicenseSkuIDs = (Get-AzureADUserLicenseDetail -ObjectId $UserPrincipalName -ErrorAction STOP -WarningAction SilentlyContinue).SkuId

      if ($null -eq $UserLicenseSkuIDs) {
        Write-Verbose -Message "'$DisplayName' No licenses assigned. OK"
      }
      else {
        $Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        # This should work:
        Write-Verbose -Message "'$DisplayName' Removing Removing licenses"
        $Licenses.RemoveLicenses = @($UserLicenseSkuIDs)
        Set-AzureADUserLicense -ObjectId $Object.ObjectId -AssignedLicenses $Licenses -ErrorAction STOP
        Write-Verbose -Message "SUCCESS"
      }
    }
    catch {
      Write-Error -Message "Removal of Licenses failed" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Set-AzureADUserLicense"
      Write-ErrorRecord $_ #This handles the error message in human readable format.
      return
    }

    #endregion

    #region Account Removal
    # Removing AzureAD User
    Write-Verbose -Message "Processing: '$DisplayName' Removing AzureAD User Object"
    if ($PSCmdlet.ShouldProcess("Resource Account with DisplayName: '$DisplayName'", 'Remove-AzureADUser')) {
      try {
        $null = (Remove-AzureADUser -ObjectId $UserPrincipalName -ErrorAction STOP)
        Write-Verbose -Message "SUCCESS - Object removed from Azure Active Directory"
      }
      catch {
        Write-Error -Message "Removal failed" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Remove-AzureAdUser"
        Write-ErrorRecord $_ #This handles the error message in human readable format.
      }
    }
    else {
      Write-Verbose -Message "SKIPPED - Object removed not confirmed Azure Active Directory"
    }



    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"

  } #end
} #Remove-TeamsResourceAccount
