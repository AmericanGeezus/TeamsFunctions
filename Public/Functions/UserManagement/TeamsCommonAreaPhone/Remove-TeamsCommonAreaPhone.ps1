# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
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
  .PARAMETER Force
    Optional. Suppresses Confirmation prompt to remove User.
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
  .COMPONENT
    UserManagement
  .FUNCTIONALITY
    Removes a Common Area Phone in AzureAD for use in Teams
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TeamsCommonAreaPhone.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
  [Alias('Remove-TeamsCAP')]
  [OutputType([System.Void])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'UPN of the Object to create.')]
    [ValidateScript( {
        If ($_ -match '@') { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Parameter UserPrincipalName must be a valid UPN'
          $false
        }
      })]
    [Alias('Identity', 'ObjectId')]
    [string[]]$UserPrincipalName,

    [Parameter(Mandatory = $false)]
    [switch]$PassThru,

    [Parameter(Mandatory = $false)]
    [switch]$Force
  ) #param

  begin {
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Asserting MicrosoftTeams Connection
    if ( -not $script:TFPSST) { $script:TFPSST = Assert-MicrosoftTeamsConnection; if ( -not $script:TFPSST ) { break } }

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

    # Caveat - Access rights
    Write-Verbose -Message "This CmdLet requires the Office 365 Admin Role 'User Administrator' to execute Remove-AzureAdUser" -Verbose
    Write-Verbose -Message 'No verification of required admin roles is performed. Use Get-AzureAdAdminRole to determine roles for your account'

    # Adding Types - Required for License manipulation in Process
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $StatusID0 = 'Processing Removal'
    [int] $private:StepsID0 = $UserPrincipalName.Count
    foreach ($UPN in $UserPrincipalName) {
      $StatusID0 = $CurrentOperationID0 = ''
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      $ActivityID1 = "'$UPN'"
      #region Lookup of UserPrincipalName
      $StatusID1 = 'Querying Object'
      $CurrentOperationID1 = 'Querying CsOnlineUser'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      try {
        #Trying to query the Common Area Phone
        #NOTE Call placed without the Identity Switch to make remoting call and receive object in tested format (v2.5.0 and higher)
        #$Object = Get-CsOnlineUser -Identity "$UPN" -WarningAction SilentlyContinue -ErrorAction STOP
        #$Object = Get-CsOnlineUser "$UPN" -WarningAction SilentlyContinue -ErrorAction STOP
        $Object = Get-AzureADUser -ObjectId "$UPN" -WarningAction SilentlyContinue -ErrorAction STOP
        $DisplayName = $Object.DisplayName
      }
      catch {
        # Catching anything
        Write-Warning -Message 'Object not found! Please provide a valid UserPrincipalName of an existing Common Area Phone'
        continue
      }
      #endregion

      #region Removing Voice Config
      $StatusID1 = "Processing Object '$DisplayName'"
      $CurrentOperationID1 = 'Removing Voice Configuration'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      try {
        Remove-TeamsUserVoiceConfig -UserPrincipalName $UPN -PassThru -ErrorAction Stop
      }
      catch {
        Write-Verbose "'$DisplayName' Object not licensed for Teams"
      }
      #endregion

      #region Licensing
      # Reading User Licenses
      $CurrentOperationID1 = 'Removing License Assignments'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
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
      $CurrentOperationID1 = 'Removing AzureAD Object (AzureAdUser)'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      if ($Force -or $PSCmdlet.ShouldProcess("Common Area Phone with DisplayName: '$DisplayName'", 'Remove-AzureADUser')) {
        try {
          $null = (Remove-AzureADUser -ObjectId "$UPN" -ErrorAction STOP)
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
      Write-Progress -Id 1 -Activity $ActivityID1 -Completed
      Write-Progress -Id 0 -Activity $ActivityID0 -Completed
      if ($PassThru) {
        Write-Output "AzureAdUser '$UserPrincipalName' removed"
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Remove-TeamsCommonAreaPhone
