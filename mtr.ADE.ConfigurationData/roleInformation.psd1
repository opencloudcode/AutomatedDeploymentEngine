@{    
    RoleInformation = @(
        @{
            MatchKey = 'NodeName'
            MatchValue = '*'
			SharedInformation = @(
				@{
					Win2012R2Sxs = '\\dfssharepath\dsc\Source Files\Windows Server\2012_R2\sources\sxs'
					DefaultWebSitePath = 'C:\inetpub\wwwroot'
					SharedSource = '\\dfssharepath\dsc\Source Files'
					LocalInstallerCache = 'D:\Temp'                  
				}
            );
            PSDscAllowDomainUser = $true           
        }#AllNodes
        @{
            #Properties used for matching against nodes - not copied
			MatchKey = 'NodeName'
			MatchValue = '*-SQL-*'
            #Information to copy into node configuration file (AllNodes) for DSC
            Role = 'SQL Server Test Example'
            RoleGroup = 'Test Examples'
            RoleID = 'SQL'
            SqlServer = @(
                @{
                    SqlSourceFolder = 'SQL\SW_DVD9_SQL_Svr_Ent_Core_2014w_SP1_64Bit_English_-2_MLF_X20-28988'
                    SqlInstances = @(
                        @{
                            InstanceName = 'DPSP'
                            Port = '1433'
                            ProtocolName = 'tcp'
                            Features = 'SQLENGINE,FULLTEXT,ADV_SSMS,AS,IS,RS'
                            SqlAdmins = 'BUILTIN\Administrators'
                            InstallSharedDir = 'F:\Program Files\Microsoft SQL Server'
                            InstallSharedWOWDir = 'F:\Program Files (x86)\Microsoft SQL Server'
                            InstallSqlDataDir = 'I:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data'
                            InstanceDir = 'F:\Program Files\Microsoft SQL Server'
                            SqlCollation='Latin1_General_CI_AS'
							#Database and Logs directories will have instance name appended to path during configuration.
                            SqlUserDBDir = 'I:\MSSQL\DBData'
                            SqlUserDBLogDir = 'J:\MSSQL\DBLogs'
                            SqlTempDBDir = 'G:\MSSQL\TempDBData'
                            SqlTempDBLogDir = 'H:\MSSQL\TempDBLogs'
                            SqlBackupDir = 'O:\MSSQL\Backup'
                            AsCollation='Latin1_General_CI_AS'
                            AsDataDir = 'I:\MSAS\ASData'
                            AsLogDir = 'J:\MSAS\ASLogs'
                            AsBackupDir = 'O:\MSAS\Backup'
                            AsTempDir = 'G:\MSAS\ASTemp'
                            AsConfigDir = 'F:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Config'
                            BrowserSvcStartupType = 'Automatic'
                        }
                    )
                }
            )
        }#SQLServer
        @{
            #Properties used for matching against nodes - not copied
            MatchKey = 'NodeName'
			MatchValue = '*-WEB-*'
            #Information to copy into node configuration file (AllNodes) for DSC
			Role = 'Web Server Test Example'
            RoleGroup = 'Test Examples'
			RoleID = 'WEB'
            IISWebServer = @(
                @{
                    WebAppPools = @(
                        @{
                            Name = 'AppPool'      
                        }
                    )
                    WebSites = @(
                        @{
                            Name = 'MyWebSite'
                            Description = 'A Website, for me, by me'
                            PhysicalPath ='C:\WebSites\MyWebSite'
                            SourcePath = '\\SiteContentStore\MyWebSite'
                            BindingInformation = @(
                                @{ 
                                    Protocol = 'https' 
                                    Port = 443
                                    HostName = 'mywebsite.com'
                                    CertificateRequired = $true
                                } 
                                @{ 
                                    Protocol = 'http' 
                                    Port = 80
                                    HostName = 'mywebiste.com'
                                    CertificateRequired = $true
                                } 
                            )
                        }
                    )    
                }    
            )
             
        }#WebServer
        @{
            #Properties used for matching against nodes - not copied
			MatchKey = 'NodeName'
			MatchValue = '*-TST-*'
            #Information to copy into node configuration file (AllNodes) for DSC
            Role = 'Azure Virtual Machine Test Example'
            RoleGroup = 'Test Examples'
            RoleID = 'TST'
            RoleType = 'Solution'
            AzureDeploy = @{
                InstanceSize = 'DS3_V2'
                InstanceCount = 2
                VirtualNetworkSubnetName = 'MySubnet'
                PublicIP = @{ #Optional property. Only specify if you want PIP
                    Type = 'Dynamic' #Dynamic/Static
                    IPAddress = $null #only required if Static
                    DnsName = 'mydns' #first part of dns name
                    DnsSuffix = '' #If blank, build using resourceGroup().Location .cloudapp.azure.com
                }
                AzureLoadBalancer = @{ #Optional property. Only specify if you want LB
                    VirtualNetworkSubnetName = 'MyLoadBalancerSubnet'
                    PublicIP = @{ #Optional property. Only specify if you want PIP
                        Type = 'Dynamic' #Dynamic/Static
                        IPAddress = $null #only required if Static
                        DnsName = 'mydns' #first part of dns name
                        DnsSuffix = '' #If blank, build using resourceGroup().Location .cloudapp.azure.com
                    }
                }
                VirtualMachineConfiguration = @{
                    DataDisks = @(#DataDisks count is required, should be retrieved from this array size. 
                    ##Means all required disks must be defined
                        @{
                            Name = 'AppData' #Disk name/label
                            UriSuffix = '-AppData.vhd' #Suffix for VHD. Prefix is VM Name
                            SizeInGB = 20
                            StorageType = 'Premium' #Choice of 'Premium' or 'Standard' currently supported
                        }
                    )
                }
            }
        }#AzureConfig
    );
}