function New-GroupManagedServiceAccount{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName = $true,
                   HelpMessage = "Name of Service Account to be created, used for Name, SamAccountName, and DisplayName properites. Account must be between 6 and 20 characters")]
        [ValidateLength(6, 20)]
        [Alias('ServiceAccountName')]
        [string]$Name,

        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName = $true)]
        [Alias('ServiceAccountDescription')]
        [string]$Description,

        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName = $true,
                   HelpMessage = "Distinguished Name of Organisational Unit where account will be created. Does not support wildcards")]
        [ValidateScript({Test-Path "AD:\$_"})]
        [Alias('ServiceAccountPath', 'PSPath')]
        [string]$Path,

        [Parameter(Mandatory=$false,
                   HelpMessage="The DNS Hostname of the Service Account. If left blank, domain DNS Suffix will be added to Name provided")]
        [string]$DnsHostName,

        [Parameter(ParameterSetName = 'UseGroup',
                   HelpMessage = "Name of Domain Local Group to create and use as container for Principals Allowed To Retrieve Managed Password")]
        [Alias('GroupName')]
        [string]$Group,

        [Parameter(ParameterSetName = 'UseGroup')]
        [ValidateNotNullOrEmpty()]
        [string]$GroupDescription,

        [Parameter(ParameterSetName = 'UseGroup',
                   HelpMessage = "Distinguished Name of Organisational Unit where group will be created. Does not support wildcards")]
        [ValidateScript({Test-Path "AD:\$_"})]
        [string]$GroupPath,

        [Parameter(Mandatory=$false)]
        [Alias('GroupMembers', 'Members')]
        [object[]]$PrincipalsAllowedToRetrieveManagedPassword,

        [Parameter(Mandatory=$false)]
        [switch]$Force,

        [Parameter(Mandatory=$false)]
        [switch]$PassThru

    )
    if($PSCmdLet.ParameterSetName -eq 'UseGroup'){

        #Check for group, create if necessary
        try{
            Write-Verbose "Checking for existence of Domain Group called '$Group'"
            $ExistingGroup = Get-AdGroup -Identity $Group
        }
        catch{
            #Catch required as Get-AdGroup can't be silenced (ignores ErrorAction SilentlyContinue and generates error if group isn't found)
        }
        if($ExistingGroup){
        
            Write-Verbose "--> $Group exists"
        }
        else{
            if($PSCmdLet.ShouldProcess("-> CREATE: '$Group'")){
                Write-Verbose "--> $Group not found. Will create"
                New-AdGroup -Name $Group -DisplayName $Group -SamAccountName $Group `
                            -Description "Principals allowed to retrieve managed password for $Group" `
                            -Path $GroupPath `
                            -GroupScope DomainLocal -GroupCategory Security
            }
        }
    }
    

    #Add any specified accounts to group
    if($PrincipalsAllowedToRetrieveManagedPassword -ne $null `
       -and $PrincipalsAllowedToRetrieveManagedPassword.Count -gt 0 `
       -and $PSCmdLet.ParameterSetName -eq 'UseGroup'){
        if($PSCmdLet.ShouldProcess("$Env:ComputerName-> ADD: group members to '$Group'")){
            Write-Verbose "-->Adding '$($PrincipalsAllowedToRetrieveManagedPassword.Name)' to '$Group'"
            Add-ADGroupMember -Identity $Group -Member $PrincipalsAllowedToRetrieveManagedPassword
        }
    }


    #Check for account, create if necessary
    try{
        Write-Verbose "Checking for existence of Managed Service Account called $Name"
        $ExistingAccount = Get-AdServiceAccount -Identity $Name
    }
    catch{
        #Catch required because Get-AdServiceAccount cannot be silenced when no account is available. 
    }

    if($PSCmdLet.ParameterSetName -eq 'UseGroup'){
        $AdPrincipals = Get-ADGroup -Identity $Group
    }
    else{
        $AdPrincipals = $PrincipalsAllowedToRetrieveManagedPassword
    }

    if($ExistingAccount){
        Write-Verbose "--> '$Name' found"
        if($Force){
            Write-Verbose "Updating '$Name'"
            Set-AdServiceAccount -Identity $Name -DisplayName $Name -SamAccountName $Name `
                                 -Description $Description `
                                 -DNSHostName $DnsHostName `
                                 -PrincipalsAllowedToRetrieveManagedPassword $AdPrincipals -PassThru:$PassThru
        }
    }
    else{
        if($DnsHostName -eq $Null){$DnsHostName = "$Name.$($(Get-AdDomain).DnsRoot)"}

        if($PsCmdLet.ShouldProcess("$Env:ComputerName-> CREATE: '$Name' Managed Service Account")){
            Write-Verbose "--> '$Name' not found. Will create"
            New-AdServiceAccount -Name $Name -DisplayName $Name -SamAccountName $Name `
                                    -Description $Description `
                                    -Path $Path `
                                    -DNSHostName $DnsHostName `
                                    -PrincipalsAllowedToRetrieveManagedPassword $AdPrincipals -PassThru:$PassThru
        }
    }
}



<#
    $ParentPath ="OU=DPS, OU=Solution Roles, OU=Data Collections, $($(Get-AdDomain).DistinguishedName)"
    $AccountPath = "OU=Service Accounts,$ParentPath"
    $GroupPath = "OU=Rights, OU=Administrative Groups,$ParentPath"
    $Principals = (Get-AdComputer -Filter "name -like '*-DPSP-*'")

    #Example using Group Membership for Principals
    New-GroupManagedServiceAccount -Name "sa_DpsDaemon" -Description "Group Managed Service Account for the DPS Distributor Daemon" -Path $AccountPath `
                                   -DnsHostName "sa_DpsDaemon.datacollections.production" `
                                   -Group "sa_DpsDaemon_RMP" -GroupDescription "Contains Principals permitted to retrieve managed password for sa_DpsDaemon" `
                                   -GroupPath $GroupPath -PrincipalsAllowedToRetrieveManagedPassword $Principals -Verbose -Force -PassThru

    #Example using direct principal mapping
    New-GroupManagedServiceAccount -Name "sa_DpsDaemon" -Description "Group Managed Service Account for the DPS Distributor Daemon" -Path $AccountPath `
                                   -DnsHostName "sa_DpsDaemon.datacollections.production" `
                                   -PrincipalsAllowedToRetrieveManagedPassword $Principals -Verbose -Force -PassThru

#>