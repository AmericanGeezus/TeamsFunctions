# Module:     TeamsFunctions
# Function:   UserAdmin
# Author:     David Eberhardt
# Updated:    20-DEC-2020
# Status:     Beta


#TODO: Currently EnableAll is on by default - needs filtering to specific Ids (6 Teams ones)
#TODO: Privileged Admin Groups buildout
function Enable-AzureAdAdminRole {
  <#
  .SYNOPSIS
    Enables eligible Admin Roles
  .DESCRIPTION
    Azure Ad Privileged Identity Management can require you to activate Admin Roles.
    Eligibe roles or groups can be activated with this Command
  .PARAMETER Identity
    Username of the Admin Account to enable roles for
  .PARAMETER Reason
    Optional. Small statement why these roles are requested
    By default, "admin" is used as the reason.
  .PARAMETER EnableAll
    By default, enables only Roles required to Administer Teams
    These are: Lync Administrator, User Administrator, License Administrator,
    Teams Communications Administrator, Teams Service Administrator
    This switch, when used, tries to enable all found admin role
  .PARAMETER Duration
     Optional. Integer. By default, enables Roles for 4 hours.
    Depending on your Administrators settings, values between 1 and 24 hours can be specified
  .PARAMETER TicketNr
    Optional. Integer. Only used if provided
    Depending on your Administrators settings, a ticket number may be required to process the request
  .PARAMETER ProviderId
    Optional. Default is 'aadRoles' for the ProviderId, however, this script could also be used for activating
    Azure Resources ('azureResources'). Use with Confirm and EnableAll.
  .PARAMETER PassThru
    Optional. Displays output object for each activated Role
    Used for further processing to verify command was successful
  .EXAMPLE
    Enable-AzureAdAdminRole John@domain.com
    Enables all eligible Teams Admin roles for User John@domain.com
  .EXAMPLE
    Enable-AzureAdAdminRole John@domain.com -EnableAll -Reason "Need to provision Users" -Duration 4
    Enables all eligible Admin roles for User John@domain.com with the reason provided.
  .EXAMPLE
    Enable-AzureAdAdminRole John@domain.com -EnableAll -ProviderId azureResources -Confirm
    Enables all eligible Azure Resources for User John@domain.com with confirmation for each Resource.
  .INPUTS
    System.String
  .OUTPUTS
    None
  .NOTES
    Limitations: MFA must be authorised first
    Currently no way to trigger it via PowerShell. If the activation fails, please sign into Office.com
    Once Authorised, this command can be used to activate your eligible Admin Roles.
    AzureResources provider activation is not yet tested.
  .COMPONENT
    UserAdmin
  .ROLE
    Activating Admin Roles
  .FUNCTIONALITY
    Enables eligible Privileged Identity roles for Administration of Teams
  .LINK
    Enable-AzureAdAdminRole
    Get-AzureAdAssignedAdminRoles
  #>

  [CmdletBinding()]
  [OutputType([Void])]

  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Enter the identity of the Admin Account")]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string]$Identity,

    [Parameter(HelpMessage = "Optional Reason for the request")]
    [string]$Reason,

    [Parameter(HelpMessage = "Integer in hours to activate role(s) for")]
    [int]$Duration,

    [Parameter(HelpMessage = "Ticket Number for use to provide to the request")]
    [int]$TicketNr,

    [Parameter(HelpMessage = "Enables all eligible roles")]
    [switch]$EnableAll,

    [Parameter(HelpMessage = "Azure ProviderId to be used")]
    [ValidateSet('aadRoles', 'azureResources')]
    [string]$ProviderId = 'aadRoles',

    [Parameter(HelpMessage = "Displays output of activated roles to verify")]
    [switch]$PassThru

  ) #param

  begin {
    Show-FunctionStatus -Level Beta
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    #Requires -Modules @{ ModuleName="AzureADpreview"; ModuleVersion="2.0.2.24" }

    # preparing Splatting Object
    $Parameters = $null

    #region Supporting Parameters
    # Duration
    if ( -not $Duration ) {
      [int]$Duration = 4
      # Duration is used in $Schedule
    }

    # Reason & Ticket Number
    if ( -not $Reason ) { $Reason = "Admin" }
    if ( $TicketNr ) { $Reason = "Ticket: $TicketNumber - $Reason" }
    $Parameters += @{'Reason' = $Reason }

    # ProviderId is hardcoded (or overridden by providing a value)
    Write-Verbose -Message "Using Azure Provider Id"
    $Parameters += @{'ProviderId' = $ProviderId }

    # ResourceId - is the Tenant Id
    Write-Verbose -Message "Querying Azure Tenant Id"
    $ResourceId = (Get-AzureADCurrentSessionInfo).TenantId
    $Parameters += @{'ResourceId' = $ResourceId }

    # Assignment state is always Active - This will change for the Disable command
    $Parameters += @{'AssignmentState' = 'Active' }

    # Importing all Roles
    Write-Verbose -Message "Querying Azure Privileged Role Definitions"
    $AllRoles = Get-AzureADMSPrivilegedRoleDefinition -ProviderId $ProviderId -ResourceId $ResourceId

    # Defining Schedule
    Write-Verbose -Message "Creating Schedule based on Duration: $Duration hours"
    $Date = Get-Date
    $start = $Date.ToUniversalTime()
    $end = $Date.AddHours($Duration).ToUniversalTime()

    $schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
    $schedule.Type = "Once"
    $schedule.StartDateTime = $start.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $schedule.endDateTime = $end.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    # To increase usability, we could could try 8 then 4 not successful

    if ($PSBoundParameters.ContainsKey('Debug')) {
      "Function: $($MyInvocation.MyCommand.Name)", ($schedule | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }
    Write-Output -Message "Admin Roles will be active for $Duration hours, until: $($end.ToString())"
    $Parameters += @{'Schedule' = $schedule }
    #endregion

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($Id in $Identity) {
      # Querying User Account
      Write-Verbose -Message "Processing User '$Id'"
      try {
        $SubjectId = (Get-AzureADUser -ObjectId "$Id" -WarningAction SilentlyContinue -ErrorAction STOP).ObjectId

        if ($PSBoundParameters.ContainsKey('Debug')) {
          "Function: $($MyInvocation.MyCommand.Name)", ( $SubjectId | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }

        # Adding SubjectId to Parameters
        if ($Parameters.SubjectId) {
          $Parameters.SubjectId = $SubjectId
        }
        else {
          $Parameters += @{'SubjectId' = $SubjectId }
        }
      }
      catch {
        Write-Error -Message "User Account not valid" -Category ObjectNotFound -RecommendedAction "Verify Identity/UserPrincipalName"
        continue
      }

      # Query current Admin Roles
      $MyRoles = Get-AzureADMSPrivilegedRoleAssignment -ProviderId $ProviderId -ResourceId $ResourceId -Filter "subjectId eq '$SubjectId'"
      $MyActiveRoles = $MyRoles | Where-Object AssignmentState -EQ "Active"
      Write-Verbose -Message "User '$Id' has currently $($MyActiveRoles.Count) of $($MyRoles.Count) activated" -Verbose


      # Eligibile Roles
      $MyEligibleRoles = $MyRoles | Where-Object AssignmentState -EQ "Eligible"
      if ($MyEligibleRoles.Count -eq 0) {
        Write-Warning -Message "User '$Id' has currently no eligible Roles available!"
        Write-Verbose -Message "User '$Id' may have Privileged Access Groups that can be activated." -Verbose
        #Capture no eligible Roles - Navigate Groups here?

        Write-Verbose -Message "This has not yet been implemented. Sorry. Script will stop here." -Verbose
        Continue
      }

      # Activating Role
      [System.Collections.ArrayList]$ActivatedRoles = @()

      foreach ($R in $MyEligibleRoles) {
        # Querying Role Display Name
        $RoleName = $AllRoles | Where-Object { $_.Id -eq $R.RoleDefinitionId } | Select-Object -ExpandProperty DisplayName

        # Preparing Output object
        $ActivatedRole = @()
        $ActivatedRole = [PsCustomObject][ordered]@{
          'User'           = $Id
          'Rolename'       = $RoleName
          'ActivationType' = $null
          'Active until'   = $null
        }

        # Adding Role Definition Id
        if ($Parameters.RoleDefinitionId) {
          $Parameters.RoleDefinitionId = $R.RoleDefinitionId
        }
        else {
          $Parameters += @{'RoleDefinitionId' = $R.RoleDefinitionId }
        }

        # Determining Activation Type (UserAdd VS UserRenew)
        <#
        The request type. Required.
        The value can be AdminAdd, UserAdd, AdminUpdate, AdminRemove, UserRemove, UserExtend, UserRenew, AdminRenew and AdminExtend.
        #CHECK which value is suitable to a) enable  b) extend  c) deactivate the respective role!
        Currently, UserAdd and UserRenew are used - If renew works, the duration may be able to be scrapped (hardcoded) alltogether
        Role will be activated every hour for another 4 hour period.
        #>
        if ( $R.RoleDefinitionId -in $MyActiveRoles.Id) {
          Write-Verbose -Message "User '$Id' - Role '$RoleName' is already active and will be renewed"
          $ActivatedRole.Type = 'UserRenew'
          if ($Parameters.Type) {
            $Parameters.Type = 'UserRenew'
          }
          else {
            $Parameters += @{'Type' = 'UserRenew' }
          }
        }
        else {
          Write-Verbose -Message "User '$Id' - Role '$RoleName' is currently not active and will be activated"
          $ActivatedRole.Type = 'UserAdd'
          if ($Parameters.Type) {
            $Parameters.Type = 'UserAdd'
          }
          else {
            $Parameters += @{'Type' = $UserAdd }
          }
        }

        #Activating the Role
        Write-Verbose "User '$Id' - Activating Role: '$RoleName'" -Verbose
        #Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId $ProviderId -ResourceId $ResourceId -RoleDefinitionId $R.RoleDefinitionId -SubjectId $SubjectId -Type 'UserAdd' -AssignmentState 'Active' -Schedule $schedule -Reason $Reason
        if ($PSBoundParameters.ContainsKey('Debug')) {
          "Function: $($MyInvocation.MyCommand.Name) - Parameters for Open-AzureADMSPrivilegedRoleAssignmentRequest", ( $Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }

        #TODO Add ShouldProcess and Confirm decision here!
        #CHECK output of Command?
        Open-AzureADMSPrivilegedRoleAssignmentRequest @Parameters

        [void]$ActivatedRoles.Add($ActivatedRole)
      }

      # Re-Query and output
      if ( $PassThru ) {
        Write-Verbose -Message "User '$Id' - Activated Roles:" -Verbose
        $ActivatedRoles | Format-Table -AutoSize

        # Can probably be removed
        Write-Verbose -Message "Querying current assignments"
        $MyRoles = Get-AzureADMSPrivilegedRoleAssignment -ProviderId $ProviderId -ResourceId $ResourceId -Filter "subjectId eq '$SubjectId'"
        $MyActiveRoles = $MyRoles | Where-Object AssignmentState -EQ "Active"
        Write-Verbose -Message "User '$Id' has now $($MyActiveRoles.Count) of $($MyRoles.Count) activated" -Verbose

      }

    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Enable-AzureAdAdminRole
