Get-Module mtr.ADE | Remove-Module
Import-Module mtr.ADE
Import-Molude ActiveDirectory

$UpdateExisting = $true
$Accounts = (Import-PowerShellDataFile -Path 'F:\Build\DSC\Configuration Data\ManagementAccounts.psd1').ManagementAccounts

$Context       = $Accounts
$DomainDN      = (Get-AdDomain).DistinguishedName
$DomainDnsRoot = (Get-AdDomain).DnsRoot

foreach ($c in $Context){
    if(-not $c.Path.EndsWith($DomainDn)){
        $c.Path = "$($c.Path),$DomainDn"
    }

    if(-not (Test-Path -Path "AD:\$($c.Path)")){Create-Item -Path "AD:\$($c.Path)"}

    foreach ($identity in $c.Identities){
        if($identity.Upn -eq $null){
            $identity.Upn = "$($identity.UserName)@$DomainDnsRoot"
        }
        $properties = @{
            Name                = $identity.UserName
            DisplayName         = $identity.UserName
            samAccountName      = $identity.UserName
            GivenName           = $identity.FirstName
            Surname             = $identity.LastName
            Description         = $identity.Description
            UserPrincipalName   = $identity.Upn  
        }


        try{
            $AccountNotFound = $null
            Get-AdUser -Identity $identity.UserName -ErrorVariable AccountNotFound
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            Write-Verbose "$($identity.UserName) does not exist"
        }

        if($AccountNotFound){
            $password = (ConvertTo-SecureString -String (New-ComplexPassword -PasswordLength 10) -Force -AsPlainText)
            #Create Account
            New-AdUser @Properties `
                        -PasswordNeverExpires $false `
                        -AccountPassword $password -ChangePasswordAtLogon $true `
                        -Path $c.Path -Enabled $true -PassThru
        }
        else{
            #Update Account
            Set-AdUser -Identity $identity.UserName `
                        -Description $identity.Description

            $user = Get-AdUser -Identity $identity.UserName -Properties MemberOf
            $user.MemberOf | % {Remove-ADGroupMember -Identity $_ -Members $identity.UserName -Confirm:$false}
        }

        $identity.MemberOf | % {
            if(-not([string]::IsNullOrWhitespace($_))){	
                Add-ADGroupMember -Identity $_ -Members "$($identity.UserName)"
            }
        }
    }
}