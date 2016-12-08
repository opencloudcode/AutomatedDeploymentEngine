@{
    PackageLibrary = @(
        @{
            InstallType = 'MSI'
            FriendlyName = 'MyProgram'
            DisplayName = 'My MSI Based Program'
            ProductID = '{9D9AD51B-E559-4295-835D-4C15A7EA58D2}'
            SourcePath = '\\Source\Installers'
            SourceFile = 'MyProgram.msi'
            Arguments = '/TargetPath "F:\Program Files\MyProgram\" /Quiet'
        }
        @{
            InstallType = 'EXE'
            FriendlyName = 'SQL 2012 Native Client'
            SourcePath = '\\Source\Installers'
            SourceFile = 'installme.exe'
            Arguments = '/S /Log:"D:\Temp\Logs'                                                                  
        }         
    )
}