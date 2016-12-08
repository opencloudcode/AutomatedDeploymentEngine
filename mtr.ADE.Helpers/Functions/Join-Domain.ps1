Function Join-Domain {
    Param(
        [string]$domainName,
        [string]$domainDnsSuffix,

        [Parameter(HelpMessage='Server Role Identifier, such as "ADCS""')]
        [string]$ServerRole,

        [ValidateSet('Solution Roles', 'Infrastructure Services')]
        [string]$RoleCategory, 

        [pscredential]$Credential,

        [switch]$Restart
    )


    if(!(Test-Connection "$domainName.$domainDnsSuffix" -Count 1 -Quiet)){
        Write-Error -Message "'$domainName.$domainDnsSuffix' cannot be found, please ensure the values are correct and DNS is functioning correctly" `
        -Category ResourceUnavailable
        return
    }
    else {
        Add-Computer -DomainName "$domainName.$domainDnsSuffix" -OUPath "OU=Computers,OU=$serverRole,OU=$roleCategory,OU=$domainName,DC=$domainName,DC=$domainDnsSuffix" -Credential $Credential -Restart:$Restart
    }
}