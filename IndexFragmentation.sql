
SELECT partition_number AS PartitionNumber,
       index_type_desc AS IndexType,
       index_depth AS Depth,
       avg_fragmentation_in_percent AS AverageFragmentation,
       page_count AS Pages,
       avg_page_space_used_in_percent AS AveragePageDensity,
       record_count AS Rows,
       ghost_record_count AS GhostRows,
       version_ghost_record_count AS VersionGhostRows,
       min_record_size_in_bytes AS MinimumRecordSize,
       max_record_size_in_bytes AS MaximumRecordSize,
       avg_record_size_in_bytes AS AverageRecordSize,
       forwarded_record_count AS ForwardedRecords
FROM sys.dm_db_index_physical_stats(6, 59628497, 1, NULL, 'SAMPLED');

set nocount on

declare @DbId smallint
set @DbId = db_id()

  select quotename(db_name())                    as DatabaseName
       , quotename(object_name(ips.object_id))   as TableName
       , quotename(i.name)                       as IndexName
       , ips.page_count                          as PageCount
       , ips.page_count * 8 / 1024               as IndexSizeMB
       , ips.fragment_count                      as FragCount
       , ips.avg_fragmentation_in_percent        as AvgFrag
       , ips.index_type_desc                     as IndexType
    from sys.dm_db_index_physical_stats(@DbId, NULL, NULL, NULL, NULL)   ips
    join sys.indexes                                                     i
      on ips.object_id = i.object_id
     and ips.index_id  = i.index_id
   where i.index_id    <> 0
     and ips.page_count > 0
order by FragCount desc
