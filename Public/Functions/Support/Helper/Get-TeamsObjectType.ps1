﻿# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:   David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Get-TeamsObjectType {
  <#
  .SYNOPSIS
    Resolves the type of the object
  .DESCRIPTION
    Helper function to find the Callable Entity Type of Teams Objects
    Returns ObjectType: User (AzureAdUser), Group (AzureAdGroup), ResourceAccount (ApplicationInstance) or TelURI String (ExternalPstn)
  .PARAMETER Identity
    Required. String for the TelURI, Group Name or Mailnickname, UserPrincipalName, depending on the Entity Type
  .EXAMPLE
    Get-TeamsObjectType -Identity "John@domain.com"
    Returns "User" as the type of Entity if an AzureAdUser with the UPN "John@domain.com" is found
  .EXAMPLE
    Get-TeamsObjectType -Identity "Accounting"
    Returns "Group" as the type of Entity if a AzureAdGroup with the Name "Accounting" is found.
  .EXAMPLE
    Get-TeamsObjectType -Identity "Accounting@domain.com"
    Returns "Group" as the type of Entity if a AzureAdGroup with the Mailnickname "Accounting@domain.com" is found.
  .EXAMPLE
    Get-TeamsObjectType -Identity "ResourceAccount@domain.com"
    Returns "ResourceAccount" as the type of Entity if a CsOnlineApplicationInstance with the UPN "ResourceAccount@domain.com" is found
  .EXAMPLE
    Get-TeamsObjectType -Identity "tel:+1555123456"
    Returns "TelURI" as the type of Entity
  .EXAMPLE
    Get-TeamsObjectType -Identity "+1555123456"
    Returns an Error as the type of Entity cannot be determined correctly
  .INPUTS
    System.String
  .OUTPUTS
    System.String
  .NOTES
    None
  .COMPONENT
    UserManagement
    TeamsAutoAttendant
    TeamsCallQueue
  .FUNCTIONALITY
    Determining the Object Type for the String
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsObjectType.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(ConfirmImpact = 'Low')]
  [OutputType([System.String])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'Identity of the Call Target')]
    [string[]]$Identity
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Asserting MicrosoftTeams Connection
    if ( -not (Assert-MicrosoftTeamsConnection) ) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($Id in $Identity) {
      if ($Id -match '^(tel:\+|\+)?([0-9]?[-\s]?(\(?[0-9]{3}\)?)[-\s]?([0-9]{3}[-\s]?[0-9]{4})|([0-9][-\s]?){4,20})((x|;ext=)([0-9]{3,8}))?$' -and -not ($Id -match '@')) {
        Write-Verbose -Message "Callable Entity - Call Target '$Id' found: TelURI (ExternalPstn)"
        return 'TelURI'
      }
      elseif ($Id -match '^(19:)[0-9a-f]{32}(@thread.)(skype|tacv2|([0-9a-z]{5}))$') {
        Write-Verbose -Message "Callable Entity - Call Target '$Id' found: Channel (Channel)"
        return 'Channel'
      }
      else {
        try {
          $User = Get-AzureADUser -ObjectId "$Id" -WarningAction SilentlyContinue -ErrorAction Stop
          if ( $User ) {
            if ($User[0].Department -eq 'Microsoft Communication Application Instance') {
              #if ( Test-TeamsResourceAccount $Id ) {
              Write-Verbose -Message "Callable Entity - Call Target '$Id' found: ResourceAccount (ApplicationEndpoint), (VoiceApp)"
              return 'ApplicationEndpoint'
            }
            else {
              Write-Verbose -Message "Callable Entity - Call Target '$Id' found: User (Forward, Voicemail)"
              return 'User'
            }
          }
        }
        catch {
          Write-Verbose -Message "Callable Entity - Call Target '$Id' is not a TelUri, Channel, User (Forward, Voicemail), ApplicationEndPoint - Trying to find an AzureAdGroup"
        }
      }

      # Last resort - Try AzureAdGroup
      if ( Test-AzureADGroup $Id ) {
        Write-Verbose -Message "Callable Entity - Call Target '$Id' found: Group (SharedVoicemail)"
        return 'Group'
      }
      else {
        # Catch neither
        Write-Verbose -Message 'Callable Entity - ObjectType cannot be determined. (Neither TelURI, nor Channel, AzureAdUser, ApplicationEndPoint or Group)'
        return 'Unknown'
      }
    }
  }

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsObjectType
