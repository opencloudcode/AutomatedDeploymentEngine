function Set-IISApplicationPoolIdentity{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline = $true, 
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$true, 
                   ValueFromPipeline = $true, 
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,

        [Parameter(ParameterSetName = 'StandardAccount')]
        [ValidateNotNull()]
        [PsCredential]$Credential,

        [Parameter(ParameterSetName = 'ManagedServiceAccount')]
        [string]$Identity
    )

    BEGIN{
        if($PSCmdLet.ParameterSetName -eq 'ManagedServiceAccount'){
            $userName = $Identity
            $password = ''  
            $identityType = 3          
        }
        elseif($PSCmdLet.ParameterSetName -eq 'StandardAccount'){
            $userName = $Credential.UserName
            $password = $Credential.GetNetworkCredential().Password    
            $identityType = 3
         }
    }
    PROCESS{
        foreach ($Computer in $ComputerName){
            $s = New-PSSession -ComputerName $Computer

            #Check for AppPool
            $sb = {
                Import-Module WebAdministration
                $ap = Get-ChildItem -Path IIS:\AppPools | ? {$_.Name -eq $Using:Name}
                if($ap -ne $null){
                    $ap.ProcessModel.UserName = $using:userName
                    $ap.ProcessModel.Password = $using:password
                    $ap.ProcessModel.IdentityType = $using:identityType
                    $ap | Set-Item
                }
                else{
                    Write-Error -Message "'$($Using:Name)' not found on remote machine, ensure it exists and the name is correct" -Category ObjectNotFound
                }
            }
            Invoke-Command -Session $s -ScriptBlock $sb
            Remove-PSSession $s     
        } 
    }
    END{}
}
