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
			MatchKey = 'NodeName'
			MatchValue = '*-SQL-*'
            RoleGroup = 'SQLServers'
            Role = 'SQL Server for XX'
            RoleID = 'SQL'
            RoleType = 'Solution'
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
            MatchKey = 'NodeName'
			MatchValue = '*-WEB-*'
			RoleID = 'WEB'
			Role = 'Some Web Server'
            RoleGroup = 'WebServers'
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
        }#WebServer
    );
}