# Module:   TeamsFunctions
# Function: Helper
# Author:   David Eberhardt
# Updated:  15-JAN-2021
# Status:   Live




function Get-PublicHolidayCountry {
  <#
  .SYNOPSIS
    Returns a list of Countries for which Public Holidays are available
  .DESCRIPTION
    Queries the Nager.Date API for supported Countries
  .EXAMPLE
    Get-PublicHolidayCountry
    Lists the Countries for which Public Holidays are available
  .INPUTS
    System.Void
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
    Queries available Countries from the Nager.Date API to generate a Get-PublicHolidayList
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-PublicHolidayCountry.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  #[Alias('')]
  [OutputType([PSCustomObject])]
  param ()

  begin {
    #Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    #read the content from nager.date
    $url = 'https://date.nager.at/api/v2/AvailableCountries'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Countries = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $url
    $Countries.GetEnumerator() | Select-Object @{Label = 'CountryCode'; Expression = { $_.Key } }, @{Label = 'Country'; Expression = { $_.Value } }

  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-PublicHolidayCountry