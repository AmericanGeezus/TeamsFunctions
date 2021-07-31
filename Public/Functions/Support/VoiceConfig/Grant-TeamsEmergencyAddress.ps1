#SupportsConfirm: MID
# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  18-MAY-2021
# Status:   RC

# IDEA:
# Grant-TeamsEmergencyAddress
# Queries existing Location by Name "Get-CsOnlineLisLocation -Location "3rd Floor Cafe" and determines $LocationId
# Applies ID with "Set-CsOnlineVoiceUser -Identity $ObjectId -LocationId $LocationId" # Does this also _need_ a TelephoneNumber?

# https://docs.microsoft.com/en-us/powershell/module/skype/get-csonlinelislocation?view=skype-ps
# https://docs.microsoft.com/en-us/powershell/module/skype/set-csonlinevoiceuser?view=skype-ps



function Grant-TeamsEmergencyAddress {
  <#
  .SYNOPSIS
    Grants an existing Emergency Address (CivicAddress) to a User
  .DESCRIPTION
    The Civic Address used as an Emergency Address is assigned to the CsOnlineVoiceUser Object
    This is done by Name (Description) of the Address instead of the Id
  .PARAMETER Identity
    Required. UserPrincipalName or ObjectId of the User Object or a TelephoneNumber
  .PARAMETER Address
    Required. Friendly name of the Address as specified in the Tenant or LocationId of the Address.
    LocationIds are taken as-is, friendly names are queried against Get-CsOnlineLisLocation for a defined Location
  .PARAMETER PassThru
    Optional. Displays Object after action.
  .EXAMPLE
    Grant-TeamsEmergencyAddress -Identity John@domain.com -Address "3rd Floor Cafe"
    Searches for the Civic Address with the Exact description of "3rd Floor Cafe" and assigns this Address to the User

  .EXAMPLE
    Grant-TeamsEmergencyAddress -Identity +15551234567 -Address "3rd Floor Cafe"
    Searches for the Civic Address with the Exact description of "3rd Floor Cafe" and
    assigns this Address to the Number +15551234567 if found in the Business Voice Directory
    AddressDescription is an Alias for Address
  .EXAMPLE
    Grant-TeamsEmergencyAddress -Identity John@domain.com -LocationId 0000000-0000-000000000000
    Searches for the Civic Address with the LocationId 0000000-0000-000000000000 and assigns this Address to the User
    LocationId is an Alias for Address
  .EXAMPLE
    Grant-TeamsEmergencyAddress -Identity +15551234567 -PolicyName 0000000-0000-000000000000
    Searches for the Civic Address with the LocationId 0000000-0000-000000000000 and
    assigns this Address to the Number +15551234567 if found in the Business Voice Directory
    PolicyName is an Alias for Address (as it fits the theme)
  .INPUTS
    System.String
  .OUTPUTS
    System.Void
  .NOTES
    This script looks up the Civic Address in the Lis-Database and feeds the Address Object to Set-CsOnlineVoiceUser
    This treats the Address like a Policy and behaves in the same way as the EmergencyCallingPolicy or the
    EmergencyCallRoutingPolicy to assign to a user. Accepts the Address Description or a LocationId directly.
    Can be utilised like any other policy. Aliases to Address are: AddressDescription, LocationId, PolicyName.
    https://docs.microsoft.com/en-us/microsoftteams/manage-emergency-call-routing-policies
    https://docs.microsoft.com/en-us/microsoftteams/configure-dynamic-emergency-calling
  .COMPONENT
    VoiceConfig
  .FUNCTIONALITY
    Changes the CsOnlineVoiceUser Object to add a Civic Address to the User or Phone Number
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Grant-TeamsEmergencyAddress.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('Grant-TeamsEA')]
  [OutputType([System.Void])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Identity of the CsOnlineVoiceUser or TelephoneNumber')]
    [Alias('UserPrincipalName', 'ObjectId', 'PhoneNumber')]
    [string]$Identity,

    [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, HelpMessage = 'Type of Object presented. Determines Output')]
    [ValidateSet('PolicyName', 'AddressDescription', 'LocationId')]
    [string]$Address,

    [Parameter(HelpMessage = 'No output is written by default, Switch PassThru will return changed object')]
    [switch]$PassThru
  ) #param

  begin {
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # preparing Splatting Object
    $Parameters = $null
    $Parameters += @{'ErrorAction' = 'Stop' }

    try {
      $CsOnlineLisLocation = if ( $Address -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$' ) {
        Get-CsOnlineLisLocation -LocationId $Address -ErrorAction Stop
      }
      else {
        Get-CsOnlineLisLocation -Location "$Address" -ErrorAction Stop
      }

      $Parameters += @{'LocationId' = $CsOnlineLisLocation.LocationId }
    }
    catch {
      throw "Location '$Address' not found (CsOnlineLisLocation)! Please provide LocationId or Address Description"
    }

  }
  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($Id in $Identity) {
      Write-Verbose -Message "[PROCESS] Processing '$Id'"

      # Determining type of Id
      if ($Id -match '^(tel:\+|\+)?([0-9]?[-\s]?(\(?[0-9]{3}\)?)[-\s]?([0-9]{3}[-\s]?[0-9]{4})|[0-9]{8,15})((;ext=)([0-9]{3,8}))?$') {
        $Number = Format-StringForUse $Id -As E164
        Write-Verbose -Message "Identity matches a Phone Number - Number normalised to '$Number'"
        $Parameters += @{'TelephoneNumber' = $Number }
      }
      else {
        # Querying Identity
        try {
          Write-Verbose -Message "User '$User' - Querying User Account"
          $CsUser = Get-CsOnlineUser -Identity "$User" -WarningAction SilentlyContinue -ErrorAction Stop
        }
        catch {
          Write-Error -Message "User '$User' not found (CsOnlineUser): $($_.Exception.Message)" -Category ObjectNotFound
          continue
        }
        $Parameters += @{'Identity' = $CsUser.ObjectId }
      }


      # Apply
      try {
        if ($PSCmdlet.ShouldProcess("$Identity", 'Set-CsOnlineVoiceUser')) {
          #Static, no splatting, only for Identities (not for phone numbers!)
          #$CsOnlineVoiceUser = Set-CsOnlineVoiceUser -Identity "$Identity" -LocationID $CsOnlineLisLocation.LocationId
          $CsOnlineVoiceUser = Set-CsOnlineVoiceUser @Parameters
          # Output
          if ( $PassThru ) {
            return $CsOnlineVoiceUser
          }
        }
      }
      catch {
        throw "Error applying Location to CsOnlineVoiceUser. Exception: $($_.Exception.Message)"
      }

    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} # Grant-TeamsEmergencyAddress
