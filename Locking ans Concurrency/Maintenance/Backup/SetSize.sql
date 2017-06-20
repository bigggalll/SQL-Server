SELECT database_name,
       backup_start_date,
       backup_size
FROM msdb.dbo.backupset b
WHERE type = 'L'
      --AND database_name = DB_NAME()
ORDER BY 2 DESC;