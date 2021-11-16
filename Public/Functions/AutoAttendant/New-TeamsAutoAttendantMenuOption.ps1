# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:   David Eberhardt
# Updated:  12-DEC-2020
# Status:   Live




function New-TeamsAutoAttendantMenuOption {
  <#
  .SYNOPSIS
    Creates a Menu Options Object
  .DESCRIPTION
    Creates a Menu Options Object to be used in Auto Attendants
    Wrapper for New-CsAutoAttendantMenuOption with friendly names
  .PARAMETER DisconnectCall
    Required to create a basic 'Disconnect' option. Switch. Default.
  .PARAMETER Press
    Required for binding a specific Dial Key. Integer.
    Dtmf Tone (digit) to be pressed for this option. Set to Automatic if not provided.
  .PARAMETER OrSay
    Optional for Option TransferToCallTarget. String.
    Voice Response to be used for this option. Expected: Single word
  .PARAMETER ToOperator
    Required for Option TransferToOperator. Switch. No other input necessary.
    The AutoAttendant which will receive a Menu with this option, must have an Operator defined.
    Creating or Updating an Auto Attendant with an Operator that is not defined will lead to errors.
  .PARAMETER ToCallTarget
    Required for Option TransferToCallTarget. String identifying the Call Target:
    UserPrincipalName (User, ApplicationEndpoint), Group Name (Shared Voicemail), Tel Uri (ExternalPstn)
  .PARAMETER Announcement
    Required for Option Announcement. String for the Audio File OR Text-to-Voice
  .EXAMPLE
    New-TeamsAutoAttendantMenuOption -Disconnect
    Creates a default Menu Option to be used for disconnecting the call.
  .EXAMPLE
    New-TeamsAutoAttendantMenuOption -Press 0 -TransferToOperator
    Creates a Menu Option on pressing 0 (voice response is 'Operator' by default) to Transfer to the Operator.
    Note: The Operator must be specified in the AutoAttendant!
  .EXAMPLE
    New-TeamsAutoAttendantMenuOption -Press 1 -CallTarget "My Group"
    Creates a Menu Option on pressing 1 or saying 'one' (default) to Transfer to the Call Target (Shared Voicemail)
  .EXAMPLE
    New-TeamsAutoAttendantMenuOption -Press 2 -CallTarget Sales@domain.com -OrSay "Sales"
    Creates a Menu Option on pressing 2 or saying 'Sales' to Transfer to the Call Target (User).
  .EXAMPLE
    New-TeamsAutoAttendantMenuOption -Press 3 -CallTarget MyCQ@domain.com -OrSay "Queue"
    Creates a Menu Option on pressing 3 or saying 'Queue' to Transfer to the Call Target (Call Queue).
  .EXAMPLE
    New-TeamsAutoAttendantMenuOption -Press 4 -CallTarget MyAA@domain.com -OrSay "Menu"
    Creates a Menu Option on pressing 4 or saying 'Menu' to Transfer to the Call Target (Auto Attendant).
  .EXAMPLE
    New-TeamsAutoAttendantMenuOption -Press 5 -CallTarget "tel:+15551234567" -OrSay "Engineer"
    Creates a Menu Option on pressing 5 or saying 'Engineer' to Transfer to the Call Target (ExternalPstn).
  .EXAMPLE
    New-TeamsAutoAttendantMenuOption -Press 6 -Announcement "We are open Monday to Friday from 9 AM to 5 PM" -OrSay "Hours"
    Creates a Menu Option on pressing 6 or saying 'Hours' to play an Announcement (Text-to-Voice) and return to the main menu.
  .EXAMPLE
    New-TeamsAutoAttendantMenuOption -Press 7 -Announcement "C:\Temp\AudioFile-OpeningHours.wav" -OrSay "Hours"
    Creates a Menu Option on pressing 7 or saying 'Hours' to play an Announcement (Audio File) and return to the main menu.
    The File must exist in the specified
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    None
  .COMPONENT
    TeamsAutoAttendant
  .FUNCTIONALITY
    Creates a MenuOption Object to be used in Auto Attendants
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantMenuOption.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'DisconnectCall', ConfirmImpact = 'Low')]
  [Alias('New-TeamsAAOption')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory, ParameterSetName = 'DisconnectCall', Position = 0, HelpMessage = 'Option to disconnect for default menus')]
    [switch]$DisconnectCall,

    [Parameter(ParameterSetName = 'Operator', HelpMessage = 'Number to press on the Dial Pad')]
    [Parameter(ParameterSetName = 'CallTarget', HelpMessage = 'Number to press on the Dial Pad')]
    [Parameter(ParameterSetName = 'Announcement', HelpMessage = 'Number to press on the Dial Pad')]
    [Alias('DtmfResponseTone')]
    [ValidateRange(0, 9)]
    [int]$Press,

    [Parameter(Mandatory, ParameterSetName = 'Operator', HelpMessage = 'Option to transfer the Call to the Operator defined')]
    [Alias('Operator')]
    [switch]$TransferToOperator,

    [Parameter(ParameterSetName = 'Operator', HelpMessage = 'Alternative voice Response')]
    [Parameter(ParameterSetName = 'CallTarget', HelpMessage = 'Alternative voice Response')]
    [Parameter(ParameterSetName = 'Announcement', HelpMessage = 'Alternative voice Response')]
    [Alias('VoiceResponses', 'Say')]
    [ValidateScript( { if ($_ -match '^[^\W_]+$') { $true } else { Write-Error -Message 'Voice Response must be one word without spaces or symbols.' } })]
    [string]$OrSay,

    [Parameter(ParameterSetName = 'CallTarget', HelpMessage = 'CallTarget')]
    [string]$CallTarget,

    [Parameter(ParameterSetName = 'Announcement', HelpMessage = 'Path the the recording OR Text-to-Voice string')]
    [ArgumentCompleter( { '<Your Text-to-speech-string>', 'C:\Temp\' })]
    [string]$Announcement

  ) #param

  begin {
    Show-FunctionStatus -Level Live
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

    # Preparing Splatting Object
    $Parameters = $null
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ( $PSCmdlet.ParameterSetName -ne 'DisconnectCall') {
      # Process Press & Say if specified
      if ($Press) {
        $DtmfResponse = 'Tone' + $Press
        if ($OrSay) {
          $Parameters += @{'VoiceResponses' = $OrSay }
        }
      }
      else {
        $DtmfResponse = 'Automatic'
        if ($OrSay) {
          Write-Warning -Message "Parameter 'OrSay' can only be used together with 'Press' - omitted."
        }
      }
    }

    switch ($PSCmdlet.ParameterSetName) {
      'DisconnectCall' {
        $Parameters += @{'DtmfResponse' = 'Automatic' }
        $Parameters += @{'Action' = 'DisconnectCall' }
      }
      'Operator' {
        $Parameters += @{'DtmfResponse' = $DtmfResponse }
        $Parameters += @{'Action' = 'TransferCallToOperator' }
      }
      'Announcement' {
        # Creating Prompt
        try {
          $Prompt = New-TeamsAutoAttendantPrompt -String "$Announcement" -ErrorAction Stop
          if ( $Prompt ) {
            $Parameters += @{'Prompt' = $Prompt }
          }
          $Parameters += @{'DtmfResponse' = $DtmfResponse }
          $Parameters += @{'Action' = 'Announcement' }
        }
        catch {
          Write-Error -Message "Error Creating Prompt: $($_.Exception.Message)" -ErrorAction Stop
        }
      }
      'CallTarget' {
        # Determine Call Target
        try {
          $CallableEntity = New-TeamsCallableEntity -Identity "$CallTarget" -ErrorAction Stop
          if ( $CallableEntity ) {
            $Parameters += @{'CallTarget' = $CallableEntity }
          }
          $Parameters += @{'DtmfResponse' = $DtmfResponse }
          $Parameters += @{'Action' = 'TransferCallToTarget' }
        }
        catch {
          Write-Error -Message "Error Creating Call Target: $($_.Exception.Message)" -ErrorAction Stop
        }
      }
    }

    # Create Menu Option
    Write-Verbose -Message '[PROCESS] Creating Menu Option'
    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
      "Function: $($MyInvocation.MyCommand.Name): Parameters:", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }

    if ($PSCmdlet.ShouldProcess('New MenuOption', 'New-CsAutoAttendantMenuOption')) {
      New-CsAutoAttendantMenuOption @Parameters
    }
  }

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsAutoAttendantMenu
