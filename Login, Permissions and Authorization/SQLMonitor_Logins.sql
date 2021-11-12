
/*Server level Logins and roles*/

SET NOCOUNT ON;
SELECT @@ServerName AS ServerName,
       sp.default_database_name AS DefaultDBName,
       sp.name AS LoginName,
       sp.type_desc AS LoginType,
       slog.createdate,
       slog.updatedate,
       CAST(sp.is_disabled AS BIT) AS isDisabled,
       CAST(slog.denylogin AS BIT) AS denylogin,
       CAST(slog.hasaccess AS BIT) AS hasaccess,
       CAST(slog.sysadmin AS BIT) AS SysAdmin,
       CAST(slog.securityadmin AS BIT) AS SecurityAdmin,
       CAST(slog.serveradmin AS BIT) AS ServerAdmin,
       CAST(slog.setupadmin AS BIT) AS SetupAdmin,
       CAST(slog.processadmin AS BIT) AS ProcessAdmin,
       CAST(slog.diskadmin AS BIT) AS DiskAdmin,
       CAST(slog.dbcreator AS BIT) AS DBCreator,
       CAST(slog.bulkadmin AS BIT) AS BulkAdmin,
       CAST(slog.isntname AS BIT) isntname,
       CAST(slog.isntgroup AS BIT) isntgroup,
       CAST(slog.isntuser AS BIT) isntuser
FROM   sys.server_principals sp
       JOIN sys.syslogins slog ON sp.sid = slog.sid
WHERE  sp.type <> 'R';