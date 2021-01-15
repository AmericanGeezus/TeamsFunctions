# Teams Scripts and Functions

This module exists as many of Microsofts Teams back-end (SkypeOnline) Cmdlets were too clunky to handle easily on a daily basis without building a big library of quirks and GUIDs and snippets as well as a growing understanding of all the pitfalls and requirements needed for individual features.

Teams Voice CmdLets adding and improving on AzureAd and MicrosoftTeams CmdLets

As Teams evolves, so does this Module.

## Documentation

- Where to start [about_TeamsFunctions](/help/about_TeamsFunctions.md)
- Individual about_-Files for each Topic have been created in [/help](/help])
- Documentation for individual CmdLets can be found in [/docs](/docs)
- External Help is available as XML in [/docs](/docs)
- Markdown documentation is generated automatically with PlatyPS and updated with each Version
- More information can be found via [my blog](https://davideberhardt.wordpress.com/)
- A breakdown of the Change log for Major Versions can be found in VERSION.md
- A detailed breakdown of changes for Pre-Release Versions is recorded in VERSION-PreRelease.md

## Current Focus

- Performance improvements, bug fixing and more testing
- Adding Functional improvements to lookup
- Adding individual Scripts to ease admin tasks

### Extension plans

- Figuring out Pester, Writing proper Test scenarios
- Standing up a full CI/CD Pipeline with Appveyor (most is done manually presently)
- Comparing backups, changed elements for Change control... Looking at Lee Fords backup scripts :)

### Limitations

- Privileged Admin Groups cannot be queried via PowerShell yet.
- Testing: Currently, only limited Pester tests are available for the Module and select functions.
No Pester tests exist for Functions that require a Session to AzureAd or SkypeOnline - I cannot figure them out yet. All Testing is done with VScode and my trusty ISESteroids.

## Final Word

I hope you enjoy using this module and its functions as much as I do :)

David
