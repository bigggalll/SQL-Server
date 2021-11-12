

/***************************************************************************
*
* 3/2/2012  REH   Turn on row compression for all DynamicsPerf indexes
*                   if compression is supported.
*
*		This is done automatically during installation but if you upgrade
*		SQL Editions or move the database to a server that supports
*		database compression then you can run these scripts.
*
*
****************************************************************************/
IF  (cast(serverproperty('Edition') as varchar(100)) like 'Enterprise%' or cast(serverproperty('Edition') as varchar(100)) like 'Developer%')
BEGIN
		DECLARE @INDEX_NAME SYSNAME
		DECLARE @TABLE_NAME SYSNAME
		DECLARE @SQL VARCHAR(MAX)


		DECLARE INDEXCURSOR CURSOR FOR
			SELECT	
					si.name, 
					so.name
			FROM	DynamicsPerf.sys.indexes si
			JOIN	DynamicsPerf.sys.sysindexes ii on si.object_id = ii.id and si.index_id = ii.indid
			JOIN	DynamicsPerf.sys.objects so on so.object_id = si.object_id
			JOIN	DynamicsPerf.sys.schemas ss on ss.schema_id = so.schema_id
			WHERE	so.type = 'U'
			AND		si.type > 0  --other than heap tables
			
			OPEN INDEXCURSOR

		FETCH INDEXCURSOR INTO 
			@INDEX_NAME		,
			@TABLE_NAME		
			
			
		WHILE @@FETCH_STATUS = 0
			BEGIN
			
			--Need page compression on this table to get maximum space savings
			IF @TABLE_NAME = 'SQLErrorLog'
			BEGIN
			SELECT @SQL = 'ALTER INDEX [' + @INDEX_NAME + '] ON ' + @TABLE_NAME + 
			' REBUILD WITH (DATA_COMPRESSION = PAGE)'
			END
			ELSE
			BEGIN
			SELECT @SQL = 'ALTER INDEX [' + @INDEX_NAME + '] ON ' + @TABLE_NAME + 
			' REBUILD WITH (DATA_COMPRESSION = ROW)'
			END
			
			EXEC (@SQL)
			
			FETCH NEXT FROM INDEXCURSOR INTO @INDEX_NAME,@TABLE_NAME
			END
			
			CLOSE INDEXCURSOR
			DEALLOCATE INDEXCURSOR
			
			
			--REH Compress the QUERY_PLANS table that we removed the clustered index on
			ALTER TABLE dbo.QUERY_PLANS  REBUILD WITH ( DATA_COMPRESSION = ROW )
END