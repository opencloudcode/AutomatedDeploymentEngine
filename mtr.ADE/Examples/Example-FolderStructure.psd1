@{
    ExampleFolderStructure =  @(
        @{Name = 'Top-Level Folder'; Children = @(
                @{Name = 'Source'}
                @{Name = 'Build'; Children = @(
                    @{Name = '_ConfigurationData'}
                    @{Name = 'FileServices'}
                    @{Name = 'SqlServers'}
                    @{Name = 'WebServers'}
                )}
                @{Name = 'Scripts'; Children = @(
                    @{Name = 'Management'}
                    @{Name = 'Configuration'}
                )}
                @{Name = 'Modules'; Children = @(
                    @{Name = 'Custom'}
                    @{Name = 'Gallery'}
                )}
                @{Name = 'Certificates'}
                @{Name = 'Source Files'}
            )
        }
    );
}