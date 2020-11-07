# Module:     TeamsFunctions
# Function:   Teams Auto Attendant
# Author:     David Eberhardt
# Updated:    01-NOV-2020
# Status:     PreLive




function Get-TeamsAutoAttendantCallableEntity {
  <#
	.SYNOPSIS
		Returns a callable Entity Object from an Identity/ObjectId
	.DESCRIPTION
    Helper function to prepare a nested Object of an Auto Attendant for display
    Used in Get-TeamsAutoAttendant
  .PARAMETER Identity
    The input Object to transform
  .LINK
    Get-TeamsAutoAttendant

	#>

  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory, Position = 0, HelpMessage = 'Identity of the Callable Entity')]
    [Alias('ObjectId')]
    [string]$Identity

  ) #param

  begin {
    #Show-FunctionStatus -Level PreLive
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ("tel:" -in $Identity) {
      $CallableEntity = [PsCustomObject][ordered]@{
        'Entity'   = $Identity
        'Identity' = $Identity
        'Type'     = "ExternalPstn"
      }
    }
    else {
      try {
        # FIRST: Trying an AzureAdUser for User or ApplicationEndPoint
        $CallTarget = Get-AzureADUser -ObjectId $Identity -WarningAction SilentlyContinue
        try {
          $ApplicationInstance = Get-CsOnlineApplicationInstance -Identity $CallTarget.ObjectId -WarningAction SilentlyContinue
        }
        catch {
          $ApplicationInstance = $null
        }

        $CallableEntity = [PsCustomObject][ordered]@{
          'Entity'   = $CallTarget.UserPrincipalName
          'Identity' = $CallTarget.ObjectId
          'Type'     = if ($ApplicationInstance) { "ApplicationEndpoint" } else { "User" }
        }
      }
      catch {
        # Not a User, not an ApplicationEndPoint
        try {
          # SECOND: Trying a AzureAdGroup for SharedVoicemail
          $CallTarget = Get-AzureADGroup -ObjectId $Identity
          $CallableEntity = [PsCustomObject][ordered]@{
            'Entity'   = $CallTarget.DisplayName
            'Identity' = $CallTarget.ObjectId
            'Type'     = "Group"
          }
        }
        catch {
          Write-Warning -Message "The Object may be a HuntGroup or OrganizationalAutoAttendant which are SfBO types and are not supported by this CmdLet"
          $CallableEntity = [PsCustomObject][ordered]@{
            'Entity'   = $null
            'Identity' = $Identity
            'Type'     = "HuntGroup or OrganizationalAutoAttendant"
          }
        }
      }
    }

    return $CallableEntity

  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end

} # Get-TeamsAutoAttendantCallableEntity
