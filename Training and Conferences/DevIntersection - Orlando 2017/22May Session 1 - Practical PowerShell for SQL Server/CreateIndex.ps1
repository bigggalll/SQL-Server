Add-Type -AssemblyName "Microsoft.SqlServer.Smo, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"
Add-Type -AssemblyName "Microsoft.SqlServer.SmoExtended, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"

$class = "Microsoft.SqlServer.Management.Smo"
$server = New-Object -TypeName "$class.Server" -ArgumentList "LOCALHOST\S1"
$db = $server.Databases["MyDB"]

$table = $db.Tables["Table1"]

$index = New-Object -TypeName "$class.Index" -ArgumentList $table, "NewIndex"

$col1 = New-Object -TypeName "$class.IndexedColumn" -ArgumentList $index, "Table1Id", $true
$index.IndexedColumns.Add($col1)

$index.IndexKeyType = [Microsoft.SqlServer.Management.Smo.IndexKeyType]::DriPrimaryKey
$index.IsClustered = $true

$index.Create()
