select name, type, buckets_count 
from sys.dm_os_memory_cache_hash_tables
where name IN ( 'SQL Plans' , 'Object Plans' , 'Bound Trees' )

select name, type, pages_kb, entries_count 
from sys.dm_os_memory_cache_counters
where name IN ( 'SQL Plans' , 'Object Plans' ,  'Bound Trees' )

SELECT objtype AS [CacheType],
    COUNT_BIG(*) AS [Total Plans],
    SUM(CAST(size_in_bytes AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs],
    AVG(usecounts) AS [Avg Use Count],
    SUM(CAST((CASE WHEN usecounts = 1 THEN size_in_bytes
        ELSE 0
        END) AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs – USE Count 1],
    SUM(CASE WHEN usecounts = 1 THEN 1
        ELSE 0
        END) AS [Total Plans – USE Count 1]
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY [Total MBs – USE Count 1] DESC
GO

SELECT S.CacheType, S.Avg_Use, S.Avg_Multi_Use,
       S.Total_Plan_3orMore_Use, S.Total_Plan_2_Use, S.Total_Plan_1_Use, S.Total_Plan,
       CAST( (S.Total_Plan_1_Use * 1.0 / S.Total_Plan) as Decimal(18,2) )[Pct_Plan_1_Use],
       S.Total_MB_1_Use,   S.Total_MB,
       CAST( (S.Total_MB_1_Use   * 1.0 / S.Total_MB  ) as Decimal(18,2) )[Pct_MB_1_Use]
  FROM
  (
    SELECT CP.objtype[CacheType],
           COUNT(*)[Total_Plan],
           SUM(CASE WHEN CP.usecounts > 2 THEN 1 ELSE 0 END)[Total_Plan_3orMore_Use],
           SUM(CASE WHEN CP.usecounts = 2 THEN 1 ELSE 0 END)[Total_Plan_2_Use],
           SUM(CASE WHEN CP.usecounts = 1 THEN 1 ELSE 0 END)[Total_Plan_1_Use],
           CAST((SUM(CP.size_in_bytes * 1.0) / 1024 / 1024) as Decimal(12,2) )[Total_MB],
           CAST((SUM(CASE WHEN CP.usecounts = 1 THEN (CP.size_in_bytes * 1.0) ELSE 0 END)
                      / 1024 / 1024) as Decimal(18,2) )[Total_MB_1_Use],
           CAST(AVG(CP.usecounts * 1.0) as Decimal(12,2))[Avg_Use],
           CAST(AVG(CASE WHEN CP.usecounts > 1 THEN (CP.usecounts * 1.0)
                         ELSE NULL END) as Decimal(12,2))[Avg_Multi_Use]
      FROM sys.dm_exec_cached_plans as CP
     GROUP BY CP.objtype
  ) AS S
ORDER BY S.CacheType
