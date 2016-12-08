#
# Script1.ps1
#
Function Set-DnsRecord {
	[CmdletBinding()]
    [OutputType([String])]
    Param
    (        
        [Parameter(Mandatory=$true)]
		[string]$RecordName,
        [Parameter(Mandatory=$true)]
        [validateset("A","AAAA","AFSDB","APL","CAA","CDNSKEY","CDS","CERT","CNAME","DHCID","DLV","DNAME","DNSKEY","DS","HIP","IPSECKEY","KEY","KX","LOC","MX","NAPTR","NS","NSEC","NSEC3","NSEC3PARAM","PTR","RRSIG","RP","SIG","SOA","SRV","SSHFP","TA","TKEY","TLSA","TSIG","TXT","URI")]
		[string]$RecordType,
        [Parameter(Mandatory=$false)]
		[string]$RecordTarget,
        [Parameter(Mandatory=$false)]
		[string]$Zonename,
        [Parameter(Mandatory=$false)]
		[Bool]$Overwrite = $false
    )

    if (!$Zonename){$Zonename = $env:USERDNSDOMAIN
                      $ADComputer = ($env:LOGONSERVER).replace("\","")}
    switch ($RecordType) 
    { 
        "A" {
        
            if (!(Get-DnsServerResourceRecord -Name $RecordName -ZoneName $Zonename -ComputerName $ADComputer -ErrorAction SilentlyContinue)){
            Add-DnsServerResourceRecordA -IPv4Address $RecordTarget -Name $RecordName -ZoneName $Zonename -ComputerName $ADComputer
            write-output "Record $recordname Created"
                } else {
            
                if ($overwrite){ 
                
                $OldObj = Get-DnsServerResourceRecord -Name $RecordName -ZoneName $Zonename -ComputerName $ADComputer
                $servers = Get-DnsClientServerAddress | where {($_.InterfaceAlias -eq "Ethernet") -and $_.ServerAddresses -ne $null } | select-object serveraddresses            
                Remove-DnsServerResourceRecord -InputObject $OldObj -ZoneName $Zonename -ComputerName $servers.serveraddresses[0] -force 
                Remove-DnsServerResourceRecord -InputObject $OldObj -ZoneName $Zonename -ComputerName $servers.serveraddresses[1] -force
                Add-DnsServerResourceRecordA -IPv4Address $RecordTarget -Name $RecordName -ZoneName $Zonename -ComputerName $servers.serveraddresses[0]
                #Add-DnsServerResourceRecordA -IPv4Address $RecordTarget -Name $RecordName -ZoneName $Zonename -ComputerName $servers.serveraddresses[1]
                Get-DnsServerResourceRecord -Name $RecordName -ZoneName $Zonename -ComputerName $ADComputer
                            }
            
            }
        }
        "CNAME" {
        if (!(Get-DnsServerResourceRecord -Name $RecordName -ZoneName $Zonename -ComputerName $ADComputer -ErrorAction SilentlyContinue))
        {
        $servers = Get-DnsClientServerAddress | where {($_.InterfaceAlias -eq "Ethernet") -and $_.ServerAddresses -ne $null } | select-object serveraddresses 
        Add-DnsServerResourceRecordCName -HostNameAlias $RecordTarget -ComputerName $servers.serveraddresses[0] -ZoneName $Zonename -Name $RecordName
        } else {
        if ($overwrite){
                        $oldobj = Get-DnsServerResourceRecord -Name $RecordName -ZoneName $Zonename -ComputerName $ADComputer
                        Remove-DnsServerResourceRecord -InputObject $OldObj -ZoneName $Zonename -ComputerName $servers.serveraddresses[0] -force 
                        Remove-DnsServerResourceRecord -InputObject $OldObj -ZoneName $Zonename -ComputerName $servers.serveraddresses[1] -force  
                        $servers = Get-DnsClientServerAddress | where {($_.InterfaceAlias -eq "Ethernet") -and $_.ServerAddresses -ne $null } | select-object serveraddresses 
                        Add-DnsServerResourceRecordCName -HostNameAlias $RecordTarget -ComputerName $servers.serveraddresses[0] -ZoneName $Zonename -Name $RecordName              
                        }
     
                }
            
        }

#        "AAAA" {"This Record is not covered by this function"}
#        "AFSDB" {"This Record is not covered by this function"}
#        "APL" {"This Record is not covered by this function"}
#        "CAA" {"This Record is not covered by this function"}
#        "CDNSKEY" {"This Record is not covered by this function"}
#        "CDS" {"This Record is not covered by this function"}
#        "CERT" {"This Record is not covered by this function"}
#        "DHCID" {"This Record is not covered by this function"}
#        "DLV" {"This Record is not covered by this function"}
#        "DNAME" {"This Record is not covered by this function"}
#        "DNSKEY" {"This Record is not covered by this function"}
#        "DS" {"This Record is not covered by this function"}
#        "HIP" {"This Record is not covered by this function"}
#        "IPSECKEY" {"This Record is not covered by this function"}
#        "KEY" {"This Record is not covered by this function"}
#        "KX" {"This Record is not covered by this function"}
#        "LOC" {"This Record is not covered by this function"}
#        "MX" {"This Record is not covered by this function"}
#        "NAPTR" {"This Record is not covered by this function"}
#        "NS" {"This Record is not covered by this function"}
#        "NSEC" {"This Record is not covered by this function"}
#        "NSEC3" {"This Record is not covered by this function"}
#        "NSEC3PARAM" {"This Record is not covered by this function"}
#        "PTR" {"This Record is not covered by this function"}
#        "RRSIG" {"This Record is not covered by this function"}
#        "RP" {"This Record is not covered by this function"}
#        "SIG" {"This Record is not covered by this function"}
#        "SOA" {"This Record is not covered by this function"}
#        "SRV" {"This Record is not covered by this function"}
#        "SSHFP" {"This Record is not covered by this function"}
#        "TA" {"This Record is not covered by this function"}
#        "TKEY" {"This Record is not covered by this function"}
#        "TLSA" {"This Record is not covered by this function"}
#        "TSIG" {"This Record is not covered by this function"}
#        "TXT" {"This Record is not covered by this function"}
#        "URI" {"This Record is not covered by this function"}
        default {"This Record is not covered by this function"}
    }

}