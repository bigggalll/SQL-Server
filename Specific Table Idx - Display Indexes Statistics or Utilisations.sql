DECLARE @TableName  nVARCHAR(250) = 'person';  
DECLARE @WithHeader int = 0  -- 0 for no, 1 for yes (Title for each section) 

DECLARE @stat_name   SYSNAME;
DECLARE @table_name  SYSNAME;
DECLARE @schema_name SYSNAME;
DECLARE @no_recompute BIT;
DECLARE @sql VARCHAR(max);
 
DECLARE stats_cursor CURSOR
FOR
SELECT a.NAME stat_name
       ,b.NAME stat_owner
       ,c.NAME schema_name
       ,a.no_recompute
FROM sys.stats a
INNER JOIN sys.objects b ON a.object_id = b.object_id
INNER JOIN sys.schemas c ON b.schema_id = c.schema_id
WHERE a.object_id > 255
       AND b.type <> 'IT'
AND b.NAME IN
(
@TableName
)
order by b.NAME desc;
 
select '-- Missings Indexes --' as Title;
	SELECT TOP 25
	convert(varChar,
					dateadd(
						ss,
						(dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) )/1000,
					0),
					108) as [Avg Estimated Impact],
	dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) as Avg_Estimated_Impact,
	dm_migs.last_user_seek AS Last_User_Seek,
	object_name(dm_mid.object_id,dm_mid.database_id) AS [TableName] ,
	'CREATE________INDEX [IX_' + object_name(dm_mid.object_id,dm_mid.database_id) + '_'
	+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','') +
	CASE
		WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN '_'
		ELSE ''
	END
	+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','')
	+ ']'
	+ ' ON ' + dm_mid.statement
	+ ' (' + ISNULL (dm_mid.equality_columns,'')
	+ CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN ',' ELSE
	'' END
	+ ISNULL (dm_mid.inequality_columns, '')
	+ ')'
	+ ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement 
	FROM sys.dm_db_missing_index_groups dm_mig
	INNER JOIN sys.dm_db_missing_index_group_stats dm_migs
	ON dm_migs.group_handle = dm_mig.index_group_handle
	INNER JOIN sys.dm_db_missing_index_details dm_mid
	ON dm_mig.index_handle = dm_mid.index_handle
	where object_name(dm_mid.object_id,dm_mid.database_id) = @TableName
	ORDER BY Avg_Estimated_Impact DESC 
	;

if @WithHeader = 1 select '-- All indexes overview' as Title;

	SELECT distinct
	ind.name as [Index Name],
	ind.type_desc as [Index Type],
	ind.fill_factor,
	ind.is_unique,
	ind.has_filter,
	ind.allow_page_locks,
	ind.allow_row_locks,
	internals.total_pages,
	internals.used_pages, 
	FORMAT(internals.used_pages/cast(internals.total_pages as decimal(15,2)),'P') as [Perc. Utilisé],
	internals.data_pages
 
	FROM sys.objects obj
		INNER JOIN sys.partitions part 
			ON obj.object_id = part.object_id
		INNER JOIN sys.allocation_units alloc 
			ON alloc.container_id = part.hobt_id
		INNER JOIN sys.system_internals_allocation_units internals 
			ON internals.container_id = alloc.container_id
		Inner JOIN sys.indexes ind  
			on ind.index_id = part.index_id
		INNER JOIN sys.tables t 
			ON ind.object_id = t.object_id and t.name = @TableName
	where obj.name = @TableName and
	      ind.is_disabled = 0 and
		  cast(internals.total_pages as decimal(15,2))   <> 0
	order by ind.name;

if @WithHeader = 1 select '-- All indexes utilisations' as Title;

	SELECT  
	 i.name AS IndexName
	,I.type_desc AS [Index type]
	, i.index_id AS IndexID  
	, dm_ius.user_seeks AS UserSeek
	, dm_ius.user_scans AS UserScans
	, dm_ius.user_lookups AS UserLookups
	, dm_ius.user_updates AS UserUpdates
	, p.TableRows
	/*, 'DROP INDEX ' + QUOTENAME(i.name) 
	+ ' ON ' + QUOTENAME(s.name) + '.' + QUOTENAME(OBJECT_NAME(dm_ius.object_id)) as 'drop statement'*/
	FROM sys.dm_db_index_usage_stats dm_ius  
	INNER JOIN sys.indexes i ON i.index_id = dm_ius.index_id AND dm_ius.object_id = i.object_id   
	INNER JOIN sys.objects o on dm_ius.object_id = o.object_id
	INNER JOIN sys.schemas s on o.schema_id = s.schema_id
	INNER JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.object_id 
					FROM sys.partitions p GROUP BY p.index_id, p.object_id) p 
			ON p.index_id = dm_ius.index_id AND dm_ius.object_id = p.object_id
	WHERE OBJECTPROPERTY(dm_ius.object_id,'IsUserTable') = 1
	AND dm_ius.database_id = DB_ID()   
	--AND i.type_desc = 'nonclustered'
	--AND i.is_primary_key = 0
	--AND i.is_unique_constraint = 0
	-- Filter by schema or table name 
	and o.name = @TableName
	ORDER BY i.name;
 
if @WithHeader = 1 select '-- All indexes summary data' as Title;

	with tmpSize as ( -- Extraire la taille des indexes. Tiré d'un autre site
	SELECT 
		i.object_id						as ObjectID,
		i.index_id						as IndexID,
		cast(SUM(s.[used_page_count]) * 8.0 / 1024.0 / 1024.0 as numeric(19,3)) 	AS IndexSizeGB
	FROM sys.dm_db_partition_stats AS s
	INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
		AND s.[index_id] = i.[index_id]
	GROUP BY i.[index_id],
	i.object_id
	),
	tmpCompression as ( -- Extraire les infos de partition par index
	select
		i.Object_id					as ObjectID,
		i.index_id					as IndexID,
		p.data_compression_desc		as Compression
	from
		sys.partitions					as p
		LEFT OUTER JOIN sys.indexes		as i
			on	p.object_id = i.object_id and
				p.index_id = i.index_id
	)
	select 
		i.name as [Index] 
		,tmpSize.IndexSizeGB as IndexSizeGB
		,tmpCompression.Compression	as Compression
		,i.is_unique as [IsUnique]
		,ius.user_seeks as [Seeks], ius.user_scans as [Scans]
		,ius.user_lookups as [Lookups]
		,ius.user_seeks + ius.user_scans + ius.user_lookups as [Reads]
		,ius.user_updates as [Updates], ius.last_user_seek as [Last Seek]
		,ius.last_user_scan as [Last Scan], ius.last_user_lookup as [Last Lookup]
		,ius.last_user_update as [Last Update]
	from 
		sys.tables t with (nolock) join sys.indexes i with (nolock) on
			t.object_id = i.object_id
		join sys.schemas s with (nolock) on 
			t.schema_id = s.schema_id
		left outer join sys.dm_db_index_usage_stats ius on
			ius.database_id = db_id() and
			ius.object_id = i.object_id and 
			ius.index_id = i.index_id
		join tmpSize on
			i.index_id = tmpSize.IndexID and
			i.object_id = tmpSize.ObjectID 
		join tmpCompression on
			i.index_id = tmpCompression.IndexID and
			i.object_id = tmpCompression.ObjectID 
	where
		t.name = @TableName
	ORDER BY i.name;

select '-- Statistics Details --' as Section;

	if @WithHeader = 1 select 'DBCC SHOW_STATISTICS' as Title;
		OPEN stats_cursor;

		FETCH NEXT
		FROM stats_cursor
		INTO @stat_name
			   ,@table_name
			   ,@schema_name
			   ,@no_recompute;

       
		WHILE @@FETCH_STATUS = 0
		BEGIN
			   SET @sql = 'DBCC SHOW_STATISTICS (''' + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name) + ''', ' + QUOTENAME(@stat_name) + ')-- WITH NO_INFOMSGS, STAT_HEADER;';
			   EXEC (@sql);
			   --PRINT @sql;

			   FETCH NEXT
			   FROM stats_cursor
			   INTO @stat_name
					  ,@table_name
					  ,@schema_name
					  ,@no_recompute;
		END;

		CLOSE stats_cursor;

		DEALLOCATE stats_cursor;

