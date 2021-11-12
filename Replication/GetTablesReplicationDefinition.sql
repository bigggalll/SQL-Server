SELECT tables.name AS TabRepli,
       columns.name AS ColName
FROM sysarticles
     INNER JOIN sys.tables ON sysarticles.objid = tables.object_id
     INNER JOIN sysarticlecolumns ON sysarticlecolumns.artid = sysarticles.artid
     INNER JOIN sys.columns ON sysarticlecolumns.colid = columns.column_id
                               AND columns.object_id = tables.object_id
WHERE sysarticles.artid = 79;

