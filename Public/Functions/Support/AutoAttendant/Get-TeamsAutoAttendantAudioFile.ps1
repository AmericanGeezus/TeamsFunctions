# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:   David Eberhardt
# Updated:  01-SEP-2021
# Status:   RC




function Get-TeamsAutoAttendantAudioFile {
  <#
  .SYNOPSIS
    Queries Auto Attendants and displays all Audio Files found on the Object
  .DESCRIPTION
    Managing Audio Files for an Auto Attendant is limited in the Admin Center.
    Files cannot be downloaded there. This CmdLet tries to plug that gap by exposing Download Links for all Audio Files
    linked on a given Auto Attendant
  .PARAMETER Name
    Required for ParameterSet Name. Finds all Auto Attendants with this name (unique results).
  .PARAMETER SearchString
    Required for ParameterSet Search. Searches all Auto Attendants for this string (multiple results possible).
  .PARAMETER Detailed
    Optional Switch. Displays all information for the nested Audio File Objects of the Auto Attendant
    By default, only Names and Download URI of nested Objects are shown.
  .EXAMPLE
    Get-TeamsAutoAttendantAudioFile -Name "My AutoAttendant"
    Returns an Object for every Auto Attendant found with the exact Name "My AutoAttendant"
  .EXAMPLE
    Get-TeamsAutoAttendantAudioFile -Name "My AutoAttendant" -Detailed
    Returns an Object for every Auto Attendant found with the exact Name "My AutoAttendant"
    Detailed view will display all nested Objects indented as a tree
  .EXAMPLE
    Get-TeamsAutoAttendantAudioFile -Name "My AutoAttendant" -SearchString "My AutoAttendant"
    Returns an Object for every Auto Attendant found with the exact Name "My AutoAttendant" and
    Returns an Object for every Auto Attendant matching the String "My AutoAttendant"
  .EXAMPLE
    Get-TeamsAutoAttendantAudioFile -SearchString "My AutoAttendant"
    Returns an Object for every Auto Attendant matching the String "My AutoAttendant"
    Synonymous with Get-CsAutoAttendant -NameFilter "My AutoAttendant", but output shown differently.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Managing Audio Files for an Auto Attendant is limited in the Admin Center.
    Files cannot be downloaded there. This CmdLet tries to plug that gap by exposing Download Links for all Audio Files
    linked on a given Auto Attendant
  .COMPONENT
    TeamsAutoAttendant
  .FUNCTIONALITY
    Finding download links for Audio Files on Auto Attendants
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsAutoAttendantAudioFile.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(DefaultParameterSetName = 'Name')]
  [Alias('Get-TeamsAAAudioFile')]
  [OutputType([System.Object[]])]
  param(
    [Parameter(ParameterSetName = 'Name', ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Full Name of the Auto Attendant')]
    [Alias('Identity')]
    [string[]]$Name,

    [Parameter(ParameterSetName = 'Search', HelpMessage = 'Partial or full Name of the Auto Attendant to search')]
    [Alias('NameFilter')]
    [string]$SearchString,

    [switch]$Detailed
  ) #param

  begin {
    Show-FunctionStatus -Level RC
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

    $IsDetailed = ($PSBoundParameters.ContainsKey('Detailed'))

    # Helper Function for outputting Audio Files
    function OutputAudioFile ($AAName, $Prompt, $Step, $IsDetailed) {
      if ($Prompt) {
        Write-Verbose -Message "'$AAName' - $Step - Parsing Prompt"
        if ($IsDetailed) {
          Write-Output $Prompt | Select-Object *
        }
        else {
          Write-Debug "FileName:    $($Prompt.FileName)"
          Write-Debug "DownloadUri: $($Prompt.DownloadUri)"
          Write-Output $Prompt | Select-Object Id,FileName,DownloadUri
        }
      }
      else {
        Write-Verbose -Message "'$AAName' - $Step - No Prompt"
      }
    }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    # Capturing no input
    if (-not $PSBoundParameters.ContainsKey('Name') -and -not $PSBoundParameters.ContainsKey('SearchString')) {
      Write-Information 'INFO:    No Parameters specified - No action taken. Please provide Parameter Name or SearchString'
      return
    }
    else {
      #region Query objects
      $AutoAttendants = @()
      switch ($PSCmdlet.ParameterSetName) {
        'Name' {
          # Lookup
          Write-Verbose -Message "Parameter 'Name' - Querying unique result for each provided Name"
          foreach ($DN in $Name) {
            if ( $DN -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$' ) {
              #Identity or ObjectId
              Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - ID - '$DN'"
              $AAByName = Get-CsAutoAttendant -Identity "$DN" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
              $AutoAttendants += $AAByName
            }
            else {
              #Name
              Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Name - '$DN'"
              $AAByName = Get-CsAutoAttendant -NameFilter "$DN" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
              $AAByName = $AAByName | Where-Object Name -EQ "$DN"
              $AAById = Get-CsAutoAttendant -Identity $AAbyName.Identity
              $AutoAttendants += $AAById
            }
          }
        }
        'Search' {
          # Search
          Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - SearchString - '$SearchString'"
          $AAbyName = Get-CsAutoAttendant -NameFilter "$SearchString" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          $AAById = Get-CsAutoAttendant -Identity $AAbyName.Identity
          $AutoAttendants += $AAById
        }
      }
      #endregion
    }

    # Parsing found Objects
    Write-Verbose -Message "[PROCESS] Processing found Auto Attendants: $AACount"
    $AACounter = 0
    [int]$AACount = $AutoAttendants.Count
    #IMPROVE Explore Workflows with Parallel parsing:
    #foreach -parallel ($AA in $AutoAttendants) {
    foreach ($AA in $AutoAttendants) {
      # Initialising counters for Progress bars
      Write-Progress -Id 0 -Status "Auto Attendant '$($AA.Name)'" -Activity $MyInvocation.MyCommand -PercentComplete ($AACounter / $AACount * 100)
      $AACounter++
      [int]$step = 0
      [int]$sMax = 2

      #region Parsing Default Call Flow
      $Operation = 'Parsing Default CallFlow'
      $step++
      Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "'$($AA.Name)' - $Operation"
      Write-Information "INFO:    Parsing Audio Files for Auto Attendant '$($AA.Name)'"

      # Default Call Flow Greetings
      $Operation2 = 'Default Call Flow - Greeting'
      Write-Verbose -Message "'$($AA.Name)' - $Operation2"
      $Prompt = $AA.DefaultCallFlow.Greetings.AudioFilePrompt
      OutputAudioFile -AAName $($AA.Name) -Step $Operation2 -IsDetailed $IsDetailed -Prompt $Prompt

      # Default Call Flow Menu
      $Operation2 = 'Default Call Flow - Menu - Prompt'
      Write-Verbose -Message "'$($AA.Name)' - $Operation2"
      $Prompt = $AA.DefaultCallFlow.Menu.Prompts.AudioFilePrompt
      OutputAudioFile -AAName $($AA.Name) -Step $Operation2 -IsDetailed $IsDetailed -Prompt $Prompt

      # Default Call Menu Option Prompt
      $Operation2 = 'Default Call Flow - Menu Option - Prompt'
      Write-Verbose -Message "'$($AA.Name)' - $Operation2"
      $Prompt = $AA.DefaultCallFlow.Menu.MenuOptions.Prompt.AudioFilePrompt
      OutputAudioFile -AAName $($AA.Name) -Step $Operation2 -IsDetailed $IsDetailed -Prompt $Prompt
      #endregion

      #region CallFlows
      $Operation = 'Parsing CallFlows'
      $step++
      Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "'$($AA.Name)' - $Operation"

      foreach ($Flow in $AA.CallFlows) {
        # Call Flow Greeting Prompt
        $Operation2 = "Call Flow '$($Flow.Name)' - Greeting - Prompt"
        Write-Verbose -Message "'$($AA.Name)' - $Operation2"
        $Prompt = $Flow.Greetings.AudioFilePrompt
        OutputAudioFile -AAName $($AA.Name) -Step $Operation2 -IsDetailed $IsDetailed -Prompt $Prompt

        # Call Flow Menu Prompt
        $Operation2 = "Call Flow '$($Flow.Name)' - Menu - Prompt"
        Write-Verbose -Message "'$($AA.Name)' - $Operation2"
        $Prompt = $Flow.Menu.Prompts.AudioFilePrompt
        OutputAudioFile -AAName $($AA.Name) -Step $Operation2 -IsDetailed $IsDetailed -Prompt $Prompt

        # Call Flow Menu Option Prompt
        $Operation2 = "Call Flow '$($Flow.Name)' - Menu Option - Prompt"
        Write-Verbose -Message "'$($AA.Name)' - $Operation2"
        $Prompt = $Flow.Menu.MenuOptions.Prompt.AudioFilePrompt
        OutputAudioFile -AAName $($AA.Name) -Step $Operation2 -IsDetailed $IsDetailed -Prompt $Prompt
      }
      #endregion
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsAutoAttendantAudioFile