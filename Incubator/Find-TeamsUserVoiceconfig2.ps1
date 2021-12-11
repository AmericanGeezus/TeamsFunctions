# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live

#IMPROVE Add SupportsPaging for OVP and TDP? (result size is not managable!)


function Find-TeamsUserVoiceConfig2 {
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
  .PARAMETER UserPrincipalName
    Optional. UserPrincipalName (UPN) of the User
    Behaves like Get-TeamsUserVoiceConfig, displaying the Users Voice Configuration
  .PARAMETER PhoneNumber
    Optional. Searches all Users matching the given String in their LineURI.
    The expected ResultSize is limited, the full Object is displayed (Get-TeamsUserVoiceConfig)
    Please see NOTES for details
  .PARAMETER ConfigurationType
    Optional. Searches all enabled Users which are at least partially configured for 'CallingPlans', 'DirectRouting' or 'SkypeHybridPSTN'.
    The expected ResultSize is big, therefore only UserPrincipalNames are returned
    Please note, that seaching with ConfigurationType does not support paging
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
    Optional. In addition to validation of Parameters, also validates License assignment for the found user(s).
    License Check is performed AFTER parameters are verified.
  .EXAMPLE
    Find-TeamsUserVoiceConfig -UserPrincipalName John@domain.com
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
    System.String - UserPrincipalName - With any Parameter except Identity or PhoneNumber
    System.Object - With Parameter Identity or PhoneNumber
  .NOTES
    With the exception of Identity and PhoneNumber, all searches are filtering on Get-CsOnlineUser
    This usually should not take longer than a minute to complete.
    Identity is querying the provided UPN and only wraps Get-TeamsUserVoiceConfig
    PhoneNumber has to do a full search with 'Where-Object' which will take time to complete
    Depending on the number of Users in the Tenant, this may take a few minutes!

    All Parameters except UserPrincipalName or PhoneNumber will only return UserPrincipalNames (UPNs)
    - PhoneNumber: Searches against the LineURI parameter. For best compatibility, provide in E.164 format (with or without the +)
    This script can find duplicate assignments if the Number was assigned with and without an extension.
    - ConfigurationType: This is determined with Test-TeamsUserVoiceConfig -Partial and will return all Accounts found
    - VoicePolicy: BusinessVoice are PhoneSystem Users exclusively configured for Microsoft Calling Plans.
      HybridVoice are PhoneSystem Users who are configured for TDR, Hybrid SkypeOnPrem PSTN or Hybrid CloudConnector PSTN breakouts
    - OnlineVoiceRoutingPolicy: Finds all users which have this particular Policy assigned
    - TenantDialPlan: Finds all users which have this particular DialPlan assigned.
    Please see Related Link for more information
  .COMPONENT
    VoiceConfiguration
  .FUNCTIONALITY
    Finding Users with a specific values in their Voice Configuration
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsUserVoiceConfig.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating
  #>

  [CmdletBinding(DefaultParameterSetName = 'Tel', SupportsPaging)]
  [Alias('Find-TeamsUVC2')]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(ParameterSetName = 'ID')]
    [Alias('ObjectId', 'Identity')]
    [string]$UserPrincipalName,

    [Parameter(ParameterSetName = 'Tel', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'String to be found in any of the PhoneNumber fields')]
    [ValidateScript( {
        If ($_ -match '^(tel:\+|\+)?([0-9]?[-\s]?(\(?[0-9]{3}\)?)[-\s]?([0-9]{3}[-\s]?[0-9]{4})|([0-9][-\s]?){4,20})((x|;ext=)([0-9]{3,8}))?$') { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Not a valid phone number format. Expected min 4 digits, but multiple formats accepted. Extensions will be stripped'
          $false
        }
      })]
    [Alias('Number', 'TelephoneNumber', 'Tel', 'LineURI', 'OnPremLineURI')]
    [string]$PhoneNumber,

    [Parameter(ParameterSetName = 'Ext', HelpMessage = 'String to be found in any of the PhoneNumber fields as an Extension')]
    [Alias('Ext')]
    [string]$Extension,

    [Parameter(ParameterSetName = 'CT', HelpMessage = 'Filters based on Configuration Type')]
    [ValidateSet('CallingPlans', 'SkypeHybridPSTN', 'DirectRouting')]
    [String]$ConfigurationType,

    [Parameter(ParameterSetName = 'VP', HelpMessage = 'Filters based on VoicePolicy')]
    [ValidateSet('BusinessVoice', 'HybridVoice')]
    [String]$VoicePolicy,

    [Parameter(ParameterSetName = 'OVP', HelpMessage = 'Filters based on OnlineVoiceRoutingPolicy')]
    [AllowNull()]
    [Alias('OVP')]
    [String]$OnlineVoiceRoutingPolicy,

    [Parameter(ParameterSetName = 'TDP', HelpMessage = 'Filters based on TenantDialPlan')]
    [AllowNull()]
    [Alias('TDP')]
    [String]$TenantDialPlan,

    [Parameter(HelpMessage = 'Additionally also validates License (CallingPlan or PhoneSystem)')]
    [switch]$ValidateLicense

  ) #param

  begin {
    #Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Asserting MicrosoftTeams Connection
    if ( -not (Assert-MicrosoftTeamsConnection) ) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    [System.Collections.ArrayList]$Query = @()
    #region Creating Filter
    #Filter must be written as-is, e.g '$Filter = 'SipAddress -like "*{0}*"' -f $UserPrincipalName' (Get-CsOnlineUser is an Online command, handover of parameters is sketchy)
    switch ($PsCmdlet.ParameterSetName) {
      'ID' {
        Write-Information "TRYING:  Finding Users with SipAddress '$UserPrincipalName'"
        $Filter = 'SipAddress -like "*{0}*"' -f $UserPrincipalName #Filter must be written as-is
        break
      } #ID

      'Tel' {
        Write-Verbose -Message "Normalising Input for Phone Number '$PhoneNumber'"
        if ($PhoneNumber -match '([0-9]{3,25});ext=([0-9]{3,8})') {
          $Number = $matches[1] # Phone Number
          # $Number = $matches[2] # Extension
        }
        else {
          $Number = Format-StringForUse "$($PhoneNumber.split(';')[0].split('x')[0])" -SpecialChars 'telx:+() -'
        }
        if ( -not $Called) {
          Write-Information "TRYING:  Finding all Users enabled for Teams with Phone Number string '$Number': Searching..."
        }
        $Filter = 'LineURI -like "*{0}*"' -f $Number #Filter must be written as-is
        break
      } #Tel

      'Ext' {
        Write-Verbose -Message "Normalising Input for Extension '$Extension'"
        if ($Extension -match '([0-9]{3,15})?;?ext=([0-9]{3,8})') {
          # $Number = $matches[1] # Phone Number
          # $Number = $matches[2] # Extension
          $ExtN = 'ext=' + $matches[2]
        }
        else {
          $ExtN = 'ext=' + $ext
        }
        if ( -not $Called) {
          Write-Information "TRYING:  Finding all Users enabled for Teams with Extension '$ExtN': Searching..."
        }
        $Filter = 'LineURI -like "*{0}*"' -f "$ExtN" #Filter must be written as-is
        break
      } #Ext

      'CT' {
        #TEST Filter - If not working, may need filtering twice (runtime!)
        Write-Information "TRYING:  Finding all Users enabled for Teams with ConfigurationType '$ConfigurationType' Searching..."
        switch ($ConfigurationType) {
          'DirectRouting' {
            #$Filter = 'VoicePolicy -eq "HybridVoice" -and $null -eq VoiceRoutingPolicy -and ($null -ne OnPremLineURI -or $null -ne OnlineVoiceRoutingPolicy)' #Filter must be written as-is
            $Filter = 'VoicePolicy -eq "HybridVoice"' #Filter must be written as-is
          }
          'SkypeHybridPSTN' {
            #$Filter = 'VoicePolicy -eq "HybridVoice" -and $null -eq OnlineVoiceRoutingPolicy -and ($null -ne OnPremLineURI -or $null -ne VoiceRoutingPolicy)' #Filter must be written as-is
            $Filter = 'VoicePolicy -eq "HybridVoice"' #Filter must be written as-is
          }
          'CallingPlans' {
            #$Filter = 'VoicePolicy -eq "BusinessVoice" -and TelephoneNumber -ne $null' #Filter must be written as-is
            $Filter = 'VoicePolicy -eq "BusinessVoice"' #Filter must be written as-is
          }
        }

        <# commented out due to refactor
        #NOTE: CT does not support paging!
        Write-Verbose -Message 'Searching for all Users enabled for Teams: Searching... This will take quite some time!'
        #BODGE Rework Filter to include required string (maybe filter twice?)
        $Filter = 'Enabled -eq $TRUE' #Filter must be written as-is
        $CsUsers = Get-CsOnlineUser -Filter $Filter -WarningAction SilentlyContinue -ErrorAction Stop
        Write-Verbose -Message "Sifting through Information for $($CsUsers.Count) Users: Parsing..."
        if ( -not $Called) {
          Write-Information "TRYING:  Finding all Users enabled for Teams with ConfigurationType '$ConfigurationType' Searching..."
        }

        switch ($ConfigurationType) {
          'DirectRouting' {
            if ($PSBoundParameters.ContainsKey('ValidateLicense')) {
              Write-Verbose -Message 'Switch ValidateLicense: Only users with PhoneSystem license (enabled ServicePlan) are displayed!' -Verbose
            }
            foreach ($U in $CsUsers) {
              if ($U.VoicePolicy -eq 'HybridVoice' -and $null -eq $U.VoiceRoutingPolicy -and ($null -ne $U.OnPremLineURI -or $null -ne $U.OnlineVoiceRoutingPolicy)) {
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
          'SkypeHybridPSTN' {
            if ($PSBoundParameters.ContainsKey('ValidateLicense')) {
              Write-Verbose -Message 'Switch ValidateLicense: Only users with PhoneSystem license (enabled ServicePlan) are displayed!' -Verbose
            }
            foreach ($U in $CsUsers) {
              if ($U.VoicePolicy -eq 'HybridVoice' -and $null -eq $U.OnlineVoiceRoutingPolicy -and ($null -ne $U.OnPremLineURI -or $null -ne $U.VoiceRoutingPolicy)) {
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
          'CallingPlans' {
            if ($PSBoundParameters.ContainsKey('ValidateLicense')) {
              Write-Verbose -Message 'Switch ValidateLicense: Only users with CallPlan license are displayed!' -Verbose
            }
            foreach ($U in $CsUsers) {
              if ($U.VoicePolicy -eq 'BusinessVoice' -or $null -ne $U.TelephoneNumber) {
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
        #>
        break
      } #CT

      'VP' {
        if ( -not $Called) {
          Write-Information "TRYING:  Finding all Users enabled for Teams with VoicePolicy '$VoicePolicy': Searching..."
        }
        $Filter = 'VoicePolicy -EQ "{0}"' -f $VoicePolicy #Filter must be written as-is
        #break
        continue
      } #VP

      'OVP' {
        Write-Verbose -Message "Finding OnlineVoiceRoutingPolicy '$OnlineVoiceRoutingPolicy'..."
        $OVP = Get-CsOnlineVoiceRoutingPolicy $OnlineVoiceRoutingPolicy -WarningAction SilentlyContinue
        if ($null -ne $OVP) {
          if ( -not $Called) {
            Write-Information "TRYING:  Finding all Users enabled for Teams with OnlineVoiceRoutingPolicy '$OnlineVoiceRoutingPolicy': Searching..."
          }
          $Filter = 'OnlineVoiceRoutingPolicy -EQ "{0}"' -f $OnlineVoiceRoutingPolicy #Filter must be written as-is
        }
        else {
          Write-Error -Message "OnlineVoiceRoutingPolicy '$OnlineVoiceRoutingPolicy' not found" -Category ObjectNotFound -ErrorAction Stop
        }
        break
      } #OVP

      'TDP' {
        Write-Verbose -Message "Finding TenantDialPlan '$TenantDialPlan'..."
        $TDP = Get-CsTenantDialPlan $TenantDialPlan -WarningAction SilentlyContinue
        if ($null -ne $TDP) {
          if ( -not $Called) {
            Write-Information "TRYING:  Finding all Users enabled for Teams with TenantDialPlan '$TenantDialPlan': Searching..."
          }
          $Filter = 'TenantDialPlan -EQ "{0}"' -f $TenantDialPlan #Filter must be written as-is
        }
        else {
          Write-Error -Message "TenantDialPlan '$TenantDialPlan' not found" -Category ObjectNotFound -ErrorAction Stop
        }
        break
      } #TDP

      default {
        # No Parameter is specified
        Write-Warning -Message 'No Parameters specified. Please specify search criteria (Parameter and value)!' -Verbose
        break
      } #default
    } #Switch
    #endregion

    #region Query
    if ( $Filter ) {
      Write-Verbose -Message "[QUERY  ] Performing search against Get-CsOnlineUser ($($PsCmdlet.ParameterSetName))"
      try {
        $CsUser = Get-CsOnlineUser -Filter $Filter -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        $CsUser | ForEach-Object { [void]$Query.Add($_) }
        if ( -not $CsUser ) {
          throw [Exception] 'No Object found'
        }
      }
      catch [Exception] {
        # Optional Secondary filter option to catch an ID that is not correctly configured (UPN deviates from SIP)
        if ( $PsCmdlet.ParameterSetName -eq 'ID') {
          Write-Information "TRYING:  Finding Users with UserPrincipalName '$UserPrincipalName'"
          $Filter = 'UserPrincipalName -like "*{0}*"' -f $UserPrincipalName
          $CsUser = Get-CsOnlineUser -Filter $Filter -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          $CsUser | ForEach-Object { [void]$Query.Add($_) }
        }
      }
      catch {
        Write-Error -Message "Error executing Get-CsOnlineUser: $($_.Exception.Message)" -ErrorAction Stop
      }
    }

    # Applying Secondary Filter for ConfigurationType
    if ( $PsCmdlet.ParameterSetName -eq 'CT') {
      [System.Collections.ArrayList]$ConfigurationTypeUsers = @()
      switch ($ConfigurationType) {
        'DirectRouting' {
          $ConfigurationTypeObjects = $Query | Where-Object { $_.VoicePolicy -eq 'HybridVoice' -and $null -eq $_.VoiceRoutingPolicy -and ($null -ne $_.OnPremLineURI -or $null -ne $_.OnlineVoiceRoutingPolicy) }
          $ConfigurationTypeObjects | ForEach-Object { [void]$ConfigurationTypeUsers.Add( $_ ) }
        }
        'SkypeHybridPSTN' {
          #This will output overlapping with DirectRouting
          #$Query | Where-Object { $_.VoicePolicy -eq 'HybridVoice' -and $null -eq $_.OnlineVoiceRoutingPolicy -and ($null -ne $_.OnPremLineURI -or $null -ne $_.VoiceRoutingPolicy) }
          $ConfigurationTypeObjects = $Query | Where-Object { $_.VoicePolicy -eq 'HybridVoice' -and $null -eq $_.OnlineVoiceRoutingPolicy -and $null -ne $_.VoiceRoutingPolicy }
          $ConfigurationTypeObjects | ForEach-Object { [void]$ConfigurationTypeUsers.Add( $_ ) }
        }
        'CallingPlans' {
          # Secondary filter not required, but for more granularity, a TelephoneNumber (MicrosoftNumber) can be queried with -and instead:
          $ConfigurationTypeObjects = $Query | Where-Object { $_.VoicePolicy -eq 'BusinessVoice' -or $null -ne $_.TelephoneNumber }
          $ConfigurationTypeObjects | ForEach-Object { [void]$ConfigurationTypeUsers.Add( $_ ) }
        }
      }
      $Query = $ConfigurationTypeUsers
    }

    $UnfilteredCount = $Query.Count
    Write-Verbose -Message "[QUERY  ] $($MyInvocation.MyCommand) - $UnfilteredCount Objects found for the filter ('$Filter')"
    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
      "  Function: $($MyInvocation.MyCommand.Name) - Unfiltered Output: ($UnfilteredCount)", ($Query | Select-Object UserPrincipalName, LineUri | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }
    #endregion

    #region ValidateLicense
    if ( $Query -and $PSBoundParameters.ContainsKey('ValidateLicense')) {
      Write-Verbose -Message 'Verifying whether filtered Objects are correctly provisioned for PhoneSystem (assigned, enabled & provisioned successfully).'
      [System.Collections.ArrayList]$LicensedUsers = @()
      foreach ($U in $Query) {
        if ( (Test-TeamsUserLicense $($U.UserPrincipalName) -ServicePlan MCOEV) ) {
          #Adding all Users that are licensed for Phone System to LicensedUsers Object
          [void]$LicensedUsers.Add($U)
        }
      }
      $Query = $LicensedUsers
    }
    $LicensedCount = $Query.Count
    Write-Verbose -Message "[QUERY  ] $($MyInvocation.MyCommand) - $LicensedCount Objects found with valid license"
    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
      "  Function: $($MyInvocation.MyCommand.Name) - Filtered Output: ($LicensedCount)", ($Query | Select-Object UserPrincipalName, LineUri | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }
    #endregion


    #region OUTPUT
    # Paging: First & Skip
    if ( $Query.Count -gt 0 ) {
      # Displaying warnings & Feedback
      if ( $Query.Count -gt 1 ) {
        switch ( $PsCmdlet.ParameterSetName) {
          'Tel' {
            Write-Warning -Message "Number: '$Number' - Found multiple Users matching the criteria! If the search string represents the FULL number, it is assigned incorrectly. Inbound calls to this number will not work as Teams will not find a unique match"
            Write-Verbose -Message 'Investigate OnPremLineURI string. Verify unique PhoneNumber is applied.' -Verbose
          }
          'Ext' {
            Write-Warning -Message "Extension: '$ExtN' - Found multiple Users matching the criteria! If the search string represents the FULL extension, it is assigned incorrectly. Inbound calls to this extension may fail depending on normalisation as Teams will not find a unique match"
            Write-Verbose -Message 'Investigate OnPremLineURI string. Verify unique Extension is applied.' -Verbose
          }
        }
      }

      # Processing paging
      $FirstId = 0
      $LastId = $LicensedCount - 1
      if ($PSCmdlet.PagingParameters.Skip -ge $Query.count) {
        Write-Verbose -Message "[PAGING ] $($MyInvocation.MyCommand) - No results satisfy the Skip parameters"
      }
      elseif ($PSCmdlet.PagingParameters.First -eq 0) {
        Write-Verbose -Message "[PAGING ] $($MyInvocation.MyCommand) - No results satisfy the First parameters"
      }
      else {
        $FirstId = $PSCmdlet.PagingParameters.Skip
        Write-Verbose -Message ("[PAGING ] $($MyInvocation.MyCommand) - FirstId: {0}" -f $FirstId)
        $LastId = $FirstId + ([Math]::Min($PSCmdlet.PagingParameters.First, $Query.Count - $PSCmdlet.PagingParameters.Skip) - 1)
      }
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        "  Function: $($MyInvocation.MyCommand.Name) - Queried:  $($Query.Count)" | Write-Debug
        "  Function: $($MyInvocation.MyCommand.Name) - FirstId:  $FirstId" | Write-Debug
        "  Function: $($MyInvocation.MyCommand.Name) - LastId:   $LastId" | Write-Debug
      }
      $Query = $Query[$FirstId..$LastId]
      $FilteredCount = $Query.Count
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        "  Function: $($MyInvocation.MyCommand.Name) - Paginated Output: ($FilteredCount)", ($Query | Select-Object UserPrincipalName, LineUri | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
      }

      if ($Query) {
        if ($Query.Count -gt 3 ) {
          $Query | Select-Object UserPrincipalName, SipAddress, LineUri
        }
        elseif ($Query.Count -gt 1 ) {
          $Query | Select-Object UserPrincipalName, SipAddress, InterpretedUserType, VoicePolicy, EnterpriseVoiceEnabled, OnlineVoiceRoutingPolicy, TenantDialPlan, TelephoneNumber, LineUri, OnPremLineURI
        }
        else {
          $Query.UserPrincipalName | Get-TeamsUserVoiceConfig
        }
      }
      Write-Verbose -Message ("[PAGING ] $($MyInvocation.MyCommand) - LastId: {0}" -f $LastId)
    }
    elseif ( -not $Called) {
      Write-Verbose -Message "[QUERY  ] $($MyInvocation.MyCommand) - No results found ($($PsCmdlet.ParameterSetName))" -Verbose
    }
    #endregion
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
    # Paging: IncludeTotalCount
    If ($PSCmdlet.PagingParameters.IncludeTotalCount) {
      [double]$Accuracy = 1.0
      $PSCmdlet.PagingParameters.NewTotalCount($FilteredCount, $Accuracy)
    }
    if ( $FilteredCount -lt $UnfilteredCount ) {
      Write-Information "INFO:    A total of $UnfilteredCount objects have been found$( if ( $ValidateLicense ) { " ($LicensedCount licensed correctly)"}), but only the requested $FilteredCount object(s) are displayed."
    }
  } #end
} # Find-TeamsUserVoiceConfig2
