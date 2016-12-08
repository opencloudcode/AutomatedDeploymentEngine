function Install-ManagedServiceAccount{
    Param(
        [Parameter(ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName  = $ENV:ComputerName,
        
        [Parameter(Mandatory = $true)]
        [Alias('User', 'UserName', 'Account')]
        [string]$Identity,

        [PSCredential]$Credential = (Get-Credential)
    )

    foreach ($Computer in $ComputerName){
        Write-Verbose "-->No password supplied, assuming Managed Service Account"
        Write-Verbose "-->Configuring CredSSP"
        Enable-WSManCredSSP Client -DelegateComputer $Computer -Force
        Invoke-Command -ComputerName $Computer -ScriptBlock {Enable-WSManCredSSP Server -Force}

        if(-not $Identity.EndsWith('$')){
            $Identity = "-->$Identity$"
        }
        
        try{
            if(Invoke-Command -ComputerName $Computer -Credential $Credential -Authentication Credssp -ScriptBlock {Test-AdServiceAccount -Identity $Using:Identity}){
                Write-Verbose "-->$Computer is allowed to retrieve password for $Identity"
                Invoke-Command -ComputerName $Computer -Credential $Credential -Authentication Credssp -ScriptBlock {Install-AdServiceAccount -Identity $using:Identity -Verbose}
            }
            else{
                Write-Error "-->$Computer is not allowed to retrieve managed password for $Identity. Please ensure AdServiceAccount is configured correctly and try again"
            }          
        }
        catch{
            if($Error[0].Exception.ToString().Contains('Access Denied')){
                Write-Error "-->Access Denied: Ensure Server Principal is authorised to retrieve password and Server has been rebooted"
                break
            }
            else{ throw $_ }
        }
    
    }
}