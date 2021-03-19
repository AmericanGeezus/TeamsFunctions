# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-APR-2020
# Status:   RC




function Assert-TeamsUserVoiceConfig {
  <#
  .SYNOPSIS
    Short description
  .DESCRIPTION
    Long description
  .PARAMETER Identity
    x
  .PARAMETER x
    x
  .EXAMPLE
    Verb-Noun -Identity John@domain.com
    xx
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    xx
  .COMPONENT
    xx
  .ROLE
    xx
  .FUNCTIONALITY
    xx
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Assert-TeamsUserVoiceConfig
  #>

  [CmdletBinding()]
  [Alias('Assert-TeamsUVC')]
  #[OutputType([Boolean])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Username(s)')]
    [Alias('UserPrincipalName', 'UPN')]
    [string[]]$Identity

  )

  begin {
    Show-FunctionStatus -Level RC
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

    foreach ($Id in $Identity) {
      Write-Verbose -Message "[PROCESS] Processing '$Id'"

      try {
        $CsOnlineUser = Get-CsOnlineUser -Identity "$Id" -WarningAction SilentlyContinue -ErrorAction STOP
        $User = $CsOnlineUser.UserPrincipalName
      }
      catch {
        Write-Error -Message "User '$User' not found"
        continue
      }
      if ($CsOnlineUser.InterpretedUserType -notlike '*User*') {
        Write-Information "User '$User' not a User"
        continue
      }
      if (-not $CsOnlineUser.EnterpriseVoiceEnabled ) {
        Write-Information "User '$User' not enabled for Enterprise Voice"
        continue
      }
      else {
        Write-Verbose -Message "User '$User' - User Voice Configuration (Full)"
        $TestFull = Test-TeamsUserVoiceConfig -Identity "$User"

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
          Write-Verbose -Message "User '$User' - User Voice Configuration (Partial)"
          $TestPart = Test-TeamsUserVoiceConfig -Identity "$User" -Partial
          if ($TestPart) {
            if ($Called) {
              Write-Output $TestPart
            }
            else {
              Write-Warning "User '$User' is partially configured! Please investigate"
              # Output with Switch (faster with values already queried!)
              Get-TeamsUserVoiceConfig "$User" -SkipLicenseCheck -DiagnosticLevel 1
              #$CsOnlineUser | Select-Object UserPrincipalName, InterpretedUserType, EnterpriseVoiceEnabled, VoiceRoutingPolicy, OnlineVoiceRoutingPolicy, TelephoneNumber, LineUri, OnPremLineURI
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