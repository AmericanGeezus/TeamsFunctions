# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   PreLive




function Find-TeamsUserVoiceConfig {
  <#
	.SYNOPSIS
		Displays User Accounts matching a specific Voice Configuration Parameter
	.DESCRIPTION
    Returns UserPrincipalNames of Objects matching specific parameters. For PhoneNumbers also displays their basic Voice Configuration
    Search parameters are mutually exclusive, only one Parameter can be specified at the same time.
    Available parameters are:
    - PhoneNumber: Part of the LineURI (ideally without 'tel:','+' or ';ext=...')
    - ConfigurationType: 'CallPlans' or 'DirectRouting'. Will deliver partially configured accounts as well.
    - VoicePolicy: 'BusinessVoice' (CallPlans) or 'HybridVoice' (DirectRouting or any other Hybrid PSTN configuration)
    - OnlineVoiceRoutingPolicy: Any string value (incl. $Null), but not empty ones.
    - TenantDialPlan: Any string value (incl. $Null), but not empty ones.
  .PARAMETER Identity
    Optional. UserPrincipalName (UPN) of the User
    Behaves like Get-TeamsUserVoiceConfig, displaying the Users Voice Configuration
	.PARAMETER PhoneNumber
    Optional. Searches all Users matching the given String in their LineURI.
    The expected ResultSize is limited, the full Object is displayed (Get-TeamsUserVoiceConfig)
    Please see NOTES for details
	.PARAMETER ConfigurationType
    Optional. Searches all enabled Users which are at least partially configured for 'CallingPlans', 'DirectRouting' or 'SkypeHybridPSTN'.
    The expected ResultSize is big, therefore only UserPrincipalNames are returned
    Please see NOTES for details
	.PARAMETER VoicePolicy
    Optional. Searches all enabled Users which are reported as 'BusinessVoice' or 'HybridVoice'.
    The expected ResultSize is big, therefore only UserPrincipalNames are returned
    Please see NOTES for details
	.PARAMETER OnlineVoiceRoutingPolicy
    Optional. Searches all enabled Users which have the OnlineVoiceRoutingPolicy specified assigned.
    Please specify full and correct name or '$null' to receive all Users without one
    The expected ResultSize is big, therefore only UserPrincipalNames are returned
    Please see NOTES for details
	.PARAMETER TenantDialPlan
    Optional. Searches all enabled Users which have the TenantDialPlan specified assigned.
    Please specify full and correct name or '$null' to receive all Users without one
    The expected ResultSize is big, therefore only UserPrincipalNames are returned
    Please see NOTES for details
	.PARAMETER ValidateLicense
    Optional. Can be combined only with -ConfigurationType
    In addition to validation of Parameters, also validates License assignment for the found user.
    License Check is performed AFTER parameters are verified.
	.EXAMPLE
    Find-TeamsUserVoiceConfig -Identity John@domain.com
    Shows Voice Configuration for John, returning the full Object
	.EXAMPLE
    Find-TeamsUserVoiceConfig -PhoneNumber "15551234567"
    Shows all Users which have this String in their LineURI (TelephoneNumber or OnPremLineURI)
    The expected ResultSize is limited, the full Object is returned (Get-TeamsUserVoiceConfig)
    Please see NOTES for details
	.EXAMPLE
    Find-TeamsUserVoiceConfig -ConfigurationType CallingPlans
    Shows all Users which are configured for CallingPlans (Full)
    The expected ResultSize is big, therefore only Names (UPNs) of Users are returned
    Pipe to Get-TeamsUserVoiceConfiguration for full output.
    Please see NOTES for details
  .EXAMPLE
    Find-TeamsUserVoiceConfig -VoicePolicy BusinessVoice
    Shows all Users which are configured for PhoneSystem with CallingPlans
    The expected ResultSize is big, therefore only Names (UPNs) of Users are displayed
    Pipe to Get-TeamsUserVoiceConfiguration for full output.
    Please see NOTES and LINK for details
  .EXAMPLE
    Find-TeamsUserVoiceConfig -OnlineVoiceRoutingPolicy O_VP_EMEA
    Shows all Users which have the OnlineVoiceRoutingPolicy "O_VP_EMEA" assigned
    The expected ResultSize is big, therefore only Names (UPNs) of Users are displayed
    Pipe to Get-TeamsUserVoiceConfiguration for full output.
    Please see NOTES for details
  .EXAMPLE
    Find-TeamsUserVoiceConfig -TenantDialPlan DP-US
    Shows all Users which have the TenantDialPlan "DP-US" assigned.
    Please see NOTES for details
  .INPUTS
    System.String
  .OUTPUTS
    String (UPN)  - With any Parameter except Identity or PhoneNumber
    System.Object - With Parameter Identity or PhoneNumber
  .NOTES
    With the exception of Identity and PhoneNumber, all searches are filtering on Get-CsOnlineUser
    This usually should not take longer than a minute to complete.
    Identity is querying the provided UPN and only wraps Get-TeamsUserVoiceConfig
    PhoneNumber has to do a full search with 'Where-Object' which will take time to complete
    Depending on the number of Users in the Tenant, this may take a few minutes!

    All Parameters except Identity or PhoneNumber will only return UPNs
    - PhoneNumber: Searches against the LineURI parameter. For best compatibility, provide in E.164 format (with or without the +)
    This script can find duplicate assignments if the Number was assigned with and without an extension.
    - ConfigurationType: This is determined with Test-TeamsUserVoiceConfig -Partial and will return all Accounts found
    - VoicePolicy: BusinessVoice are PhoneSystem Users exclusively configured for Microsoft Calling Plans.
      HybridVoice are PhoneSystem Users who are configured for TDR, Hybrid SkypeOnPrem PSTN or Hybrid CloudConnector PSTN breakouts
    - OnlineVoiceRoutingPolicy: Finds all users which have this particular Policy assigned
    - TenantDialPlan: Finds all users which have this particular DialPlan assigned.
    Please see Related Link for more information
	.FUNCTIONALITY
    Finding Users with a specific values in their Voice Configuration
  .LINK
    https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating
  .LINK
    Find-TeamsUserVoiceConfig
    Get-TeamsTenantVoiceConfig
    Get-TeamsUserVoiceConfig
    Set-TeamsUserVoiceConfig
    Remove-TeamsUserVoiceConfig
    Test-TeamsUserVoiceConfig
  #>

  [CmdletBinding(DefaultParameterSetName = "Tel")]
  [Alias('Find-TeamsUVC')]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(ParameterSetName = "ID")]
    [string]$Identity,

    [Parameter(ParameterSetName = "Tel", Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'String to be found in any of the PhoneNumber fields')]
    [Alias('Number', 'TelephoneNumber', 'Tel', 'LineURI', 'OnPremLineURI')]
    [string[]]$PhoneNumber,

    [Parameter(ParameterSetName = "CT", HelpMessage = 'Filters based on Configuration Type')]
    [ValidateSet('CallingPlans', 'SkypeHybridPSTN', 'DirectRouting')]
    [String]$ConfigurationType,

    [Parameter(ParameterSetName = "VP", HelpMessage = 'Filters based on VoicePolicy')]
    [ValidateSet('BusinessVoice', 'HybridVoice')]
    [String]$VoicePolicy,

    [Parameter(ParameterSetName = "OVP", HelpMessage = 'Filters based on OnlineVoiceRoutingPolicy')]
    [AllowNull()]
    [Alias('OVP')]
    [String]$OnlineVoiceRoutingPolicy,

    [Parameter(ParameterSetName = "TDP", HelpMessage = 'Filters based on TenantDialPlan')]
    [AllowNull()]
    [Alias('TDP')]
    [String]$TenantDialPlan,

    [Parameter(ParameterSetName = "CT", HelpMessage = 'Additionally also validates License (CallingPlan or PhoneSystem)')]
    [switch]$ValidateLicense

  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    if ($PSBoundParameters.ContainsKey('ValidateLicense')) {
      Write-Warning -Message "The switch 'ValidateLicense' verifies whether the correct license is assigned before considering the User. This increases run-time tremendously!"
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    switch ($PsCmdlet.ParameterSetName) {
      "ID" {
        Write-Verbose -Message "Finding Users with Identity '$Identity': Acting as an Alias to 'Get-TeamsUserVoiceConfig'" -Verbose
        Get-TeamsUserVoiceConfig $Identity

        break
      } #ID

      "Tel" {
        foreach ($Number in $PhoneNumber) {
          Write-Verbose -Message "Finding Users with PhoneNumber '$Number': This will take a bit of time!" -Verbose
          #Filter must be written as-is (Get-CsOnlineUser is an Online command, handover of parameters is sketchy)
          $Filter = 'LineURI -like "*{0}*"' -f $Number
          $Users = Get-CsOnlineUser -Filter $Filter -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Select-Object UserPrincipalName
          if ($Users) {
            if ($Users.Count -gt 1) {
              Write-Warning -Message "Number: '$Number' - Found multiple Users matching the criteria! If the search string represents a partial number, this is to be expected.`nIf the search string represents a FULL number, it is assigned incorrectly. Inbound calls to this number will not work as Teams will not find a unique match"
              Write-Verbose -Message "Investigate OnPremLineURI string. Has one of them set an Extension (';ext=') set, the other one not?" -Verbose
            }

            if ($Users.Count -gt 3) {
              Write-Verbose -Message "Multiple results found - Displaying UserPrincipalNames only" -Verbose
              $Users.UserPrincipalName
            }
            else {
              Write-Verbose -Message "Limited results found - Displaying User Voice Configuration for each" -Verbose
              Get-TeamsUserVoiceConfig $($Users.UserPrincipalName)
            }
          }
          else {
            Write-Verbose -Message "Number: '$Number' - No assignments found (LineURI)" -Verbose
          }
        }

        break
      } #Tel

      "CT" {
        Write-Verbose -Message "Finding all Users enabled for Teams: Searching... This will take quite some time!" -Verbose
        $Filter = 'Enabled -eq $TRUE'
        $CsUsers = Get-CsOnlineUser -Filter $Filter -WarningAction SilentlyContinue -ErrorAction Stop

        Write-Verbose -Message "Sifting through Information for $($CsUsers.Count) Users: Parsing..." -Verbose
        switch ($ConfigurationType) {
          "DirectRouting" {
            Write-Verbose -Message "Returning all Users that are correctly configured for DirectRouting... This will take a bit of time!" -Verbose
            if ($PSBoundParameters.ContainsKey('ValidateLicense')) {
              Write-Verbose -Message "Switch ValidateLicense: Only users with PhoneSystem license are displayed!" -Verbose
            }
            foreach ($U in $CsUsers) {
              if ($U.VoicePolicy -eq "HybridVoice" -and $null -eq $U.VoiceRoutingPolicy -and ($null -ne $U.OnPremLineURI -or $null -ne $U.OnlineVoiceRoutingPolicy)) {
                if ($PSBoundParameters.ContainsKey('ValidateLicense')) {
                  if (Test-TeamsUserLicense $U -ServicePlan MCOEV) {
                    $U.UserPrincipalName
                  }
                }
                else {
                  $U.UserPrincipalName
                }
              }
            }

            break
          }

          "SkypeHybridPSTN" {
            Write-Verbose -Message "Returning all Users that are correctly configured for SkypeHybridPSTN... This will take a bit of time!" -Verbose
            if ($PSBoundParameters.ContainsKey('ValidateLicense')) {
              Write-Verbose -Message "Switch ValidateLicense: Only users with PhoneSystem license are displayed!" -Verbose
            }
            foreach ($U in $CsUsers) {
              if ($U.VoicePolicy -eq "HybridVoice" -and $null -eq $U.OnlineVoiceRoutingPolicy -and ($null -ne $U.OnPremLineURI -or $null -ne $U.VoiceRoutingPolicy)) {
                if ($PSBoundParameters.ContainsKey('ValidateLicense')) {
                  if (Test-TeamsUserLicense $U -ServicePlan MCOEV) {
                    $U.UserPrincipalName
                  }
                }
                else {
                  $U.UserPrincipalName
                }
              }

              break
            }
          }

          "CallingPlans" {
            Write-Verbose -Message "Returning all Users that are correctly configured for CallingPlans... This will take a bit of time!" -Verbose
            if ($PSBoundParameters.ContainsKey('ValidateLicense')) {
              Write-Verbose -Message "Switch ValidateLicense: Only users with CallPlan license are displayed!" -Verbose
            }
            foreach ($U in $CsUsers) {
              if ($U.VoicePolicy -eq "BusinessVoice" -or $null -ne $U.TelephoneNumber) {
                if ($PSBoundParameters.ContainsKey('ValidateLicense')) {
                  if (Test-TeamsUserHasCallPlan $U) {
                    $U.UserPrincipalName
                  }
                }
                else {
                  $U.UserPrincipalName
                }
              }
            }

            break
          }
        }

        break
      } #CT

      "VP" {
        Write-Verbose -Message "Finding Users with VoicePolicy '$VoicePolicy': Searching... This will take a bit of time!" -Verbose
        $Filter = 'Enabled -eq $TRUE -and  VoicePolicy -EQ "{0}"' -f $VoicePolicy
        Get-CsOnlineUser -Filter $Filter -WarningAction SilentlyContinue | Select-Object UserPrincipalName

        break
      } #VP

      "OVP" {
        Write-Verbose -Message "Finding OnlineVoiceRoutingPolicy '$OnlineVoiceRoutingPolicy': Searching... This will take a bit of time!" -Verbose
        $OVP = Get-CsOnlineVoiceRoutingPolicy $OnlineVoiceRoutingPolicy -WarningAction SilentlyContinue
        if ($null -ne $OVP) {
          Write-Verbose -Message "Finding Users with OnlineVoiceRoutingPolicy '$OnlineVoiceRoutingPolicy': Searching..." -Verbose
          $Filter = 'Enabled -eq $TRUE -and  OnlineVoiceRoutingPolicy -EQ "{0}"' -f $OnlineVoiceRoutingPolicy
          Get-CsOnlineUser -Filter $Filter -WarningAction SilentlyContinue | Select-Object UserPrincipalName
        }
        else {
          Write-Error -Message "OnlineVoiceRoutingPolicy '$OnlineVoiceRoutingPolicy' not found" -Category ObjectNotFound -ErrorAction Stop
        }

        break
      } #OVP

      "TDP" {
        Write-Verbose -Message "Finding TenantDialPlan '$TenantDialPlan': Searching... This will take a bit of time!" -Verbose
        $TDP = Get-CsTenantDialPlan $TenantDialPlan -WarningAction SilentlyContinue
        if ($null -ne $TDP) {
          Write-Verbose -Message "Finding Users with TenantDialPlan '$TenantDialPlan': Searching..." -Verbose
          $Filter = 'Enabled -eq $TRUE -and  TenantDialPlan -EQ "{0}"' -f $TenantDialPlan
          Get-CsOnlineUser -Filter $Filter -WarningAction SilentlyContinue | Select-Object UserPrincipalName
        }
        else {
          Write-Error -Message "TenantDialPlan '$TenantDialPlan' not found" -Category ObjectNotFound -ErrorAction Stop
        }

        break
      } #TDP

      default {
        # No Parameter is specified
        Write-Warning -Message "No Parameters specified. Please specify search criteria (Parameter and value)!" -Verbose

        break
      } #default

    } #Switch

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Find-TeamsUserVoiceConfig
