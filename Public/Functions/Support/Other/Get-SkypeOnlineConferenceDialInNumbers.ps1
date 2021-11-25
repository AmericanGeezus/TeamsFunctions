# Module:     TeamsFunctions
# Function:   Lookup
# Author:    Jeff Brown
# Updated:    03-MAY-2020
# Status:     Unmanaged




function Get-SkypeOnlineConferenceDialInNumbers {
  <#
  .SYNOPSIS
    Gathers the audio conference dial-in numbers information for a Skype for Business Online tenant.
  .DESCRIPTION
    This command uses the tenant's conferencing dial-in number web page to gather a "user-readable" list of
    the regions, numbers, and available languages where dial-in conferencing numbers are available. This web
    page can be access at https://dialin.lync.com/DialInOnline/Dialin.aspx?path=<DOMAIN> replacing "<DOMAIN>"
    with the tenant's default domain name (i.e. contoso.com).
  .PARAMETER Domain
    The Skype for Business Online Tenant domain to gather the conference dial-in numbers.
  .EXAMPLE
    Get-SkypeOnlineConferenceDialInNumbers -Domain contoso.com
    Example 1 will gather the conference dial-in numbers for contoso.com based on their conference dial-in number web page.
  .INPUTS
    System.String
  .OUTPUTS
    System.Void - Default Behavior
    System.Object - With Switch PassThru
  .NOTES
    This function was taken 1:1 from SkypeFunctions and remains untested for Teams
  .COMPONENT
    None
  .FUNCTIONALITY
    Lists Dial-In Conferencing numbers
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-SkypeOnlineConferenceDialInNumbers.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Unmanaged.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, HelpMessage = 'Enter the domain name to gather the available conference dial-in numbers')]
    [string]$Domain
  ) #param

  begin {
    Show-FunctionStatus -Level Unmanaged
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting MicrosoftTeams Connection
    if ( -not (Assert-MicrosoftTeamsConnection) ) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    try {
      $siteContents = Invoke-WebRequest https://webdir1a.online.lync.com/DialinOnline/Dialin.aspx?path=$Domain -ErrorAction STOP
    }
    catch {
      Write-Warning -Message "Unable to access that dial-in page. Please check the domain name and try again. Also try to manually navigate to the page using the URL http://dialin.lync.com/DialInOnline/Dialin.aspx?path=$Domain."
      return
    }

    $tables = $siteContents.ParsedHtml.getElementsByTagName('TABLE')
    $table = $tables[0]
    $rows = @($table.rows)

    $output = [PSCustomObject][ordered]@{
      Location  = $null
      Number    = $null
      Languages = $null
    }

    for ($n = 0; $n -lt $rows.Count; $n += 1) {
      if ($rows[$n].innerHTML -like '<TH*') {
        $output.Location = $rows[$n].innerText
      }
      else {
        $output.Number = $rows[$n].cells[0].innerText
        $output.Languages = $rows[$n].cells[1].innerText
        Write-Output $output
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-SkypeOnlineConferenceDialInNumbers
