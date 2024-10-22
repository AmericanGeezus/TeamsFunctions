﻿# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:   David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live




function New-TeamsAutoAttendantPrompt {
  <#
  .SYNOPSIS
    Creates a prompt
  .DESCRIPTION
    Wrapper for New-CsAutoAttendantPrompt for easier use
  .PARAMETER String
    Required. String as a Path for a Recording or a Greeting (Text-to-Voice)
  .PARAMETER AlternativeString
    Optional. Alternative (secondary) String as a Path for a Recording or a Greeting (Text-to-Voice)
    Must be the opposite type of the main String
  .EXAMPLE
    New-TeamsAutoAttendantPrompt -String "Welcome to Contoso"
    Creates a Text-to-Voice Prompt for the String
    Warning: This will break if the String ends in a supported File extension
  .EXAMPLE
    New-TeamsAutoAttendantPrompt -String "myAudioFile.mp3"
    Verifies the file exists, then imports it (with Import-TeamsAudioFile)
    Creates a Audio File Prompt after import.
  .EXAMPLE
    New-TeamsAutoAttendantPrompt -String "Welcome to Contoso" -AlternativeString "myAudioFile.mp3"
    Creates a Text-to-Voice Prompt for the String and the AudioFile, but will play the Text-to-Voice one
    Warning: This will break if the String ends in a supported File extension
  .EXAMPLE
    New-TeamsAutoAttendantPrompt -String "myAudioFile.mp3"
    Verifies the file exists, then imports it (with Import-TeamsAudioFile)
    Creates a Audio File Prompt after import and for Text-to-Voice, but will play the AudioFile
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Warning: The Automatic detection of the String depends on the last 4 characters of the String.
    This will break if the String ends in a supported File extension (WAV, WMA or MP3), for example.
    This Cmdlet does not allow use of the ActiveType Parameter as the the type is inferred by the string provided.
    Further development may see an addition of a secondary String (which would then make the provided -String the active type)
  .COMPONENT
    TeamsAutoAttendant
  .FUNCTIONALITY
    Creates a Prompt object to be used in Auto Attendants
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantPrompt.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
  [Alias('New-TeamsAAPrompt')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory, HelpMessage = 'Main String. Path the the recording OR Text-to-Voice string')]
    [ArgumentCompleter( { '<Your Text-to-speech-string>', 'C:\Temp\' })]
    [string]$String,

    [Parameter(HelpMessage = 'Alternative (secondary) String. Path the the recording OR Text-to-Voice string')]
    [ArgumentCompleter( { 'C:\Temp\', '<Your Text-to-speech-string>' })]
    [string]$AlternativeString

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting MicrosoftTeams Connection
    if ( -not (Assert-MicrosoftTeamsConnection) ) { break }

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
    $Prompt = $null

    #region Processing String - Main application
    if ($String -match '.(wav|wma|mp3)') {
      #Recording
      if (-not (Test-Path $String)) {
        Write-Error -Message 'Auto Attendant Prompt - AudioFile - File not found.' -ErrorAction Stop
      }
      else {
        Write-Verbose -Message '[PROCESS] Creating Auto Attendant Prompt - AudioFile'
        if ($PSCmdlet.ShouldProcess("$String", 'Import-TeamsAudioFile')) {
          try {
            $audioFile = Import-TeamsAudioFile -ApplicationType AutoAttendant -File "$String"
            $Parameters += @{'ActiveType' = 'AudioFile' }
            $Parameters += @{'AudioFilePrompt' = $audioFile }
          }
          catch {
            Write-Error -Message "Importing Audio File failed: $($_.Exception.Message)" -ErrorAction Stop
          }
        }
      }
    }
    else {
      #Assume it is Text-to-Voice
      Write-Verbose -Message '[PROCESS] Creating Auto Attendant Prompt - Text-to-Voice'
      if ($PSCmdlet.ShouldProcess("$Prompt", 'New-CsAutoAttendantPrompt')) {
        $Parameters += @{'ActiveType' = 'TextToSpeech' }
        $Parameters += @{'TextToSpeechPrompt' = "$String" }
      }
    }
    #endregion

    #region Processing AlternativeString - Secondary application
    if ( $AlternativeString ) {
      switch ( $Parameters.ActiveType ) {
        'TextToSpeech' {
          if ($AlternativeString -notmatch '.(wav|wma|mp3)') {
            # AlternativeString is not a Recording
            Write-Warning 'Auto Attendant Prompt - String and AlternativeString are both TextToSpeech strings - only one is supported - omitting'
          }
          else {
            # AlternativeString is a Recording
            if (-not (Test-Path $AlternativeString)) {
              Write-Warning -Message 'Auto Attendant Prompt - AlternativeString - AudioFile - File not found.' -ErrorAction Stop
            }
            else {
              Write-Verbose -Message '[PROCESS] Creating Alternative Auto Attendant Prompt - AudioFile'
              if ($PSCmdlet.ShouldProcess("$Prompt", 'New-CsAutoAttendantPrompt')) {
                try {
                  $audioFile2 = Import-TeamsAudioFile -ApplicationType AutoAttendant -File "$AlternativeString"
                  $Parameters += @{'AudioFilePrompt' = $audioFile2 }
                }
                catch {
                  Write-Warning -Message "Importing Audio File failed: $($_.Exception.Message) - Omitting alternative method" -ErrorAction Stop
                }
              }
            }
          }
        }
        'AudioFile' {
          if ($AlternativeString -match '.(wav|wma|mp3)') {
            # AlternativeString is a Recording
            Write-Warning 'String and AlternativeString are both AudioFiles - only one is supported - omitting'
          }
          else {
            # AlternativeString is not a Recording
            #Assume it is Text-to-Voice
            Write-Verbose -Message '[PROCESS] Creating Alternative Auto Attendant Prompt - Text-to-Voice'
            if ($PSCmdlet.ShouldProcess("$Prompt", 'New-CsAutoAttendantPrompt')) {
              $Parameters += @{'TextToSpeechPrompt' = "$AlternativeString" }
            }
          }
        }
      }
    }
    #endregion

    # Creating Prompt
    Write-Verbose -Message '[PROCESS] Creating Prompt'
    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
      "  Function: $($MyInvocation.MyCommand.Name) - Parameters:", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }

    if ($PSCmdlet.ShouldProcess("$Name", 'New-CsAutoAttendantPrompt')) {
      New-CsAutoAttendantPrompt @Parameters
    }
  }

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsAutoAttendantPrompt
