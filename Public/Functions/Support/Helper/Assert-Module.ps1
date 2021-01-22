# Module:   TeamsFunctions
# Function: Support
# Author:		David Eberhardt
# Updated:  01-JUL-2020
# Status:   Live

function Assert-Module {
  <#
	.SYNOPSIS
		Tests whether a Module is loaded
  .DESCRIPTION
    Tests whether a specific Module is loaded
  .PARAMETER Module
    Names of one or more Modules to assert
  .PARAMETER UpToDate
    Verifies Version installed is equal to the latest found online
  .PARAMETER PreRelease
    Verifies Version installed is equal to the latest prerelease version found online
  .EXAMPLE
		Assert-Module -Module ModuleName
		Will Return $TRUE if the Module 'ModuleName' is installed and loaded
  .EXAMPLE
		Assert-Module -Module ModuleName -UpToDate
		Will Return $TRUE if the Module 'ModuleName' is installed in the latest release version and loaded
  .EXAMPLE
		Assert-Module -Module ModuleName -UpToDate -PreRelease
		Will Return $TRUE if the Module 'ModuleName' is installed in the latest pre-release version and loaded
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  Param
  (
    [Parameter(Position = 0, HelpMessage = 'Module to test')]
    [string[]]$Module,

    [Parameter(HelpMessage = 'Verifies the latest version is installed')]
    [switch]$UpToDate,

    [Parameter(HelpMessage = 'Verifies the latest prerelease version is installed')]
    [switch]$PreRelease

  )

  begin {

  } #begin

  process {
    foreach ($M in $Module) {
      Write-Verbose -Message "Verifying Module '$M' - Checking Installation"
      $Installed = Get-Module -Name $M -ListAvailable -Verbose:$false -WarningAction SilentlyContinue
      if ( -not $Installed) {
        Write-Verbose -Message "Verifying Module '$M' - Checking Installation - Module not installed"
        return $false
      }
      else {
        if ($UpToDate) {
          Write-Verbose -Message "Verifying Module '$M' - Checking Version"
          $FindModuleParams = $null
          $FindModuleParams += @{'Name' = $M }
          $FindModuleParams += @{'Verbose' = $false }
          $FindModuleParams += @{'ErrorAction' = 'SilentlyContinue' }
          if ($PreRelease) { $FindModuleParams += @{'AllowPrerelease' = $true } }
          $Latest = Find-Module @FindModuleParams
          $LatestVersion = if ($Latest.Version -match '-') { $Latest.Version.Split('-')[0] } else { $Latest.Version }

          if ($Installed.count -gt 1) { $Current = $Installed[0] } else { $Current = $Installed }
          Write-Verbose -Message "Verifying Module '$M' - Current Version installed: ($($Current.Version))"
          $CurrentVersion = [Version] ($Current.Version.ToString() -replace '^(\d+(\.\d+){0,3})(\.\d+?)*$' , '$1')
          $LatestVersion = [Version] ($LatestVersion.ToString() -replace '^(\d+(\.\d+){0,3})(\.\d+?)*$' , '$1')

          if ($CurrentVersion -lt $LatestVersion) {
            # $CurrentVersion is less than $LatestVersion
            Write-Verbose -Message "Verifying Module '$M' - Latest Version not installed ($($Latest.Version))"
            return $false
          }
        }

        Write-Verbose -Message "Verifying Module '$M' - Checking Import"
        $Loaded = Get-Module -Name $M -Verbose:$false -WarningAction SilentlyContinue
        if ($Loaded) {
          return $true
        }
        else {
          if ($M -eq 'MicrosoftTeams') {
            Import-Module -Name $M -Force -Global -Verbose:$false -ErrorAction SilentlyContinue
          }
          else {
            Import-Module -Name $M -Verbose:$false -ErrorAction SilentlyContinue
          }
          if (Get-Module -Name $M -WarningAction SilentlyContinue) {
            return $true
          }
          else {
            return $false
          }
        }
      }
    }
  } #process

  end {

  } #end
} # Assert-Module
