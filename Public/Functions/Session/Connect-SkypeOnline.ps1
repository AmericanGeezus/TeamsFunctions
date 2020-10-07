# Module:   TeamsFunctions
# Function: Session
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live


function Connect-SkypeOnline {
  <#
	.SYNOPSIS
		Creates a remote PowerShell session to Skype for Business Online and Teams
	.DESCRIPTION
		Connecting to a remote PowerShell session to Skype for Business Online requires several components
		and steps. This function consolidates those activities by
		- verifying the SkypeOnlineConnector is installed and imported
    - prompting for username and password (once) to establish the session
    - prompting for MFA if required (once)
    - prompting for OverrideAdminDomain if connection fails to establish and retries connection attempt
		- extending the session time-out limit beyond 60mins (SkypeOnlineConnector v7 or higher only!)
    A SkypeOnline Session requires the SkypeForBusiness Legacy Admin role to connect
    To execute commands against Teams, one of the Teams Admin roles is required.
	.PARAMETER UserName
		Optional String. The username or sign-in address to use when making the remote PowerShell session connection.
	.PARAMETER OverrideAdminDomain
		Optional. Only used if managing multiple Tenants or SkypeOnPrem Hybrid configuration uses DNS records.
	.PARAMETER IdleTimeout
		Optional. Defines the IdleTimeout of the session in full hours between 1 and 8. Default is 4 hrs.
		Note, by default, creating a session with New-CsSkypeOnlineSession results in a Timeout of 15mins!
	.EXAMPLE
		Connect-SkypeOnline
    Example 1 will prompt for the username and password of an administrator with permissions to connect to Skype for Business Online.
    Additional prompts for Multi Factor Authentication are displayed as required
	.EXAMPLE
		Connect-SkypeOnline -UserName admin@contoso.com
		Example 2 will pre-fill the authentication prompt with admin@contoso.com and only ask for the password for the account to connect out to Skype for Business Online.
    Additional prompts for Multi Factor Authentication are displayed as required
	.NOTES
		Requires that the Skype Online Connector PowerShell module be installed.
		If the PowerShell Module SkypeOnlineConnector is v7 or higher, the Session TimeOut of 60min can be circumvented.
		Enable-CsOnlineSessionForReconnection is run.
		Download v7 here: https://www.microsoft.com/download/details.aspx?id=39366
		The SkypeOnline Session allows you to administer SkypeOnline and Teams respectively.
		To manage Teams, Channels, etc. within Microsoft Teams, use Connect-MicrosoftTeams
		Connect-MicrosoftTeams requires a Teams Admin role and is part of the PowerShell Module MicrosoftTeams
    https://www.powershellgallery.com/packages/MicrosoftTeams
    Please note, that the session timeout is broken and does currently not work as intended
    To help reconnect sessions, Assert-SkypeOnlineConnection can be used (Alias: pol) which runs Get-CsTenant to trigger the reconnect
    This will require additional authentication.
  .LINK
    Connect-Me
    Connect-SkypeOnline
    Connect-AzureAD
    Connect-MicrosoftTeams
    Assert-SkypeOnlineConnection
    Disconnect-Me
    Disconnect-SkypeOnline
    Disconnect-AzureAD
    Disconnect-MicrosoftTeams
  #>

  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false)]
    [string]$UserName,

    [Parameter(Mandatory = $false)]
    [AllowNull()]
    [string]$OverrideAdminDomain,

    [Parameter(Helpmessage = "Idle Timeout of the session in hours between 1 and 8; Default is 4")]
    [ValidateRange(1, 8)]
    [int]$IdleTimeout = 4
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    # Required as Warnings on the OriginalRegistrarPool may halt Script execution
    $WarningPreference = "Continue"

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"

    #region SessionOptions
    # Generating Session Options (Timeout) based on input
    $IdleTimeoutInMS = $IdleTimeout * 3600000
    if ($PSboundparameters.ContainsKey('IdleTimeout')) {
      $SessionOption = New-PSSessionOption -IdleTimeout $IdleTimeoutInMS
    }
    else {
      $SessionOption = New-PSSessionOption -IdleTimeout 14400000
    }
    Write-Verbose -Message "Idle Timeout for session established: $IdleTimeout hours"

    #endregion

    # Testing existing Module and Connection
    if (Test-Module SkypeOnlineConnector) {
      if ((Test-SkypeOnlineConnection) -eq $false) {
        $moduleVersion = (Get-Module -Name SkypeOnlineConnector -WarningAction SilentlyContinue).Version
        Write-Verbose -Message "Module SkypeOnlineConnector installed in Version: $moduleVersion"
        if ($moduleVersion.Major -le "6") {
          # Version 6 and lower do not support MFA authentication for Skype Module PowerShell; also allows use of older PSCredential objects
          try {
            $SkypeOnlineSession = New-CsOnlineSession -Credential (Get-Credential $UserName -Message "Enter the sign-in address and password of a Global or Skype for Business Admin") -ErrorAction STOP
            Import-Module (Import-PSSession -Session $SkypeOnlineSession -AllowClobber -ErrorAction STOP) -Global
          }
          catch {
            $errorMessage = $_
            if ($errorMessage -like "*Making sure that you have used the correct user name and password*") {
              Write-Warning -Message "Logon failed. Please try again and make sure that you have used the correct user name and password."
            }
            elseif ($errorMessage -like "*Please create a new credential object*") {
              Write-Warning -Message "Logon failed. This may be due to multi-factor being enabled for the user account and not using the latest Skype for Business Online PowerShell module."
            }
            else {
              Write-Warning -Message $_
            }
          }
        }
        else {
          # This should be all newer version than 6; does not support PSCredential objects but supports MFA
          try {
            # Constructing Parameters to be passed to New-CsOnlineSession
            Write-Verbose -Message "Constructing parameter list to be passed on to New-CsOnlineSession"
            $Parameters = $null
            if ($PSBoundParameters.ContainsKey("UserName")) {
              #TODO Check whether New-CsOnlineSession has a Parameter called UserName. What to do if not!
              Write-Verbose -Message "Adding: Username: $Username"
              $Parameters += @{'UserName' = $UserName }
            }
            if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
              Write-Verbose -Message "OverrideAdminDomain: Provided: $OverrideAdminDomain"
              $Parameters += @{'OverrideAdminDomain' = $OverrideAdminDomain }
            }
            else {
              $UserNameDomain = $UserName.Split('@')[1]
              $Parameters += @{'OverrideAdminDomain' = $UserNameDomain }

            }
            Write-Verbose -Message "Adding: SessionOption with IdleTimeout $IdleTimeout (hrs)"
            $Parameters += @{'SessionOption' = $SessionOption }
            Write-Verbose -Message "Adding: Common Parameters"
            $Parameters += @{'ErrorAction' = 'STOP' }
            $Parameters += @{'WarningAction' = 'Continue' }

            # Creating Session
            Write-Verbose -Message "Creating Session with New-CsOnlineSession and these parameters: $($Parameters.Keys)"
            $SkypeOnlineSession = New-CsOnlineSession @Parameters
          }
          catch [System.Net.WebException] {
            try {
              Write-Warning -Message "Session could not be created. Maybe missing OverrideAdminDomain to connect?"
              $Domain = Read-Host "Please enter an OverrideAdminDomain for this Tenant"
              # $Parameters +=@{'OverrideAdminDomain' = $Domain} # This works only if no OverrideAdminDomain is yet in the $Parameters Array. Current config means it will be there!
              $Parameters.OverrideAdminDomain = $Domain
              # Creating Session (again)
              Write-Verbose -Message "Creating Session with New-CsOnlineSession and these parameters: $($Parameters.Keys)"
              $SkypeOnlineSession = New-CsOnlineSession @Parameters
            }
            catch {
              Write-Error -Message "Session creation failed" -Category NotEnabled -RecommendedAction "Please verify input, especially Password, OverrideAdminDomain and, if activated, Azure AD Privileged Identity Management Role activation"
              Write-ErrorRecord $_
            }
          }
          catch {
            Write-Error -Message "Session creation failed" -Category NotEnabled -RecommendedAction "Please verify input, especially Password, OverrideAdminDomain and, if activated, Azure AD Privileged Identity Management Role activation"
            Write-ErrorRecord $_
          }

          # Separated session creation from Import for better troubleshooting
          if ($Null -ne $SkypeOnlineSession) {
            try {
              Import-Module (Import-PSSession -Session $SkypeOnlineSession -AllowClobber -ErrorAction STOP) -Global
              $null = Enable-CsOnlineSessionForReconnection
            }
            catch {
              Write-Verbose -Message "Session import failed - Error for troubleshooting" -Verbose
              Write-ErrorRecord $_
            }

            #region For v7 and higher: run Enable-CsOnlineSessionForReconnection
            if (Test-SkypeOnlineConnection) {
              $moduleVersion = (Get-Module -Name SkypeOnlineConnector -WarningAction SilentlyContinue).Version
              Write-Verbose -Message "SkypeOnlineConnector Module is installed in Version $ModuleVersion" -Verbose
              Write-Verbose -Message "Your Session will time out after $IdleTimeout hours" -Verbose
              if ($moduleVersion.Major -ge "7") {
                # v7 and higher can run Session Limit Extension
                try {
                  Enable-CsOnlineSessionForReconnection -WarningAction SilentlyContinue -ErrorAction STOP
                  Write-Verbose -Message "Enable-CsOnlineSessionForReconnection was run; The session should reconnect, allowing it to be re-used without having to launch a new instance to reconnect." -Verbose
                }
                catch {
                  Write-ErrorRecord $_
                }
              }
              else {
                Write-Verbose -Message "Enable-CsOnlineSessionForReconnection is unavailable; To prevent having to re-authenticate, Update this module to v7 or higher" -Verbose
                Write-Verbose -Message "You can download the Module here: https://www.microsoft.com/download/details.aspx?id=39366" -Verbose
              }
            }
            #endregion
          }
        } # End of if statement for module version checking
      }
      else {
        Write-Warning -Message "A valid Skype Online PowerShell Sessions already exists. Please run Disconnect-SkypeOnline before attempting this command again."
      } # End checking for existing Skype Online Connection
    }
    else {
      Write-Warning -Message "Skype Online PowerShell Connector module is not installed. Please install and try again."
      Write-Warning -Message "The module can be downloaded here: https://www.microsoft.com/en-us/download/details.aspx?id=39366"
    } # End of testing module existence
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Connect-SkypeOnline
