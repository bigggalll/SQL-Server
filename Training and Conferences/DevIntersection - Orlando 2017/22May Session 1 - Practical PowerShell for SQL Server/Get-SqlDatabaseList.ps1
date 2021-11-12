param ($ServerInstance) 

Add-Type -AssemblyName "Microsoft.SqlServer.Smo, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"

$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -args $ServerInstance

$dbinit = $server.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database])
[void]$dbinit.Add("ID")
[void]$dbinit.Add("RecoveryModel")
$server.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $dbinit)

$server.Databases | Select Name, ID, RecoveryModel | Format-Table * -AutoSize

