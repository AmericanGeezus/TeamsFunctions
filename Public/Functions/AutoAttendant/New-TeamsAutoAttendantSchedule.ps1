# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:   David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live




function New-TeamsAutoAttendantSchedule {
  <#
  .SYNOPSIS
    Creates a Schedule to be used in Auto Attendants
  .DESCRIPTION
    Wrapper for New-CsOnlineSchedule to simplify creation of Schedules with repeating patterns
    Incorporates New-CsOnlineTimeRange with examples
  .PARAMETER Name
    Provides a friendly Name to the Schedule (visible in the Auto Attendant Object)
  .PARAMETER WeeklyRecurrentSchedule
    Defines a schedule that is recurring weekly with Business Hours for every day of the week.
    This is suitable for an After Hours in an Auto Attendant. New-TeamsAutoAttendant will utilise a Default Schedule
    For simplicity, this command assumes the same hours of operation for each day that the business is open.
    For a more granular approach, aim for a "best match", then amend the schedule afterwards in the Admin Center
    If desired via PowerShell, please use BusinessHoursStart/BusinessHoursEnd or define manually with:
    New-CsOnlineTimeRange and New-CsOnlineSchedule respectively.
  .PARAMETER Fixed
    Defines a fixed schedule, suitable for Holiday Sets
  .PARAMETER BusinessDays
    Parameter for WeeklyReccurrentSchedule
    Days defined as Business days. Will be combined with BusinessHours to form a WeeklyReccurrentSchedule
  .PARAMETER BusinessHours
    Parameter for WeeklyReccurrentSchedule - Option 1: Choose from a predefined Time Frame
    Predefined business hours. Combined with BusinessDays, forms the WeeklyRecurrentSchedule
    Covering most of regular working hour patterns to choose from.
  .PARAMETER BusinessHoursStart
    Parameter for WeeklyReccurrentSchedule - Option 2: Select a specific Start and End Time
    Predefined business hours. Combined with BusinessDays, forms the WeeklyRecurrentSchedule
    Manual start and end time to be provided in the format "09:00" - 15 minute increments only
  .PARAMETER BusinessHoursEnd
    Parameter for WeeklyReccurrentSchedule - Option 2: Select a specific Start and End Time
    Predefined business hours. Combined with BusinessDays, forms the WeeklyRecurrentSchedule
    Manual start and end time to be provided in the format "09:00" - 15 minute increments only
  .PARAMETER DateTimeRanges
    Parameter for WeeklyReccurrentSchedule - Option 3: Provide a DateTimeRange Object
    Object or Objects defined with New-CsOnlineTimeRange
    Allows for more granular options then the provided BusinessHours examples or to provide Dates for Fixed
  .PARAMETER Complement
    The Complement parameter indicates how the schedule is used.
    When Complement is enabled, the schedule is used as the inverse of the provided configuration
    For example, if Complement is enabled and the schedule only contains time ranges of Monday to Friday from 9AM to 5PM,
    then the schedule is active at all times other than the specified time ranges.
  .EXAMPLE
    New-TeamsAutoAttendantSchedule -WeeklyRecurrentSchedule -BusinessDays MonToFri -BusinesHours 9to5
    Creates a weekly recurring schedule for business hours Monday to Friday from 9am to 5pm
  .EXAMPLE
    New-TeamsAutoAttendantSchedule -WeeklyRecurrentSchedule -BusinessDays MonToSat -BusinessHoursStart 09:15 -BusinessHoursEnd 17:45
    Creates a weekly recurring schedule for business hours Monday to Saturday from 09:15 to 17:45
  .EXAMPLE
    New-TeamsAutoAttendantSchedule -WeeklyRecurrentSchedule -BusinessDays SunToThu -DateTimeRange @($TR1, $TR2)
    Creates a weekly recurring schedule for business hours Sunday to Thursday with custom TimeRange(s) provided with the Objects $TR1 and $TR2
  .EXAMPLE
    New-TeamsAutoAttendantSchedule -Fixed -DateTimeRange @($TR1, $TR2)
    Adds a fixed schedule for the TimeRange(s) provided with the Objects $TR1 and $TR2
  .INPUTS
    System.String, System.Object
  .OUTPUTS
    System.Object
  .NOTES
    Combinations of BusinesHours and BusinessDays are numerous but not exhaustive.
    For simplicity, this command assumes the same hours of operation for each day that the business is open.
    With the following Parameters, these three options are available:
    1. BusinessHours - Choose time range from a predefined list (amend in Admin Center afterwards, if needed)
    2. BusinessHoursStart and BusinessHoursEnd - Provide a Start and End Time for the Time Range (15 minute increments)
    3. DateTimeRange - Provide a DateTimeRange Object manually defined with New-CsOnlineTimeRange and New-CsOnlineSchedule
  .COMPONENT
    TeamsAutoAttendant
  .FUNCTIONALITY
    Creates a Schedule Object for use in an AutoAttendant
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantSchedule.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'WeeklyBusinessHours')]
  [Alias('New-TeamsAASchedule')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory, ParameterSetName = 'WeeklyBusinessHours2')]
    [Parameter(Mandatory, ParameterSetName = 'WeeklyBusinessHours')]
    [Parameter(Mandatory, ParameterSetName = 'WeeklyTimeRange')]
    [switch]$WeeklyRecurrentSchedule,

    [Parameter(Mandatory, ParameterSetName = 'FixedTimeRange')]
    [switch]$Fixed,

    [Parameter(Mandatory, ParameterSetName = 'WeeklyBusinessHours2')]
    [Parameter(Mandatory, ParameterSetName = 'WeeklyBusinessHours')]
    [Parameter(Mandatory, ParameterSetName = 'WeeklyTimeRange')]
    [ValidateSet('MonToFri', 'MonToSat', 'MonToSun', 'SunToThu')]
    [string]$BusinessDays,

    [Parameter(Mandatory, ParameterSetName = 'WeeklyBusinessHours')]
    [ValidateSet('9to6', '9to5', '9to4', '8to6', '8to5', '8to4', '7to6', '7to5', '7to4', '6to6', '10to6', '0830to1700', '0830to1730', '0800to1730', '0830to1800', '0900to1730', '0930to1730', '0930to1800', '8to12and13to17', '8to12and13to18', '9to12and13to17', '9to12and13to18', '9to13and14to18', '8to12and14to18', 'AllDay')]
    [string]$BusinessHours,

    #IMPROVE This does not allow for AM/PM notation, but for 12:00 and 1200 - improve?
    [Parameter(Mandatory, ParameterSetName = 'WeeklyBusinessHours2')]
    [ValidatePattern( { '^(?:[01]?\d|2[0-3])(?::)(00|15|30|45)' })]
    [string]$BusinessHoursStart,

    [Parameter(Mandatory, ParameterSetName = 'WeeklyBusinessHours2')]
    [ValidatePattern( { '^(?:[01]?\d|2[0-3])(?::)(00|15|30|45)' })]
    [string]$BusinessHoursEnd,

    [Parameter(Mandatory, ParameterSetName = 'WeeklyTimeRange')]
    [Parameter(Mandatory, ParameterSetName = 'FixedTimeRange')]
    [system.Object[]]$DateTimeRanges,

    [Parameter(ParameterSetName = 'WeeklyBusinessHours2')]
    [Parameter(ParameterSetName = 'WeeklyBusinessHours')]
    [Parameter(ParameterSetName = 'WeeklyTimeRange')]
    [switch]$Complement
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

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

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    #region Prep
    # Initialising Splatting Object
    $Parameters = @{}

    # Adding generic parameters
    $Parameters.Name = $Name
    #$Parameters.ErrorAction' = $Stop }

    if ($Complement) {
      Write-Verbose -Message '[PROCESS] Processing Complement'
      $Parameters.Complement = $true
    }
    #endregion

    #region Defining recurrance Fixed/Weekly
    if ($PSBoundParameters.ContainsKey('WeeklyRecurrentSchedule')) {
      Write-Verbose -Message '[PROCESS] Processing WeeklyRecurrentSchedule'
      $Parameters.WeeklyRecurrentSchedule = $true
    }
    elseif ($PSBoundParameters.ContainsKey('Fixed')) {
      Write-Verbose -Message '[PROCESS] Processing Fixed'
      $Parameters.Fixed = $true
    }
    #endregion

    #region Defining $TimeFrame
    if ($PSBoundParameters.ContainsKey('DateTimeRanges')) {
      Write-Verbose -Message '[PROCESS] Processing DateTimeRanges'
      Write-Information 'INFO: The DateTimeRanges provided are not validated, just passed on to New-CsOnlineSchedule as is. Handle with care'
      $TimeFrame = @($DateTimeRanges)
      $Parameters.DateTimeRanges = @($TimeFrame)
    }
    else {
      # Differentiating between BusinessHours and BusinessHoursStart/End
      if ($PSBoundParameters.ContainsKey('BusinessHoursStart') -and $PSBoundParameters.ContainsKey('BusinessHoursEnd')) {
        Write-Verbose -Message "[PROCESS] Processing BusinessHoursStart '$BusinessHoursStart' and BusinessHoursEnd '$BusinessHoursEnd'"
        if ($BusinessHoursStart -gt $BusinessHoursEnd) {
          $TimeFrame = New-CsOnlineTimeRange -Start $BusinessHoursStart -End 1.$BusinessHoursEnd
        }
        else {
          $TimeFrame = New-CsOnlineTimeRange -Start $BusinessHoursStart -End $BusinessHoursEnd
        }
      }
      else {
        Write-Verbose -Message "[PROCESS] Processing BusinessHours '$BusinessHours'"
        switch ($BusinessHours) {
          # Defining time of Day ($TimeFrame)
          'AllDay' { $TimeFrame = New-CsOnlineTimeRange -Start 00:00 -End 1.00:00 }
          '9to6' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 18:00 }
          '9to5' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 17:00 }
          '9to4' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 16:00 }
          '8to6' { $TimeFrame = New-CsOnlineTimeRange -Start 08:00 -End 18:00 }
          '8to5' { $TimeFrame = New-CsOnlineTimeRange -Start 08:00 -End 17:00 }
          '8to4' { $TimeFrame = New-CsOnlineTimeRange -Start 08:00 -End 16:00 }
          '7to6' { $TimeFrame = New-CsOnlineTimeRange -Start 07:00 -End 18:00 }
          '7to5' { $TimeFrame = New-CsOnlineTimeRange -Start 07:00 -End 17:00 }
          '7to4' { $TimeFrame = New-CsOnlineTimeRange -Start 07:00 -End 16:00 }
          '6to6' { $TimeFrame = New-CsOnlineTimeRange -Start 06:00 -End 18:00 }
          '10to6' { $TimeFrame = New-CsOnlineTimeRange -Start 10:00 -End 18:00 }
          '0800to1730' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 17:00 }
          '0830to1700' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 17:00 }
          '0830to1730' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 17:00 }
          '0830to1800' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 17:00 }
          '0900to1730' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 17:30 }
          '0930to1730' { $TimeFrame = New-CsOnlineTimeRange -Start 09:30 -End 17:30 }
          '0930to1800' { $TimeFrame = New-CsOnlineTimeRange -Start 09:30 -End 18:00 }
          '8to12and13to17' {
            $Range1 = New-CsOnlineTimeRange -Start 08:00 -End 12:00
            $Range2 = New-CsOnlineTimeRange -Start 13:00 -End 17:00
            $TimeFrame = @($Range1, $Range2)
          }
          '8to12and13to18' {
            $Range1 = New-CsOnlineTimeRange -Start 08:00 -End 12:00
            $Range2 = New-CsOnlineTimeRange -Start 13:00 -End 18:00
            $TimeFrame = @($Range1, $Range2)
          }
          '9to12and13to17' {
            $Range1 = New-CsOnlineTimeRange -Start 09:00 -End 12:00
            $Range2 = New-CsOnlineTimeRange -Start 13:00 -End 17:00
            $TimeFrame = @($Range1, $Range2)
          }
          '9to12and13to18' {
            $Range1 = New-CsOnlineTimeRange -Start 09:00 -End 12:00
            $Range2 = New-CsOnlineTimeRange -Start 13:00 -End 18:00
            $TimeFrame = @($Range1, $Range2)
          }
          '9to13and14to18' {
            $Range1 = New-CsOnlineTimeRange -Start 09:00 -End 13:00
            $Range2 = New-CsOnlineTimeRange -Start 14:00 -End 17:00
            $TimeFrame = @($Range1, $Range2)
          }
          '8to12and14to18' {
            $Range1 = New-CsOnlineTimeRange -Start 08:00 -End 12:00
            $Range2 = New-CsOnlineTimeRange -Start 14:00 -End 18:00
            $TimeFrame = @($Range1, $Range2)
          }
          default { $TimeFrame = @($(New-CsOnlineTimeRange -Start 09:00 -End 17:00)) }
        }
      }
    }
    #endregion

    #region Defining $BusinessDays
    # Then Using $TimeFrame to define full Schedule for $BusinessDays
    if ($BusinessDays) {
      Write-Verbose -Message "[PROCESS] Processing BusinessDays '$BusinessDays"
      switch ($BusinessDays) {
        'MonToFri' {
          $Parameters.MondayHours = @($TimeFrame)
          $Parameters.TuesdayHours = @($TimeFrame)
          $Parameters.WednesdayHours = @($TimeFrame)
          $Parameters.ThursdayHours = @($TimeFrame)
          $Parameters.FridayHours = @($TimeFrame)
        }
        'MonToSat' {
          $Parameters.MondayHours = @($TimeFrame)
          $Parameters.TuesdayHours = @($TimeFrame)
          $Parameters.WednesdayHours = @($TimeFrame)
          $Parameters.ThursdayHours = @($TimeFrame)
          $Parameters.FridayHours = @($TimeFrame)
          $Parameters.SaturdayHours = @($TimeFrame)
        }
        'MonToSun' {
          $Parameters.MondayHours = @($TimeFrame)
          $Parameters.TuesdayHours = @($TimeFrame)
          $Parameters.WednesdayHours = @($TimeFrame)
          $Parameters.ThursdayHours = @($TimeFrame)
          $Parameters.FridayHours = @($TimeFrame)
          $Parameters.SaturdayHours = @($TimeFrame)
          $Parameters.SundayHours = @($TimeFrame)
        }
        'SunToThu' {
          $Parameters.SundayHours = @($TimeFrame)
          $Parameters.MondayHours = @($TimeFrame)
          $Parameters.TuesdayHours = @($TimeFrame)
          $Parameters.WednesdayHours = @($TimeFrame)
          $Parameters.ThursdayHours = @($TimeFrame)
        }
        default {
          $Parameters.MondayHours = @($TimeFrame)
          $Parameters.TuesdayHours = @($TimeFrame)
          $Parameters.WednesdayHours = @($TimeFrame)
          $Parameters.ThursdayHours = @($TimeFrame)
          $Parameters.FridayHours = @($TimeFrame)
        }
      }
    }
    #endregion


    # Creating Schedule
    Write-Verbose -Message '[PROCESS] Creating Schedule'
    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
      "Function: $($MyInvocation.MyCommand.Name): Parameters:", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }

    if ($PSCmdlet.ShouldProcess("$Name", 'New-CsOnlineSchedule')) {
      New-CsOnlineSchedule @Parameters
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsAutoAttendantSchedule
