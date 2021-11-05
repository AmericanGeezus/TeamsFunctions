# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  05-NOV-2021
# Status:   Live




function Get-InterpretedVoiceConfigType {
  <#
  .SYNOPSIS
    Returns the Voice Config Type for one or more Users
  .DESCRIPTION
    InterpretedVoiceConfigType is a Parameter aimed to clarify what type of Voice Configuration a User is configured for.
    Based on status of Parameters VoicePolicy, VoiceRoutingPolicy and OnlineVoiceRoutingPolicy it returns the status
    for one or more UserPrincipalNames or CsOnlineUser-Objects
  .PARAMETER UserPrincipalName
    Required for Parameterset UserPrincipalName. UserPrincipalName or ObjectId of the Object
  .PARAMETER Object
    Required for Parameterset Object. CsOnlineUser Object passed to the function to reduce query time.
  .EXAMPLE
    Get-InterpretedVoiceConfigType -Object $CsOnlineUser
    Interprets a CsOnlineUser-Object and returns a string for the Type of Voice Config the User(s) are provisioned for.
    This will help reduce query time
  .EXAMPLE
    Get-InterpretedVoiceConfigType -UserPrincipalName $UserPrincipalName
    Queries the Object and returns a string for the Type of Voice Config the User(s) are provisioned for.
  .INPUTS
    System.String
    System.Object
  .OUTPUTS
    System.String
  .NOTES
    Returns 'CallPlans' if Parameter VoicePolicy is "BusinessVoice". No check against licenses is performed.
    Returns 'SkypeHybridPSTN' if Parameter VoicePolicy is "HybridVoice" and VoiceRoutingPolicy is configured
    while Parameter OnlineVoiceRoutingPolicy is empty
    Returns 'DirectRouting' if not CallingPlans and not SkypeHybridPSTN
    Returns 'Unknown' if Parameter VoicePolicy is not set.
  .COMPONENT
    VoiceConfiguration
  .FUNCTIONALITY
    Testing Users Voice Configuration
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-InterpretedVoiceConfigType.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating
  #>

  [CmdletBinding(DefaultParameterSetName = 'UserPrincipalName')]
  [OutputType([System.String])]
  param(
    [Parameter(Mandatory, Position = 0, ParameterSetName = 'Object', ValueFromPipeline)]
    [Object[]]$Object,

    [Parameter(Mandatory, Position = 0, ParameterSetName = 'UserPrincipalName', ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    $Stack = Get-PSCallStack
    $script:Called = ($stack.length -ge 3)
    $script:CalledByAssertTUVC = ($Stack.Command -Contains 'Assert-TeamsUserVoiceConfig')

    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }


    # Test function
    function TestVoiceConfigType ($CsUser) {
      if ($CsUser.VoicePolicy -eq 'BusinessVoice') {
        Write-Verbose -Message "InterpretedVoiceConfigType is 'CallingPlans' (VoicePolicy found as 'BusinessVoice')"
        $InterpretedVoiceConfigType = 'CallingPlans'
      }
      elseif ($CsUser.VoicePolicy -eq 'HybridVoice') {
        Write-Verbose -Message "VoicePolicy found as 'HybridVoice'"
        if ($null -ne $CsUser.VoiceRoutingPolicy -and $null -eq $CsUser.OnlineVoiceRoutingPolicy) {
          Write-Verbose -Message "InterpretedVoiceConfigType is 'SkypeHybridPSTN' (VoiceRoutingPolicy assigned and no OnlineVoiceRoutingPolicy found)"
          $InterpretedVoiceConfigType = 'SkypeHybridPSTN'
        }
        else {
          Write-Verbose -Message "InterpretedVoiceConfigType is 'DirectRouting' (VoiceRoutingPolicy not assigned)"
          $InterpretedVoiceConfigType = 'DirectRouting'
        }
      }
      else {
        Write-Verbose -Message "InterpretedVoiceConfigType is 'Unknown' (undetermined)"
        $InterpretedVoiceConfigType = 'Unknown'
      }
      return $InterpretedVoiceConfigType
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    switch ($PSCmdlet.ParameterSetName) {
      'UserprincipalName' {
        foreach ($User in $UserPrincipalName) {
          Write-Verbose -Message "[PROCESS] Processing '$User'"
          try {
            #NOTE Call placed without the Identity Switch to make remoting call and receive object in tested format (v2.5.0 and higher)
            #$CsUser = Get-CsOnlineUser -Identity "$User" -WarningAction SilentlyContinue -ErrorAction Stop
            $CsUser = Get-CsOnlineUser "$User" -WarningAction SilentlyContinue -ErrorAction Stop
          }
          catch {
            Write-Error "User '$User' not found" -Category ObjectNotFound
            continue
          }
          Write-Output (TestVoiceConfigType -CsUser $CsUser)
        }
      }
      'Object' {
        foreach ($O in $Object) {
          Write-Verbose -Message "[PROCESS] Processing provided CsOnlineUser Object for '$($O.UserPrincipalName)'"
          Write-Output (TestVoiceConfigType -CsUser $O)
        }
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-InterpretedVoiceConfigType
