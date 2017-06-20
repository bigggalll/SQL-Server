	-- Instruction pour purger commit_table
	use AsyncServerMsgDB; exec sys.sp_flush_commit_table_on_demand
	 
	-- Voir ce qui reste à purger
	use AsyncServerMsgDB; select count(*) nombre, min(commit_time) old_commit_time, max(commit_ts) commit_clean_up from sys.dm_tran_commit_table where commit_ts < (select min(cleanup_version) from sys.change_tracking_tables)
	 
	-- Clean up version des TrackTable
	use AsyncServerMsgDB; select object_name (object_id) as table_name, * from sys.change_tracking_tables 
	 
	-- Taille track table interne
	use AsyncServerMsgDB
	select sot1.object_id, sct1.name as CT_schema,
	sot1.name as CT_table,
	ps1.row_count as CT_rows,
	ps1.reserved_page_count*8./1024. as CT_reserved_MB,
	sct2.name as tracked_schema,
	sot2.name as tracked_name,
	ps2.row_count as tracked_rows,
	ps2.reserved_page_count*8./1024. as tracked_base_table_MB,
	change_tracking_min_valid_version(sot2.object_id) as min_valid_version
	FROM sys.internal_tables it
	JOIN sys.objects sot1 on it.object_id=sot1.object_id
	JOIN sys.schemas AS sct1 on sot1.schema_id=sct1.schema_id
	JOIN sys.dm_db_partition_stats ps1 on it.object_id = ps1. object_id and ps1.index_id in (0,1)
	LEFT JOIN sys.objects sot2 on it.parent_object_id=sot2.object_id
	LEFT JOIN sys.schemas AS sct2 on sot2.schema_id=sct2.schema_id
	LEFT JOIN sys.dm_db_partition_stats ps2 on sot2.object_id = ps2. object_id and ps2.index_id in (0,1)
WHERE it.internal_type IN (209, 210);