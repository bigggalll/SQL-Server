--USE [master]
--GO

--DROP PROCEDURE [dbo].[get_crossdatabase_dependencies]
--go
--CREATE PROCEDURE [dbo].[get_crossdatabase_dependencies] AS

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#databases') IS NOT NULL DROP TABLE #databases
CREATE TABLE #databases(
    database_id int, 
    database_name sysname
);

-- ignore systems databases
INSERT INTO #databases(database_id, database_name)
SELECT database_id, name FROM sys.databases
WHERE database_id > 4;	

DECLARE 
    @database_id int, 
    @database_name sysname, 
    @sql varchar(max);

IF OBJECT_ID('DBA_TEMP..dependencies') IS NOT NULL DROP TABLE DBA_TEMP..dependencies
CREATE TABLE DBA_TEMP..dependencies(
    referencing_database varchar(max),
    referencing_schema varchar(max),
    referencing_object_name varchar(max),
    referenced_server varchar(max),
    referenced_database varchar(max),
    referenced_schema varchar(max),
    referenced_object_name varchar(max)
);

WHILE (SELECT COUNT(*) FROM #databases) > 0 BEGIN
    SELECT TOP 1 @database_id = database_id, 
                 @database_name = database_name 
    FROM #databases;

    SET @sql = 'INSERT INTO DBA_TEMP..dependencies select 
        DB_NAME(' + convert(varchar,@database_id) + '), 
        OBJECT_SCHEMA_NAME(referencing_id,' 
            + convert(varchar,@database_id) +'), 
        OBJECT_NAME(referencing_id,' + convert(varchar,@database_id) + '), 
        referenced_server_name,
        ISNULL(referenced_database_name, db_name(' 
             + convert(varchar,@database_id) + ')),
        referenced_schema_name,
        referenced_entity_name
    FROM ' + quotename(@database_name) + '.sys.sql_expression_dependencies';

    EXEC(@sql);

    DELETE FROM #databases WHERE database_id = @database_id;
END;

SET NOCOUNT OFF;

SELECT * FROM DBA_TEMP..dependencies where referenced_object_name = 'Succursales';

--exec master.dbo.[get_crossdatabase_dependencies]