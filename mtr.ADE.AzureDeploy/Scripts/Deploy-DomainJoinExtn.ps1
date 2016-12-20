$AddsInfo = (Import-PowerShellDataFile -Path '<path to role info').ActiveDirectoryDomainServices
$RoleInfo = (Import-PowerShellDataFile -Path '<path to role info').Roles

$DomainName = 'lrs'
$DnsSuffix = 'test'
$rootOuDn = "DC=$DomainName,DC=$DnsSuffix" 

$vmName
$resourceGroup
$location

$domainFqdn = "$domainName.$dnsSuffix"
$domainUser
$domainJoinOU
$domainJoinOptions = 3
$restart = $true

$Cred = (Get-Credential)
$Cred.UserName
$Cred.Password

$roleInformation = 
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

function New-DomainJoinSettings {
    [CmdLetBinding()]
    Param(
        [string]$DomainName,
        [string]$DnsSuffix,
        [string]$OrganizationalUnit,
        [string]$Restart,
        [int]$DomainJoinOptions = 3,
        [pscredential]$Credential
    )

    $_userName = $Credential.UserName
    if($_userName.Contains('@')){
        #upn format - split at @ and take first part of UserName
    }
    if($_userName.Contains('\')){
        #netbios format, split at '\' and take second part for username
    }

    $settingString = "{ 
            'Name': '$domainFqdn', 
            'User': '$domainFqdn\\$domainUser', 
            'OUPath': '$domainJoinOU',
            'Restart': '$restart', 
            'Options': '$domainJoinOptions' 
        }"
    $protectedSettingString = "{ 'Password': '$password' }"

    $property = @{
        SettingString = $settingString.Replace("'",'"')
        ProtectedSettingString = $protectedSettingString.Replace("'",'"')

    }
    $returnObj = New-Object -TypeName PSObject -Property $property
    Write-Output $returnObj
}

if($AzureRM){
    Import-Module AzureRm
    Login-AzureRmAccount
    Get-AzureRmSubscription | Out-GridView -PassThru | Set-AzureRmContext




    Set-AzureRmVMExtension -ResourceGroupName $resourceGroup -ExtensionType "JsonADDomainExtension" `
        -Name "joindomain" -Publisher "Microsoft.Compute" -TypeHandlerVersion "1.0" `
        -VMName $vmName -Location $location -SettingString $domainJoinSettings `
        -ProtectedSettingString $domainJoinPassword
}
elseif($AzureCli){

}
