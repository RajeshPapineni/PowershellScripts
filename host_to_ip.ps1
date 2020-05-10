function Get-HostToIP($hostname) {    
    $result = [system.Net.Dns]::GetHostByName($hostname)    
    $result.AddressList | ForEach-Object {$_.IPAddressToString }
}

Get-Content "D:\Data\Servers.txt" | ForEach-Object {(Get-HostToIP($_)) + ($_).HostName >> d:\data\Addresses.txt}
