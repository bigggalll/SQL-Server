select db_name() as DBName,* from sys.database_principals 
where sid not in (select sid from master.sys.server_principals)
AND type_desc != 'DATABASE_ROLE' AND name != 'guest'