# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   RC




function Remove-TeamsCommonAreaPhone {
  <#
	.SYNOPSIS
		Removes a Common Area Phone from AzureAD
	.DESCRIPTION
		This function allows you to remove Common Area Phones (AzureAdUser) from AzureAD
	.PARAMETER UserPrincipalName
		Required. Identifies the Object being changed
	.PARAMETER PassThru
		Optional. Displays UserPrincipalName of removed objects.
	.EXAMPLE
		Remove-TeamsCommonAreaPhone -UserPrincipalName "Common Area Phone@TenantName.onmicrosoft.com"
		Removes a CommonAreaPhone
		Removes in order: Phone Number, License and Account
  .INPUTS
    System.String
  .OUTPUTS
    None
	.NOTES
		Execution requires User Admin Role in Azure AD
	.FUNCTIONALITY
		Removes a Common Area Phone in AzureAD for use in Teams
  .COMPONENT
		TeamsUserVoiceConfig
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
	.LINK
    Get-TeamsCommonAreaPhone
	.LINK
    New-TeamsCommonAreaPhone
	.LINK
    Set-TeamsCommonAreaPhone
	.LINK
    Remove-TeamsCommonAreaPhone
	.LINK
    Find-TeamsUserVoiceConfig
	.LINK
    Get-TeamsUserVoiceConfig
	.LINK
    Set-TeamsUserVoiceConfig
	#>

  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
  [Alias('Remove-TeamsCAP')]
  [OutputType([System.Void])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'UPN of the Object to create.')]
    [ValidateScript( {
        If ($_ -match '@') {
          $True
        }
        else {
          Write-Host 'Must be a valid UPN' -ForegroundColor Red
          $false
        }
      })]
    [Alias('Identity', 'ObjectId')]
    [string[]]$UserPrincipalName,

    [Parameter(Mandatory = $false)]
    [switch]$PassThru
  ) #param

  begin {
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }

    # Caveat - Access rights
    Write-Verbose -Message 'This Script requires the executor to have access to AzureAD and rights to execute Remove-AzureAdUser' -Verbose
    Write-Verbose -Message 'No verification of required admin roles is performed. Use Get-AzureAdAdminRole to determine roles for your account'

    # Adding Types - Required for License manipulation in Process
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($UPN in $UserPrincipalName) {
      # Initialising counters for Progress bars
      [int]$step = 0
      [int]$sMax = 3

      #region Lookup of UserPrincipalName
      Write-Progress -Id 0 -Status "Processing '$UPN'" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "Processing: $UPN"
      try {
        #Trying to query the Common Area Phone
        $Object = (Get-CsOnlineUser $UPN -WarningAction SilentlyContinue -ErrorAction STOP)
        $DisplayName = $Object.DisplayName
      }
      catch {
        # Catching anything
        Write-Warning -Message 'Object not found! Please provide a valid UserPrincipalName of an existing Common Area Phone'
        continue
      }
      #endregion

      #region Removing Voice Config
      $Operation = "'$DisplayName' - Removing Voice Configuration"
      $step++
      Write-Progress -Id 0 -Status "Processing '$UPN'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      Remove-TeamsUserVoiceConfig -Identity $UPN -PassThru
      #endregion

      #region Licensing
      # Reading User Licenses
      $Operation = "'$DisplayName' - License Assignments"
      $step++
      Write-Progress -Id 0 -Status "Processing '$UPN'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      try {
        $UserLicenseSkuIDs = (Get-AzureADUserLicenseDetail -ObjectId $UPN -ErrorAction STOP -WarningAction SilentlyContinue).SkuId

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
      $Operation = "'$DisplayName' - Removing AzureAD Object (AzureAdUser)"
      $step++
      Write-Progress -Id 0 -Status "Processing '$UPN'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      if ($PSCmdlet.ShouldProcess("Common Area Phone with DisplayName: '$DisplayName'", 'Remove-AzureADUser')) {
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


      Write-Progress -Id 0 -Status 'Complete' -Activity $MyInvocation.MyCommand -Completed

      # Output
      if ($PassThru) {
        Write-Output "AzureAdUser '$UserPrincipalName' removed"
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Remove-TeamsCommonAreaPhone
