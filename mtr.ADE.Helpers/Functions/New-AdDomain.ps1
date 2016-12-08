#
# Create_Domain.ps1
#
Function Get-DomainParametersFromFile {
    Param(
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [ValidateSet('Dev', 'CI', 'Test')]
        [string]$Environment
    )

    $config = (Import-PowerShellDataFile -Path $Path).ActiveDirectoryDomainServices 

    $NetBIOS = $config.$Environment.NetBIOSName
    $dnsSuffix = $config.$Environment.dnsSuffix

    $properties = @{
        DomainFQDN = "$($NetBIOS)$($dnsSuffix)"
        DomainNetBios = $NetBIOS
        ForestMode = $config.ForestMode
        DomainMode = $config.DomainMode
        SysVolPath = $config.SysVolPath
        NtdsDataPath = $config.NtdsDataPath
        NtdsLogPath = $config.NtdsLogsPath
    }

    Write-Output $properties
}

Function New-AdDomain(){
	Param(
		[ValidateNotNullOrEmpty()]
		[Parameter(Mandatory=$true)]
		[string]$DomainFQDN,
		[ValidateNotNullOrEmpty()]
		[Parameter(Mandatory=$true)]
		[string]$DomainNetBIOS,
        [string]$ForestMode,
        [string]$DomainMode,
        [string]$SysVolPath,
        [string]$NtdsDataPath,
        [string]$NtdsLogPath,
		[switch]$SecondaryController
	)
	# Create New Forest, add Domain Controller 
	$DomainFQDN = $DomainFQDN
	$DomainNetBIOS = $DomainNetBIOS
	Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools 
	Install-WindowsFeature -Name RSAT-AD-Tools -IncludeAllSubFeature -IncludeManagementTools 
	Import-Module ADDSDeployment 

	if(-not $SecondaryController){
		Install-ADDSForest -DatabasePath $NtdsDataPath -LogPath $NtdsLogPath -SysvolPath $SysVolPath `
		-ForestMode $ForestMode `
		-DomainMode $DomainMode `
		-DomainName $DomainFQDN `
		-DomainNetbiosName $DomainNetBIOS `
		-InstallDns:$true `
		-NoRebootOnCompletion:$true `
		-CreateDnsDelegation:$false `
		-Force:$true
	}
	elseif ($SecondaryController){
		Install-ADDSDomainController -DatabasePath $NtdsDataPath -LogPath $NtdsLogPath -SysvolPath $SysVolPath `
		-DomainName $DomainFQDN `
		-InstallDns:$true `
		-NoGlobalCatalog:$false `
		-SiteName 'Default-First-Site-Name' `
		-NoRebootOnCompletion:$true `
        -Credential (Get-Credential) `
		-Force:$true
	}
}

