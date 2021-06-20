# Module:   TeamsFunctions
# Function: Helper
# Author:   David Eberhardt
# Updated:  15-JAN-2021
# Status:   Live




function Get-PublicHolidayList {
  <#
  .SYNOPSIS
    Returns a list of Public Holidays for a country for a given year
  .DESCRIPTION
    Queries the Nager.Date API for public Holidays and returns a list per country and year.
  .PARAMETER CountryCode
    Required. ISO3166-Alpha-2 Country Code
  .PARAMETER Year
    Optional. Year for which the Holidays are to be listed. One or more Years between 2000 and 3000
    If not provided, the current year is taken. If the current month is December, the coming year is taken.
  .EXAMPLE
    Get-PublicHolidayList [-CountryCode] CA [-Year] 2022
    Lists the Holidays for Canada in 2022. The Parameters are positional, so can be omitted
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
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-PublicHolidayList.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_SupportingFunction
  .LINK
    about_TeamsAutoAttendant
  .LINK
    Get-PublicHolidayList
  .LINK
    Get-PublicHolidayCountry
  #>

  [CmdletBinding()]
  #[Alias('')]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory, Position = 0, HelpMessage = 'ISO 3166-alpha2 Country Code (2-digit CC)')]
    [ValidateScript( {
        $Countries = Get-PublicHolidayCountry
        if ($_ -in $Countries.CountryCode) { $true } else {
          throw [System.Management.Automation.ValidationMetadataException] "Country '$_' not supported (yet), sorry. Please provide a CountryCode from the output of Get-PublicHolidayCountry or check https://date.nager.at/"
          $false
        }
      })]
    [Alias('CC')]
    [String]$CountryCode,

    [Parameter(Position = 1, ValueFromPipeline, HelpMessage = 'Year')]
    [Alias('Y')]
    [ValidateRange(2000, 3000)]
    [int]$Year
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

    #read the content from nager.date
    $url = "https://date.nager.at/api/v2/publicholidays/$Year/$CountryCode"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Holidays = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $url

    return $Holidays

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Verb-Noun