#Import role information
Get-Verb
$path = ''
$roles = (Import-PowerShellDataFile -Path $path).Roles

$vmName
$resourceGroup
$location

$domainFqdn
$domainUser
$domainJoinOU
$domainJoinOptions = 3
$restart = $true

$Cred = (Get-Credential)
$Cred.UserName
$Cred.Password

if($AzureRM){
    Import-Module AzureRm
    Login-AzureRmAccount
    Get-AzureRmSubscription | Out-GridView -PassThru | Set-AzureRmContext

    $domainJoinSettings = "{ 
            'Name': '$domainFqdn', 
            'User': '$domainFqdn\\$domainUser', 
            'OUPath': '$domainJoinOU',
            'Restart': '$restart', 
            'Options': '$domainJoinOptions' 
        }"
    $domainJoinPassword = "{ 'Password': '$password' }"

    $domainJoinSettings = $domainJoinSettings.Replace("'",'"')
    $domainJoinPassword = $domainJoinPassword.Replace("'",'"')


    Set-AzureRmVMExtension -ResourceGroupName $resourceGroup -ExtensionType "JsonADDomainExtension" `
        -Name "joindomain" -Publisher "Microsoft.Compute" -TypeHandlerVersion "1.0" `
        -VMName $vmName -Location $location -SettingString $domainJoinSettings `
        -ProtectedSettingString $domainJoinPassword
}
elseif($AzureCli){

}