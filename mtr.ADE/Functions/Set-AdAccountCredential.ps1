Function Set-AdAccountCredential {
    <#
    .Synopsis

    .DESCRIPTION
    .EXAMPLE
		$Credential = Set-AdAccountCredential -User "NewUser" `
            -Path "OU=Service Accounts, OU=Application, DC=Domain, DC=Com" `
            -PasswordLength 200 `
            -Description "A new service account" `
            -MemberOf @("Domain Admins", "LocalAdmin_Member Servers") `
            -Verbose
    .OUTPUTS
		This function outputs The password for the stated account in plain text
    .FUNCTIONALITY

    #>

    #Requires -Modules ActiveDirectory   
	[CmdletBinding()]
    [OutputType([PSCredential])]
    Param
    (      
        [Parameter(Mandatory=$true)]
        [ValidateLength(4,20)]
		[string]$Name,
        [Parameter(
            Mandatory=$true, 
            HelpMessage = 'Distinguished Name of Organisational Unit for account to be created in'
        )]
		[string]$Path,
        [Parameter(Mandatory=$false)]
		[int]$PasswordLength = 200,
        [Parameter(Mandatory=$false)]
		[string]$Description, 
        [Parameter(Mandatory=$false)]
        [string[]]$MemberOf, 
        [Parameter(Mandatory=$false)]
        [string]$Password
    )

    if ($Name -match '@'){
        $userName = $Username.Split('@')[0]
        $userDomain = $Username.Split('@')[1]    
    }
    else
    {
        $userName = $Name
    }

    if ($userDomain -eq $null){$userDomain = $env:USERDNSDOMAIN}
    
    $userObject = Get-ADUser -Filter * | where {$_.samaccountname -eq $userName}
    if ($userObject){
        Write-verbose "User Exists, Reseting password"
        if([string]::IsNullOrEmpty($Password)){$password = New-ComplexPassword -PasswordLength $PasswordLength}

        Set-ADAccountPassword -Identity $userObject -NewPassword ($Password | ConvertTo-SecureString -AsPlainText -Force) -Reset | Out-Null
        $userObject | Enable-ADAccount | Out-Null
    } 
    else {
        if([string]::IsNullOrEmpty($Password)){$password = New-ComplexPassword -PasswordLength $PasswordLength}

        New-ADUser -Name $userName `
            -DisplayName $userName `
            -SamAccountName $userName `
            -UserPrincipalName "$userName@$userDomain" `
            -Description $Description `
            -ChangePasswordAtLogon $false `
            -AccountPassword ($Password | ConvertTo-SecureString -AsPlainText -Force) `
            -Path $Path `
            -Enabled $true `
            -CannotChangePassword $true | Out-Null
    }
    
    foreach($group in $MemberOf){
        Add-ADGroupMember -Identity $group -Members $userName
    }

    [PSCredential]$InstallCredential = New-Object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList "$userDomain\$userName", ($password | ConvertTo-SecureString -AsPlainText -Force)

    Write-Output $InstallCredential
}
