# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   BETA

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
    Internal only! Enables this Command to be used for Call Queues.
    This will validate the Object and then only return the ObjectId
  .PARAMETER Force
    Suppresses confirmation prompt to enable Users for Enterprise Voice, if required and $Confirm is TRUE
  .EXAMPLE
    New-TeamsAutoAttendantDialScope -Type ExternalPstn -Identity "tel:+1555123456"
    Creates a callable Entity for the Tel URI
  .EXAMPLE
    New-TeamsAutoAttendantDialScope -Type User -Identity John@domain.com
    Creates a callable Entity for the User John@domain.com
  .NOTES
    This will verify the Objects eligibility.
    Requires a valid license but can enable the Object for Enterprise Voice if needed.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object - (default)
    System.String - With Switch ReturnObjectIdOnly
  .COMPONENT
    TeamsAutoAttendant
    TeamsCallQueue
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

    [Parameter(HelpMessage = "OutputType: Object or Id")]
    [switch]$ReturnObjectIdOnly,

    [Parameter(HelpMessage = "Suppresses confirmation prompt to enable Users for Enterprise Voice, if Users are specified")]
    [switch]$Force

  ) #param

  begin {
    # Caveat - Script in Development
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    Show-FunctionStatus -Level BETA
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

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
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    switch ($Type) {
      "ExternalPstn" {
        try {
          if ($Identity -match "^tel:\+\d") {
            #Telephone URI
            $Id = "tel:$Identity"
          }
          elseif ($Identity -match "^\+\d") {
            #Telephone Number (E.164)
            $Id = "$Identity"
          }
          else {
            Write-Error -Message "Invalid format Target for Type 'ExternalPstn'. Please provide a Tel URI or an E.164 number" -Category InvalidType -RecommendedAction "Please correct and retry" -ErrorAction Stop
          }
          Write-Verbose -Message "Callable Entity - Call Target '$Identity' (TelURI) used"
        }
        catch {
          Write-Error -Message "Callable Entity - Call Target '$Identity' (TelURI) not enumerated. Omitting Object" -Category ResourceUnavailable -ErrorAction Stop
        }
      }
      "User" {
        if ( Test-AzureADUser $Identity ) {
          $UserObject = Get-CsOnlineUser "$Identity" -WarningAction SilentlyContinue
          $IsEVenabled = $UserObject.EnterpriseVoiceEnabled
          $IsLicensed = Test-TeamsUserLicense -Identity $Identity -ServicePlan MCOEV
        }
        else {
          Write-Error -Message "Callable Entity - Call Target '$Identity' (User) not found" -Category ObjectNotFound -ErrorAction Stop
        }

        if ( -not $IsLicensed  ) {
          Write-Error -Message "Callable Entity - Call Target '$Identity' (User) found but not licensed (PhoneSystem). Please assign a license" -Category ResourceUnavailable -RecommendedAction "Please assign a license that contains Phone System" -ErrorAction Stop
        }

        if ( -not $IsEVenabled) {
          Write-Verbose -Message "Callable Entity - Call Target '$Identity' (User) found and licensed, but not enabled for EnterpriseVoice" -Verbose
          if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Set-CsUser -EnterpriseVoiceEnabled $TRUE")) {
            $IsEVenabled = Enable-TeamsUserForEnterpriseVoice -Identity $Identity -Force
          }
        }

        # Add Operator
        if ( $IsEVenabled ) {
          Write-Verbose -Message "Callable Entity - Call Target '$Identity' (User) used"
          $Id = (Get-AzureADUser -ObjectId "$Identity" -WarningAction SilentlyContinue -ErrorAction STOP).ObjectId
        }
        else {
          Write-Error -Message "Callable Entity - Call Target '$Identity' (User) not enumerated. Omitting Object" -Category ResourceUnavailable -ErrorAction Stop
        }

      }
      "SharedVoicemail" {
        $DLObject = $null
        $DLObject = Resolve-AzureAdGroupObjectFromName "$Identity"

        if ($DLObject) {
          Write-Verbose -Message "Callable Entity - Call Target '$Identity' (Group) used"
          $Id = $DLObject.ObjectId
        }
        else {
          Write-Error -Message "Callable Entity - Call Target '$Identity' (Group) not found" -Category ObjectNotFound -ErrorAction Stop
        }

      }
      "ApplicationEndpoint" {
        if (Test-AzureADUser $Identity) {
          $Id = (Get-TeamsResourceAccount "$Identity" -ErrorAction STOP).ObjectId
          if ($Id) {
            Write-Verbose -Message "Callable Entity - Call Target '$Identity' (VoiceApp - ApplicationInstance - ResourceAccount) used"
          }
          else {
            Write-Warning -Message "Callable Entity - Call Target '$Identity' (VoiceApp - ApplicationInstance - ResourceAccount) not enumerated. Omitting Object"
          }
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
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #New-TeamsAutoAttendantCallableEntity