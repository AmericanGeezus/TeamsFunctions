# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   BETA

function Get-TeamsAutoAttendant {
  <#
	.SYNOPSIS
		Queries Auto Attendants and displays friendly Names (UPN or DisplayName)
	.DESCRIPTION
		Same functionality as Get-CsAutoAttendant, but display reveals friendly Names,
		like UserPrincipalName or DisplayName for the following connected Objects
    Operator and ApplicationInstances (Resource Accounts)
	.PARAMETER Name
		Optional. Searches all Auto Attendants for this name (multiple results possible).
    If omitted, Get-TeamsAutoAttendant acts like an Alias to Get-CsAutoAttendant (no friendly names)
  .PARAMETER Detailed
    Optional Switch. Displays nested Objects for all Parameters of the Auto Attendant
    By default, only Names of nested Objects are shown.
	.EXAMPLE
		Get-TeamsAutoAttendant
		Same result as Get-CsAutoAttendant
	.EXAMPLE
		Get-TeamsAutoAttendant -Name "My AutoAttendant"
		Returns an Object for every Auto Attendant found with the String "My AutoAttendant"
		Operator and Resource Accounts are displayed with friendly name.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.NOTES
    Main difference to Get-CsAutoAttendant (apart from the friendly names) is how the Objects are shown.
    The connected Objects DefaultCallFlow, CallFlows, Schedules, CallHandlingAssociations and DirectoryLookups
    are all shown with Name only, but can be queried with .<ObjectName>
    This also works with Get-CsAutoAttendant, but with the help of "Display" Parameters.
	.FUNCTIONALITY
		Get-CsAutoAttendant with friendly names instead of GUID-strings for connected objects
	.LINK
		New-TeamsCallQueue
		Get-TeamsCallQueue
    Set-TeamsCallQueue
    Remove-TeamsCallQueue
    New-TeamsAutoAttendant
    Get-TeamsAutoAttendant
    Set-TeamsAutoAttendant
    Remove-TeamsAutoAttendant
    Get-TeamsResourceAccountAssociation
    New-TeamsResourceAccountAssociation
		Remove-TeamsResourceAccountAssociation
  #>

  [CmdletBinding()]
  [Alias('Get-TeamsAA')]
  [OutputType([System.Object[]])]
  param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Partial or full Name of the Auto Attendant to search')]
    [AllowNull()]
    [string]$Name,

    [switch]$Detailed
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

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

    # Capturing no input
    try {
      if (-not $PSBoundParameters.ContainsKey('Name')) {
        Write-Verbose -Message "No parameters specified. Acting as an Alias to Get-CsAutoAttendant" -Verbose
        Write-Verbose -Message "Warnings are suppressed for this operation. Please query with -Name to display them" -Verbose
        Get-CsAutoAttendant -WarningAction SilentlyContinue -ErrorAction STOP
      }
      else {
        foreach ($DN in $Name) {
          Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - '$DN'"
          # Finding all AAs with this Name (Should return one Object, but since it IS a filter, handling it as an array)
          #$AAs = Get-CsAutoAttendant -NameFilter "$DN" -WarningAction SilentlyContinue -ErrorAction STOP
          $AAs = Get-CsAutoAttendant -NameFilter "$DN" -WarningAction SilentlyContinue -ErrorAction STOP | Select-Object *

          # Initialising Arrays
          [System.Collections.ArrayList]$AIObjects = @()

          # Reworking Objects
          Write-Verbose -Message "[PROCESS] Finding parsable Objects for $($AAs.Count) Auto Attendants"
          foreach ($AA in $AAs) {
            #region Finding Operator
            Write-Verbose -Message "'$($AA.Name)' - Parsing Operator"
            if ($null -eq $AA.Operator) {
              $OperatorObject = $null
            }
            else {
              # Parsing Callable Entity
              switch ($AA.Operator.Type) {
                "User" {
                  try {
                    $OperatorObject = Get-AzureADUser -ObjectId "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                    $Operator = $OperatorObject.UserPrincipalName
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
                "OrganizationalAutoAttendant" {
                  try {
                    $OperatorObject = Get-CsOrganizationalAutoAttendant -Identity "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                    $Operator = $OperatorObject.Name
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
                "HuntGroup" {
                  try {
                    $OperatorObject = Get-CsHuntGroup -Identity "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                    $Operator = $OperatorObject.Name
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
                "ApplicationEndpoint" {
                  try {
                    $OperatorObject = Get-CsOnlineApplicationInstance -ObjectId "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                    $Operator = $OperatorObject.UserPrincipalName
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
                "ExternalPstn" {
                  try {
                    $Operator = $AA.Id
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
                "SharedVoicemail" {
                  try {
                    $OperatorObject = Get-AzureADGroup -ObjectId "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                    $Operator = $OperatorObject.DisplayName
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
                default {
                  try {
                    $OperatorObject = Get-AzureADUser -ObjectId "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                    $Operator = $OperatorObject.UserPrincipalName
                    if ($null -eq $Operator) {
                      try {
                        $OperatorObject = Get-AzureADGroup -ObjectId "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                        $Operator = $OperatorObject.DisplayName
                        if ($null -eq $Operator) {
                          throw
                        }
                      }
                      catch {
                        Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                      }
                    }
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
              }

            }
            # Output: $Operator, $OperatorTranscription
            #endregion

            #region Application Instance UPNs
            Write-Verbose -Message "'$($AA.Name)' - Parsing Resource Accounts"
            foreach ($AI in $AA.ApplicationInstances) {
              $AIObject = $null
              $AIObject = Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue | Where-Object { $_.ObjectId -eq $AI } | Select-Object UserPrincipalName, DisplayName, PhoneNumber
              if ($null -ne $AIObject) {
                [void]$AIObjects.Add($AIObject)
              }
            }

            # Output: $AIObjects.UserPrincipalName
            #endregion


            #region Creating Output Object
            # Building custom Object with Friendly Names
            Write-Verbose -Message "'$($AA.Name)' - Constructing Output Object"
            $AAObject = [PsCustomObject][ordered]@{
              Identity                        = $AA.Identity
              Name                            = $AA.Name
              LanguageId                      = $AA.LanguageId
              TimeZoneId                      = $AA.TimeZoneId
              VoiceId                         = $AA.VoiceId
              VoiceResponseEnabled            = $AA.VoiceResponseEnabled
              OperatorName                    = $Operator
              OperatorType                    = $AA.Operator.Type
              DefaultCallFlowName             = $AA.DefaultCallFlow.Name
              CallFlowNames                   = $AA.CallFlows.Name
              ScheduleNames                   = $AA.Schedules.Name
              CallHandlingAssociationNames    = $AA.CallHandlingAssociations.Type
              DirectoryLookupScope            = $AA.DirectoryLookupScope.Name
              GreetingsSettingAuthorizedUsers = $AA.GreetingsSettingAuthorizedUsers
            }
            #endregion

            #region Extending Output Object with Switch Detailed
            if ($PSBoundParameters.ContainsKey('Detailed')) {
              Write-Verbose -Message "'$($AA.Name)' - Constructing Output Object with Switch 'Detailed' - This may take a bit..." -Verbose

              #region Operator
              $OperatorObject # Construct new Object with Add-Member and display that
              Write-Verbose -Message "Parsing Operator"
              $AAOperator = @()
              $AAOperator = [PsCustomObject][ordered]@{
                'Entity'              = $Operator
                'Type'                = $AA.Operator.Type
                'EnableTranscription' = $AA.Operator.EnableTranscription
                'Id'                  = $AA.Operator.Id
              }
              Add-Member -Force -InputObject $AAOperator -MemberType ScriptMethod -Name ToString -Value {
                [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
              }
              #endregion

              #region DefaultCallFlow
              Write-Verbose -Message "Parsing DefaultCallFlow"
              #region Call Flow Menu
              # Call Flow Menu Prompts
              <# TODO Test and Remove
              $AADefaultCallFlowMenuPrompts = @()
              foreach ($Prompt in $AA.DefaultCallFlow.Menu.Prompts) {
                $AADefaultCallFlowMenuPrompt = @()
                $AADefaultCallFlowMenuPrompt = [PsCustomObject][ordered]@{
                  'ActiveType'         = $Prompt.ActiveType
                  'TextToSpeechPrompt' = $Prompt.TextToSpeechPrompt
                  'AudioFilePrompt'    = $Prompt.AudioFilePrompt
                  # More parameters are available with | FL *: HasTextToSpeechPromptData, HasAudioFilePromptData, IsAudioFileAlreadyUploaded, IsDisabled, HasDualPromptData (all BOOLEAN)
                }
                Add-Member -Force -InputObject $AADefaultCallFlowMenuPrompt -MemberType ScriptMethod -Name ToString -Value {
                  [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                }
                $AADefaultCallFlowMenuPrompts += Add-Member -InputObject $AADefaultCallFlowMenuPrompt -TypeName My.Menu.MenuOption -PassThru
              }
              #>

              $AACallFlowMenuPrompts = Merge-AutoAttendantArtefact -Type Prompt -Object $AA.DefaultCallFlow.Menu.Prompts

              # Call Flow Menu Options
              <# TODO Test and Remove
              $AADefaultCallFlowMenuOptions = @()
              foreach ($Option in $AA.DefaultCallFlow.Menu.MenuOptions) {
                $AADefaultCallFlowMenuOption = @()
                $AADefaultCallFlowMenuOption = [PsCustomObject][ordered]@{
                  'Action'         = $Option.Action
                  'DtmfResponse'   = $Option.DtmfResponse
                  'VoiceResponses' = $Option.VoiceResponses
                  'CallTarget'     = $Option.CallTarget #TODO Enumerate Call Target with breakout-function - Return DisplayName (as Operator above!)
                  'Prompt'         = $Option.Prompt
                }
                Add-Member -Force -InputObject $AADefaultCallFlowMenuOption -MemberType ScriptMethod -Name ToString -Value {
                  [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                }
                $AADefaultCallFlowMenuOptions += Add-Member -InputObject $AADefaultCallFlowMenuOption -TypeName My.Menu.MenuOption -PassThru
              }
              #>

              $AADefaultCallFlowMenuOptions = Merge-AutoAttendantArtefact -Type MenuOptions -Object $AA.DefaultCallFlow.Menu.MenuOptions

              # Call Flow Menu
              <# TODO Test and Remove
              $AADefaultCallFlowMenu = @()
              $AADefaultCallFlowMenu = [PsCustomObject][ordered]@{
                'Name'                  = $AA.DefaultCallFlow.Menu.Name
                'Prompts'               = $AADefaultCallFlowMenuPrompts
                'MenuOptions'           = $AADefaultCallFlowMenuOptions
                'DialByNameEnabled'     = $AA.DefaultCallFlow.Menu.DialByNameEnabled
                'DirectorySearchMethod' = $AA.DefaultCallFlow.Menu.DirectorySearchMethod
              }
              Add-Member -Force -InputObject $AADefaultCallFlowMenu -MemberType ScriptMethod -Name ToString -Value {
                [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
              }
              #>

              $AADefaultCallFlowMenu = Merge-AutoAttendantArtefact -Type Menu -Object $AA.DefaultCallFlow.Menu -Prompts $AADefaultCallFlowMenuPrompts -MenuOptions $AADefaultCallFlowMenuOptions

              # Call Flow Greetings
              <# TODO Test and Remove
              $AADefaultCallFlowGreetings = @()
              foreach ($Prompt in $AA.DefaultCallFlow.Greetings) {
                $AADefaultCallFlowGreeting = @()
                $AADefaultCallFlowGreeting = [PsCustomObject][ordered]@{
                  'ActiveType'         = $Prompt.ActiveType
                  'TextToSpeechPrompt' = $Prompt.TextToSpeechPrompt
                  'AudioFilePrompt'    = $Prompt.AudioFilePrompt
                  # More parameters are available with | FL *: HasTextToSpeechPromptData, HasAudioFilePromptData, IsAudioFileAlreadyUploaded, IsDisabled, HasDualPromptData (all BOOLEAN)
                }
                Add-Member -Force -InputObject $AADefaultCallFlowGreeting -MemberType ScriptMethod -Name ToString -Value {
                  [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                }
                $AADefaultCallFlowGreetings += Add-Member -InputObject $AADefaultCallFlowGreeting -TypeName My.Prompt -PassThru
              }
              #>

              $AADefaultCallFlowGreetings = Merge-AutoAttendantArtefact -Type Prompt -Object $AA.DefaultCallFlow.Greetings
              #endregion

              # Call Flow
              <# TODO Test and Remove
              $AADefaultCallFlow = @()
              $AADefaultCallFlow = [PsCustomObject][ordered]@{
                'Name'      = $AA.DefaultCallFlow.Name
                'Id'        = $AA.DefaultCallFlow.Id
                'Greetings' = $AADefaultCallFlowGreetings
                'Menu'      = $AADefaultCallFlowMenu
              }
              Add-Member -Force -InputObject $AADefaultCallFlow -MemberType ScriptMethod -Name ToString -Value {
                [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
              }
              #>

              $AADefaultCallFlow = Merge-AutoAttendantArtefact -Type CallFlow -Object $Flow -Prompts $AADefaultCallFlowGreetings -Menu $AADefaultCallFlowMenu
              #endregion

              #region CallFlows
              Write-Verbose -Message "Parsing CallFlows"
              $AACallFlows = @()
              foreach ($Flow in $AA.CallFlows) {
                #region Call Flow Menu
                # Call Flow Menu Prompts
                <# TODO Test and Remove
                $AACallFlowMenuPrompts = @()
                foreach ($Prompt in $Flow.Menu.Prompts) {
                  $AACallFlowMenuPrompt = @()
                  $AACallFlowMenuPrompt = [PsCustomObject][ordered]@{
                    'ActiveType'         = $Prompt.ActiveType
                    'TextToSpeechPrompt' = $Prompt.TextToSpeechPrompt
                    'AudioFilePrompt'    = $Prompt.AudioFilePrompt
                    # More parameters are available with | FL *: HasTextToSpeechPromptData, HasAudioFilePromptData, IsAudioFileAlreadyUploaded, IsDisabled, HasDualPromptData (all BOOLEAN)
                  }
                  Add-Member -Force -InputObject $AACallFlowMenuPrompt -MemberType ScriptMethod -Name ToString -Value {
                    [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                  }
                  $AACallFlowMenuPrompts += Add-Member -InputObject $AACallFlowMenuPrompt -TypeName My.Menu.MenuOption -PassThru
                }
                #>

                $AACallFlowMenuPrompts = Merge-AutoAttendantArtefact -Type Prompt -Object $Flow.Menu.Prompts

                # Call Flow Menu Options
                <# TODO Test and Remove
                $AACallFlowMenuOptions = @()
                foreach ($Option in $Flow.Menu.MenuOptions) {
                  $AACallFlowMenuOption = @()
                  $AACallFlowMenuOption = [PsCustomObject][ordered]@{
                    'Action'         = $Option.Action
                    'DtmfResponse'   = $Option.DtmfResponse
                    'VoiceResponses' = $Option.VoiceResponses
                    'CallTarget'     = $Option.CallTarget #TODO Enumerate Call Target with breakout-function - Return DisplayName (as Operator above!)
                    'Prompt'         = $Option.Prompt
                  }
                  Add-Member -Force -InputObject $AACallFlowMenuOption -MemberType ScriptMethod -Name ToString -Value {
                    [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                  }
                  $AACallFlowMenuOptions += Add-Member -InputObject $AACallFlowMenuOption -TypeName My.Menu.MenuOption -PassThru
                }
                #>

                $AACallFlowMenuOptions = Merge-AutoAttendantArtefact -Type MenuOptions -Object $Flow.Menu.MenuOptions

                # Call Flow Menu
                <# TODO Test and Remove
                $AACallFlowMenu = @()
                $AACallFlowMenu = [PsCustomObject][ordered]@{
                  'Name'                  = $Flow.Menu.Name
                  'Prompts'               = $AACallFlowMenuPrompts
                  'MenuOptions'           = $AACallFlowMenuOptions
                  'DialByNameEnabled'     = $Flow.Menu.DialByNameEnabled
                  'DirectorySearchMethod' = $Flow.Menu.DirectorySearchMethod
                }
                Add-Member -Force -InputObject $AACallFlowMenu -MemberType ScriptMethod -Name ToString -Value {
                  [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                }
                #>

                $AACallFlowMenu = Merge-AutoAttendantArtefact -Type Menu -Object $Flow.Menu -Prompts $AACallFlowMenuPrompts -MenuOptions $AACallFlowMenuOptions

                # Call Flow Greetings
                <# TODO Test and Remove
                $AACallFlowGreetings = @()
                foreach ($Prompt in $Flow.Greetings) {
                  $AACallFlowGreeting = @()
                  $AACallFlowGreeting = [PsCustomObject][ordered]@{
                    'ActiveType'         = $Prompt.ActiveType
                    'TextToSpeechPrompt' = $Prompt.TextToSpeechPrompt
                    'AudioFilePrompt'    = $Prompt.AudioFilePrompt
                    # More parameters are available with | FL *: HasTextToSpeechPromptData, HasAudioFilePromptData, IsAudioFileAlreadyUploaded, IsDisabled, HasDualPromptData (all BOOLEAN)
                  }
                  Add-Member -Force -InputObject $AACallFlowGreeting -MemberType ScriptMethod -Name ToString -Value {
                    [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                  }
                  $AACallFlowGreetings += Add-Member -InputObject $AACallFlowGreeting -TypeName My.Prompt -PassThru
                }
                #>

                $AACallFlowGreetings = Merge-AutoAttendantArtefact -Type Prompt -Object $Flow.Greetings
                #endregion

                # Call Flow
                <# TODO Test and Remove
                $AACallFlow = @()
                $AACallFlow = [PsCustomObject][ordered]@{
                  'Name'      = $Flow.Name
                  'Id'        = $Flow.Id
                  'Greetings' = $AACallFlowGreetings # $Flow.Greetings | Select-Object Greetings -ExpandProperty Greetings
                  'Menu'      = $AACallFlowMenu
                }
                Add-Member -Force -InputObject $AACallFlow -MemberType ScriptMethod -Name ToString -Value {
                  [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                }
                $AACallFlows += Add-Member -InputObject $AACallFlow -TypeName My.CallFlow -PassThru
                #>

                $AACallFlows = Merge-AutoAttendantArtefact -Type CallFlow -Object $Flow -Prompts $AACallFlowGreetings -Menu $AACallFlowMenu
              }
              #endregion

              #region Schedules
              Write-Verbose -Message "Parsing Schedules"
              $AASchedules = @()
              foreach ($Schedule in $AA.Schedules) {
                $AASchedule = Get-CsOnlineSchedule -Id $Schedule.Id
                <# TODO Test and Remove
                switch ($AASchedule.Type) {
                  0 {
                    # Schedule Type is WeeklyRecurrence
                    $AAScheduleFixed = $null
                    $AAScheduleWeekly = @()
                    $AAScheduleWeekly = [PsCustomObject][ordered]@{
                      'ComplementEnabled' = $AASchedule.WeeklyRecurrentSchedule.ComplementEnabled
                      'MondayHours'       = $AASchedule.WeeklyRecurrentSchedule.DisplayMondayHours
                      'TuesdayHours'      = $AASchedule.WeeklyRecurrentSchedule.DisplayTuesdayHours
                      'WednesdayHours'    = $AASchedule.WeeklyRecurrentSchedule.DisplayWednesdayHours
                      'ThursdayHours'     = $AASchedule.WeeklyRecurrentSchedule.DisplayThursdayHours
                      'FridayHours'       = $AASchedule.WeeklyRecurrentSchedule.DisplayFridayHours
                      'SaturdayHours'     = $AASchedule.WeeklyRecurrentSchedule.DisplaySaturdayHours
                      'SundayHours'       = $AASchedule.WeeklyRecurrentSchedule.DisplaySundayHours
                    }
                    Add-Member -Force -InputObject $AAScheduleWeekly -MemberType ScriptMethod -Name ToString -Value {
                      [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                    }
                  }

                  1 {
                    # Schedule Type is Fixed
                    $AAScheduleWeekly = $null
                    <# Alt: Broken out into individual Start/End blocks
                    $AAScheduleFixed = @()
                    foreach ($Range in $Schedule.FixedSchedule) {
                      $AAScheduleFixedRange = @()
                      $AAScheduleFixedRange = [PsCustomObject][ordered]@{
                        'Start' = $Range.DateTimeRanges.Start
                        'End'   = $Range.DateTimeRanges.End
                      }
                      Add-Member -Force -InputObject $AAScheduleFixedRange -MemberType ScriptMethod -Name ToString -Value {
                        [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                      }
                      $AAScheduleFixed += Add-Member -InputObject $AAScheduleFixedRange -TypeName My.CallHandlingAssociation -PassThru
                    }
                    #>
                <# Added here b/c of nested Comments
                    $AAScheduleFixed = $Schedule.FixedSchedule.DisplayDateTimeRanges
                  }
                }

                $AASchedule = @()
                $AASchedule = [PsCustomObject][ordered]@{
                  'Name'                    = $Schedule.Name
                  'Type'                    = $Schedule.Type
                  'WeeklyRecurrentSchedule' = $AAScheduleWeekly
                  'FixedSchedule'           = $AAScheduleFixed
                  #'FixedSchedule'           = $Schedule.FixedSchedule.DateTimeRanges
                  'Id'                      = $Schedule.Id
                }
                Add-Member -Force -InputObject $AASchedule -MemberType ScriptMethod -Name ToString -Value {
                  [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                }
                $AASchedules += Add-Member -InputObject $AASchedule -TypeName My.Schedule -PassThru
                #>

                $AASchedules = Merge-AutoAttendantArtefact -Type Schedule -Object $AASchedule

              }
              #endregion

              #region CallHandlingAssociations
              Write-Verbose -Message "Parsing CallHandlingAssociations"
              $AACallHandlingAssociations = @()
              foreach ($item in $AA.CallHandlingAssociations) {
                <# INFO Alternatively, this Object can be drilled down further (but would be duplicate)
                $AACallHandlingAssociationsSchedule = @()
                foreach ($ScheduleId in $item.ScheduleId) {
                  $Schedule = Get-CsOnlineSchedule -Id $ScheduleId
                  $CHASchedule = [PsCustomObject][ordered]@{
                    'Name' = $Schedule.Name
                    'Type' = $Schedule.Type
                    'Id'   = $Schedule.Id
                  }
                  Add-Member -Force -InputObject $CHASchedule -MemberType ScriptMethod -Name ToString -Value {
                    [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                  }
                  $AACallHandlingAssociationsSchedule += Add-Member -InputObject $CHASchedule -TypeName My.CallHandlingAssociation -PassThru
                }
                #>
                $AACallHandlingAssociationCallFlowName = ($AA.CallFlows | Where-Object Id -EQ $item.CallFlowId).Name

                <# TODO Test and Remove
                $AACallHandlingAssociation = @()
                $AACallHandlingAssociation = [PsCustomObject][ordered]@{
                  'Type'     = $item.Type
                  'Enabled'  = $item.Enabled
                  'Schedule' = $(Get-CsOnlineSchedule -Id $item.ScheduleId).Name
                  'CallFlow' = $AACallHandlingAssociationCallFlowName
                }
                Add-Member -Force -InputObject $AACallHandlingAssociation -MemberType ScriptMethod -Name ToString -Value {
                  [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                }
                $AACallHandlingAssociations += Add-Member -InputObject $AACallHandlingAssociation -TypeName My.CallHandlingAssociation -PassThru
                #>
                $AACallHandlingAssociations = Merge-AutoAttendantArtefact -Type CallHandlingAssociations -Object $item -CallFlowName $AACallHandlingAssociationCallFlowName
              }
              #endregion

              # Adding nested Objects
              $AAObject | Add-Member -MemberType NoteProperty -Name Operator -Value $AAOperator
              $AAObject | Add-Member -MemberType NoteProperty -Name DefaultCallFlow -Value $AADefaultCallFlow
              $AAObject | Add-Member -MemberType NoteProperty -Name CallFlows -Value $AACallFlows
              $AAObject | Add-Member -MemberType NoteProperty -Name Schedules -Value $AASchedules
              $AAObject | Add-Member -MemberType NoteProperty -Name CallHandlingAssociations -Value $AACallHandlingAssociations
            }

            # Adding Resource Accounts
            $AAObject | Add-Member -MemberType NoteProperty -Name ApplicationInstances -Value $AIObjects.UserPrincipalName
            #endregion

            # Output
            Write-Output $AAObject
          }
        }
      }
    }
    catch {
      Write-Error -Message 'Could not query Auto Attendants' -Category OperationStopped
      Write-ErrorRecord $_ #This handles the error message in human readable format.
      return
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsAutoAttendant
