# Module:   TeamsFunctions
# Function: Session
# Author:		Andrés Gorzelany
# Updated:  19-JAN-2021
# Status:   Live




function Enable-CsOnlineSessionForReconnection {
  <#
  .SYNOPSIS
    Enables the Skype Online Session to reconnect
  .DESCRIPTION
    Enables the Skype Online Session to reconnect
  .EXAMPLE
    Enable-CsOnlineSessionForReconnection
    Enables the Skype Online Session to reconnect
  .INPUTS
    None
  .OUTPUTS
    None
  .NOTES
    With special thanks to Andres for providing the code for this wonderful command
  .COMPONENT
    Session
  .ROLE
    Session Reconnection
  .FUNCTIONALITY
    Enables the Skype Online Session to reconnect
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Enable-CsOnlineSessionForReconnection
  .LINK
    Connect-SkypeOnline
  #>

  [CmdletBinding()]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

  } #begin

  process {

    $global:CsOnlineSessionInputParams = $UserCredential
    $modules = Get-Module tmp_*
    $csModuleUrl = '/OcsPowershellOAuth'
    $isSfbPsModuleFound = $false;

    foreach ($module in $modules) {
      [string] $moduleUrl = $module.Description
      [int] $queryStringIndex = $moduleUrl.IndexOf('?')

      if ($queryStringIndex -gt 0) {
        $moduleUrl = $moduleUrl.SubString(0, $queryStringIndex)
      }

      if ($moduleUrl.Contains($csModuleUrl)) {
        $isSfbPsModuleFound = $true
        & $module { ${function:Get-PSImplicitRemotingSession} = `
          {
            param(
              [Parameter(Mandatory = $true, Position = 0)]
              [string]
              $commandName
            )

            if (($null -eq $script:PSSession) -or ($script:PSSession.Runspace.RunspaceStateInfo.State -ne 'Opened')) {
              Set-PSImplicitRemotingSession `
              (& $script:GetPSSession `
                  -InstanceId $script:PSSession.InstanceId.Guid `
                  -ErrorAction SilentlyContinue )
            }
            if (($null -ne $script:PSSession) -and ($script:PSSession.Runspace.RunspaceStateInfo.State -eq 'Disconnected')) {
              # If we are handed a disconnected session, try re-connecting it before creating a new session.
              Set-PSImplicitRemotingSession `
              (& $script:ConnectPSSession `
                  -Session $script:PSSession `
                  -ErrorAction SilentlyContinue)
            }
            if (($null -eq $script:PSSession) -or ($script:PSSession.Runspace.RunspaceStateInfo.State -ne 'Opened')) {
              Write-PSImplicitRemotingMessage ('Recreating a new remote powershell session (implicit) for command: "{0}" ...' -f $commandName)

              if ((Test-Path variable:global:CsOnlineSessionInputParams) -ne $true) {
                throw 'Unable find input parameters from global scope, will not be able to recreate session'
              }

              if ((Test-Path variable:global:CsOnlineSessionRetryAttempt) -ne $true) {
                $global:CsOnlineSessionRetryAttempt = 1
              }
              else {
                $global:CsOnlineSessionRetryAttempt = $global:CsOnlineSessionRetryAttempt + 1
              }

              $session = New-CsOnlineSession -Credential @global:CsOnlineSessionInputParams

              if ($null -ne $session) {
                Set-PSImplicitRemotingSession -CreatedByModule $true -PSSession $session
              }

              #note - this magic string has to be same as above, search for this string above, it will become clear
              #because this will be in callback handler, I am not putting this into const variable
              $sfbPsSessionPrefix = 'SfBPowerShellSession_'
              #sessions originally created will have the below one
              $sfbPsSessionRegEx1 = $sfbPsSessionPrefix + '*'
              #sessions created later will get their name changed by powershell during Set-PSImplicitRemotingSession
              #and so it will have names like "Session for implicit remoting module at C:\Users\<user>\AppData\Local\Temp\tmp_tsdvdhga.20e\tmp_tsdvdhga.20e.psm1"
              #tmp_tsdvdhga.20e being the module name
              $sfbPsSessionRegEx2 = Get-PSImplicitRemotingModuleName
              $sfbPsSessionRegEx2 = '*' + $sfbPsSessionRegEx2 + '*'
              #delete broken sessions - begin
              $psBroken = Get-PSSession | Where-Object { ($_.Name -like $sfbPsSessionRegEx1 -or $_.Name -like $sfbPsSessionRegEx2) -and $_.State -like '*Broken*' }
              $psClosed = Get-PSSession | Where-Object { ($_.Name -like $sfbPsSessionRegEx1 -or $_.Name -like $sfbPsSessionRegEx2) -and $_.State -like '*Closed*' }

              $psBroken | Remove-PSSession;
              $psClosed | Remove-PSSession;
              #delete broken sessions - end
            }
            if (($null -eq $script:PSSession) -or ($script:PSSession.Runspace.RunspaceStateInfo.State -ne 'Opened')) {
              throw 'No session has been associated with this implicit remoting module'
            }

            return [Management.Automation.Runspaces.PSSession]$script:PSSession
          }
        }
      }
    }

  }

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Enable-CsOnlineSessionForReconnection
