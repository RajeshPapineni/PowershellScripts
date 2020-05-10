$ServerList = Get-Content "C:\ALL_Servers.txt"
$today_date_file = (Get-Date).ToString("yyyMMdd")
$creds = Get-Credential
Foreach($COMPNAME in $ServerList)
{
#$COMPNAME = ([System.Net.Dns]::GetHostEntry($env:COMPUTERNAME)).HostName
$Computer_Name = $COMPNAME + ","
#$abcd = Invoke-Command { $members = net localgroup administrators | where {$_ -AND $_ -notmatch "successfully."} | select -skip 4
#New-Object PSObject -Property @{ Computername = $Computer_Name
#Members=$members} } | Select * | Format-Table -HideTableHeaders Computername, Members
$abcd = Invoke-Command -ComputerName $COMPNAME -Credential $creds -ScriptBlock{ $members = net localgroup administrators | where {$_ -AND $_ -notmatch "successfully."} | select -skip 4
New-Object PSObject -Property @{Members=$members} } | Select * | Format-Table -HideTableHeaders PSComputerName, Members 

$efgh = $abcd | Out-String
$xyz = $efgh.replace(' {',', ')
$qwerty = $xyz.replace('}','')

$qwerty.split(',') | Out-File "C:\GRROUPS.txt"
$Group_Name = Get-Content "C:\GRROUPS.txt" | where {$_ -ne ""} 
$N = $Group_Name.Count

#For Loop for removing any Domain Names, In this example it is for TUV domain. If you do not have any domain names in your output remove this loop.
#Or you can replace with your domain name in the replace command.
for($i=2; $i -le $N-1; $i++)
{
$COMPA = $Group_Name[$i].replace(" TUV\","")
$AD_Group_List = Get-Content "C:\AD_Groups.txt"
Foreach($Each_GRoup in $AD_Group_List)
{
if($COMPA.Trim() -ne $Each_GRoup)
{
#write-host "Match not Found"
$qwerty | Out-File -FilePath "C:\AdminInfo_user.txt" -Encoding ASCII -Append
}
else
{
Write-Host "$COMPA is a Group"
$qwerty | Out-File -FilePath "C:\AdminInfo_.txt" -Encoding ASCII -Append
}
}
}

#"$Computer_Name, $qwerty" 

}

Get-Content "C:\AdminInfo.txt"  | ? {$_ -match ".."} | Out-File "C:\AdminInfo_Windows$today_date_file.csv"

#Invoke-Command { $members = net localgroup administrators | where {$_ -AND $_ -notmatch "successfully."} | select -skip 4
#New-Object PSObject -Property @{ Computername = $env:COMPUTERNAME 
#Group = "Administrators" 
#Members=$members} } | Select * | Format-Table -HideTableHeaders Computername, Group, Members | Out-File C:\AdminInfo.csv -Append
