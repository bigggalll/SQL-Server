param ($ServerInstance, $DatabaseName) 

Add-Type -AssemblyName "Microsoft.SqlServer.Smo, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"

$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -args $ServerInstance

$dbinit = $server.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database])
[void]$dbinit.Add("ID")
[void]$dbinit.Add("RecoveryModel")
[void]$dbinit.Add("PageVerify")
[void]$dbinit.Add("Owner")
$server.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $dbinit)

$server.Databases | Select Name, ID, RecoveryModel, PageVerify, Owner | Format-Table * -AutoSize

$fileinit = $server.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.DataFile])
[void]$fileinit.Add("Name")
[void]$fileinit.Add("ID")
[void]$fileinit.Add("FileName")
[void]$fileinit.Add("Growth")
[void]$fileinit.Add("GrowthType")
$server.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.DataFile], $fileinit)

$server.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.LogFile], $fileinit)


$db = $server.Databases[$DatabaseName]
$db.Filegroups | Select Name, FileGroupType, IsDefault, ReadOnly, IsFileStream, Size | Format-Table * -AutoSize

foreach($filegroup in $db.FileGroups) {
    $filegroup.Files | Select Name, ID, Parent, Growth, GrowthType, Filename | Format-Table * -AutoSize
}

$db.LogFiles | Select Name, ID, Growth, GrowthType, FileName | Format-Table * -AutoSize



