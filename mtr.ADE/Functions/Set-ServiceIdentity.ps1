function Set-ServiceIdentity{
    [CmdLetBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName  = $ENV:ComputerName,

        [Parameter(Mandatory = $true)]
        [string]$Filter,
        
        [Parameter(Mandatory = $true)]
        [Alias('User', 'UserName', 'Account')]
        [string]$Identity,
        
        [Parameter(Mandatory = $true)]
        [string]$Domain,

        #[Parameter(ParameterSetName = 'StandardAccount')]
        [string]$Password,

        [switch]$RestartService, 

        [PSCredential]$Credential
    )
    if([string]::IsNullOrEmpty($Password) -and $Credential -eq $Null){
        $Credential = Get-Credential -Message "Enter you administrative credentials, including the domain prefix. These are required in order to install Managed Service Accounts"
    }

    foreach ($Computer in $ComputerName){
        if([string]::IsNullOrEmpty($Password)){
            Write-Verbose "No password supplied, assuming Managed Service Account"
            Write-Verbose "Configuring CredSSP"
            Enable-WSManCredSSP Client -DelegateComputer $Computer -Force
            Invoke-Command -ComputerName $Computer -ScriptBlock {Enable-WSManCredSSP Server -Force}

            if(-not $Identity.EndsWith('$')){
                $Identity = "$Identity$"
            }
        
            try{
                if(Invoke-Command -ComputerName $Computer -Credential $Credential -Authentication Credssp -ScriptBlock {Test-AdServiceAccount -Identity $Using:Identity}){
                    Write-Verbose "$Computer is allowed to retrieve password for $Identity"
                    Invoke-Command -ComputerName $Computer -Credential $Credential -Authentication Credssp -ScriptBlock {Install-AdServiceAccount -Identity $using:Identity}
                }
                else{
                    Write-Error "$Computer is not allowed to retrieve managed password for $Identity. Please ensure AdServiceAccount is configured correctly and try again"
                }
            }
            catch{
                if($Error[0].Exception.ToString().Contains('Access Denied')){
                    Write-Error "Access Denied: Ensure Server Principal is authorised to retrieve password and Server has been rebooted"
                    break
                }
                else{ throw $_ }
            }
        }

        $svc = Get-WmiObject -ComputerName $Computer win32_service -filter $Filter
        if($svc -ne $null){
            Write-Verbose "Configuring ($($svc.Name)) to run as $Domain\$Identity"
            if($Password -eq $Null){
                Write-Verbose "No password supplied, ($($svc.Name)) will be configured to run with Managed Service Account"
            }
            $Svc.Change($Null, $Null, $Null, $Null, $Null, $Null, "$Domain\$Identity", $Password)
        }

        if($RestartService -eq $true){
            #Get-Service -ComputerName $Computer -Name $Name | Restart-Service
        
            Write-Verbose "Stopping $ServiceName"
            $svc.StopService()
            while ($svc.Started){
                Write-Verbose "Waiting for service ($($svc.Name)) to stop"
                sleep 2
                $svc = Get-WMIObject -ComputerName $Computer Win32_Service -Filter $Filter
            }
            $svc.StartService()
        }
    }
}