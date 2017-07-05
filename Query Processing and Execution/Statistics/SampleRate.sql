SELECT    row_number() OVER ( PARTITION BY s.name + '.' + t.name
                            ORDER BY  CAST((sp.modification_counter  * 1.0)/ (sp.[rows] * 1.0) AS numeric(12, 4)) DESC) as row_num
        , t.name AS TableNameNoSchema
        , '[' + s.name + '].[' + t.name + ']' AS TableName
        , t.[object_id] AS TableID
        , stat.name AS StatName
        , sc.NumStats
        , sp.[rows] AS [RowCount]
        , sp.modification_counter AS RowModCtr
        , sp.rows_sampled AS RowsSampled
        , sp.last_updated
        , CAST(((sp.modification_counter  * 1.0)/ (sp.[rows] * 1.0) * 100.0) AS numeric(18, 2)) AS [PercentChange]
        , CAST(((sp.rows_sampled  * 1.0)/ (sp.[rows] * 1.0) * 100.0) AS numeric(18, 2)) AS [SampleRate]
FROM        --#myTables mt
        --INNER JOIN 
        sys.tables AS t
            --ON    t.[object_id] = mt.[object_id]
        INNER JOIN sys.schemas s 
            ON    t.[schema_id] = s.[schema_id]
        INNER JOIN sys.stats stat 
            ON stat.[object_id] = t.[object_id]
            AND    stat.auto_created = 1
        CROSS APPLY sys.dm_db_stats_properties(stat.[object_id], stat.stats_id) AS sp
        LEFT OUTER JOIN (     SELECT    [object_id]
                                    , count(*) AS NumStats
                            FROM        sys.stats 
                            WHERE    [object_id] > 100
                            AND        auto_created = 1
                            GROUP BY [object_id] ) sc
            ON    sc.[object_id] = t.[object_id]
WHERE    t.[object_id] > 100        /* Exclude system objects */
