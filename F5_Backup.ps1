##### Add all the N/W Devices into the below Array #####
$Devices_List = @(
#'bigip1-1.prod.abcd.com'
#'bigip1-2.prod.abcd.com'
'qalab02.abcd.com'
'qalab01.abcd.com'
)

##### Credentials Declaration #####
$Username = "rajesh"
$Password = ConvertTo-SecureString -String "P_A_S_S_W_O_R_D" -AsPlainText -Force
$Your_creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password



##### Verify the Connectivity status and check Active devices #####
##### Graefully Logout all the N/W Devices #####

foreach($Device in $Devices_List)
    {

        New-SSHSession -ComputerName $Device -Credential $Your_creds -AcceptKey:$true -ErrorVariable conerrorvar -ErrorAction SilentlyContinue

    if($conerrorvar -cmatch "No such host is known")
        {
            Write-Host "DNS Resolution issue for $Device, please check the hostname or DNS settings." -ForegroundColor Red
        }
    elseif($conerrorvar -cmatch "Permission denied")
        {
            Write-Host "Credentials Issue for $Device, please verify if you have login access." -ForegroundColor Red
        }
    else
        {
            Write-Host "Login Successful for $Device" -ForegroundColor Green
                $Active_Device_Name = $Device
                "$Active_Device_Name is connected, going to preform the configuration backup on it."
                Invoke-SSHCommand -Index 0 -Command "modify cli preference pager disabled display-threshold 0"
                $Complete_Config = Invoke-SSHCommand -Index 0 -Command "show running-config"
                $Today_Date = (Get-Date).ToString("ddMMyyyy")
                $File_Name = "C:\Windows\Temp\" + $Device + $Today_Date + ".txt"
                $Complete_Config.Output | Out-File $File_Name
        
        if([string]::IsNullOrEmpty((Get-SSHSession).Connected))
        {
            Write-Host "Hurray!!!!......There are no Active Sessions" -ForegroundColor Green
        }
        else
        {
            Write-Host "Active Sessions are present, Please wait -- Gracefully closing those sessions" -ForegroundColor Green
            Get-SSHSession | Remove-SSHSession -Verbose
        }

        }
    }
