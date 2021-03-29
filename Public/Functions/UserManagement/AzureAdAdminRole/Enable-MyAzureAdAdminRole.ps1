# Module:   TeamsFunctions
# Function: Testing
# Author:		David Eberhardt
# Updated:  13-MAR-2021
# Status:   Live




function Enable-MyAzureAdAdminRole {
  <#
	.SYNOPSIS
		Activates Azure Ad Admin Roles for currently connected User
	.DESCRIPTION
		Activates Azure Active Directory Privileged Identity Management Admin Roles for the currently connected User.
    Requires a Connection to AzureAd
	.EXAMPLE
		Enable-MyAzureAdAdminRole
  .INPUTS
    None
  .OUTPUTS
    System.Void - If executed from shell
    Boolean - If called by other CmdLets
  .COMPONENT
    UserManagement
	.FUNCTIONALITY
    Enables eligible Privileged Identity roles for Administration of Teams for the currently connected on User
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_UserManagement
  .LINK
    Connect-Me
  .LINK
    Assert-MicrosoftTeamsConnection
  .LINK
    Enable-AzureAdAdminRole
  .LINK
    Enable-MyAzureAdAdminRole
  .LINK
    Get-AzureAdAdminRole
  .LINK
    Get-MyAzureAdAdminRole
	#>

  [CmdletBinding()]
  [Alias('ear')]
  [OutputType([Boolean])]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    try {
      $PIMavailable = Get-Command -Name 'Get-AzureADMSPrivilegedRoleAssignment' -ErrorAction Stop
      #region Activating Admin Roles
      if ( $PIMavailable ) {
        try {
          $AzureAdFeedback = Get-AzureADCurrentSessionInfo
          $ActivatedRoles = Enable-AzureAdAdminRole -Identity $AzureAdFeedback.Account -PassThru -Force -ErrorAction Stop #(default should only enable the Teams ones? switch?)
          if ( $ActivatedRoles.Count -gt 0 ) {
            return $(if ($Called) { $ActivatedRoles } else {
                Write-Information "Enable-MyAzureAdAdminrole - $($ActivatedRoles.Count) Roles activated." -InformationAction Continue
                Write-Output $ActivatedRoles
              })
          }
          else {
            #TEST Query active roles with GET and feed these back! (Direct Assignments)
            return $(if ($Called) { $ActivatedRoles } else {
                Write-Information 'Enable-MyAzureAdAdminrole - No Roles activated, the following roles are active' -InformationAction Continue
                Get-MyAzureAdAdminRole
              })
          }
        }
        catch {
          return $(if ($Called) { $false } else {
              if ($_.Exception.Message -contains 'The following policy rules failed: ["MfaRule"]') {
                Write-Information 'Enable-MyAzureAdAdminrole - No valid authentication via MFA is present. Please authenticate again and retry' -InformationAction Continue
              }
              else {
                Write-Information 'Enable-MyAzureAdAdminrole - Privileged Identity Management is not enabled for this tenant' -InformationAction Continue
              }
            })
        }
      }
      else {
        return $(if ($Called) { $false } else {
            Write-Information 'Enable-MyAzureAdAdminrole - Privileged Identity Management is not enabled for this tenant' -InformationAction Continue
          })
      }
      #endregion
    }
    catch {
      return $(if ($Called) { $false } else {
          Write-Information 'Enable-MyAzureAdAdminrole - Privileged Identity Management functions are not available' -InformationAction Continue
        })
    }
  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Enable-MyAzureAdAdminRole
