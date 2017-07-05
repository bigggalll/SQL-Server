drop table DBA_SQL01P..StatsDensity;
create table DBA_SQL01P..StatsDensity
(
 Id [int] IDENTITY(1,1) NOT NULL
,Collection_Datetime datetime default CURRENT_TIMESTAMP
,StatName nvarchar(128)
,TableName nvarchar(128)
,ErrorMessage nvarchar(max)
,[All density] real
,[Average Length] real
,[Columns] NVARCHAR(4000)
,last_updated datetime
);
create index IDX_StatDensity

DECLARE @stat_name sysname;
DECLARE @table_name sysname;
DECLARE @schema_name sysname;
DECLARE @sql varchar(max)
DECLARE stats_cursor CURSOR FOR
	SELECT a.name stat_name,b.name stat_owner,c.name schema_name 
	FROM sys.stats a 
		inner join sys.objects b 
				on a.object_id=b.object_id 
		inner join sys.schemas c
				on b.schema_id=c.schema_id
	WHERE a.object_id > 255 and b.type <> 'IT';

OPEN stats_cursor;  
  
FETCH NEXT FROM stats_cursor INTO @stat_name, @table_name, @schema_name;  
WHILE @@FETCH_STATUS = 0  
BEGIN  
	SET @sql = 'DBCC SHOW_STATISTICS (''' + QUOTENAME(@schema_name) + '.' +QUOTENAME(@table_name)+''', ' + QUOTENAME(@stat_name)+') WITH NO_INFOMSGS, DENSITY_VECTOR;'
	PRINT @sql

	BEGIN TRY
		insert into DBA_SQL01P..StatsDensity([All density],[Average Length],[Columns])
		EXEC(@sql);
	END TRY
	BEGIN CATCH
	    PRINT 'ErrorMessage: ' + ERROR_MESSAGE();
		insert into DBA_SQL01P..StatsDensity([ErrorMessage]) values (ERROR_MESSAGE());
	END CATCH;

	UPDATE DBA_SQL01P..StatsDensity SET StatName=@stat_name,TableName=@table_name
	where StatName IS NULL AND TableName IS NULL;

    FETCH NEXT FROM stats_cursor INTO @stat_name, @table_name, @schema_name;
END;  
  
CLOSE stats_cursor;  
DEALLOCATE stats_cursor;  

GO
