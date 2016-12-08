@{
    ServiceAccounts = @(
        @{
            RoleGroup = 'SQLServers'
            RoleAlias = 'SQL'
            Path = 'OU=Service Accounts,OU=SQLServers,OU=Solution Roles,OU=ParentOU'
            Identities = @(
                @{
                    Role = 'SQL','DB'
                    Name = 'sa_SqlInstall'
                    FriendlyName = 'SQLInstallAccount'
                    Description = 'Microsoft SQL Server Install Account'
                    AccountType = 'User'
                    MemberOf =  'LocalAdmin_SQL Servers', 
                                'Sec_RemoteInteractiveLogonRight_Deny'
                }
                @{
                    Role = 'SQL'
                    Name = 'sa_SQL_SqlDBE'
                    FriendlyName = 'SQLDatabaseEngine'
                    Description = 'SQL Server Database Engine Service Account'
                    AccountType = 'User'
                    MemberOf =  'Sec_SQL_ServiceLogonRight_Allow', 
                                'Sec_SQL_AssignPrimaryTokenPrivilege_Allow', 
                                'Sec_SQL_IncreaseQuotaPrivilege_Allow',
                                'Svc_SQL_SqlWriter_Start',
                                'Sec_RemoteInteractiveLogonRight_Deny'
                }
            )
        }#SQL
    )
}