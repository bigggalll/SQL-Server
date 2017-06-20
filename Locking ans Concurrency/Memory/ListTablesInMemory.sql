SELECT TOP 20
  db.name, OBJ.NAME ,index_id ,
  COUNT(*)AS CACHED_PAGES_COUNT

FROM sys.dm_os_buffer_descriptors AS BD 
    INNER JOIN 
    (
        SELECT obj.name AS NAME 
            ,index_id ,ALLOCATION_UNIT_ID
        FROM sys.allocation_units AS AU
            INNER JOIN sys.partitions AS P 
                                           
                ON AU.CONTAINER_ID = P.HOBT_ID 
                    AND (AU.type = 1 OR AU.type = 3)
                                           INNER JOIN sys.sysobjects AS obj
                                                          on obj.id = P.object_id
        UNION ALL
        SELECT obj.name AS NAME   
            ,index_id, ALLOCATION_UNIT_ID
        FROM sys.allocation_units as AU
            INNER JOIN sys.partitions AS P 
                ON AU.CONTAINER_ID = P.PARTITION_ID 
                    AND AU.type = 2
                                           INNER JOIN sys.sysobjects AS obj
                                                          on obj.id = P.object_id
    ) AS OBJ 
        ON BD.allocation_unit_id = OBJ.ALLOCATION_UNIT_ID
    INNER JOIN sys.databases db ON BD.database_id = db.database_id
WHERE db.name = DB_NAME() and db.state_desc = 'ONLINE'
GROUP BY db.database_id,db.name, OBJ.NAME, index_id
ORDER BY 4 DESC,db.database_id,db.name, OBJ.NAME, index_id
