$SQLInstance = "SQLSERVER01\INSTANCE1"
$SQLDatabase = "DATABASE1"
$SQLTable = "TABLE123"

$SQLUsername = "Db_user"
$SQLPassword = "Db_Password"

$today_date = (Get-Date 21:00).AddDays(-0)

Import-Module SqlServer

function DB_PUSH_FUNC 
{

$ABCFileName = Get-ChildItem -Path "C:\ABC_$today_date_file*" | ? { $_.LastWriteTime -lt $today_date -and $_.LastWriteTime -gt $yesterday_date }

$B = $ABCFileName.Count

if($ABCFileName.Count -eq 0)
{
Write-Host " No Files present for ABC "
}

elsif($ABCFileName.Count -ge 2){

foreach($ABCFULLNAME in $ABCFileName)
{
$ABC_DATA = (Get-Content $ABCFULLNAME | Select-String -pattern "AWAITING FOR DATA"  -NotMatch | Select-String -Pattern "G").Line.Split() | where {$_}

$ABC_REC_COUNT = $ABC_DATA[1].TrimStart('0')
$ABC_AMOUNT = $ABC_DATA[2].TrimStart('0')

$SQLCommand = "SELECT a.station S1_test,a.added S1_Money,a.FC S1_RC,b.station S2_test,b.added2 S2_Money,b.FC S2_RC,
CASE WHEN a.added1=b.added2 THEN 'Matched' ELSE 'UnMatched' END as 'Status' FROM
	(SELECT S1.station, SUM(S1.money) added1,COUNT(*) FC FROM $SQLDatabase.dbo.TABLE1 S1 WHERE CONVERT(VARCHAR,InsertedDate,23)=''+ CONVERT(VARCHAR,GETDATE(),23) +'' GROUP BY S1.station) A
FULL OUTER JOIN
	(SELECT S2.station, SUM(S2.money) added2,COUNT(*) FC FROM $SQLDatabase.dbo.TABLE2 S2 WHERE CONVERT(VARCHAR,InsertedDate,23)=''+ CONVERT(VARCHAR,GETDATE(),23) +'' GROUP BY S2.station) B
ON a.station=b.station"

$INSERT_DATA = Invoke-SQLCmd -Query $SQLCommand -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword

$ABC_S1_EXTN = $INSERT_DATA_DATA[1].S1_test
$ABC_S1_AMOUNT = $INSERT_DATA_DATA[1].S1_Money

}

for($ii=0; $ii -le 0; $ii++)
{
$ABCFileName1 = $ABCFileName[$ii].FullName
$abcd1 = Get-Content $ABCFileName1
$Total_lines1 = Get-Content $ABCFileName1 | Measure-Object
$Num1 = $Total_lines1.Count

"Inserting $Num1 rows from ABC into SQL Table "
for($i=0; $i -le $Num1-1; $i++)
{
$xyz1 = 'Hello' + $abcd1[$i]
$Var = $xyz1.Length
$RT = $xyz1.Substring(5,1)
$AN = $xyz1.Substring(7,20)
$IC = $xyz1.Substring(27,11)
$TA = $xyz1.Substring(38,16)
$OA = $Total_Amount.Substring(14,2)
$MA = $Total_Amount.Substring(0,14)
$FA = $Main_Amount1 + "." + $Other_Amount1
$MF = $xyz1.Substring(54)
$ABC_Extension = "ABC"
$ABC_Actual_Name = $ABCFileName1.Name
$SQLInsert = "USE $SQLDatabase
INSERT INTO $SQLTable (RT, AN, IC, TA, MF, ET, FN)
VALUES('$RT', '$AN', '$IC', '$FA', '$MF', '$ABC_Extension', '$ABC_Actual_Name');"

Invoke-SQLCmd -Query $SQLInsert -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
}
}

}
}

$today_date_file = (Get-Date).AddDays(-0).ToString("yyyMMdd")
$yesterday_date = (Get-Date 20:10).AddDays(-0)
&DB_PUSH_FUNC
