function Expand-SqlDatabaseFile {
    Param ($server, $database, $fileid, $growthInMB)

    $sqlsrv = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $server

    $sqlsrv.Databases[$database].FileGroups["PRIMARY"].Files[$fileid-1].Size += ($GrowthInMB*1024)
    $sqlsrv.Databases[$database].FileGroups["PRIMARY"].Files[$fileid-1].Alter()
    
    $sqlsrv.Databases[$database].FileGroups["PRIMARY"].Files[$fileid-1].Refresh()
    $sqlsrv.Databases[$database].FileGroups["PRIMARY"].Files[$fileid-1].Size
}

$size = Expand-SqlDatabaseFile localhost\s1 "DEMODB" 1 256
$size / 1KB
