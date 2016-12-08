
function Get-RemoteCertificate{
    <#
    .Synopsis

    .DESCRIPTION

    .EXAMPLE

    .OUTPUTS
		This function outputs a list of created .cer files
    .FUNCTIONALITY

    #>
    [CmdLetBinding(DefaultParameterSetName = "ByThumbprint")]
    Param(
        [Parameter(Mandatory = $true)]
        [string[]]$Computer,
        
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true,
        ParameterSetName = "ByTemplate")]
        [string]$TemplateName,

        [Parameter(Mandatory = $true,
        ParameterSetName = "ByThumbprint")]
        [string]$Thumbprint
    )
    if(-not($Path.StartsWith('Cert:\'))){
        $Path = "Cert:\$Path"
    }
    
    $jobs = @()

    #Using PSRemoting, find certificate created using the PowerShell DSC Encryption Certificate Template
    #run job asyncronously and add to list of jobs to monitor
    $Computer | % {
        if ($PsCmdlet.ParameterSetName -eq 'ByTemplate'){
            $sb = {
			    Param(
				    [Parameter(Position=0)]
                    $CertTemplate,
                    [Parameter(Position=1)]
                    $StorePath
			    )
                Get-ChildItem -Path $StorePath -Recurse | where {
                    $_.Extensions | where {
                        $_.oid.friendlyname -match "Template" -and $_.Format(0) -match $CertTemplate
                    }
                }
            }
            $job = Invoke-Command -computername $_ -ScriptBlock $sb -AsJob -JobName $_ -ArgumentList $TemplateName, $Path
            $jobs += $job
        }
        elseif($PsCmdlet.ParameterSetName -eq 'ByThumbprint'){
            $sb = {
                Param(
                    [Parameter(Position=0)]
                    $CertThumbprint,
                    [Parameter(Position=1)]
                    $StorePath
                )
                Get-ChildItem -Path $StorePath -Recurse | ? {$_.Thumbprint -eq "$CertThumbprint"}
            }
            $job = Invoke-Command -computername $_ -ScriptBlock $sb -AsJob -JobName $_ -ArgumentList $Thumbprint, $Path
            $jobs += $job
        }
    
    }

    $Certificates = @()
    $Missing = @()
    $Failed = @()

    $running = $true
    While($running){
        $running = $false
        foreach($job in $jobs){
            if($job.state -eq 'Completed'){
                $cert = Receive-Job -id $job.Id -keep
                if($cert -ne $null){
                    $Certificates += $Cert
                }
                else{
                    $Missing += $Job.Name
                }
            }
            elseif($job.State -eq 'Running'){
                $running = $true
            }
            elseif($job.State -eq 'Failed'){
                $Failed += $Job.Name
            }
        }
        Start-Sleep -Seconds 5
    }
    $jobs | Remove-Job -Force
    $Results = @{}
    $Results.Add("Certificates", $Certificates)
    $Results.Add("Missing", $Missing)
    $Results.Add("Failed", $Failed)
    return $Results
}
