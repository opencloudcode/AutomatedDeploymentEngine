Get-Module mtr.ADE | Remove-Module
Import-Module mtr.ADE


Function Set-Password{
    $RoleGroup = 'SharePoint'
    $SvcAccountInfo = (Import-PowerShellDataFile -Path 'F:\Build\DSC\Configuration Data\ServiceAccounts.psd1').ServiceAccounts
    $SvcAccountInfo  = ($SvcAccountInfo | ? {($_.RoleGroup -eq $RoleGroup -or $_.RoleAlias -eq $RoleGroup)})

    foreach($info in $SvcAccountInfo){
        foreach ($id in $Info.Identities){
            if($id.AccountType -eq 'User'){
                Get-AdUser $id.Name | Set-AdUser -Enabled $true
                $Password = New-ComplexPassword -PasswordLength 200
                Set-ADAccountPassword -Identity $id.Name -NewPassword ($Password | ConvertTo-SecureString -AsPlainText -Force)
                
                $Properties = @{
                    UserName = $id.Name
                    Password = $Password
                }
                $result = New-Object -TypeName PSObject -Property $Properties
                Write-Output $result
            }
        }  
    }
}

Set-Password | Select-Object UserName, Password | Export-Csv -Path "F:\Build\Passwords.csv" -NoTypeInformation