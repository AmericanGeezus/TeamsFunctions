# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  15-MAY-2021
# Status:   Live

#TODO Evaluate whether to integrate Find-TeamsUVC (Phone Number unique!) as a test


function Assert-TeamsUserVoiceConfig {
  <#
  .SYNOPSIS
    Tests the validity of the Voice Configuration for one or more Users
  .DESCRIPTION
    Validates Object Type, enablement for Enterprise Voice, and optionally also the Tenant Dial Plan
    For Calling Plans, validates Calling Plan License and presence of Telephone Number
    For Direct Routing, validates Online Voice Routing Policy and OnPremLineUri
    For Skype Hybrid PSTN, validate Voice Routing Policy and OnPremLineUri
    Configuration is always done on the assumption that a full configuration is desired.
    Any partial configuration is fed back on screen.
  .PARAMETER UserPrincipalName
    Required. UserPrincipalName of the User to be tested
  .PARAMETER IncludeTenantDialPlan
    Optional. By default, only the core requirements for Voice Routing are verified.
    This extends the requirements to also include the Tenant Dial Plan.
  .PARAMETER ExtensionState
    Optional. For DirectRouting, enforces the presence (or absence) of an Extension. Default: NotMeasured
    No effect for Microsoft Calling Plans
  .EXAMPLE
    Assert-TeamsUserVoiceConfig -UserPrincipalName John@domain.com
    If incorrect/missing, writes information output about every tested parameter
    Returns output of Get-TeamsUserVoiceConfig for all Objects that have an incorrectly configured Voice Configuration
  .EXAMPLE
    Assert-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -IncludeTenantDialPlan
    If incorrect/missing, writes information output about every tested parameter including the Tenant Dial Plan
    Returns output of Get-TeamsUserVoiceConfig for all Objects that have an incorrectly configured Voice Configuration
  .EXAMPLE
    Assert-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -ExtensionState MustBePopulated
    If incorrect/missing, writes information output about every tested parameter including the Extension.
    With MustBePopulated an Extension is expected. If no Extension is present, it is flagged as misconfigured
    Returns output of Get-TeamsUserVoiceConfig for all Objects that have an incorrectly configured Voice Configuration
  .INPUTS
    System.String
  .OUTPUTS
    System.Void - If called directly and no errors are found - Information Text only
    System.Object - If called directly and errors are found (Get-TeamsUserVoiceConfig)
    Boolean - If called by other CmdLets
  .NOTES
    Verbose output is available, though all required information is fed back directly to the User.
    If no objections are found, nothing is returned.
    Piping the Output to Export-Csv can give the best result for investigation into misconfigured users.
  .COMPONENT
    VoiceConfiguration
  .FUNCTIONALITY
    Finding Users with a incorrectly set up Voice Configuration
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-TeamsUserVoiceConfig.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsUserVoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating
  .LINK
    about_TeamsUserVoiceConfiguration
  .LINK
    Assert-TeamsUserVoiceConfig
  .LINK
    Find-TeamsUserVoiceConfig
  .LINK
    Get-TeamsTenantVoiceConfig
  .LINK
    Get-TeamsUserVoiceConfig
  .LINK
    New-TeamsUserVoiceConfig
  .LINK
    Set-TeamsUserVoiceConfig
  .LINK
    Remove-TeamsUserVoiceConfig
  .LINK
    Test-TeamsUserVoiceConfig
  #>

  [CmdletBinding()]
  [Alias('Assert-TeamsUVC')]
  #[OutputType([Boolean])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Username(s)')]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(HelpMessage = 'Extends requirements to include Tenant Dial Plan assignment')]
    [switch]$IncludeTenantDialPlan,

    [Parameter(HelpMessage = 'Extends requirements to validate the status of the Extension')]
    [ValidateSet('MustBePopulated','MustNotBePopulated','NotMeasured')]
    [string]$ExtensionState = 'NotMeasured'
  )

  begin {
    Show-FunctionStatus -Level Live
    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

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


  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($Id in $UserPrincipalName) {
      Write-Verbose -Message "[PROCESS] Processing '$Id'"

      try {
        $CsOnlineUser = Get-CsOnlineUser -Identity "$Id" -WarningAction SilentlyContinue -ErrorAction STOP
        $User = $CsOnlineUser.UserPrincipalName
      }
      catch {
        Write-Error -Message "User '$Id' not found"
        continue
      }
      if ($CsOnlineUser.InterpretedUserType -notlike '*User*') {
        Write-Information "User '$User' not a User"
        continue
      }
      else {
        # Testing Full Configuration
        Write-Verbose -Message "User '$User' - User Voice Configuration (Full)"
        $TestFull = Test-TeamsUserVoiceConfig -UserPrincipalName "$User" -IncludeTenantDialPlan:$IncludeTenantDialPlan -ExtensionState:$ExtensionState
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          "Function: $($MyInvocation.MyCommand.Name): TestFull:", ($TestFull | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }

        if ($TestFull) {
          if ($Called) {
            Write-Output $TestFull
          }
          else {
            Write-Information "User '$User' is correctly configured"
            continue
          }
        }
        else {
          # Testing Partial Configuration
          Write-Verbose -Message "User '$User' - User Voice Configuration (Partial)"
          $TestPart = Test-TeamsUserVoiceConfig -UserPrincipalName "$User" -Partial -IncludeTenantDialPlan:$IncludeTenantDialPlan -ExtensionState:$ExtensionState -WarningAction SilentlyContinue
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "Function: $($MyInvocation.MyCommand.Name): TestPart:", ($TestPart | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
          }

          if ($TestPart) {
            if ($Called) {
              Write-Output $TestPart
            }
            else {
              Write-Warning "User '$User' is only partially configured!"
              Get-TeamsUserVoiceConfig -UserPrincipalName "$User" -SkipLicenseCheck -DiagnosticLevel 1 -WarningAction SilentlyContinue
            }
          }
        }
      }

    } #foreach Identity

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Assert-TeamsUserVoiceConfig