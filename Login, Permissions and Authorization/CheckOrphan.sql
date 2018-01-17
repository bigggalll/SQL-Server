/*************************************************
** Purpose: To return database users (for each db) orphaned from any login.
** Created By: James Howard
** Created On: 03 DEC 09
*************************************************/

--create a temp table to store the results
CREATE TABLE #temp
(DatabaseName NVARCHAR(50),
 UserName     NVARCHAR(50)
);

select DB_NAME() [database], name as [user_name], type_desc,default_schema_name,create_date,modify_date from sys.database_principals 
where type in ('G','S','U') 
and authentication_type<>2 -- Use this filter only if you are running on SQL Server 2012 and major versions and you have "contained databases"
and [sid] not in ( select [sid] from sys.server_principals where type in ('G','S','U') ) 
and name not in ('dbo','guest','INFORMATION_SCHEMA','sys','MS_DataCollectorInternalUser')


--create statement to run on each database
DECLARE @sql NVARCHAR(500);
SET @sql = 'select ''?'' as DBName
, name AS UserName
from [?]..sysusers
where (sid is not null and sid <> 0x0)
and suser_sname(sid) is null and
(issqlrole <> 1) AND 
(isapprole <> 1) AND 
(name <> ''INFORMATION_SCHEMA'') AND 
(name <> ''guest'') AND 
(name <> ''sys'') AND 
(name <> ''dbo'') AND 
(name <> ''system_function_schema'')
order by name
';
--insert the results from each database to temp table
INSERT INTO #temp
EXEC SP_MSforeachDB
     @sql;
--return results
SELECT *
FROM #temp;
--DECLARE c CURSOR LOCAL READ_ONLY
--FOR SELECT DatabaseName,
--           UserName
--    FROM #temp;
--DECLARE @DBName NVARCHAR(100);
--DECLARE @name NVARCHAR(100);
--OPEN c;
--FETCH FROM c INTO @DBName, @name;
--WHILE @@fetch_status = 0
--    BEGIN
--        SET @sql = 'USE ['+@DBName+']; ALTER USER '+@name+' WITH LOGIN = '+@name+';';
--        EXEC (@sql);
--        PRINT @DBName;
--        PRINT @name;
--        FETCH NEXT FROM c INTO @DBName, @name;
--    END;
--CLOSE c;
--DEALLOCATE c;
DROP TABLE #temp;