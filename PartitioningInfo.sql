DECLARE @TableName NVARCHAR(200) = N'dbo.Orders'
 
--SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object]
--     , p.partition_number AS [p#]
--     , fg.name AS [filegroup]
--     , p.rows
--     , au.total_pages AS pages
--     , CASE boundary_value_on_right
--       WHEN 1 THEN 'less than'
--       ELSE 'less than or equal to' END as comparison
--     , rv.value
--     , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) +
--       SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20),
--       CONVERT (INT, SUBSTRING (au.first_page, 4, 1) +
--       SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) +
--       SUBSTRING (au.first_page, 1, 1))) AS first_page
--FROM 
--sys.partitions p
--INNER JOIN sys.indexes i
--     ON p.object_id = i.object_id
--AND p.index_id = i.index_id
--INNER JOIN 
--sys.objects o
--     ON p.object_id = o.object_id
--INNER JOIN sys.system_internals_allocation_units au
--     ON p.partition_id = au.container_id
--INNER JOIN sys.partition_schemes ps
--     ON ps.data_space_id = i.data_space_id
--INNER JOIN sys.partition_functions f
--     ON f.function_id = ps.function_id
--INNER JOIN sys.destination_data_spaces dds
--     ON dds.partition_scheme_id = ps.data_space_id
--     AND dds.destination_id = p.partition_number
--INNER JOIN sys.filegroups fg
--     ON dds.data_space_id = fg.data_space_id
--LEFT OUTER JOIN sys.partition_range_values rv
--     ON f.function_id = rv.function_id
--     AND p.partition_number = rv.boundary_id
--WHERE i.index_id < 2
--     AND o.object_id = OBJECT_ID(@TableName);
--GO

-- Kendra version qui retire les doublon pour les colunstore
--
SELECT
    sc.name + N'.' + so.name as [Schema.Table],
    si.index_id as [Index ID],
    si.type_desc as [Structure],
    si.name as [Index],
    stat.row_count AS [Rows],
    stat.in_row_reserved_page_count * 8./1024./1024. as [In-Row GB],
    stat.lob_reserved_page_count * 8./1024./1024. as [LOB GB],
    p.partition_number AS [Partition #],
    pf.name as [Partition Function],
    CASE pf.boundary_value_on_right
        WHEN 1 then 'Right / Lower'
        ELSE 'Left / Upper'
    END as [Boundary Type],
    prv.value as [Boundary Point],
    fg.name as [Filegroup]
FROM sys.partition_functions AS pf
JOIN sys.partition_schemes as ps on ps.function_id=pf.function_id
JOIN sys.indexes as si on si.data_space_id=ps.data_space_id 
JOIN sys.objects as so on si.object_id = so.object_id
JOIN sys.schemas as sc on so.schema_id = sc.schema_id
JOIN sys.partitions as p on 
    si.object_id=p.object_id 
    and si.index_id=p.index_id
LEFT JOIN sys.partition_range_values as prv on prv.function_id=pf.function_id
    and p.partition_number= 
        CASE pf.boundary_value_on_right WHEN 1
            THEN prv.boundary_id + 1
        ELSE prv.boundary_id
        END
        /* For left-based functions, partition_number = boundary_id, 
           for right-based functions we need to add 1 */
JOIN sys.dm_db_partition_stats as stat on stat.object_id=p.object_id
    and stat.index_id=p.index_id
    and stat.index_id=p.index_id and stat.partition_id=p.partition_id
    and stat.partition_number=p.partition_number
JOIN sys.allocation_units as au on au.container_id = p.hobt_id
    and au.type_desc ='IN_ROW_DATA' 
        /* Avoiding double rows for columnstore indexes. */
        /* We can pick up LOB page count from partition_stats */
JOIN sys.filegroups as fg on fg.data_space_id = au.data_space_id
ORDER BY [Schema.Table], [Index ID], [Partition Function], [Partition #];
GO