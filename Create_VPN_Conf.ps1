$File_Path = Read-Host -Prompt "Enter the Configuration file path"

$value1 = (Select-String -Path "$File_Path" -Pattern 'IPSec Tunnel #2').LineNumber
$today_date = (Get-Date).ToString("yyyMMdd")

$BASE_PATH = "C:\Powershell_Script"
$filenameA = "AWS_VPN_$today_date" + "_$LOCATION.txt"
$OUT_FILE_PATH = Join-Path "$BASE_PATH" -ChildPath "$filenameA" 

Get-Content $File_Path | Select -First $value1 | Out-File -FilePath "$BASE_PATH\tunnel1.txt"
Get-Content "$BASE_PATH\tunnel1.txt" | Where-Object {$_ -notmatch "!"} | Out-File -FilePath "$BASE_PATH\tunnel2.txt"
Select-String -Pattern "\w" "$BASE_PATH\tunnel2.txt"  | ForEach-Object { $_.line } | Set-Content -Path "$BASE_PATH\tunnel3.txt"

$ISAKMP_Keyring = Get-Content "$BASE_PATH\tunnel3.txt" | Where-Object { $_.Contains("crypto keyring keyring") }
$ISAKMP_Keyring_NAME = $ISAKMP_Keyring.Split()[-1]

$Peer_AS = Get-Content "C:\Powershell_Script\tunnel3.txt" | Where-Object { $_.Contains("remote-as ")}
$Peer_AS_Number = $Peer_AS[0].split()[-1]

$Pre_Shared_Key_NAME = Get-Content "$BASE_PATH\tunnel3.txt" | Where-Object { $_.Contains("pre-shared-key address") }
$Pre_Shared_Key = $Pre_Shared_Key_NAME.Split()[-1]
$Peer_IP_Address = $Pre_Shared_Key_NAME.Split()[-3]
$Peer_IP_Sep = $Peer_IP_Address.Split(".")
$Peer_IP_SUBNET_ID = $Peer_IP_Sep[0]+"."+$Peer_IP_Sep[1]+"."+$Peer_IP_Sep[2]+"."+"0"

$ISAKMP_PROFILE = Get-Content "$BASE_PATH\tunnel3.txt" | Where-Object { $_.Contains("crypto isakmp profile isakmp") }
$ISAKMP_PROFILE_NAME = $ISAKMP_PROFILE.Split()[-1]

$CRYPTO_PROFILE = Get-Content "$BASE_PATH\tunnel3.txt" | Where-Object { $_.Contains("crypto ipsec profile") }
$PROFILE_NAME = $CRYPTO_PROFILE.Split()[-1]

$CRYPTO_TRANSFORM = Get-Content "$BASE_PATH\tunnel3.txt" | Where-Object { $_.Contains("crypto ipsec transform-set") } 
$TRANSFORM_SET_NAME = $CRYPTO_TRANSFORM.Split()[3]

$Peer_Tunnel_IP = Get-Content "$BASE_PATH\tunnel3.txt" | Where-Object { $_.Contains("ip address ") }  
$Peer_Tunnel_IP_Address = $Peer_Tunnel_IP.Split()[-2]
$Peer_Tunnel_Subnet_Address = $Peer_Tunnel_IP.Split()[-1]

$BGP_Neighbor_IP = Get-Content "$BASE_PATH\tunnel3.txt" | Where-Object { $_.Contains("soft-reconfiguration inbound") }  
$BGP_Neighbor_IP_Address = $BGP_Neighbor_IP.Split()[-3]

#$PROFILE_NAME
#$TRANSFORM_SET_NAME
#$TUNNEL_GROUP_NAME

$Tunnel_Number = Read-Host -Prompt 'Enter the Tunnel Number for this AWS VPC Example:651'
$Subnet = Read-Host -Prompt 'Enter the Private Nework Subnet ID - Should be in X.X.X.X ---- DO NOT ENTER MASK VALUE Example:10.33.22.0'
$Prefix_Value = Read-Host -Prompt 'Enter the Prefix Value --- Example:24'
$Mix_desc = $Subnet,$Prefix_Value -join "_"
$Mix_Network = $Subnet,$Prefix_Value -join "/"
$VPC_NAME = Read-Host -Prompt 'Enter the Name of your VPC Example:EP-SCZ-VPC'

Function ConfigScript{
$Final_File = @"
######### Pre-Implementation Steps: #########
show running-config | include $BGP_Neighbor_IP_Address
show running-config | include Tunnel$Tunnel_Number

######### Configuration on $Int_Router #########
crypto keyring $ISAKMP_Keyring_NAME
  description AWS VPC $Mix_desc - $VPC_NAME - $LOCATION
  local-address $Source_IP_Local
  pre-shared-key address $Peer_IP_Address key $Pre_Shared_Key
exit

crypto isakmp profile $ISAKMP_PROFILE_NAME
  description AWS VPC $Mix_desc - $VPC_NAME - $LOCATION
  local-address $Source_IP_Local
  match identity address $Peer_IP_Address
  keyring $ISAKMP_Keyring_NAME
exit

crypto ipsec transform-set $TRANSFORM_SET_NAME esp-aes 128 esp-sha-hmac 
  mode tunnel
exit

crypto ipsec profile $PROFILE_NAME
description AWS VPC $Mix_desc - $VPC_NAME - $LOCATION
  set pfs group2
  set transform-set $TRANSFORM_SET_NAME
exit

interface Tunnel $Tunnel_Number
  description AWS VPC $Mix_desc - $VPC_NAME - $LOCATION
  ip address $Peer_Tunnel_IP_Address $Peer_Tunnel_Subnet_Address
  ip virtual-reassembly
  tunnel source $Source_IP_Local
  tunnel destination $Peer_IP_Address
  tunnel mode ipsec ipv4
  tunnel protection ipsec profile $PROFILE_NAME
  ip tcp adjust-mss 1379 
  no shutdown
exit

ip prefix-list Filter-In_AWS-VPC-$Mix_desc-$VPC_NAME-$LOCATION seq 10 permit $Mix_Network

route-map AWS-VPC-$Mix_desc-$VPC_NAME-$LOCATION-in permit 10
 match ip address prefix-list Filter-In_AWS-VPC-$Mix_desc-$VPC_NAME-$LOCATION
  set local-preference $Local_Preference
exit

router bgp $AS_Number
  neighbor $BGP_Neighbor_IP_Address remote-as $Peer_AS_Number
  neighbor $BGP_Neighbor_IP_Address description AWS VPC $Mix_desc - $VPC_NAME - $LOCATION
  neighbor $BGP_Neighbor_IP_Address activate
  neighbor $BGP_Neighbor_IP_Address timers 10 30 30
  address-family ipv4
  neighbor $BGP_Neighbor_IP_Address activate
  neighbor $BGP_Neighbor_IP_Address prefix-list Filter-In_AWS-VPC-$Mix_desc-$VPC_NAME-$LOCATION in
  neighbor $BGP_Neighbor_IP_Address prefix-list AWS-Flter-Out out
  neighbor $BGP_Neighbor_IP_Address route-map AWS-VPC-$Mix_desc-$VPC_NAME-$LOCATION-in in
    neighbor $BGP_Neighbor_IP_Address soft-reconfiguration inbound
  exit
exit

ip route $Peer_IP_SUBNET_ID 255.255.255.0 $Next_HOP_IP

$ACL


######### Configuration on $Ext_Router #########

$ACL


######### Post Change Validation Commands: #########

show crypto session isakmp profile $ISAKMP_PROFILE_NAME  | begi Interface: Tunnel$Tunnel_Number
show crypto ipsec sa peer $Peer_IP_Address
show ip bgp neighbors $BGP_Neighbor_IP_Address routes
show interface description | include $Tunnel_Number
show ip bgp summary | include $BGP_Neighbor_IP_Address

"@

$Final_File | Out-File -FilePath $OUT_FILE_PATH -Encoding ASCII
}

Function TempFiles{
Remove-Item "$BASE_PATH\tunnel1.txt"
Remove-Item "$BASE_PATH\tunnel2.txt"
Remove-Item "$BASE_PATH\tunnel3.txt"
}

$Source_IP_Local = '6.7.8.9'
$Next_HOP_IP = '2.3.4.5'
$Ext_Router = 'net-abc11-xyz & net-abc12-xyz'
$AS_Number = '12345'
$Local_Preference = "400"
$Int_Router = 'net-abc25-xyz'
$ACL = "object-group network NEW_AWS_Tun_Peers
 host $Peer_IP_Address
 exit"
&ConfigScript
&TempFiles

