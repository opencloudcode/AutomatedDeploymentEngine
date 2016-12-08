
function Get-CertificateFromTemplate{
    <#
    .Synopsis

    .DESCRIPTION

    .EXAMPLE

    .OUTPUTS
		This function outputs a list of created .cer files
    .FUNCTIONALITY

    #>
    Param(
        [string[]]$Computer,
        [string]$CertTemplateName
    )
    $jobs = @()

    #Using PSRemoting, find certificate created using the PowerShell DSC Encryption Certificate Template
    #run job asyncronously and add to list of jobs to monitor
    $Computer | % {
        $sb = {
			Param(
				[Parameter(Position=0)]
				$CertTemplate
			)
            Get-ChildItem -Path Cert:\LocalMachine\My -Recurse | where {
                $_.Extensions | where {
                    $_.oid.friendlyname -match "Template" -and $_.Format(0) -match $CertTemplate
                }
            }
        }

        $job = Invoke-Command -computername $_ -ScriptBlock $sb -AsJob -JobName $_ -ArgumentList $CertTemplateName
        $jobs += $job
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
                $Failed+= $Job.Name
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

