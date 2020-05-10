#To start an application in Windows

Start-Process "C:RIEVE.EXE"

cd V:

cd \ABC\XYZ\12347\

$data_1234 = healthcheck.bat 1234
Start-Sleep -s 10
$data_1234 | Set-Content -Path "C:\test_1234.txt"
$data_1234 = (Get-Content "C:\test_1234.txt" | select -Last 3)

if ($data_1234[0] -eq "100 index node(s) used, 0 free -- 0 data record(s) used, 0 free")
{
Write-Output "Script executed Successfully";
}

else
{
Write-Output "Match not found in output to healthcheck.bat 1234";
}

Remove-Item "C:\1234_last_date.txt"
Rename-Item "C:\1234_today_date.txt" "C:\1234_last_date.txt"
$Comp_yest_date_1234 = Get-Content "C:\1234_last_date.txt"

(Get-Item "1234abcd.dat").LastWriteTime | Out-File -FilePath "C:\1234_today_date.txt"
$Comp_today_date_1234 = Get-Content "C:\1234_today_date.txt"
$Comp_today_date_1234[1]

$UVXYZ_1234 = Get-Content "C:\1234prsn.dat" | Where-Object { $_.Contains("MM/DD/YYYY")}
$Position_String_1234 = $UVXYZ_1234.IndexOf('MM/DD/YYYY')
$Transaction_String_Position_1234 = $UVXYZ_1234.Substring(0,$Position_String)
$Trans_Length_1234 = $Transaction_String_Position_1234.Length
$ID_Transaction_1234 = $Transaction_String_Position_1234.Substring($Trans_Length_1234-4)
$ID_Transaction_1234

if ($Comp_today_date_1234[1] -eq $Comp_yest_date_1234[1])
{
$Value_1234 = "PARTIALLY FAILED"
}
else
{
$Value_1234 = "PASSED"
}

$Value_1234

if (($Value_1234 -eq "PARTIALLY FAILED") -and ($Value_1234 -eq "PARTIALLY FAILED"))
{
$Status = "Failed"
}
elseif (($Value_1234 -eq "PASSED") -and ($Value_1234 -eq "PASSED"))
{
$status = "PASSED"
}
else
{
$status = "PARTIALLY FAILED"
}

$status

Stop-Process -name DTRIEVE


# Function to Send email
function SendNotification{
 $Msg = New-Object Net.Mail.MailMessage
 $Smtp = New-Object Net.Mail.SmtpClient($MailServer)
 $Msg.From = $FromAddress
 $Msg.To.Add($ToAddress)
 $Msg.CC.Add($CCAddress) 
 $Msg.Subject = $Subject_MSG
 $Msg.Body = $EmailBody
 $Msg.IsBodyHTML = $true
 $Smtp.Send($Msg)
}
 
# Email server info and From Address.
$MailServer = "1.2.3.4"
$FromAddress = "mail@rajeshp.in"
 $ToAddress = "mail@rajeshp.in"
 $CCAddress = "mail@rajeshp.in"
 $TODAY_DATE = Get-Date
 $Subject_MSG = "The restore is complete for EMAIL,$status"
 $EmailBody = @"
 <html>
 <head>
 <style>
 table{
        font-family:arial, sans-serif;
        border-collapse: collapse;
        width: 100%;
}

td {
    border: 1px solid #dddddd;
    text-align: left;
    padding: 8px;
}

tr:nth-child(even) {
    background-color: #dddddd;
}
</style>             
</head>
 <body>
 <p>Hi </p>
 
 <p>From the EMAIL Data</p>
 
 
 <br/>
 Regards, <br/>
 Rajesh.
 <br/><br/><br/><br/>
 This is a system generated email.
 </body>
 </html>
"@
 Write-Host "Sending notification to $ToAddress" -ForegroundColor Green
 SendNotification
