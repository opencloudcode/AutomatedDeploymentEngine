Get-Module mtr.ADE | Remove-Module
Import-Module mtr.ADE

$UpdateExisting = $true
$ServiceAccounts = (Import-PowerShellDataFile -Path 'F:\Build\DSC\Configuration Data\ServiceAccounts.psd1').ServiceAccounts

$RoleGroup = 'SharePoint'
$Context      = ($ServiceAccounts | ? {$_.RoleGroup -eq $RoleGroup -or $_.RoleAlias -eq $RoleGroup})
#$Context       = $ServiceAccounts
$DomainDN      = (Get-AdDomain).DistinguishedName
$DomainDnsRoot = (Get-AdDomain).DnsRoot

foreach ($c in $Context){
    if(-not $c.Path.EndsWith($DomainDn)){
        $c.Path = "$($c.Path),$DomainDn"
    }
    foreach ($identity in $c.Identities){
        if($identity.Upn -eq $null){
            $identity.Upn = "$($identity.Name)@$DomainDnsRoot"
        }
        $properties = @{
            DisplayName       = $identity.Name
            samAccountName    = $identity.Name
            Description       = $identity.Description
            UserPrincipalName = $identity.Upn  
        }
        switch ($identity.AccountType){
            'gMSA'{
                $principals = $identity.Role | % {Get-AdComputer -Filter "name -like '*-$_-*'"}
                New-GroupManagedServiceAccount -Name $identity.Name `
                    -Description $identity.Description `
                    -Path $c.Path `
                    -DnsHostName "$($identity.Name).$DomainDnsRoot" `
                    -PrincipalsAllowedToRetrieveManagedPassword $principals -Verbose -Force

                $identity.MemberOf | % {
					if(-not([string]::IsNullOrWhiteSpace($_))){
						Add-ADGroupMember -Identity $_ -Members "$($identity.Name)$"
                    }
				}
            }
            'User'{
                try{
                    $AccountNotFound = $null
                    Get-AdUser -Identity $identity.Name -ErrorVariable AccountNotFound
                }
                catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
                    Write-Verbose "$($item.Name) does not exist"
                }

                if($AccountNotFound){
                    #Create Account
                    New-AdUser -Name $identity.Name `
                               -DisplayName $identity.Name `
                               -SamAccountName $identity.Name `
                               -UserPrincipalName $identity.Upn `
                               -Description $identity.Description `
                               -PasswordNeverExpires $true `
                               -AccountPassword (ConvertTo-SecureString -String (New-ComplexPassword -PasswordLength 200) -Force -AsPlainText) `
                               -Path $c.Path -PassThru
                }
                else{
                    #Update Account
                    Set-AdUser -Identity $identity.Name `
                               -Description $identity.Description

                    $user = Get-AdUser -Identity $identity.Name -Properties MemberOf
                    $user.MemberOf | % {Remove-ADGroupMember -Identity $_ -Members $identity.Name -Confirm:$false}
                }

                $identity.MemberOf | % {
					if(-not([string]::IsNullOrWhitespace($_))){	
						Add-ADGroupMember -Identity $_ -Members "$($identity.Name)"}
					}
            }
        }
    }
}