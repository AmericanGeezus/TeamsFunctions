# Teams Common Area Phones

## about_TeamsCommonAreaPhone

## SHORT DESCRIPTION

There are currently no native commands for this, so I tried creating them.

## LONG DESCRIPTION

Analog Devices in Teams behave differently than they do in Skype for Business. There is no Object created in Teams that represents this Analog Device. Instead, this is done via a Contact Object, to put a Name to a Number.

> [!NOTE] These CmdLets are not yet built! I have sketched out what is needed to build these CmdLets, but haven't had the time to build them yet. The links below will not work.

## CmdLets

| Function                                                           | Underlying Function | Description                                                                                             |
| ------------------------------------------------------------------: | ------------------- | ------------------------------------------------------------------------------------------------------- |
| [`New-TeamsAnalogDevice`](../docs/New-TeamsAnalogDevice.md)       | New-AzureAdContact     | Creates Contact Objects for an Analog Device.                                     |
| [`Get-TeamsAnalogDevice`](../docs/Get-TeamsAnalogDevice.md)       | Get-CsOnlineUser    | Queries Contact Objects for an Analog Device in the Tenant                                       |
| [`Set-TeamsAnalogDevice`](../docs/Set-TeamsAnalogDevice.md)       | Set-CsUser          | Changes Contact Objects for an Analog Device in the Tenant                                                                             |
| [`Remove-TeamsAnalogDevice`](../docs/Remove-TeamsAnalogDevice.md) | Remove-AzureAdUser  | Removes Contact Objects for an Analog Device in the Tenant |

## EXAMPLES

````powershell
# Example 1 - Querying an Analog Device
Get-TeamsAnalogDevice -Name "Elevator Main Building"
````

Querying a Contact Object called "Elevator Main Building"

## NOTE

Not built yet.

## Development Status

CmdLets are not built yet.

## TROUBLESHOOTING NOTE

TBC

## SEE ALSO

- [VoiceConfiguration](about_VoiceConfiguration.md)
- [TeamsCommonAreaPhone](about_TeamsCommonAreaPhone.md)

## KEYWORDS

- VoiceConfig
- Common Area Phone
- Contact Object
