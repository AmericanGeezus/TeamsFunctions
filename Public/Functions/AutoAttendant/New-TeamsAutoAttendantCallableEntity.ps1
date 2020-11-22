# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   RC




function New-TeamsAutoAttendantCallableEntity {
  <#
  .SYNOPSIS
    Creates a Callable Entity for Auto Attendants
  .DESCRIPTION
    Wrapper for New-CsAutoAttendantCallableEntity with verification
    Requires a licensed User or ApplicationEndpoint an Office 365 Group or Tel URI
  .PARAMETER Type
    Required. Type of Callable Entity to create
  .PARAMETER Identity
    Required. Tel URI, Group Name or UserPrincipalName, depending on the Entity Type
  .PARAMETER ReturnObjectIdOnly
    Using this switch will return only the ObjectId of the validated CallableEntity, but will not create the Object
    This way the Command can be used to validate connected Objects for Call Queues.
  .PARAMETER Force
    Suppresses confirmation prompt to enable Users for Enterprise Voice, if required and $Confirm is TRUE
  .EXAMPLE
    New-TeamsAutoAttendantEntity -Type ExternalPstn -Identity "tel:+1555123456"
    Creates a callable Entity for the provided string, normalising it into a Tel URI
  .EXAMPLE
    New-TeamsAutoAttendantEntity -Type User -Identity John@domain.com
    Creates a callable Entity for the User John@domain.com
  .NOTES
    For Users, it will verify the Objects eligibility.
    Requires a valid license but can enable the User Object for Enterprise Voice if needed.
    For Groups, it will verify that the Group exists in AzureAd (but not in Exchange)
    For ExternalPstn it will construct the Tel URI
  .INPUTS
    System.String
  .OUTPUTS
    System.Object - (default)
    System.String - With Switch ReturnObjectIdOnly
  .COMPONENT
    TeamsAutoAttendant
    TeamsCallQueue
	.LINK
    New-TeamsAutoAttendant
    Set-TeamsAutoAttendant
    New-TeamsAutoAttendantCallableEntity
    New-TeamsAutoAttendantDialScope
    New-TeamsAutoAttendantPrompt
    New-TeamsAutoAttendantSchedule
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('New-TeamsAAEntity')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "Callable Entity type: ExternalPstn, User, SharedVoiceMail, ApplicationEndpoint")]
    [ValidateSet('User', 'ExternalPstn', 'SharedVoicemail', 'ApplicationEndpoint')]
    [string]$Type,

    [Parameter(Mandatory = $true, HelpMessage = "Identity of the Call Target")]
    [string]$Identity,

    [Parameter(HelpMessage = "OutputType: Object or ObjectId")]
    [switch]$ReturnObjectIdOnly, #Invert and change to PassThru?

    [Parameter(HelpMessage = "Suppresses confirmation prompt to enable Users for Enterprise Voice, if Users are specified")]
    [switch]$Force

  ) #param

  begin {
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    switch ($Type) {
      "ExternalPstn" {
        $Id = Format-StringForUse -InputString "$Identity" -As LineURI
        try {
          if ($Id -match "^tel:\+\d") {
            Write-Verbose -Message "Callable Entity - Call Target '$Id' (TelURI) used"
          }
          else {
            throw
          }
        }
        catch {
          Write-Error -Message "Invalid format for Type 'ExternalPstn'. Please provide a Tel URI or an E.164 number" -Category InvalidType -RecommendedAction "Please correct and retry" -ErrorAction Stop
        }
      }
      "User" {
        #CHECK Validate ARRAY use!
        #Query is against the $Identity (UserPrincipalName), this should be returning a unique result, but could return multiple!
        $UserObject = Find-AzureADUser $Identity
        if ( $UserObject ) {
          $IsEVenabled = $UserObject.EnterpriseVoiceEnabled # Safeguard with this? $UserObject[0].EnterpriseVoiceEnabled
          $IsLicensed = Test-TeamsUserLicense -Identity $Identity -ServicePlan MCOEV

          if ( -not $IsLicensed  ) {
            Write-Error -Message "Callable Entity - Call Target '$Identity' (User) found but not licensed (PhoneSystem). Please assign a license" -Category ResourceUnavailable -RecommendedAction "Please assign a license that contains Phone System" -ErrorAction Stop
          }

          if ( -not $IsEVenabled) {
            Write-Verbose -Message "Callable Entity - Call Target '$Identity' (User) found and licensed, but not (yet) enabled for EnterpriseVoice" -Verbose
            if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Set-CsUser -EnterpriseVoiceEnabled $TRUE")) {
              $IsEVenabled = Enable-TeamsUserForEnterpriseVoice -Identity $Identity -Force
            }
          }

          # Post Verification
          if ( $IsEVenabled ) {
            Write-Verbose -Message "Callable Entity - Call Target '$Identity' (User) used"
            $Id = $UserObject.ObjectId
          }
          else {
            Write-Error -Message "Callable Entity - Call Target '$Identity' (User) not enumerated. Omitting Object" -Category ResourceUnavailable -ErrorAction Stop
          }
        }
        else {
          Write-Error -Message "Callable Entity - Call Target '$Identity' (User) not found" -Category ObjectNotFound -ErrorAction Stop
        }


      }
      "SharedVoicemail" {
        $DLObject = $null
        $DLObject = Find-AzureAdGroup "$Identity"

        if ($DLObject) {
          #CHECK Validate ARRAY use!
          Write-Verbose -Message "Callable Entity - Call Target '$Identity' (Group) used"
          $Id = $DLObject.ObjectId
        }
        else {
          Write-Error -Message "Callable Entity - Call Target '$Identity' (Group) not found" -Category ObjectNotFound -ErrorAction Stop
        }

      }
      "ApplicationEndpoint" {
        $RAobject = Find-TeamsResourceAccount "$Identity"
        if ($RAobject) {
          Write-Verbose -Message "Callable Entity - Call Target '$Identity' (VoiceApp - ApplicationInstance - ResourceAccount) used"
          $Id = $RA.ObjectId
        }
        else {
          Write-Error -Message "Callable Entity - Call Target '$Identity' (VoiceApp - ApplicationInstance - ResourceAccount) not found" -Category ObjectNotFound -ErrorAction Stop
        }

      }
    }

    # Create CsAutoAttendantCallableEntity
    Write-Verbose -Message "[PROCESS] Creating Callable Entity"
    if ($Id) {
      if ($PSBoundParameters.ContainsKey('ReturnObjectIdOnly')) {
        # Output
        return $Id
      }
      else {
        if ($PSCmdlet.ShouldProcess("$Identity", "New-CsAutoAttendantCallableEntity")) {
          $Entity = New-CsAutoAttendantCallableEntity -Type $Type -Identity $Id
          # Output
          return $Entity
        }
      }
    }
    else {
      throw [System.IO.IOException] "Callable Entity - Call Target '$Identity' ($type) not enumerated"
    }
  }

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsAutoAttendantCallableEntity
