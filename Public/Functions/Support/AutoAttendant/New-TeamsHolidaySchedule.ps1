# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:   David Eberhardt
# Updated:  13-JUN-2021
# Status:   Live




function New-TeamsHolidaySchedule {
  <#
  .SYNOPSIS
    Creates a Teams Schedule for each Country and Year specified
  .DESCRIPTION
    Queries the Nager.Date API for public Holidays for Country and year and creates a CsOnlineSchedule object for each.
  .PARAMETER CountryCode
    Required. ISO3166-Alpha-2 Country Code. One or more Countries from the list of Get-PublicHolidayCountry
  .PARAMETER Year
    Optional. Year for which the Holidays are to be listed. One or more Years between 2000 and 3000
    If not provided, the current year is taken. If the current month is December, the coming year is taken.
  .EXAMPLE
    New-TeamsHolidaySchedule -CountryCode CA -Year 2022
    Creates a Schedule Object in Teams for Canada for the year 2022.
  .EXAMPLE
    New-TeamsHolidaySchedule -CountryCode CA -Year 2022,2023,2024
    Creates 3 Schedule Object in Teams for Canada for the years 2022 to 2024.
  .EXAMPLE
    New-TeamsHolidaySchedule -CountryCode CA,MX,GB,DE -Year 2022
    Creates 4 Schedule Objects in Teams for the Canada, Mexico, Great Britain & Germany for the year 2022.
  .EXAMPLE
    New-TeamsHolidaySchedule -CountryCode CA,MX,GB,DE -Year 2022,2023,2024
    Creates 12 Schedule Objects in Teams for the Canada, Mexico, Great Britain & Germany for the years 2022 to 2024.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    The Nager.Date API currently supports a bit over 100 Countries. Please query with Get-PublicHolidayCountry
    Evaluated the following APIs:
    Nager.Date:   Decent coverage (100+ Countries). Free & Used Coverage: https://date.nager.at/Home/RegionStatistic
    TimeAndDate:  Great coverage. Requires license. Also a bit clunky. Not considering implementation.
    Calendarific: Great coverage. Requires license for commercial use. Currently not considering development
    Utilising the Calendarific API could be integrated if licensed and the API key is passed/registered locally.
  .COMPONENT
    SupportingFunction
    TeamsAutoAttendant
  .FUNCTIONALITY
    Queries available Holidays for a specific Country from the Nager.Date API
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsHolidaySchedule.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  #[Alias('')]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory, ValueFromPipelineByPropertyName, HelpMessage = 'ISO 3166-alpha2 Country Code (2-digit CC)')]
    [ValidateScript( {
        $Countries = Get-PublicHolidayCountry
        if ($_ -in $Countries.CountryCode) { $true } else {
          throw [System.Management.Automation.ValidationMetadataException] "Country '$_' not supported (yet), sorry. Please provide a CountryCode from the output of Get-PublicHolidayCountry or check https://date.nager.at/"
          $false
        }
      })]
    [Alias('CC', 'Country')]
    [String[]]$CountryCode,

    [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'Year(s)')]
    [Alias('Y')]
    [ValidateRange(2000, 3000)]
    [int[]]$Year
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Handling Year
    if (-not $PSBoundParameters.ContainsKey('Year')) {
      $Today = Get-Date
      $Year = $Today.Year
      $null = $Today.Datetime -match '\d\d (.*?) \d'
      If ($Today.Month -eq 12) {
        $Year++
      }
      Write-Information "$($MyInvocation.MyCommand) - Parameter Year not provided, as it is $($matches[1]), using year: $Year"
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($C in $CountryCode) {
      $Cname = Get-RegionFromCountryCode -CountryCode $C -Output Country
      Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Country '$Cname'"
      foreach ($Y in $Year) {
        Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Country '$Cname', Year '$Y'"
        try {
          $Hols = $null
          $Hols = Get-PublicHolidayList -CountryCode $C -Year $Y -ErrorAction Stop
        }
        catch {
          Write-Warning -Message 'Country'
        }
        #$Hols.Count

        [System.Collections.ArrayList]$Holidays = @()

        foreach ($H in $Hols) {
          $Date = $H.date | Get-Date -UFormat '%d/%m/%Y'
          $DateTimeRange = New-CsOnlineDateTimeRange -Start $Date
          if ($Holidays.Start -notcontains $DateTimeRange.Start) {
            Write-Verbose -Message "Country '$C', Year '$Y': Date: $Date`: $($H.Name) - OK, adding Date"
            [void]$Holidays.Add($DateTimeRange)
          }
          else {
            Write-Verbose -Message "Country '$C', Year '$Y': Date: $Date`: $($H.Name) - Already present, skipping"
          }
        }

        # Filtering Unique DateTimeRanges
        if ($PSCmdlet.ShouldProcess("Creating Online Schedule '$Cname $Y' with $($Holidays.Count) Holidays", "$($Schedule.Name)", 'New-TeamsAutoAttendantSchedule')) {
          try {
            $Schedule = New-TeamsAutoAttendantSchedule -Name "$Cname $Y" -Fixed -DateTimeRanges $Holidays -InformationAction SilentlyContinue -ErrorAction Stop
            Write-Information "Schedule '$($Schedule.Name)' created with $($Holidays.Count) entries"
            return $Schedule
          }
          catch {
            Write-Error -Message "Schedule '$Cname $Y' failed to create. Exception: $($_.Exception.Message)"
          }
        }
      }
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsHolidaySchedule
