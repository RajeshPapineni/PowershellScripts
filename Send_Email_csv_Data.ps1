# Function to Send email
function SendNotification{
 $Msg = New-Object Net.Mail.MailMessage
 $Smtp = New-Object Net.Mail.SmtpClient($MailServer)
 $Msg.From = $FromAddress
 $Msg.To.Add($ToAddress)
 $Msg.Subject = $Subject_MSG
 $Msg.Body = $EmailBody
 $Msg.IsBodyHTML = $true
 $Smtp.Send($Msg)
}
 
# Email server info and From Address.
$MailServer = "1.2.3.4"
$FromAddress = "mail@rajeshp.in"
 
# Import information from .CSV file
$MainList = Import-Csv "C:\IP_Space.xlsx"
 
# Send notification to each user in the list
Foreach ($Each_Row in $MainList) {
 $ToAddress = "mail@rajeshp.in"
 $IP_ADDRESS = $Each_Row."IP Address"
 $HOSTNAME = $Each_Row."Hostname / Description"
 $Port = $Each_Row.Port
 $STATUS = $Each_Row."Status (Down / Disabled)"
 $Subject_MSG = "Renewal of SSL Certificate for $HOSTNAME - $IP_ADDRESS"
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
 
 <p>From Report we have observed it is going to expire on $EXPIRY_DATE.</p>
 
<table>
 <tr>
   <td><strong>IP Address</strong></td>
   <td>$IP_ADDRESS</td>
 </tr>
 <tr>   
   <td><strong>Host Name</strong></td>
   <td>$HOSTNAME</td>
 </tr>
 <tr>   
   <td><strong>Port</strong></td>
   <td>$Port</td>
 </tr>
 <tr>    
   <td><strong>Issuer Name</strong></td>
   <td>$ISSUER_NAME</td>
 </tr>
 <tr>      
   <td><strong>Subject Name</strong></td>
   <td>$CSV_SUBJECT_NAME</td>
 </tr>
 <tr>      
   <td><strong>Signature Alg</strong></td>
   <td>$SIGNATURE_ALG</td>
 </tr>
 <tr>      
   <td><strong>Issue Date</strong></td>
   <td>$ISSUE_DATE</td>
 </tr>
 <tr>   
   <td><strong>Expiry Date</strong></td>
   <td>$EXPIRY_DATE</td>
 </tr>
 <tr>   
   <td><strong>Status</strong></td>
   <td>$STATUS</td>
 </tr>
 </table>
 
 <br/>
 Regards, <br/>
 Rajesh.
 </body>
 </html>
"@
 Write-Host "Sending notification to $ToAddress" -ForegroundColor Green
 SendNotification
}
