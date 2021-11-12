Add-Type -AssemblyName "Microsoft.SqlServer.Smo, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"
Add-Type -AssemblyName "Microsoft.SqlServer.SmoExtended, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"

$class = "Microsoft.SqlServer.Management.Smo"
$server = New-Object -TypeName "$class.Server" -ArgumentList "LOCALHOST\S1"
$db = New-Object -TypeName "$class.Database" -ArgumentList $server, "MyDB"

$filegroup = New-Object -TypeName "$class.Filegroup" -ArgumentList $db, "PRIMARY"

$db.FileGroups.Add($filegroup)

$file = New-Object -TypeName "$class.DataFile" -ArgumentList $filegroup, "$($db.Name)_Data"

$file.Size = 256000
$file.GrowthType = "KB" 
$file.Growth = 256000
$file.MaxSize = 20202020
$file.FileName = "C:\SQLDATA\S1\MyDB.mdf"

$filegroup.Files.Add($file)

$logfile = New-Object -TypeName "$class.LogFile" -ArgumentList $db, "$($db.Name)_log"

$logfile.Size = 128000
$logfile.GrowthType = "KB" 
$logfile.Growth = 128000
$logfile.MaxSize = 20202020
$logfile.FileName = "C:\SQLDATA\S1\MyDB_log.ldf"

$db.LogFiles.Add($logfile)

$db.Create()
