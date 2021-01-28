# Teams Call Queue

## about_TeamsCallQueue

## SHORT DESCRIPTION

Administering Call Queues with friendlier names.

## LONG DESCRIPTION

Microsoft has selected a GUID as the Identity the `CsCallQueue` scripts are a bit cumbersome for the average admin. Though the Searchstring parameter is available, enabling me to utilise it as a basic input method for `TeamsCallQueue` CmdLets. They query by *DisplayName*, which comes with a drawback for the `Set`-command: It requires a unique result. Also uses Filenames instead of IDs when adding Audio Files. Microsoft is continuing to improve these scripts, so I hope these can stand the test of time and make managing Call Queues easier.

## CmdLets

| Function                                                    | Underlying Function | Description                                                        |
| ----------------------------------------------------------- | ------------------- | ------------------------------------------------------------------ |
| [`Get-TeamsCallQueue`](../docs/Get-TeamsCallQueue.md)       | Get-CsCallQueue     | Queries a Call Queue with friendly inputs (UPN) and output         |
| [`New-TeamsCallQueue`](../docs/New-TeamsCallQueue.md)       | New-CsCallQueue     | Creates a Call Queue with friendly inputs (File Names, UPNs, etc.) |
| [`Set-TeamsCallQueue`](../docs/Set-TeamsCallQueue.md)       | Set-CsCallQueue     | Changes a Call Queue with friendly inputs (File Names, UPNs, etc.) |
| [`Remove-TeamsCallQueue`](../docs/Remove-TeamsCallQueue.md) | Remove-CsCallQueue  | Removes a Call Queue from the Tenant                               |

## EXAMPLES

### Example 1 - Query

```powershell
Get-TeamsCallQueue [-Name] "Test"
# Queries all Call Queues with the Name 'Test' (full name)

Get-TeamsCallQueue -SearchString "Test"
# Queries all Call Queues with the String 'Test' in the name (search)
```

### Example 2 - Creating a new Call Queue with defaults

```powershell
New-TeamsCallQueue [-Name] "My Queue"
# Creates a Call Queue with improved defaults
# Thresholds: Overflow 10, Timeout 30s
# Improved defaults also cover the default MusicOnHold

New-TeamsCallQueue [-Name] "My Queue" -UseMicrosoftDefaults
# Creates a Call Queue with Microsoft defaults (thresholds)
# Thresholds: Overflow 50, Timeout 1200s

```

### Example 3 - Setting with the Pipeline

```powershell
Get-TeamsCallQueue -Name "My Queue" | Set-TeamsCallQueue -OverflowThreshold 120

# Queries all Call Queues with the Name 'My Queue' (full name) and changes the OverflowThreshold.
# Good for changing one or more Queues to the same setting, though handle with care!
```

### Example 4 - Removing with the Pipeline

```powershell
Get-TeamsCallQueue -SearchString "Test" | Remove-TeamsCallQueue -Confirm

# Queries all Call Queues with the String 'Test' in the name and removes them. Prompts for confirmation for each.
# Handle with care!
```

## NOTE

Pipelines are available, as they are bound to the Name, this name must be unique. Bulk updating is available - see example above, but handle with care.  Best to capture the Queues to be changed in a variable and double-checking you got the correct ones (and only those) before running (-Confirm can help :))

## Development Status

Developing and testing these is very time consuming. I learned a lot while doing them, but as hard as I try, they probably still contain a few bugs.

## TROUBLESHOOTING NOTE

They are quite mature already, but if you do encounter issues, please capture verbose and debug output as they help me immensely when troubleshooting.

## SEE ALSO

[about_TeamsAutoAttendant](about_TeamsAutoAttendant.md)

[about_TeamsResourceAccount](about_TeamsResourceAccount.md)

[about_TeamsCallableEntity](about_TeamsCallableEntity.md)

## KEYWORDS

- Creation
- Configuration
- Management
- AzureAdUser
- AzureAdGroup
- CsOnlineUser
- CsOnlineApplicationInstance
- TeamsResourceAccount
