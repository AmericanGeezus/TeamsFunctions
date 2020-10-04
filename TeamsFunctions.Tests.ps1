$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$module = 'TeamsFunctions'

Describe -Tags ('Unit', 'Acceptance') "$module Module Tests"  {

  Context 'Module Setup' {
    It "has the root module $module.psm1" {
      "$here\$module.psm1" | Should -Exist
    }

    It "has the a manifest file of $module.psd1" {
      "$here\$module.psd1" | Should -Exist
      "$here\$module.psd1" | Should -FileContentMatch "$module.psm1"
    }

    It "$module folder has functions" {
      "$here\Public\Functions*.ps1" | Should -Exist
      "$here\Private\Functions*.ps1" | Should -Exist
    }

    It "$module is valid PowerShell code" {
      $psFile = Get-Content -Path "$here\$module.psm1" `
                            -ErrorAction Stop
      $errors = $null
      $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
      $errors.Count | Should -Be 0
    }

  } # Context 'Module Setup'

  #TODO Replace with Get-ChildItem from $here?
  $functions = ('Connect-SkypeOnline',
                'Connect-SkypeOnline',
                'Disconnect-SkypeOnline',
                'Connect-Me',
                'Disconnect-Me',
                'Test-Module',
                'Get-AzureAdAssignedAdminRoles',
                'Get-AzureADUserFromUPN',
                'Add-TeamsUserLicense',
                'Set-TeamsUserLicense',
                'New-AzureAdLicenseObject',
                'Get-TeamsUserLicense',
                'Get-TeamsTenantLicense',
                'Test-TeamsUserLicense',
                'Test-TeamsUserHasCallPlan',
                'Set-TeamsUserPolicy',
                'Test-TeamsTenantPolicy',
                'Test-AzureADModule',
                'Test-AzureADConnection',
                'Test-AzureADUser',
                'Test-AzureAdGroup',
                'Test-SkypeOnlineConnection',
                'Test-MicrosoftTeamsConnection',
                'Test-ExchangeOnlineConnection',
                'Test-TeamsUser',
                'Assert-AzureADConnection',
                'Assert-SkypeOnlineConnection',
                'Assert-MicrosoftTeamsConnection',
                'Get-TeamsTenantVoiceConfig',
                'Get-TeamsUserVoiceConfig',
                'Find-TeamsUserVoiceConfig',
                'Set-TeamsUserVoiceConfig',
                'New-TeamsUserVoiceConfig',
                'Remove-TeamsUserVoiceConfig',
                'Test-TeamsUserVoiceConfig',
                'New-TeamsResourceAccount',
                'Get-TeamsResourceAccount',
                'Find-TeamsResourceAccount',
                'Set-TeamsResourceAccount',
                'Remove-TeamsResourceAccount',
                'New-TeamsResourceAccountAssociation',
                'Get-TeamsResourceAccountAssociation',
                'Remove-TeamsResourceAccountAssociation',
                'New-TeamsCallQueue',
                'Get-TeamsCallQueue',
                'Set-TeamsCallQueue',
                'Remove-TeamsCallQueue',
                'New-TeamsAutoAttendant',
                'Get-TeamsAutoAttendant',
                'Set-TeamsAutoAttendant',
                'Remove-TeamsAutoAttendant',
                'New-TeamsAutoAttendantDialScope',
                'New-TeamsAutoAttendantSchedule',
                'New-TeamsAutoAttendantCallableEntity',
                'New-TeamsAutoAttendantPrompt',
                'Import-TeamsAudioFile',
                'Backup-TeamsEV',
                'Restore-TeamsEV',
                'Backup-TeamsTenant',
                'Remove-TenantDialPlanNormalizationRule',
                'Test-TeamsExternalDNS',
                'Get-SkypeOnlineConferenceDialInNumbers',
                'Resolve-AzureAdGroupObjectFromName',
                'Get-SkuPartNumberFromSkuID',
                'Get-SkuIDFromSkuPartNumber',
                'Format-StringRemoveSpecialCharacter',
                'Format-StringForUse',
                'Write-ErrorRecord',

                #non-exported functions
                'GetActionOutputObject2',
                'GetActionOutputObject3',
                'ProcessLicense',
                'GetApplicationTypeFromAppId',
                'GetAppIdFromApplicationType',
                'Enable-TeamsUserForEnterpriseVoice'
              )

  foreach ($function in $functions)
  {

    Context "Test Function $function" {

      It "$function.ps1 should exist" {
        "$here\$function.ps1" | Should -Exist
      }

      It "$function.ps1 should have a valid header" {
        "$here\$function.ps1" | Should -FileContentMatch 'Module:'
        "$here\$function.ps1" | Should -FileContentMatch 'Function:'
        "$here\$function.ps1" | Should -FileContentMatch 'Created by:'
        "$here\$function.ps1" | Should -FileContentMatch 'Updated:'
        "$here\$function.ps1" | Should -FileContentMatch 'Status:'
      }

      It "$function.ps1 should have help block" {
        "$here\$function.ps1" | Should -FileContentMatch '<#'
        "$here\$function.ps1" | Should -FileContentMatch '#>'
      }

      It "$function.ps1 should have a SYNOPSIS section in the help block" {
        "$here\$function.ps1" | Should -FileContentMatch '.SYNOPSIS'
      }

      It "$function.ps1 should have a DESCRIPTION section in the help block" {
        "$here\$function.ps1" | Should -FileContentMatch '.DESCRIPTION'
      }

      It "$function.ps1 should have a EXAMPLE section in the help block" {
        "$here\$function.ps1" | Should -FileContentMatch '.EXAMPLE'
      }

      # Add more checks for !

      # Evaluate use - not all Functions are advanced yet!

      It "$function.ps1 should be an advanced function" {
        "$here\$function.ps1" | Should -FileContentMatch 'function'
        "$here\$function.ps1" | Should -FileContentMatch 'cmdletbinding'
        "$here\$function.ps1" | Should -FileContentMatch 'param'
        #Add: OutputType, Return
      }

      It "$function.ps1 should contain Write-Verbose blocks" {
        "$here\$function.ps1" | Should -FileContentMatch 'Write-Verbose'
      }

      It "$function.ps1 is valid PowerShell code" {
        $psFile = Get-Content -Path "$here\$function.ps1" `
                              -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
        $errors.Count | Should -Be 0
      }


    } # Context "Test Function $function"

    Context "$function has tests" {
      It "function-$($function).Tests.ps1 should exist" {
        "$here\function-$($function).Tests.ps1" | Should -Exist
      }
    }

  } # foreach ($function in $functions)

}