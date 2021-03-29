# Module:   TeamsFunctions
# Function: Helper
# Author:	  David Eberhardt
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
    The Nager.Date API currently supports a bit over 100 Countries.
  .COMPONENT
    SupportingFunction
    TeamsAutoAttendant
  .FUNCTIONALITY
    Queries available Countries from the Nager.Date API to generate a Get-PublicHolidayList
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_SupportingFunction
  .LINK
    about_TeamsAutoAttendant
  .LINK
    Get-PublicHolidayCountry
  .LINK
    Get-PublicHolidayList
  #>

  [CmdletBinding()]
  #[Alias('')]
  [OutputType([PSCustomObject])]
  param (

  )

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