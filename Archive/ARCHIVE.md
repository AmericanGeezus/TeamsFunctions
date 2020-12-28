# Teams Functions - Archive

Call it the cutting room floor, an archive or just a repository of unpublished functions.
They will remain in the GitHub repository in the ARCHIVE folder, but will not be published or used in the main module.

Here are some of these functions:

| Function                        | Description                                                                                          | Replacement            |
| ------------------------------- | ---------------------------------------------------------------------------------------------------- | ---------------------- |
| `Add-TeamsUserLicense`          | Adds one or more Licenses specified per Switch to the provided Identity                              | `Set-TeamsUserLicense` |
| `Get-SkuIdFromSkuPartNumber`    | Helper function for Licensing. Returns a SkuID from a specific SkuPartNumber                         | `Get-AzureAdLicense`   |
| `Get-SkuPartNumberFromSkuId`    | Helper function for Licensing. Returns a SkuPartNumber from a specific SkuID                         |  `Get-AzureAdLicense`  |
| `Set-TeamsUserPolicy`           | Assigns specific Policies to a User. Currently only six policies available                           | None                   |
| `Write-ErrorRecord`             | Troubleshooting and to display Errors in a more readable format and in the Output stream             | `Write-Error`          |
