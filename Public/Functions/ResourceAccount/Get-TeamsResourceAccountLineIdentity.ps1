# Module:   TeamsFunctions
# Function: ResourceAccount Calling Line Identity
# Author:	  David Eberhardt
# Updated:  16-JUL-2021
# Status:   RC




function Get-TeamsResourceAccountLineIdentity {
  <#
  .SYNOPSIS
    Queries Calling Line Identity Objects for Resource Accounts
  .DESCRIPTION
    Get-CsCallingLineIdentity with resolving Resource Account Ids to Names and displaying the underlying Phone Number
  .PARAMETER Identity
    Required - Parameter set CLI. Identifies the CsCallingLineIdentity to be queried
  .PARAMETER UserPrincipalName
    Required. Identifies the Resource Account for which the Line Identity was created
  .EXAMPLE
    Get-TeamsResourceAccountLineIdentity -UserPrincipalName ResourceAccount@domain.com
    Queries a Line Identity for the Resource Account provided and displays this Object - Default
  .EXAMPLE
    Get-TeamsResourceAccountLineIdentity -Identity 'My Calling Line Identity'
    Queries a Line Identity with the Name 'My Calling Line Identity'.
  .EXAMPLE
    Get-TeamsResourceAccountLineIdentity -Filter '*Calling*'
    Queries all Line Identities with 'Calling' in the Name.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    The Calling Line Identity is created with New-TeamsResourceAccountLineIdentity (or with New-CsCallingLineIdentity).
    This CmdLet queries these objects and (provided the CallingIDSubstitute is 'Resource') resolves Resource Account ID
    to the Display Name and displays the Resource Accounts Phone Number.
    https://docs.microsoft.com/en-us/powershell/module/skype/Get-cscallinglineidentity?view=skype-ps
  .COMPONENT
    TeamsResourceAccount
    TeamsCallingLineIdentity
  .FUNCTIONALITY
    Queries a Line identity a Resource Accounts and displays its assigned Phone Number
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsResourceAccountLineIdentity.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsFunctions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(DefaultParameterSetName = 'RA', ConfirmImpact = 'Low')]
  [Alias('Get-TeamsRAIdentity', 'Get-TeamsRACLI')]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'RA', HelpMessage = 'UPN of the Object to create.')]
    [ValidateScript( {
        If ($_ -match '@' -or $_ -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$') { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Parameter UserPrincipalName must be a valid UPN or GUID of a Resource Account'
          $false
        }
      })]
    [Alias('ResourceAccount')]
    [string[]]$UserPrincipalName,

    [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Id', HelpMessage = 'Identity of the Calling Line Identity')]
    [string[]]$Identity,

    [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Filter', HelpMessage = 'Filter String for the Calling Line Identity')]
    [string]$Filter

  )

  begin {
    Show-FunctionStatus -Level RC

    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    #region Input query and validation
    switch ($PSCmdlet.ParameterSetName) {
      'RA' {
        [System.Collections.ArrayList]$ResourceAccounts = @()
        foreach ($UPN in $UserPrincipalName) {
          Write-Verbose -Message "Querying Resource Account with UserPrincipalName '$UPN'"
          try {
            $RA = Get-CsOnlineApplicationInstance -Identity "$UPN" -ErrorAction Stop
            [void]$ResourceAccounts.Add($RA)
          }
          catch {
            Write-Information "INFO:    Resource Account '$UPN' - Not found!"
          }
        }
        [System.Collections.ArrayList]$CallingLineIdentities = @()
        foreach ($RA in $ResourceAccounts) {
          Write-Verbose -Message "Querying Calling Line Identities for Resource Account '$($RA.UserPrincipalName)'"
          try {
            $CLI = Get-CsCallingLineIdentity | Where-Object ResourceAccount -EQ $RA.ObjectId -ErrorAction Stop
            [void]$CallingLineIdentities.Add($CLI)
          }
          catch {
            Write-Information "INFO:    Calling Line Identity '$($CLI.Identity)' - Not found!"
            continue
          }
        }
      }
      'Id' {
        [System.Collections.ArrayList]$CallingLineIdentities = @()
        foreach ($Id in $Identity) {
          Write-Verbose -Message "Querying Calling Line Identities for provided ID '$Id'"
          try {
            $CLI = Get-CsCallingLineIdentity -Identity "$Id"
            if ($CLI.CallingIDSubstitute -ne 'Resource') {
              Write-Warning -Message "Calling Line Identity '$($CLI.Identity)' is not of Type 'Resource' - omiting object"
              continue
            }
            else {
              Write-Verbose -Message "CallingLineIdentity '$($CLI.Identity)' is of Type 'Resource' - adding to list"
              [void]$CallingLineIdentities.Add($CLI)
            }
          }
          catch {
            Write-Information "INFO:    Calling Line Identity '$($CLI.Identity)' - Not found!"
            continue
          }
        }
      }
      'Filter' {
        Write-Verbose -Message "Querying Calling Line Identities for provided FilterString '$Filter'"
        try {
          $FilteredCLIs = Get-CsCallingLineIdentity -Filter "$Filter"
          [System.Collections.ArrayList]$CallingLineIdentities = @()
          foreach ($CLI in $FilteredCLIs) {
            if ($CLI.CallingIDSubstitute -ne 'Resource') {
              Write-Warning -Message "CallingLineIdentity '$($CLI.Identity)' is not of Type 'Resource' - omiting object"
              continue
            }
            else {
              Write-Verbose -Message "CallingLineIdentity '$($CLI.Identity)' is of Type 'Resource' - adding to list"
              [void]$CallingLineIdentities.Add($CLI)
            }
          }
        }
        catch {
          Write-Information "INFO:    Calling Line Identity '$Filter' - Not found!"
          return
        }
      }
    }
    #endregion

    # Processing found objects
    foreach ($CLI in $CallingLineIdentities) {
      Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Processing CLI: '$($CLI.Identity)'"
      try {
        if (-not $CLI.ResourceAccount) {
          throw 'Resource Account not assigned!'
        }
        else {
          $ResourceAccount = Get-TeamsResourceAccount $CLI.ResourceAccount -ErrorAction Stop
        }

        # Validating Resource Account Settings
        # Check for Line URI - only allow if PhoneNumber is set!
        if ( -not $ResourceAccount.PhoneNumber ) {
          Write-Warning -Message "Resource Account '$($ResourceAccount.UserPrincipalName)' does not have a Phone Number assigned."
        }
        # Check for OVP - if not set, write warning
        if ( -not $ResourceAccount.OnlineVoiceRoutingPolicy ) {
          Write-Warning -Message "Resource Account '$($ResourceAccount.UserPrincipalName)' does not have an OnlineVoiceRoutingPolicy assigned."
        }
        if (  -not $ResourceAccount.AssociatedTo ) {
          Write-Warning -Message 'Resource Account '$($ResourceAccount.UserPrincipalName)' is currently not associated with a Call Queue or Auto Attendant!'
        }

        # creating new PS Object (synchronous with Get and Set)
        $CLIObject = [PSCustomObject][ordered]@{
          Identity                   = $CLI.Identity
          Description                = $CLI.Description
          CallingIDSubstitute        = $CLI.CallingIDSubstitute
          EnableUserOverride         = $CLI.EnableUserOverride
          BlockIncomingPstnCallerID  = $CLI.BlockIncomingPstnCallerID
          CompanyName                = $CLI.CompanyName
          ResourceAccountDisplayName = $ResourceAccount.DisplayName
          ResourceAccount            = $ResourceAccount.UserPrincipalName
          PhoneNumberType            = $ResourceAccount.PhoneNumberType
          PhoneNumber                = $ResourceAccount.PhoneNumber
        }
        Write-Output $CLIObject
      }
      catch {
        Write-Error -Message "Error querying Resource Account: $_"
        Write-Verbose -Message 'Displaying Calling Line Identity Object as-is' -Verbose
        Write-Output $CLI
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsResourceAccountLineIdentity
