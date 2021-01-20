# Module:   TeamsFunctions
# Function: Helper
# Author:	  David Eberhardt
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
    Required. Year for which the Holidays are to be listed
  .PARAMETER DisplayAll
    Required. Year for which the Holidays are to be listed
  .EXAMPLE
    Get-PublicHolidayList [-Country] CA [-Year] 2022
    Lists the Holidays for Canada in 2022. The Parameters are positional, so can be omitted
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    The Nager.Date API currently supports a bit over 100 Countries.
    I am working on an extension to this by reading from https://www.timeanddate.com/holidays/
    For Example: https://www.timeanddate.com/holidays/uk/2022?hol=9
  .COMPONENT
    TeamsAutoAttendant
  .ROLE
    Helper Function
  .FUNCTIONALITY
    HolidaySet
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
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
        if ($_ -in $Countries.CountryCode) { $true } else { Write-Host "Country '$_' not supported (yet), sorry. Please provide a CountryCode from the output of Get-PublicHolidayCountry" -ForegroundColor Red; $false }
      })]
    [Alias('CC')]
    [String]$CountryCode,

    [Parameter(Position = 1, ValueFromPipeline, HelpMessage = 'Username(s)')]
    [Alias('Y')]
    [ValidateRange(2000, 3000)]
    [int]$Year
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Handling Year
    if (-not $PSBoundParameters.ContainsKey('Year')) {
      $Today = Get-Date
      $Year = $Today.Year
      $null = $Today.Datetime -match '\d\d (.*?) \d'
      If ($Today.Month -eq 12) {
        $Year++
      }
      Write-Verbose -Message "Parameter Year not provided, as it is $($matches[1]), using year: $Year" -Verbose
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