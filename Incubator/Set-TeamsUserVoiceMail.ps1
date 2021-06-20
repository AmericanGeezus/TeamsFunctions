# Module:   TeamsFunctions
# Function: UserVoiceConfig
# Author:	  David Eberhardt
# Updated:  xx-xxxx-2021
# Status:   Alpha




function Set-TeamsUserVoiceMail {
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
    Set-TeamsUserVoiceMail -Identity John@domain.com
    xx
  .EXAMPLE
    Set-TeamsUserVoiceMail -Identity John@domain.com -LanguageId en-IN
    Sets the Language interpreter to English India - The provided language is
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
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Set-TeamsUserVoiceMail.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsUserVoiceConfig.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_TeamsUserVoiceConfig
  .LINK
    Set-TeamsUserVoiceMail
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
  [Alias('Set=TeamsUVM')]
  [OutputType([System.Void])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'Username(s)')]
    [Alias('Username', 'UPN')]
    [string[]]$Identity,

    [Parameter(HelpMessage = 'test')]
    [Alias('t')]
    [String]$Language,

    [Parameter(HelpMessage = 'Language Identifier from Get-CsAutoAttendantSupportedLanguage.')]
    [ValidateScript( { $_ -in (Get-CsAutoAttendantSupportedLanguage).Id })]
    [string]$LanguageId = 'en-US'

  )

  begin {
    Show-FunctionStatus -Level Alpha
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


    # Language has to be normalised as the Id is case sensitive. Default value: en-US
    $Language = $($LanguageId.Split('-')[0]).ToLower() + '-' + $($LanguageId.Split('-')[1]).ToUpper()
    Write-Verbose "LanguageId '$LanguageId' normalised to '$Language'"
    $VoiceResponsesSupported = (Get-CsAutoAttendantSupportedLanguage -Id $Language).VoiceResponseSupported

    if ( -not $VoiceResponsesSupported ) {
      Write-Error -Message 'selected Language does not support Voice Responses'

    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($Id in $Identity) {
      Write-Verbose -Message "[PROCESS] Processing '$Id'"

      # Set-TeamsUserVoiceMail
      # enable Hostedvoicemail (if not done already)
      # set VM greeting language (to Tenant Dial Plan or DP/Usage Location?)
      # other settings?





      #region Setting Users Voicemail Settings - language
      Write-Verbose -Message '[PROCESS] User '$($CsUser.DisplayName)' - Setting Voicemail language'
      #NOTE this could do more, but do not want to write a full wrapper for the CsOnlineVoicemailUserSettings yet.
      $CsOnlineVoicemailUserSettings = @{
        'Identity' = $CsUser.ObjectId
        'PromptLanguage' = $Language
        'ErrorAction' = 'Stop'
      }
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        "Function: $($MyInvocation.MyCommand.Name): CsOnlineVoicemailUserSettings:", ($CsOnlineVoicemailUserSettings | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
      }
      if ($PSCmdlet.ShouldProcess("$($CsUser.DisplayName)", 'Set-CsOnlineVoicemailUserSettings')) {
        try {
          # Create the Auto Attendant with all enumerated Parameters passed through splatting
          #TEST what output is received
          $null = Set-CsOnlineVoicemailUserSettings @CsOnlineVoicemailUserSettings
          if ($Called) {
            Write-Information "User '$($CsUser.DisplayName)' Voicemail language set to '$Language'"
          }
        }
        catch {
          Write-Error -Message "Error setting Voicemail language : $($_.Exception.Message)" -Category InvalidResult
          continue
        }
      }
      else {
        continue
      }
      #endregion

    } #foreach Identity

    if ($stack.length -lt 3) {
      Write-Verbose -Message ''
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Set-TeamsUserVoiceMail
