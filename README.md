# TeamsFunctions - Administering Teams made easier

This is the home for `TeamsFunctions`, a module for Administering Teams Users and Objects in MicrosoftTeams and AzureAd

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/DEberhardt/TeamsFunctions/blob/master/LICENSE)
[![Documentation - GitHub](https://img.shields.io/badge/Documentation-TeamsFunctions-blue.svg)](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs)
[![PowerShell Gallery - TeamsFunctions](https://img.shields.io/badge/PowerShell%20Gallery-TeamsFunctions-blue.svg)](https://www.powershellgallery.com/packages/TeamsFunctions/)
[![Minimum Supported PowerShell Version](https://img.shields.io/badge/PowerShell-5.1-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)
<a href="https://www.repostatus.org/#active"><img src="https://www.repostatus.org/badges/latest/active.svg" alt="Project Status: Active – The project has reached a stable, usable state and is being actively developed." /></a>

## Introduction

This module exists as many of Microsofts Teams back-end (SkypeOnline) Cmdlets are too clunky to handle easily on a daily basis without building a big library of quirks and GUIDs and snippets as well as a growing understanding of all the pitfalls and requirements needed for individual features.

The goal is to make this easier for day-to-day use, to simplify the input and to feed back good information if not successful.
Teams evolves constantly, so does this Module. Current release cadence:

- Released monthly, later quarterly
- PreReleases as required

### Installation

```powershell
# Release
Install-Module TeamsFunctions

# PreRelease
Install-Module TeamsFunctions -AllowPrerelease
```

### Content

- Consistently handling Sessions Connection to AzureAd, MicrosoftTeams and SkypeOnline
- Improving Admin Authorisation with Privileged Identity Management Role Activation
- Improving User Administration for Licensing, Direct Routing and Calling Plans
- Enabling Administration for Common Area Phones, Analog Contact Objects, etc.(WIP)
- Improving Migration and Enablement tasks for Teams Users' Voice Configuration
- Improving Teams Resource Accounts, Call Queues and Auto Attendants
- Improving Day-to-day Administration with little helpers

### Documentation

- All help is available in [/docs](/docs)
- General overview: [about_TeamsFunctions](/docs/about_TeamsFunctions.md)
- The aliases: [about_TeamsFunctionsAliases](/docs/about_TeamsFunctionsAliases.md)
- Individual about_-Files for each Topic have been created
- External Help is available as XML
- Markdown files for all CmdLets created automatically with PlatyPS and updated with each Version
- [My blog](https://davideberhardt.wordpress.com/) will contain updates and explanations from time to time.
- A breakdown of the Change log for Major Versions can be found in [VERSION.md](VERSION.md)
- A detailed breakdown of changes for Pre-Release Versions is recorded in [VERSION-prerelease.md](VERSION-prerelease.md)

## Development

### Current Focus

- Performance improvements, bug fixing and more testing
- Adding Functional improvements to lookup
- Adding individual Scripts to ease admin tasks
- TeamsCommonAreaPhone CmdLets (Testing)
- TeamsAnalogDevice CmdLets (Design & Build)

### Extension plans

- Figuring out Pester, Writing proper Test scenarios
- Adding recently introduced features for Call Queues (Forward to Channel) and Auto Attendants (Call Target: Announcement)
- Standing up a full CI/CD Pipeline with Appveyor (most is done manually presently)
- Comparing backups, changed elements for Change control... Looking at Lee Fords backup scripts :)

### Limitations

- Privileged Admin Groups cannot be queried via PowerShell yet.
- Testing: Currently, only limited Pester tests are available for the Module and select functions.
No Pester tests exist for Functions that require a Session to AzureAd or SkypeOnline - I cannot figure them out yet. All Testing is done with VScode and my trusty ISESteroids.

## Final Word

I hope you enjoy using this module and its functions as much as I do :)

David
