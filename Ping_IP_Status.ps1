$IP_Address = import-csv "C:\IP_Address.csv" | select-object $IP_Column
$IP_Column = "IPAddress"
$Device_Column = "DeviceName"

$Device_Name = import-csv "C:\IP_Address.csv" | select-object $Device_Column


foreach($IP in $IP_Address) {
    
    if (Test-Connection $IP.($IP_Column) -count 1 -quiet) {
    
        write-host $IP.($IP_Column) "Ping Sucess" -foreground green
        $status = "UP"
    
             }
        else {
        
        write-host $IP.($IP_Column) "Ping Failed" -foreground red
        $status = "DOWN"
             }
             
             $data = @($IP.($IP_Column),$status)
             $Final += $data

                            }
                            
                             
 $Final | Add-Content -Path "C:\IP_Sample.csv" 
