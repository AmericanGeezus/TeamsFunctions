# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   BETA




function New-TeamsAutoAttendantPrompt {
  <#
  .SYNOPSIS
    Creates a prompt
  .DESCRIPTION
    Wrapper for New-CsAutoAttendantPrompt for easier use
  .PARAMETER String
    Required. String as a Path for a Recording or a Greeting (Text-to-Voice)
  .EXAMPLE
    New-TeamsAutoAttendantPrompt -String "Welcome to Contoso"
    Creates a Text-to-Voice Prompt for the String
    Warning: This will break if the String ends in a supported File extension
  .EXAMPLE
    New-TeamsAutoAttendantPrompt -String "myAudioFile.mp3"
    Verifies the file exists, then imports it (with Import-TeamsAudioFile)
    Creates a Audio File Prompt after import.
  .NOTES
    Warning: This will break if the String ends in a supported File extension (WAV, WMA or MP3)
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .COMPONENT
    TeamsAutoAttendant
	.LINK
    New-TeamsAutoAttendant
    Set-TeamsAutoAttendant
    New-TeamsAutoAttendantCallableEntity
    New-TeamsAutoAttendantDialScope
    New-TeamsAutoAttendantPrompt
    New-TeamsAutoAttendantSchedule
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
  [Alias('New-TeamsAAPrompt')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "Path the the recording OR Text-to-Voice string")]
    [string]$String

  ) #param

  begin {
    # Caveat - Script in Development
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    Show-FunctionStatus -Level BETA
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

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

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $Prompt = $null

    if ($String -match '.wav' -or $String -match '.wma' -or $String -match '.mp3') {
      #Recording
      if (-not (Test-Path $String)) {
        Write-Error -Message "Auto Attendant Prompt - AudioFile - File not found." -ErrorAction Stop
      }
      else {
        Write-Verbose -Message "[PROCESS] Creating Auto Attendant Prompt - AudioFile"
        if ($PSCmdlet.ShouldProcess("$Prompt", "New-CsAutoAttendantPrompt")) {
          $audioFile = Import-TeamsAudioFile -ApplicationType AutoAttendant -File $String
          $Prompt = New-CsAutoAttendantPrompt -ActiveType AudioFile -AudioFilePrompt $audioFile
        }
      }
    }
    else {
      #Assume it is Text-to-speech
      Write-Verbose -Message "[PROCESS] Creating Auto Attendant Prompt - Text-to-Speech"
      if ($PSCmdlet.ShouldProcess("$Prompt", "New-CsAutoAttendantPrompt")) {
        $Prompt = New-CsAutoAttendantPrompt -ActiveType TextToSpeech -TextToSpeechPrompt "$String"
      }
    }

    return $Prompt
  }

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsAutoAttendantPrompt
