# Module:     TeamsFunctions
# Function:   UserAdmin
# Author:    David Eberhardt
# Updated:    01-SEP-2020
# Status:     Live


#TODO Add Eligible Groups

function Get-AzureAdAdminRole {
  <#
  .SYNOPSIS
    Queries Admin Roles assigned to an Object
  .DESCRIPTION
    Azure Active Directory Admin Roles assigned to an Object
    Requires a Connection to AzureAd
    Querying '-Type Elibile' requires the Module AzureAdPreview installed
  .PARAMETER Identity
    Required. One or more UserPrincipalNames of the Office365 Administrator
  .PARAMETER Type
    Optional. Switches query to Active (Default) or Eligible Admin Roles
    Eligibility can only be queried with Module AzureAdPreview installed
  .EXAMPLE
    Get-AzureAdAdminRole [-Identity] user@domain.com [-Type Active]
    Returns all active Admin Roles for the provided Identity
  .EXAMPLE
    Get-AzureAdAdminRole [-Identity] user@domain.com -Type Eligible
    Returns all eligible Admin Roles for the provided Identity
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Returns an Object containing all Admin Roles assigned to a User.
    This is intended as an informational for the User currently connected to a specific PS session (whoami and whatcanido)
    The Output can be used as baseline for other functions (-contains "Teams Service Admin")
  .COMPONENT
    UserManagement
  .FUNCTIONALITY
    Queries active or eligible Privileged Identity roles for Administration of Teams
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_UserManagement
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
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Enter the identity of the User to Query')]
    [Alias('UserPrincipalName', 'ObjectId')]
    [string]$Identity,

    [Parameter(HelpMessage = 'Active, Eligible')]
    [ValidateSet('Active', 'Eligible')]
    #[ValidateSet('Active', 'Eligible','Group')]
    [string]$Type = 'Active'

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    #R#equires -Modules @{ ModuleName="AzureADpreview"; ModuleVersion="2.0.2.24" }
    if ($Type -eq 'Eligible') {
      #TODO To be removed once AzureAd is updated containing the PIM functions and made part of the Requirements for this Module
      try {
        Write-Verbose -Message "Removing Module 'AzureAd', Importing Module 'AzureAdPreview'"
        $SaveVerbosePreference = $global:VerbosePreference;
        $global:VerbosePreference = 'SilentlyContinue';
        Remove-Module AzureAd -Force -ErrorAction SilentlyContinue
        Import-Module AzureAdPreview -Global -Force -ErrorAction Stop
        $global:VerbosePreference = $SaveVerbosePreference
      }
      catch {
        Write-Error -Message 'Module AzureAdPreview not present or failed to import. Please make sure the Module is installed'
        return
      }

      # Importing all Roles
      Write-Verbose -Message 'Querying Azure Privileged Role Definitions'
      try {
        $ProviderId = 'aadRoles'
        $ResourceId = (Get-AzureADCurrentSessionInfo).TenantId
        $AllRoles = Get-AzureADMSPrivilegedRoleDefinition -ProviderId $ProviderId -ResourceId $ResourceId -ErrorAction Stop
      }
      catch {
        if ($_.Exception.Message.Contains('The tenant needs an AAD Premium 2 license')) {
          Write-Error -Message 'Cannot query role definitions. AzureAd Premium License Required' -ErrorAction Stop
        }
        else {
          Write-Error -Message "Cannot query role definitions. Exception: $($_.Exception.Message)" -ErrorAction Stop
        }
      }

    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($Id in $Identity) {
      #TODO replace Id with $AzureAdUser.UserPrincipalName and 'User' with 'UserPrincipalName' for more consistency.
      $AzureAdUser = Get-AzureADUser -ObjectId "$Id"

      [System.Collections.ArrayList]$MyRoles = @()

      switch ($Type) {
        'Active' {
          $MyMemberships = Get-AzureADUserMembership -ObjectId $AzureAdUser.ObjectId #-All $true #CHECK Test Performance and reliability without "all!"
          $ActiveRoles = $MyMemberships | Where-Object ObjectType -EQ Role

          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "Function: $($MyInvocation.MyCommand.Name) - ActiveRoles", ( $ActiveRoles | Format-List | Out-String).Trim() | Write-Debug
          }

          #Output
          if ( -not $ActiveRoles ) {
            Write-Warning -Message 'No active, direct assignments found. This user may be eligible for activating Admin Role access through Group assignment or Privileged Admin Groups'
            Write-Verbose -Message "Membership of Group assignments or Privileged Admin Groups is currently not queried by $($MyInvocation.MyCommand)" -Verbose
          }

          foreach ($R in $ActiveRoles) {
            # Preparing Output object
            $Role = @()
            $Role = [PsCustomObject][ordered]@{
              'User'            = $Id
              'Rolename'        = $R.DisplayName
              'Type'            = 'Direct' # This may be different once we incorporate Groups too!
              'ActiveSince'     = ''
              'ActiveUntil'     = ''
              'AssignmentState' = 'Active'
            }

            [void]$MyRoles.Add($Role)
          }

        }
        'Eligible' {
          $SubjectId = $AzureAdUser.ObjectId
          $MyPrivilegedRoles = Get-AzureADMSPrivilegedRoleAssignment -ProviderId $ProviderId -ResourceId $ResourceId -Filter "subjectId eq '$SubjectId'"

          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "Function: $($MyInvocation.MyCommand.Name) - MyPrivilegedRoles", ( $MyPrivilegedRoles | Format-List | Out-String).Trim() | Write-Debug
          }

          foreach ($R in $MyPrivilegedRoles) {
            # Querying Role Display Name
            $RoleObject = $AllRoles | Where-Object { $_.Id -eq $R.RoleDefinitionId }
            # Preparing Output object
            $Role = @()
            $Role = [PsCustomObject][ordered]@{
              'User'            = $Id
              'Rolename'        = $RoleObject.DisplayName
              'Type'            = $R.MemberType
              'ActiveSince'     = $R.StartDateTime
              'ActiveUntil'     = $R.EndDateTime
              'AssignmentState' = $R.AssignmentState
            }

            [void]$MyRoles.Add($Role)
          }

        }
      }

      Write-Output $MyRoles

    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-AzureAdAdminRole
