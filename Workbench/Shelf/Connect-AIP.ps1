function Connect-ToAIP {
  param(
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$Username = "adm_deberhardt@arkadinplatform.com"
  )
  
  #AzureAD
  if(-not (Test-AzureADConnection)) {
    if ($PSBoundParameters.ContainsKey('Username')) {
      Connect-AzureAD -UserName $Username
    }
    else {
      Connect-AzureAD
    }
  }

  # Skype
  if(-not (Test-SkypeOnlineConnection)) {
    Disconnect-SkypeOnline
    
    if ($PSBoundParameters.ContainsKey('Username')) {
      Connect-SkypeOnline -UserName $Username -OverrideAdminDomain arkadinplatform.onmicrosoft.com
    }
    else {
      Connect-SkypeOnline -OverrideAdminDomain arkadinplatform.onmicrosoft.com
    }  
  }
}

function Connect-ToAPPConsulting {
  param(
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$Username = "adm_de@applicableconsulting.co.uk"
  )
  
  #AzureAD
  if(-not (Test-AzureADConnection)) {
    if ($PSBoundParameters.ContainsKey('Username')) {
      Connect-AzureAD -UserName $Username
    }
    else {
      Connect-AzureAD
    }
  }

  # Skype
  if(-not (Test-SkypeOnlineConnection)) {
    Disconnect-SkypeOnline
    
    if ($PSBoundParameters.ContainsKey('Username')) {
      Connect-SkypeOnline -UserName $Username -OverrideAdminDomain arkadinplatform.onmicrosoft.com
    }
    else {
      Connect-SkypeOnline
    }  
  }
}

Set-Alias -Name caip -Value Connect-ToAIP
Set-Alias -Name capc -Value Connect-ToAPPConsulting