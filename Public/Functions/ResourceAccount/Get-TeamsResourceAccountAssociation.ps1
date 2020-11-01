# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   PreLive

function Get-TeamsResourceAccountAssociation {
  <#
	.SYNOPSIS
		Queries a Resource Account Association
	.DESCRIPTION
		Queries an existing Resource Account and lists its Association (if any)
	.PARAMETER UserPrincipalName
		Optional. UPN(s) of the Resource Account(s) to be queried
	.EXAMPLE
		Get-TeamsResourceAccountAssociation
		Queries all Resource Accounts and enumerates their Association as well as the Association Status
	.EXAMPLE
		Get-TeamsResourceAccountAssociation -UserPrincipalName ResourceAccount@domain.com
		Queries the Association of the Account 'ResourceAccount@domain.com'
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.NOTES
		Combination of Get-CsOnlineApplicationInstanceAssociation and Get-CsOnlineApplicationInstanceAssociationStatus but with friendly Names
		Without any Parameters, can be used to enumerate all Resource Accounts
    This may take a while to calculate, depending on # of Accounts in the Tenant
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
  [CmdletBinding()]
  [Alias('Get-TeamsRAAssoc')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN of the Object to manipulate.")]
    [Alias('UserPrincipalName')]
    [string[]]$Identity
  ) #param

  begin {
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

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
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    $Accounts = $null
    [System.Collections.ArrayList]$Accounts = @()
    if (-not $PSBoundParameters.ContainsKey('Identity')) {
      Write-Verbose -Message "Querying all Resource Accounts, this may take some time..." -Verbose
      $Accounts = Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue
    }
    else {
      # Querying ObjectId from provided $Identity
      foreach ($UPN in $Identity) {
        Write-Verbose -Message "Querying Resource Account '$UPN'"
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
    }

    # Processing found accounts
    if ($null -ne $Accounts) {
      foreach ($Account in $Accounts) {
        $Association = Get-CsOnlineApplicationInstanceAssociation $Account.ObjectId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        $ApplicationType = GetApplicationTypeFromAppId $Account.ApplicationId
        if ($null -ne $Association) {
          # Finding associated entity
          $AssocObject = switch ($Association.ConfigurationType) {
            'CallQueue' { Get-CsCallQueue -Identity $Association.ConfigurationId -WarningAction SilentlyContinue }
            'AutoAttendant' { Get-CsAutoAttendant -Identity $Association.ConfigurationId -WarningAction SilentlyContinue }
          }
          $AssociationStatus = Get-CsOnlineApplicationInstanceAssociationStatus -Identity $Account.ObjectId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        }
        else {
          Write-Verbose -Message "'$($Account.UserPrincipalName)' - No Association found!" -Verbose
          continue
        }

        # Output
        $ResourceAccountAssociationObject = [PSCustomObject][ordered]@{
          UserPrincipalName = $Account.UserPrincipalName
          ConfigurationType = $ApplicationType
          Status            = $AssociationStatus.Status
          StatusType        = $AssociationStatus.Type
          StatusMessage     = $AssociationStatus.Message
          StatusCode        = $AssociationStatus.StatusCode
          StatusTimeStamp   = $AssociationStatus.StatusTimestamp
          AssociatedTo      = $AssocObject.Name
        }

        # Output
        Write-Output $ResourceAccountAssociationObject
      }
    }
    else {
      Write-Verbose -Message "No Accounts found" -Verbose
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Get-TeamsResourceAccountAssociation
