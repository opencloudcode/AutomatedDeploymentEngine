@{
    SolutionOUs = @(
        @{Name = 'ParentOU'; ContainsDefaultOUs = $true; Children = @(
            @{Name = 'Infrastructure Services'; ContainsDefaultOUs = $true}
            @{Name = 'Solution Roles'; Children = @(
                @{Name = 'SQLServers'; ContainsDefaultOUs = $true}               
                @{Name = 'WebServers'; ContainsDefaultOUs = $true}  
            )}
            @{Name = 'Administrative Users'}
            @{Name = 'Standard Users'}
        )
    });
    DefaultOUs = @(
        #Default OUs can be added into any parent that has 'ContainsDefaultOUs' set to true
        #...this greatly simplifies the creation process of an OU structure that is compartmentalised
        #...for increased security and availability.
        @{Name = 'Administrative Groups'; Children = @(
            @{Name = 'Roles'}
            @{Name = 'Rights'}
        )}
        @{Name = 'Service Accounts'}
        @{Name = 'Computers'}
    );
}