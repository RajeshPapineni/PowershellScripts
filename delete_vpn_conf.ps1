$today_date = (get-date).ToString("yyyMMdd")
$Tunnel_Value = Read-Host -Prompt 'Enter the Tunnel Number you want to detlete'
$File_Path = Read-Host -Prompt "Enter the Configuration file path"
$Enter_Tunnel_Value = "interface Tunnel$Tunnel_Value"

Get-Content $File_Path | Select-String -Pattern "$Enter_Tunnel_Value" -Context 1,9 | Out-File -FilePath "C:\deltunnel1.txt"

$Tunnel_Dest = Get-Content "C:\deltunnel1.txt" | Where-Object { $_.Contains("tunnel destination") }
$Peer_Public_IP = $Tunnel_Dest.Split()[-1]

$IPSEC_PROFILE = Get-Content "C:\deltunnel1.txt" | Where-Object { $_.Contains("tunnel protection ipsec profile") }
$IPSEC_PROFILE_NAME = $IPSEC_PROFILE.Split()[-1]

$BGP_Local_IP = Get-Content "C:\deltunnel1.txt" | Where-Object { $_.Contains("ip address") }
$BGP_LOCAL_IP_NAME = $BGP_Local_IP.Split()[-2]

$BGP_PEER_IP_NAME = $BGP_LOCAL_IP_NAME.Split(".")
$BGP_PEER_IP_NAME_LAST = $BGP_PEER_IP_NAME[3]-1
$BGP_Neighbor_IP = $BGP_PEER_IP_NAME[0]+"."+$BGP_PEER_IP_NAME[1]+"."+$BGP_PEER_IP_NAME[2]+"."+$BGP_PEER_IP_NAME_LAST


Get-Content $File_Path | Select-String -Pattern "crypto ipsec profile $IPSEC_PROFILE_NAME" -Context 1,4 | Out-File -FilePath "C:\deltunnel2.txt"

$Transform_Set = Get-Content "C:\deltunnel2.txt" | Where-Object { $_.Contains("set transform-set ") }
$Transform_Set_Name = $Transform_Set.Split()[-1]

Get-Content $File_Path | Select-String -Pattern "pre-shared-key address $Peer_Public_IP" -Context 2 | Out-File -FilePath "C:\deltunnel3.txt"
Get-Content "C:\deltunnel3.txt" | Select -First 4 | Out-File -FilePath "C:\deltunnel4.txt"
$data4 = Get-Content "C:\deltunnel4.txt"
$ISAKMP_Keyring = Get-Content "C:\deltunnel4.txt" | Where-Object { $_.Contains("crypto keyring keyring") }
$ISAKMP_Keyring_NAME = $ISAKMP_Keyring.Split()[-1]

Get-Content $File_Path | Select-String -Pattern "match identity address $Peer_Public_IP" -Context 3  | Out-File -FilePath "C:\deltunnel5.txt"
Get-Content "C:\deltunnel5.txt" | Select -First 6 | Out-File -FilePath "C:\deltunnel6.txt"
$ISAKMP_PROFILE = Get-Content "C:\deltunnel6.txt" | Where-Object { $_.Contains("crypto isakmp profile") }
$ISAKMP_PROFILE_NAME = $ISAKMP_PROFILE.Split()[-1]

$data6 = Get-Content $File_Path | Where-Object { $_.Contains("neighbor $BGP_Neighbor_IP prefix-list Filter") }
if($data6 -eq $null)
        {
$Prefix_List = $null  
$Prefix_List_Desc = "#There is no Prefix list for this VPN"
$Route_Map_Desc = "#There is no Route map for this VPN"   
        } 
   else {
$Prefix_List = $data6.Split()[-2]
Get-Content $File_Path | Select-String -Pattern "match ip address prefix-list $Prefix_List" -Context 2 | Out-File -FilePath "C:\deltunnel7.txt"
Get-Content "C:\deltunnel7.txt" | Select -First 5 | Out-File -FilePath "C:\deltunnel8.txt"
$Route_Map = Get-Content "C:\deltunnel8.txt" | Where-Object { $_.Contains("route-map ") }
$Prefix_List_Desc = "no ip prefix-list $Prefix_List"
$Route_Map_Desc = "no route-map $Route_Map"
}       

Function ConfigScript{
$Final_File = @"
#Configuration on $Int_Router

no interface Tunnel $Tunnel_Value
no crypto ipsec profile $IPSEC_PROFILE_NAME
no crypto ipsec transform-set $TRANSFORM_SET_NAME
no crypto keyring $ISAKMP_Keyring_NAME
no crypto isakmp profile $ISAKMP_PROFILE_NAME

router bgp $AS_Number
  no neighbor $BGP_Neighbor_IP
exit

$Prefix_List_Desc
$Route_Map_Desc

no ip route $Peer_Public_IP 255.255.255.0 $Next_HOP_IP

object-group network NEW_AWS_Tun_Peers
no host $Peer_Public_IP
exit

#Configuration on $Ext_Router
object-group network NEW_AWS_Tun_Peers
no host $Peer_Public_IP
exit

"@

$Final_File | Out-File -FilePath "C:\AWS_VPN_DELETE_$today_date.txt" -Encoding ASCII
}

Function TempFiles{
Remove-Item "C:\deltunnel1.txt"
Remove-Item "C:\deltunnel2.txt"
Remove-Item "C:\deltunnel3.txt"
Remove-Item "C:\deltunnel4.txt"
Remove-Item "C:\deltunnel5.txt"
Remove-Item "C:\deltunnel6.txt"
Remove-Item "C:\deltunnel7.txt"
Remove-Item "C:\deltunnel8.txt"
}

$Next_HOP_IP = '6.7.8.9'
$Ext_Router = 'net-abc11-xyz & net-abc12-xyz'
$AS_Number = '12345'
$Int_Router = 'net-abc13-xyz'
&ConfigScript
&TempFiles
