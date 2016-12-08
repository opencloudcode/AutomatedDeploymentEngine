Get-Module mtr.ADE | Remove-Module
Import-Module mtr.ADE

$RoleGroup = 'DPS'
$Credential = Get-Credential -Message 'Enter administrative credentials, required to install AD Service Account on target host(s)'
$SvcAccountInfo = (Import-PowerShellDataFile -Path 'F:\DFS\DscRepo\Documents\_ConfigurationData\EnvironmentConfiguration\ServiceAccounts.psd1').ServiceAccounts
$SvcAccountInfo  = ($SvcAccountInfo | ? {($_.RoleGroup -eq $RoleGroup -or $_.RoleAlias -eq $RoleGroup)})

foreach($info in $SvcAccountInfo){
    foreach ($id in $Info.Identities){
        foreach($role in $id.Role){
            $Computers = (Get-AdComputer -Filter "name -like '*-$role-*'").Name  
                     
            if($id.AccountType -eq 'gMSA' -and $id.ServiceType -eq 'NTService'){
                Set-ServiceIdentity -Filter "name = '$($id.ServiceName)'" -ComputerName $Computers -Identity "$($id.Name)" -Password $null -Domain 'DataCollections' -Credential $Credential -Verbose
            }
            elseif($id.AccountType -eq 'gMSA' -and $id.ServiceType -eq 'WebAppPool'){
                Install-ManagedServiceAccount -Identity "$($id.Name)$" -ComputerName $Computers -Credential $Credential
                Set-IISApplicationPoolIdentity -Name $id.ServiceName -ComputerName $Computers -Identity "$ENV:UserDomain\$($id.Name)$" -Verbose   
            }
            elseif($id.AccountType -eq 'User'){
                Get-AdUser $userName | Set-AdUser -Enabled $true
                $Password = New-ComplexPassword -PasswordLength 200
                Set-ADAccountPassword -Identity $id.Name -NewPassword ($Password | ConvertTo-SecureString -AsPlainText -Force)
                
                if($id.ServiceType -eq 'NTService'){
                    Set-ServiceIdentity -Filter "name = '$($id.ServiceName)'" -ComputerName $Computers -Identity "$($id.Name)" -Password $Password -Domain 'DataCollections' -Verbose
                }
                elseif($id.ServiceType -eq 'WebAppPool'){
                    $userName = "$ENV:UserDomain\$($id.Name)"
                    $securePassword = ($Password | ConvertTo-SecureString -AsPlainText -Force)
                    $AppPoolCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $securePassword
                    Set-IISApplicationPoolIdentity -Name $id.ServiceName -ComputerName $Computers -Credential $AppPoolCredential -Verbose              
                }
            }
        }  
    }
}