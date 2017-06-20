SELECT SUM(total_size_mb)
FROM
(
    SELECT database_name = DB_NAME(database_id),
           log_size_mb = CAST(SUM(CASE
                                      WHEN type_desc = 'LOG'
                                      THEN size
                                  END)*8./1024 AS   DECIMAL(8, 2)),
           row_size_mb = CAST(SUM(CASE
                                      WHEN type_desc = 'ROWS'
                                      THEN size
                                  END)*8./1024 AS   DECIMAL(8, 2)),
           total_size_mb = CAST(SUM(size) * 8. / 1024 AS DECIMAL(8, 2))
    FROM sys.master_files WITH (NOWAIT)
    --WHERE database_id = DB_ID() -- for current db 
    GROUP BY database_id
) x;