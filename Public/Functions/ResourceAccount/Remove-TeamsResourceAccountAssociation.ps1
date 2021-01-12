# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   PreLive




function Remove-TeamsResourceAccountAssociation {
  <#
	.SYNOPSIS
		Removes the connection between a Resource Account and a CQ or AA
	.DESCRIPTION
		Removes an associated Resource Account from a Call Queue or Auto Attendant
	.PARAMETER UserPrincipalName
		Required. UPN(s) of the Resource Account(s) to be removed from a Call Queue or AutoAttendant
	.PARAMETER Force
		Optional. Suppresses Confirmation dialog if -Confirm is not provided
	.PARAMETER PassThru
		Optional. Displays Object after removal of association.
	.EXAMPLE
		Remove-TeamsResourceAccountAssociation -UserPrincipalName ResourceAccount@domain.com
		Removes the Association of the Account 'ResourceAccount@domain.com' from the identified Call Queue or Auto Attendant
	.NOTES
		Does the same as Remove-CsOnlineApplicationInstanceAssociation, but with friendly Names
		General notes
  .INPUTS
    System.String
  .OUTPUTS
    None
  .COMPONENT
    TeamsAutoAttendant
    TeamsCallQueue
  .EXTERNALHELP
    https://raw.githubusercontent.com/DEberhardt/TeamsFunctions/master/docs/TeamsFunctions-help.xml
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Get-TeamsResourceAccountAssociation
	.LINK
    New-TeamsResourceAccountAssociation
	.LINK
		Remove-TeamsResourceAccountAssociation
	.LINK
    Remove-TeamsResourceAccount
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('Remove-TeamsRAA', 'Remove-CsOnlineApplicationInstance')]
  [OutputType([System.Void])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "UPN of the Object to manipulate.")]
    [Alias('Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [switch]$PassThru
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }

    # Enabling $Confirm to work with $Force
    if ($Force -and -not $Confirm) {
      $ConfirmPreference = 'None'
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    # Querying ObjectId from provided UPNs
    [System.Collections.ArrayList]$Accounts = @()
    foreach ($UPN in $UserPrincipalName) {
      try {
        $AppInstance = Get-CsOnlineApplicationInstance -Identity $UPN -WarningAction SilentlyContinue -ErrorAction Stop
        [void]$Accounts.Add($AppInstance)
        Write-Verbose "Resource Account found: '$($AppInstance.DisplayName)'"
      }
      catch {
        Write-Error "Resource Account not found: '$UPN'" -Category ObjectNotFound
        continue
      }
    }

    # Processing found accounts
    if ( $Accounts ) {
      foreach ($Account in $Accounts) {
        $Association = Get-CsOnlineApplicationInstanceAssociation $Account.ObjectId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        if ( $Association ) {
          # Finding associated entity
          $AssocObject = switch ($Association.ConfigurationType) {
            'CallQueue' { Get-CsCallQueue -Identity $Association.ConfigurationId -WarningAction SilentlyContinue }
            'AutoAttendant' { Get-CsAutoAttendant -Identity $Association.ConfigurationId -WarningAction SilentlyContinue }
          }

          # Removing Association
          try {
            if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Removing Association of the Target Account to $($Association.ConfigurationType) '$($AssocObject.Name)'")) {
              Write-Verbose -Message "'$UserPrincipalName' - Removing Association to $($Association.ConfigurationType) '$($AssocObject.Name)'"
              $OperationStatus = Remove-CsOnlineApplicationInstanceAssociation $Association.Id -ErrorAction Stop
            }
            else {
              continue
            }
          }
          catch {
            throw $_
          }
        }
        else {
          Write-Verbose -Message "'$UserPrincipalName' - No Association found!" -Verbose
          continue
        }

        # Output
        if ($PassThru) {
          $ResourceAccountAssociationObject = [PSCustomObject][ordered]@{
            UserPrincipalName  = $Account.UserPrincipalName
            ConfigurationType  = $OperationStatus.Results.ConfigurationType
            Result             = $OperationStatus.Results.Result
            StatusCode         = $OperationStatus.Results.StatusCode
            StatusMessage      = $OperationStatus.Results.Message
            AssociatedTo       = $null
            AssociationRemoved = $AssocObject.Name

          }
          Write-Output $ResourceAccountAssociationObject
        }
      }
    }
    else {
      Write-Warning -Message "No Accounts found"
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Remove-TeamsResourceAccountAssociation
