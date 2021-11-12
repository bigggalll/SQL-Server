SELECT object_name(p.object_id) as TableName,
                                p.partition_number as Partition,
                                cast( Avg( (rg.deleted_rows * 1. / rg.total_rows) * 100 ) as Decimal(5,2)) as 'Total Fragmentation (Percentage)',
                                sum (case rg.deleted_rows when rg.total_rows then 1 else 0 end ) as 'Deleted Segments Count',
                                cast( (sum (case rg.deleted_rows when rg.total_rows then 1 else 0 end ) * 1. / count(*)) * 100 as Decimal(5,2)) as 'DeletedSegments (Percentage)'
                FROM sys.partitions AS p 
                                INNER JOIN sys.column_store_row_groups rg
                                                ON p.object_id = rg.object_id 
                where rg.state in (1,2, 3,4)
                group by p.object_id, p.partition_number
                order by object_name(p.object_id);
