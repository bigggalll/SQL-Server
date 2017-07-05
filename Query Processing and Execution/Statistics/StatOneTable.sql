DECLARE @table_name sysname = 'RETAILTRANSACTIONSALESTRANS';
DECLARE @schema_name sysname = 'dbo';
DECLARE @stat_name sysname;
DECLARE @sql varchar(max)
SET @sql = '
DECLARE stats_cursor CURSOR FOR
	SELECT a.name stat_name,b.name stat_owner,c.name schema_name 
	FROM sys.stats a 
		inner join sys.objects b 
				on a.object_id=b.object_id 
		inner join sys.schemas c
				on b.schema_id=c.schema_id
	WHERE b.name=''' + @table_name + ''' AND c.name=''' + @schema_name + ''''

EXEC(@sql);

OPEN stats_cursor;  
  
FETCH NEXT FROM stats_cursor INTO @stat_name, @table_name, @schema_name;  
WHILE @@FETCH_STATUS = 0  
BEGIN  
	SET @sql = 'DBCC SHOW_STATISTICS (''' + QUOTENAME(@schema_name) + '.' +QUOTENAME(@table_name)+''', ' + QUOTENAME(@stat_name)+') WITH NO_INFOMSGS;'
	PRINT @sql
	EXEC(@sql);

    FETCH NEXT FROM stats_cursor INTO @stat_name, @table_name, @schema_name;
END;  
  
CLOSE stats_cursor;  
DEALLOCATE stats_cursor;  

GO
