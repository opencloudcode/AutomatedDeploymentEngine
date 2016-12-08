@{
    SecurityGroups = @(
        @{
            Type = 'Roles'
            Context = 'Parent'
            ContextDescription = 'Default, top-level security roles'
            Path = 'OU=Roles, OU=Administrative Groups, OU=ParentOU'
            Groups = @(
                @{
                    Name = 'Example_Role'
                    Description = 'Contains members of the "Example_Role", this role is granted rights appropriate to the role'
                    MemberOf = 'AD_ParentOU_RegisterSPN',
                               'Sec_RemoteInteractiveLogonRight_Allow'
                }
            )
        }
        @{
            Type = 'Rights'
            Context = 'Parent'
            ContextDescription = 'Default, top-level security rights'
            Path = 'OU=Rights, OU=Administrative Groups, OU=ParentOU'
            Groups = @(
                @{
                    Name = 'LocalAdmin_SQL Servers'
                    Description = 'This group is added to the BUILIN\Administrators group for all SQL Role Servers'
                    PrivilegeTo = 'BUILTIN\Administrators'
                    Privilege   = 'Member'
                }
                @{
                    Name = 'AD_ParentOU_RegisterSPN'
                    Description = 'Grants ability to register Service Principal Names for systems under ParentOU'
                    PrivilegeTo = 'ADDS'
                    Privilege   = 'Validated Write to Service Principal Names'
                }
                @{
                    Name = 'Sec_BatchLogonRight_Deny'
                    Description = 'Denies ability to Logon as a Batch Job on all servers under ParentOU structure'
                    PrivilegeTo = 'LSA'
                    Privilege   = 'SeDenyBatchLogonRight'
                }
                @{
                    Name = 'Sec_RemoteInteractiveLogonRight_Deny'
                    Description = 'Denies ability to Logon using Remote Desktop Services on all servers under ParentOU structure'
                    PrivilegeTo = 'LSA'
                    Privilege   = 'SeDenyRemoteInteractiveLogonRight'
                }
                @{
                    Name = 'Sec_RemoteInteractiveLogonRight_Allow'
                    Description = 'Grants ability to Logon using Remote Desktop Services on all servers under ParentOU structure'
                    PrivilegeTo = 'LSA'
                    Privilege   = 'SeRemoteInteractiveLogonRight'
                }
            )
        }#ParentOU
        @{
            Type = 'Rights'
            Context = 'File Services'
            ContextDescription = 'File Services security rights'
            Path = 'OU=Rights, OU=Administrative Groups, OU=Infrastructure Services, OU=ParentOU'
            Groups = @(
                @{
                    Name = 'Sec_FS_RemoteInteractiveLogonRight_Allow'
                    Description = 'Grants ability to Logon using Remote Desktop Services on all File Services (FS) Servers'
                    PrivilegeTo = 'LSA'
                    Privilege = 'SeRemoteInteractiveLogonRight'
                }
                @{
                    Name = 'FS_Archive_Read'
                    Description = 'Read Permissions for File Services Archive Share and Folder Structure'
                    PrivilegeTo = 'FILE\F:\Archive'
                    Privilege   = 'Read'
                }
                @{
                    Name = 'FS_Archive_Write'
                    Description = 'Write Permissions for File Services Archive Share and Folder Structure'
                    PrivilegeTo = 'FILE\F:\Archive'
                    Privilege   = 'Write'
                }
                @{
                    Name = 'FS_Archive_Modify'
                    Description = 'Modify Permissions for File Service Archive Share and Folder Structure'
                    PrivilegeTo = 'FILE\F:\Archive'
                    Privilege   = 'Modify'                    
                } 
            )
        }#File Services
    )
}