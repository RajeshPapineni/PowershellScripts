<#
.SYNOPSIS
  <Files concatenation Script>
.DESCRIPTION
  <Read all the file extensions matching a particular string from a folder that matches the last modified date of a file.
   Remove the first line in each file and after that concatenate all files to a single file with that specific date.>
.NOTES
  Version:        1.0
  Creation Date:  08/17/2018
  Purpose/Change: To schedule the run for 6 p.m files
#>

#Script Version = "1.1"


#Variable Initialization
$today_date = (get-date 18:00).AddDays(-0)
$today_day_of_week = (Get-Date).DayOfWeek
$today_date_file = (Get-Date).ToString("yyyMMdd")

New-Item -ItemType Directory -Force -Path "C:\Windows\Temp\"

Function ABC_FUNC_6{
$BASE_PATH_ABC = "C:\Windows\Temp\ABC\ABC\"
#$BASE_PATH_ABC

$abcdata = @(Get-ChildItem -Path "C:\Windows\Temp\ABC\ABC\*.ABC*" | ? { $_.LastWriteTime -lt $today_date -and $_.LastWriteTime -gt $yesterday_date })
#$abcdata[0]

$A = (Get-ChildItem -Path "C:\Windows\Temp\ABC\ABC\*.ABC*" | ? { $_.LastWriteTime -lt $today_date -and $_.LastWriteTime -gt $yesterday_date } | measure ).Count
#$A

#iterative loop for ABC Files
for($i=0; $i -le $A-1; $i++)
{
#$i
$filenameA = $abcdata[$i].name
#$filenameA

$CURRENT_PATH_ABC = Join-Path "$BASE_PATH_ABC" -ChildPath "$filenameA" 
#$CURRENT_PATH_ABC

$FINAL_BASE_PATH_ABC = "C:\Windows\Temp\ABC\ABC\ABC_Concatenated\$today_date_file\ABC_XYZ\"
$final_FILE_EXT_ABC = "$today_date_file.txt.ABC"
$FINAL_FILE_ABC = Join-Path "$FINAL_BASE_PATH_ABC" -ChildPath "$final_FILE_EXT_ABC"

Add-Content -Path $FINAL_FILE_ABC -Value (Get-Content -Path "$CURRENT_PATH_ABC")
#$FINAL_FILE_ABC
}

}

if ($today_day_of_week -eq "Monday")
{
$yesterday_date = (Get-Date 18:00).AddDays(-3)
&ABC_FUNC_6
}
else
{
$yesterday_date = (Get-Date 18:00).AddDays(-1)
&ABC_FUNC_6
}
