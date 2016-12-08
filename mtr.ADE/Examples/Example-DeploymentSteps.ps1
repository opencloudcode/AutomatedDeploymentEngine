Get-Module -Name "mtr.ADE" | Remove-Module
Import-Module -Name "F:\DFS\DscRepo\Modules\Custom\mtrade\mtrade.psm1"
$EnvConfig = Import-PowerShellDataFile -Path 'F:\DFS\DscRepo\Modules\Custom\mtrade\EnvironmentConfiguration.psd1'



function InstallMGMTFeatures{
    $Servers = (Get-ADComputer -Filter {name -like "*-MGMT-*"}).Name
    $DfsJob = Invoke-Command -ComputerName $Servers -ScriptBlock {Install-WindowsFeature FS-DFS-Namespace, FS-DFS-Replication, RSAT-DFS-Mgmt-Con} -AsJob
    Wait-Job -Job $DfsJob
    if($DfsJob.State -eq "Completed"){Remove-Job $DfsJob}

    $RsatJob = Invoke-Command -ComputerName $Servers -ScriptBlock {Get-WindowsFeature RSAT-* | Install-WindowsFeature} -AsJob
    Wait-Job -Job $RsatJob
    if($RsatJob.State -eq "Completed"){Remove-Job $RsatJob}

    Get-Job
}


function BuildOUs{
    $RootDN = (Get-ADDomain).DistinguishedName
    Assert-ADOrganisationalUnit -ParentDistinguishedName $RootDN -Children $EnvConfig.SolutionOUs -DefaultOUs $EnvConfig.DefaultOUs -CreateIfAbsent $true -Verbose
}


function BuildDscRepo{
    Assert-FolderStructure -FolderStructure $EnvConfig.DscFolderStructure.Structure -ParentPath $EnvConfig.DscFolderStructure.Root -CreateIfNotExist:$true
    New-Item \\DCS-PD-MGMT-02\DFS -ItemType Directory
    Copy-Item F:\DFS -Destination \\DCS-PD-MGMT-02\F$\DFS -Recurse -Container
}


function RemoveGUI{
    $Servers = @("DCS-PD-ADDS-01","DCS-PD-ADDS-02","DCS-PD-ADCS-01","DCS-PD-ADCS-02")
    Invoke-Command -ComputerName $Servers -ScriptBlock {Remove-WindowsFeature Server-GUI-Shell} -AsJob
}


function GetDscCerts{
    Get-RemoteCertificate -CentralCertStore 'F:\DFS\DSCRepo\Public Certificates' -ADSearchFilter 'DCS-*' -ADSearchBase 'OU=Data Collections, DC=Datacollections, DC=Production' -CertTemplateName 'PowerShell DSC Encryption CSP' -Export $true


    $Bob = Get-CertificateFromTemplate -Computer $Servers -CertTemplateName 'PowerShell DSC Encryption CSP'
    $Bob.Certificates | % {$_ | Export-Certificate -FilePath (Join-Path -Path "F:\DFS\DSCRepo\Test" -ChildPath "$($_.PSComputerName).cer")}
}


function CreateConfigDoc{
    $servers = (Get-ADComputer -SearchBase "OU=Solution Roles,OU=Data Collections,$($(Get-ADDomain).DistinguishedName)" -Filter * | select name).name
    $ConfigData = New-DscConfigurationData -Computer $servers -CertificateLocation "\\datacollections\DSC\Public Certificates"
    Out-DscConfigurationDataFile -ConfigurationData $ConfigData -FilePath "F:\DFS\DscRepo\Documents\_ConfigurationData\SolutionRoles.psd1"
}


function CreateLCMConfigs{

    [DSCLocalConfigurationManager()]
    Configuration ConfigureLCM{
        Node $AllNodes.NodeName {
            Settings{
                CertificateID = $node.Thumbprint
                ConfigurationMode = 'ApplyAndAutoCorrect' 
                RefreshMode = 'Push'
            }
        }
    }


    ConfigureLCM -ConfigurationData "F:\DFS\DscRepo\Documents\_ConfigurationData\SolutionRoles.psd1" -OutputPath "F:\DFS\DscRepo\Documents\AllServers" -Verbose

    Set-DscLocalConfigurationManager -Path F:\DFS\DscRepo\Documents\AllServers -ComputerName $servers -Verbose 
}


function DeployModules {
    $sourcePath = "\\$ENV:userdomain\dsc\Modules\Gallery"
    $outPath = "\\$ENV:userdomain\dsc\documents\AllServers"

    Configuration CopyModules{
        Param ( 
            [string[]] $nodename,
            [string] $sourcePath 
        )
        Import-DscResource -ModuleName PSDesiredStateConfiguration
    
        Node $nodename{
            File CopyModules
            {
			    Ensure = 'Present'
			    Type = 'Directory'
                SourcePath = $sourcePath
			    DestinationPath = 'C:\Program Files\WindowsPowerShell\Modules'
                Recurse = $true
                Checksum = "SHA-256"
                MatchSource = $true
			
		    }
        }
    }

    CopyModules -Nodename $servers -sourcePath $sourcePath -OutputPath $outPath
    Start-DscConfiguration -ComputerName $servers -Path $outPath -Wait -Verbose -Force   
}


function CreateDCSFileShares{   
    $DfsJob = Invoke-Command -ComputerName $FileServers -ScriptBlock {Install-WindowsFeature FS-DFS-Namespace, FS-DFS-Replication, RSAT-DFS-Mgmt-Con} -AsJob -Verbose
    Wait-Job -Job $DfsJob
    if($DfsJob.State -eq "Completed"){Remove-Job $DfsJob}

    $FileServers = (Get-ADComputer -Filter {name -like "*-FS-*"}).Name
    $FileServers | % {
        New-Item -Path (Join-Path -Path "\\$_\F$" -ChildPath "DFS") -ItemType Directory
        New-Item -Path (Join-Path -Path "\\$_\F$\DFS" -ChildPath "_Roots") -ItemType Directory
        Assert-FolderStructure -FolderStructure $EnvConfig.DataCollectionsFolderStructure.Structure -ParentPath "\\$_\F$\DFS" -CreateIfNotExist:$true
    }

}


function UpdateAllNodesDoc{
    $AllNodesDoc = Import-PowerShellDataFile -Path "\\datacollections\dsc\Documents\_ConfigurationData\SolutionRoles.psd1"
    $MergedConfig = Merge-DscConfigurationData -AllNodes $AllNodesDoc.AllNodes -RoleInformation $EnvConfig.RoleInformation
    Out-DscConfigurationDataFile -ConfigurationData $MergedConfig -FilePath "F:\DFS\DscRepo\Documents\_ConfigurationData\Output.psd1"
}

