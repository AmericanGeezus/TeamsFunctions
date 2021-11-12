# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:   David Eberhardt
# Updated:  01-OCT-2020
# Status:   RC




function Find-TeamsResourceAccount {
  <#
  .SYNOPSIS
    Finds Resource Accounts from AzureAD
  .DESCRIPTION
    Returns Resource Accounts based on input (Search String).
    This runs Find-CsOnlineApplicationInstance but reformats the Output with friendly names
  .PARAMETER SearchQuery
    Required. Positional. Part of the DisplayName of the Account.
  .PARAMETER AssociatedOnly
    Optional. Considers only associated Resource Accounts
  .PARAMETER UnAssociatedOnly
    Optional. Considers only unassociated Resource Accounts
  .EXAMPLE
    Find-TeamsResourceAccount -SearchQuery "Office"
    Returns all Resource Accounts with "Office" as part of their DisplayName
  .EXAMPLE
    Find-TeamsResourceAccount -SearchQuery "Office" -AssociatedOnly
    Returns all associated Resource Accounts with "Office" as part of their DisplayName
  .EXAMPLE
    Find-TeamsResourceAccount -SearchQuery "Office" -UnAssociatedOnly
    Returns all unassociated Resource Accounts with "Office" as part of their DisplayName
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    None
  .COMPONENT
    TeamsResourceAccount
    TeamsAutoAttendant
    TeamsCallQueue
  .FUNCTIONALITY
    Finds Resource Accounts by Name
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsResourceAccount.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsResourceAccount.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(DefaultParameterSetName = 'Search')]
  [Alias('Find-TeamsRA')]
  [OutputType([System.Object])]
  param (
    [Parameter(Mandatory, Position = 0, ParameterSetName = 'Search', HelpMessage = 'Part of the DisplayName to be found')]
    [Parameter(Mandatory, Position = 0, ParameterSetName = 'AssociatedOnly', HelpMessage = 'Part of the DisplayName to be found')]
    [Parameter(Mandatory, Position = 0, ParameterSetName = 'UnAssociatedOnly', HelpMessage = 'Part of the DisplayName to be found')]
    [ValidateLength(3, 255)]
    [string]$SearchQuery,

    [Parameter(Mandatory, Position = 1, ParameterSetName = 'AssociatedOnly', HelpMessage = 'Returns only Objects assigned to CQ or AA')]
    [Alias('Assigned', 'InUse')]
    [switch]$AssociatedOnly,

    [Parameter(Mandatory, Position = 1, ParameterSetName = 'UnAssociatedOnly', HelpMessage = 'Returns only Objects not assigned to CQ or AA')]
    [Alias('Unassigned', 'Free')]
    [switch]$UnAssociatedOnly
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

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

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $ResourceAccounts = $null

    #region Data gathering
    if ($PSBoundParameters.ContainsKey('AssociatedOnly')) {
      Write-Verbose -Message "SearchQuery - Searching for ASSOCIATED Accounts containing '$SearchQuery'"
      $ResourceAccounts = Find-CsOnlineApplicationInstance -SearchQuery "$SearchQuery" -AssociatedOnly
    }
    elseif ($PSBoundParameters.ContainsKey('UnAssociatedOnly')) {
      Write-Verbose -Message "SearchQuery - Searching for UNASSOCIATED Accounts containing '$SearchQuery'"
      $ResourceAccounts = Find-CsOnlineApplicationInstance -SearchQuery "$SearchQuery" -UnAssociatedOnly
    }
    else {
      Write-Verbose -Message "SearchQuery - Searching for Accounts containing '$SearchQuery'"
      $ResourceAccounts = Find-CsOnlineApplicationInstance -SearchQuery "$SearchQuery"
    }

    if ( -not $ResourceAccounts ) {
      Write-Verbose -Message 'No Resource Accounts found matching this string.'
      return
    }
    else {
      Write-Verbose -Message 'Found Resource Accounts. Performing lookup. Please wait...'
      foreach ($ResourceAccount in $ResourceAccounts) {
        Write-Verbose -Message "Querying Account '$($ResourceAccount.Id)'"
        $AdUser = Get-AzureADUser -ObjectId $ResourceAccount.Id -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

        # creating new PS Object (synchronous with Get and Set)
        $ResourceAccountObject = [PSCustomObject][ordered]@{
          ObjectId          = $AdUser.ObjectId
          UserPrincipalName = $AdUser.UserPrincipalName
          DisplayName       = $AdUser.DisplayName
          UsageLocation     = $AdUser.UsageLocation
          PhoneNumber       = $AdUser.PhoneNumber
        }

        # Associations
        if ( $PSBoundParameters.ContainsKey('AssociatedOnly')) {
          Write-Verbose -Message "'$($AdUser.DisplayName)' Parsing: Association"
          $Association = Get-CsOnlineApplicationInstanceAssociation -Identity $AdUser.ObjectId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          $AssociationObject = switch ($Association.ConfigurationType) {
            'CallQueue' { Get-CsCallQueue -Identity $Association.ConfigurationId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue }
            'AutoAttendant' { Get-CsAutoAttendant -Identity $Association.ConfigurationId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue }
          }
          $AssociationStatus = Get-CsOnlineApplicationInstanceAssociationStatus -Identity "$($AdUser.ObjectId)" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

          # Expanding Object
          $ResourceAccountObject | Add-Member -MemberType NoteProperty -Name AssociatedTo -Value $AssociationObject.Name
          $ResourceAccountObject | Add-Member -MemberType NoteProperty -Name AssociatedAs -Value $Association.ConfigurationType
          $ResourceAccountObject | Add-Member -MemberType NoteProperty -Name AssociationStatus -Value $AssociationStatus.Status
        }

        Write-Output $ResourceAccountObject

      }

    }
    #endregion


    #region OUTPUT
    # Creating new PS Object
    try {
      Write-Verbose -Message 'Parsing Resource Accounts, please wait...'
    }
    catch {
      Write-Warning -Message 'Object Output could not be determined. Please verify manually with Get-CsOnlineApplicationInstance'
    }
    #endregion
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Find-TeamsResourceAccount
