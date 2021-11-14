# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:   David Eberhardt
# Updated:  01-SEP-2021
# Status:   Live




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
    [Parameter(ParameterSetName = 'Name', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Full Name of the Auto Attendant')]
    [AllowNull()]
    [Alias('Identity')]
    [string[]]$Name,

    [Parameter(ParameterSetName = 'Search', HelpMessage = 'Partial or full Name of the Auto Attendant to search')]
    [Alias('NameFilter')]
    [string]$SearchString,

    [switch]$Detailed
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

    #Initialising Counters
    $private:StepsID0, $private:StepsID1 = Get-WriteBetterProgressSteps -Code $($MyInvocation.MyCommand.Definition) -MaxId 1
    $private:ActivityID0 = $($MyInvocation.MyCommand.Name)
    [int] $private:CountID0 = [int] $private:CountID1 = 1

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
          Write-Output $Prompt | Select-Object Id, FileName, DownloadUri
        }
      }
      else {
        Write-Verbose -Message "'$AAName' - $Step - No Prompt"
      }
    }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    [int] $private:CountID0 = [int] $private:CountID1 = 1

    $StatusID0 = 'Information Gathering'
    #region Data gathering
    $CurrentOperationID0 = 'Querying Auto Attendants'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    # Capturing no input
    if (-not $PSBoundParameters.ContainsKey('Name') -and -not $PSBoundParameters.ContainsKey('SearchString') ) {
      Write-Information 'No Parameters - Querying ALL Auto Attendants. This could take a while. To query individual items, please provide Parameter Name or SearchString'
      $AAQuery = Get-CsAutoAttendant -IncludeStatus -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      $AutoAttendants += $AAQuery
    }
    else {
      $AutoAttendants = @()
      switch ($PSCmdlet.ParameterSetName) {
        'Name' {
          # Lookup
          Write-Verbose -Message "Parameter 'Name' - Querying unique result for each provided Name"
          foreach ($DN in $Name) {
            if ( $DN -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$' ) {
              #Identity or ObjectId
              #NOTE DO NOT use `-IncludeStatus` with Identity, it generates an error ParameterBindingException
              Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - ID - '$DN'"
              $AAQuery = Get-CsAutoAttendant -Identity "$DN" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
              $AutoAttendants += $AAQuery
            }
            else {
              #Name
              Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Name - '$DN'"
              #$AAQuery = Get-CsAutoAttendant -NameFilter "$DN" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
              $AAQuery = Get-CsAutoAttendant -NameFilter "$DN" -IncludeStatus -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
              $AAQuery = $AAQuery | Where-Object Name -EQ "$DN"
              $AutoAttendants += $AAQuery
            }
          }
        }
        'Search' {
          # Search
          Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - SearchString - '$SearchString'"
          #$AAQuery = Get-CsAutoAttendant -NameFilter "$SearchString" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          $AAQuery = Get-CsAutoAttendant -NameFilter "$SearchString" -IncludeStatus -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          $AutoAttendants += $AAQuery
        }
      }
    }
    #endregion


    # Parsing found Objects
    [int] $private:StepsID0 = $private:StepsID0 + $AutoAttendants.Count
    Write-Verbose -Message "[PROCESS] Processing found Auto Attendants:  $($AutoAttendants.Count)"
    #IMPROVE Explore Workflows with Parallel parsing:
    #foreach -parallel ($AA in $AutoAttendants) {
    foreach ($AA in $AutoAttendants) {
      # Initialising counters for Progress bars
      [int] $private:CountID0 = 1
      [int] $private:CountID1 = 1
      $ActivityID0 = "'$($AA.Name)'"
      Write-Information "INFO:    Parsing Audio Files for Auto Attendant '$($AA.Name)'"

      $StatusID0 = 'Parsing'
      #region Parsing Default Call Flow
      $CurrentOperationID0 = 'Default Call Flow'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0

      # Default Call Flow Greetings
      $Operation2 = 'Greeting'
      Write-Verbose -Message "$ActivityID0 - $Operation2"
      $Prompt = $AA.DefaultCallFlow.Greetings.AudioFilePrompt
      OutputAudioFile -AAName $($AA.Name) -Step $Operation2 -IsDetailed $IsDetailed -Prompt $Prompt

      # Default Call Flow Menu
      $Operation2 = 'Menu - Prompt'
      Write-Verbose -Message "$ActivityID0 - $Operation2"
      $Prompt = $AA.DefaultCallFlow.Menu.Prompts.AudioFilePrompt
      OutputAudioFile -AAName $($AA.Name) -Step $Operation2 -IsDetailed $IsDetailed -Prompt $Prompt

      # Default Call Menu Option Prompt
      $Operation2 = 'Menu Option - Prompt'
      Write-Verbose -Message "$ActivityID0 - $Operation2"
      $Prompt = $AA.DefaultCallFlow.Menu.MenuOptions.Prompt.AudioFilePrompt
      OutputAudioFile -AAName $($AA.Name) -Step $Operation2 -IsDetailed $IsDetailed -Prompt $Prompt
      #endregion

      #region CallFlows
      $CurrentOperationID0 = 'Call Flows'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      foreach ($Flow in $AA.CallFlows) {
        # Call Flow Greeting Prompt
        $Operation2 = "'$($Flow.Name)' - Greeting - Prompt"
        Write-Verbose -Message "$ActivityID0 - $Operation2"
        $Prompt = $Flow.Greetings.AudioFilePrompt
        OutputAudioFile -AAName $($AA.Name) -Step $Operation2 -IsDetailed $IsDetailed -Prompt $Prompt

        # Call Flow Menu Prompt
        $Operation2 = "'$($Flow.Name)' - Menu - Prompt"
        Write-Verbose -Message "$ActivityID0 - $Operation2"
        $Prompt = $Flow.Menu.Prompts.AudioFilePrompt
        OutputAudioFile -AAName $($AA.Name) -Step $Operation2 -IsDetailed $IsDetailed -Prompt $Prompt

        # Call Flow Menu Option Prompt
        $Operation2 = "'$($Flow.Name)' - Menu Option - Prompt"
        Write-Verbose -Message "$ActivityID0 - $Operation2"
        $Prompt = $Flow.Menu.MenuOptions.Prompt.AudioFilePrompt
        OutputAudioFile -AAName $($AA.Name) -Step $Operation2 -IsDetailed $IsDetailed -Prompt $Prompt
      }
      #endregion

      Write-Progress -Id 0 -Activity $ActivityID0 -Completed
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsAutoAttendantAudioFile