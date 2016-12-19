$path = ''
$DomainName = 'lrs'
$DnsSuffix = 'test'
$rootOuDn = "DC=$DomainName,DC=$DnsSuffix" 

$roleInformation = (Import-PowerShellDataFile -Path $path).Roles
$filtered = $roleInformation.Where($_.RoleId -ne 'DC' -and $_.RoleId -ne 'ADDS')

if($filtered -ne $null){
    Login-AzureRmAccount
    Get-AzureRmSubscription | Out-GridView -PassThru | Set-AzureRmContext
}
else {
    Write-Error 'No role information'
    Exit
}

foreach ($role in $filtered){
    $ouPath = $role.AdComputerPath
    if(-not $ouPath.EndsWith($rootOuDn)){$ouPath = "$ouPath,$rootOuDn"}

}


