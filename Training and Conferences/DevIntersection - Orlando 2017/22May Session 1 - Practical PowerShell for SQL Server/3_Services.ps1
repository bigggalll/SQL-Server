# Get-Service let's you search for a Service with wildcards
# Get-Service mssql*

# $ is a special character and will do a string replace
# when used in a " string or without any quotes and no spaces
# when used in a ' string then it becomes a literal string

# $service = Get-Service 'mssql$s1'
# $service.Stop()
# $service.Start()

Get-Service mssql*
Start-Service 'mssql$s2'
Stop-Service 'mssql$s2'
Restart-Service 'mssql$s2'

Start-Service mssql`$s2
Stop-Service mssql`$s2
Restart-Service "mssql`$s2"

$service = Get-Service 'mssql$s2'

$service.Stop()
$service.Start()

# If you want to see what other things the Service object can do
# Get-Service | Get-Member (or you can do Get-Service | gm)
