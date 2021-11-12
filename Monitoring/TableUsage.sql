--use tempdb
SELECT  sc.name + '.' + t.NAME AS TableName,  
        max(p.[Rows]) as [nbRows],
             max(case when i.type <= 1 then i.type_desc else '' end) as type_desc,
             SUM(case when i.type > 1 then 1 else 0 end) as nb_idx,
             ( SUM(a.total_pages)  * 8 ) /1024  AS TotalReservedSpaceMB,
        ( SUM(case when i.type <= 1 then a.data_pages else 0 end) * 8 )  /1024  AS T_UsedDataSpaceMB,  -- Number of total pages * 8KB size of each page in SQL Server  
        ( SUM(a.used_pages - case when i.type <= 1 then a.data_pages else 0 end) * 8 )  /1024  AS idx_spaceMB, 
             ( SUM(a.total_pages-a.used_pages)  * 8 ) /1024 AS UnusedSpaceMB
             ,max(t.create_date) as Create_date
FROM    sys.tables t  
        INNER JOIN sys.schemas sc ON sc.schema_id = t.schema_id  
        INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id  
        INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID  
                                            AND i.index_id = p.index_id  
        INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id  
WHERE   t.type_desc = 'USER_TABLE'  
GROUP BY sc.name + '.' + t.NAME  
ORDER BY sum(a.total_pages) desc
