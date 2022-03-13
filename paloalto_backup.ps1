##### Add all the Palo Alto Firewalls to the below array #####
$Devices_List = @(
'firewall01.abcd.com'
#'fw01-1-mgmt.qa.abcd.com'
#'fw01-2-mgmt.prod.abcd.com'
)


##### Credentials Declaration #####
$Username = "rajesh"
$Password = ConvertTo-SecureString -String "P_A_S_S_W_O_R_D" -AsPlainText -Force
$Your_creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password


##### Verify the Connectivity status #####
##### Graefully Logout all the N/W Devices #####

foreach($Device in $Devices_List)
    {
        $CS_Session = New-SSHSession -ComputerName $Device -Credential $Your_creds -AcceptKey:$true -ErrorVariable conerrorvar -ErrorAction SilentlyContinue
        $SSHResponse = New-SSHShellStream -SessionId $CS_Session.SessionId

    if($conerrorvar -cmatch "No such host is known")
        {
            Write-Host "DNS Resolution issue for $Device, please check the hostname or DNS settings." -ForegroundColor Red
        }
    elseif($conerrorvar -cmatch "Permission denied")
        {
            Write-Host "Credentials Issue for $Device, please verify if you have login access." -ForegroundColor Red
        }
    elseif($conerrorvar -cmatch "Connection failed to establish")
        {
            Write-Host "Reachability Issue for $Device, failed to establish connection within 10000 milliseconds." -ForegroundColor Red
        }
    else
        {

            if ($CS_Session.Connected)
                {
                    Write-Host "Login successfull for $Device" -ForegroundColor Green  
                    $SSHResponse.WriteLine("set cli config-output-format set")
                    $SSHResponse.WriteLine("set cli pager off")
                    $SSHResponse.WriteLine("configure")
                    Start-Sleep -Seconds 10
                    $SSHResponse.WriteLine("show")
                    Start-Sleep -Seconds 20
                    $SSHResponse.WriteLine("exit")
                    Start-Sleep -Seconds 20
                    $Today_Date = (Get-Date).ToString("ddMMyyyy")
                    $File_Name = "C:\Windows\Temp\" + $Device + $Today_Date + ".txt"
                    $Write_Data = $SSHResponse.Read()
                    $Write_Data | Out-File $File_Name

                }
            else
                {
                    throw [System.InvalidOperationException]"Could not connect to SSH host: $($HostAddress):$HostPort.";
                }
            $CS_SessionRemoveResult = Remove-SSHSession -SSHSession $CS_Session;
                
                if (-Not $CS_SessionRemoveResult)
                    {
                        Write-Error "Could not remove SSH Session $($CS_Session.SessionId):$($CS_Session.Host)."; -ForegroundColor Red
                    }
                else
                    {
                        Write-Host "SSH Session removed successfully" -ForegroundColor Green
                    }
                       

        }
    }
