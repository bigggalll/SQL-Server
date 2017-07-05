drop table DBA_SQL01P..StatsHistogram;
create table DBA_SQL01P..StatsHistogram
(
 Id [int] IDENTITY(1,1) NOT NULL
,Collection_Datetime datetime default CURRENT_TIMESTAMP
,StatName nvarchar(128)
,TableName nvarchar(128)
,ErrorMessage nvarchar(max)
,Range_hi_key sql_variant
,Range_rows real
,eq_rows real
,distinct_range_rows bigint
,avg_range_rows real
);

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
	SET @sql = 'DBCC SHOW_STATISTICS (''' + QUOTENAME(@schema_name) + '.' +QUOTENAME(@table_name)+''', ' + QUOTENAME(@stat_name)+') WITH NO_INFOMSGS, HISTOGRAM;'
	PRINT @sql

	BEGIN TRY
		insert into DBA_SQL01P..StatsHistogram(Range_hi_key,Range_rows,eq_rows,distinct_range_rows,avg_range_rows)
		EXEC(@sql);
	END TRY
	BEGIN CATCH
	    PRINT 'ErrorMessage: ' + ERROR_MESSAGE();
		insert into DBA_SQL01P..StatsHistogram([ErrorMessage]) values (ERROR_MESSAGE());
	END CATCH;

	UPDATE DBA_SQL01P..StatsHistogram SET StatName=@stat_name,TableName=@table_name
	where StatName IS NULL AND TableName IS NULL;

    FETCH NEXT FROM stats_cursor INTO @stat_name, @table_name, @schema_name;
END;  
  
CLOSE stats_cursor;  
DEALLOCATE stats_cursor;  

GO
