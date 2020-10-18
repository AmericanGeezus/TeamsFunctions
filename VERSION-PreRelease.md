# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## v20.10.18-prerelease

This is a big internal shift from a Module of ONE file of 13k+ lines of code to separate PS1 files dot-sourced into the main Module.
While the one-file approach was managable with regions, it was a bit tiresome to scroll all the time...

Limiting the Scope to one function per file also means that I can - finally - use the debugger in VScode. This will help me find variable states easier and not rely on the ISE Steroids and live testing that much. Speaking of testing, I am now also in a position to write tests for individual Functions.

### Restructuring

E unum pluribus - Out of one, there are many :) - Moving from one file containing all functions to multiple individual .ps1 files (one file per function).

- Functions are split into *Public* and *Private* Functions, Public functions are exported, Private functions are not.
- One file per function. Every Function file *should* have an accompanying Tests-File (ending in .Tests.ps1)
- Introducing a folder structure to represent this: Root: Private, Public. Each folder has a sub-folder *Functions* and *Tests*.
- To group Public functions more meaningfully together, Private\Functions has a sub-folder per Topic covered: *AutoAttendant*, *CallQueue*, *Licensing*, *ResourceAccount*, *Session*, *VoiceConfig* & *Support*. The latter has more subfolders, as required.

### Other Improvements

- Pester Testing
  - Current Status: Tests Passed: 757, Failed: 0, Skipped: 0 NotRun: 0
  - I excluded the test to validate all files have Tests-Files, otherwise I would have 70+ Failures here...
  - These are - mostly Module related tests, meaning verifying that I have CmdLetBinding, Begin/Process/End blocks, etc.
  - More tests will be added once I have figured out Mocking.
- Code Signing - The Module itself is now code-signed, this means:
- PowerShell 7 support. Having installed v7.1.0-RC1 (which solves the issue with SkypeOnlineConnector not being able to be loaded), I will now test on both v5.1 and v7.1

### Pipeline

- More module related Tests to really make this one as sturdy as I can
- More function tests, again, once I figure out Mocking
- Automated Testing for multiple PowerShell versions
- AppVeyor CI/CD build
- Automated Workflow for releases and prereleases (like posting this update on my blog :))
