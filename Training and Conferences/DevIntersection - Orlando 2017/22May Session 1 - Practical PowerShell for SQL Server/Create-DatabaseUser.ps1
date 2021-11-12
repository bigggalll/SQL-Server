Add-Type -AssemblyName "Microsoft.SqlServer.Smo, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"
Add-Type -AssemblyName "Microsoft.SqlServer.SmoExtended, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"

add-sqllogin -sqlserver localhost\s1 -name mylogin -password Password1 `
    -logintype SqlLogin -DefaultDatabase MyDB

$class = "Microsoft.SqlServer.Management.Smo"
$server = New-Object -TypeName "$class.Server" -ArgumentList "LOCALHOST\S1"
$db = $server.Databases["MyDB"]

$name = "mylogin"
$login = "mylogin"

$user = New-Object -TypeName "$class.User" -ArgumentList $db, $name
$user.Login = $login
$user.DefaultSchema = 'dbo'

$user.Create() 
