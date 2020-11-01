# Module:   TeamsFunctions
# Function: Testing
# Author:		David Eberhardt
# Updated:  01-SEP-2020
# Status:   Unmanaged

function Test-TeamsExternalDNS {
  <#
	.SYNOPSIS
		Tests a domain for the required external DNS records for a Teams deployment.
	.DESCRIPTION
		Teams requires the use of several external DNS records for clients and federated
		partners to locate services and users. This function will look for the required external DNS records
		and display their current values, if they are correctly implemented, and any issues with the records.
	.PARAMETER Domain
		The domain name to test records. This parameter is required.
	.EXAMPLE
		Test-TeamsExternalDNS -Domain contoso.com
		Example 1 will test the contoso.com domain for the required external DNS records for Teams.
	#>

  [CmdletBinding()]
  [OutputType([Boolean])]
  Param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the domain name to test the external DNS Skype Online records.")]
    [string]$Domain
  ) #param

  begin {
    Show-FunctionStatus -Level Unmanaged
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"


    # VARIABLES
    [string]$federationSRV = "_sipfederationtls._tcp.$Domain"
    [string]$sipSRV = "_sip._tls.$Domain"
    [string]$lyncdiscover = "lyncdiscover.$Domain"
    [string]$sip = "sip.$Domain"

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    # Federation SRV Record Check
    $federationSRVResult = Resolve-DnsName -Name "_sipfederationtls._tcp.$Domain" -Type SRV -ErrorAction SilentlyContinue
    $federationOutput = [PSCustomObject][ordered]@{
      Name    = $federationSRV
      Type    = "SRV"
      Target  = $null
      Port    = $null
      Correct = "Yes"
      Notes   = $null
    }

    if ($null -ne $federationSRVResult) {
      $federationOutput.Target = $federationSRVResult.NameTarget
      $federationOutput.Port = $federationSRVResult.Port
      if ($federationOutput.Target -ne "sipfed.online.lync.com") {
        $federationOutput.Notes += "Target FQDN is not correct for Skype Online. "
        $federationOutput.Correct = "No"
      }

      if ($federationOutput.Port -ne "5061") {
        $federationOutput.Notes += "Port is not set to 5061. "
        $federationOutput.Correct = "No"
      }
    }
    else {
      $federationOutput.Notes = "Federation SRV record does not exist. "
      $federationOutput.Correct = "No"
    }

    Write-Output -InputObject $federationOutput

    # SIP SRV Record Check
    $sipSRVResult = Resolve-DnsName -Name $sipSRV -Type SRV -ErrorAction SilentlyContinue
    $sipOutput = [PSCustomObject][ordered]@{
      Name    = $sipSRV
      Type    = "SRV"
      Target  = $null
      Port    = $null
      Correct = "Yes"
      Notes   = $null
    }

    if ($null -ne $sipSRVResult) {
      $sipOutput.Target = $sipSRVResult.NameTarget
      $sipOutput.Port = $sipSRVResult.Port
      if ($sipOutput.Target -ne "sipdir.online.lync.com") {
        $sipOutput.Notes += "Target FQDN is not correct for Skype Online. "
        $sipOutput.Correct = "No"
      }

      if ($sipOutput.Port -ne "443") {
        $sipOutput.Notes += "Port is not set to 443. "
        $sipOutput.Correct = "No"
      }
    }
    else {
      $sipOutput.Notes = "SIP SRV record does not exist. "
      $sipOutput.Correct = "No"
    }

    Write-Output -InputObject $sipOutput

    #Lyncdiscover Record Check
    $lyncdiscoverResult = Resolve-DnsName -Name $lyncdiscover -Type CNAME -ErrorAction SilentlyContinue
    $lyncdiscoverOutput = [PSCustomObject][ordered]@{
      Name    = $lyncdiscover
      Type    = "CNAME"
      Target  = $null
      Port    = $null
      Correct = "Yes"
      Notes   = $null
    }

    if ($null -ne $lyncdiscoverResult) {
      $lyncdiscoverOutput.Target = $lyncdiscoverResult.NameHost
      $lyncdiscoverOutput.Port = "----"
      if ($lyncdiscoverOutput.Target -ne "webdir.online.lync.com") {
        $lyncdiscoverOutput.Notes += "Target FQDN is not correct for Skype Online. "
        $lyncdiscoverOutput.Correct = "No"
      }
    }
    else {
      $lyncdiscoverOutput.Notes = "Lyncdiscover record does not exist. "
      $lyncdiscoverOutput.Correct = "No"
    }

    Write-Output -InputObject $lyncdiscoverOutput

    #SIP Record Check
    $sipResult = Resolve-DnsName -Name $sip -Type CNAME -ErrorAction SilentlyContinue
    $sipOutput = [PSCustomObject][ordered]@{
      Name    = $sip
      Type    = "CNAME"
      Target  = $null
      Port    = $null
      Correct = "Yes"
      Notes   = $null
    }

    if ($null -ne $sipResult) {
      $sipOutput.Target = $sipResult.NameHost
      $sipOutput.Port = "----"
      if ($sipOutput.Target -ne "sipdir.online.lync.com") {
        $sipOutput.Notes += "Target FQDN is not correct for Skype Online. "
        $sipOutput.Correct = "No"
      }
    }
    else {
      $sipOutput.Notes = "SIP record does not exist. "
      $sipOutput.Correct = "No"
    }

    Write-Output -InputObject $sipOutput
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-TeamsExternalDNS
