# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:   David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live




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
  .COMPONENT
    TeamsResourceAccount
    TeamsAutoAttendant
    TeamsCallQueue
  .FUNCTIONALITY
    Queries the Association Status of one or more Resource Accounts
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsResourceAccountAssociation.md
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
    Get-TeamsResourceAccount
  .LINK
    Find-TeamsResourceAccount
  .LINK
    New-TeamsResourceAccount
  .LINK
    Remove-TeamsResourceAccount
  .LINK
    Set-TeamsResourceAccount

  #>
  [CmdletBinding()]
  [Alias('Get-TeamsRAA')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'UPN of the Object to manipulate.')]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName
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

    # Enabling $Confirm to work with $Force
    if ($Force -and -not $Confirm) {
      $ConfirmPreference = 'None'
    }


  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $Accounts = $null
    [System.Collections.ArrayList]$Accounts = @()
    if (-not $PSBoundParameters.ContainsKey('UserPrincipalName')) {
      Write-Information 'INFO: Querying all Resource Accounts, this may take some time...'
      $Accounts = Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue
    }
    else {
      # Querying ObjectId from provided $UserPrincipalName
      foreach ($UPN in $UserPrincipalName) {
        Write-Verbose -Message "Querying Resource Account '$UPN'"
        try {
          $AppInstance = Get-CsOnlineApplicationInstance -Identity "$UPN" -WarningAction SilentlyContinue -ErrorAction Stop
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
        $Association = Get-CsOnlineApplicationInstanceAssociation -Identity $Account.ObjectId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
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
      Write-Verbose -Message 'No Accounts found' -Verbose
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsResourceAccountAssociation
