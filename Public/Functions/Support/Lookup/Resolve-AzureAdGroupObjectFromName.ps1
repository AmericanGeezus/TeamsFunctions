# Module:     TeamsFunctions
# Function:   Lookup
# Author:     David Eberhardt
# Updated:    01-OCT-2020
# Status:     PreLive

function Resolve-AzureAdGroupObjectFromName {
  <#
	.SYNOPSIS
		Resolves an Azure AD Group Object from a given Name
	.DESCRIPTION
		Simple lookup - does the Group Object exist - to avoid TRY/CATCH statements for processing
	.PARAMETER GroupName
		Mandatory. The Name of the Group to resolve.
	.EXAMPLE
		Resolve-AzureAdGroupObjectFromName "My Group"
		Will Return the Group Object for "My Group" if it can be resolved.
    Will Return $null if not.
  .NOTES
    This simple lookup Script is an evolution of Test-AzureAdGroup and aims to gain better
    accuracy when looking up AzureAd Groups. It searches for Search String first, then
    splits the String at the '@' (if provided) to find the MailNickName (if set) and finally
    looks up the Group with ObjectId. If none are successful, it will return $null
  .LINK
    Test-AzureAdGroup
	#>

  [CmdletBinding()]
  [OutputType([Object])]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, HelpMessage = "This is the Name of the Group")]
    [string]$GroupName
  )

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"

    try {
      $GroupObject = Get-AzureADGroup -SearchString "$GroupName" -WarningAction SilentlyContinue -ErrorAction STOP
      if ($null -ne $GroupObject) {
        return $GroupObject
      }
      else {
        try {
          $MailNickName = $GroupName.Split('@')[0]
          $GroupObject = Get-AzureADGroup -SearchString "$MailNickName" -WarningAction SilentlyContinue -ErrorAction STOP
          if ($null -ne $GroupObject) {
            return $GroupObject
          }
          else {
            return $null
          }
        }
        catch {
          return $null
        }
      }
    }
    catch {
      try {
        $GroupObject = Get-AzureADGroup -ObjectId $GroupName -ErrorAction STOP
        if ($null -ne $GroupObject) {
          return $GroupObject
        }
        else {
          return $null
        }
      }
      catch {
        return $null
      }
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Resolve-AzureAdGroupObjectFromName
