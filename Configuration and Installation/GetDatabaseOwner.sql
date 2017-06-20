
SELECT suser_sname( owner_sid ) owner_name, name, @@servername FROM sys.databases where database_id>4 order by name

