SELECT 
	'[' + SCHEMA_NAME(t.schema_id) + '].[' + t.name + ']' AS fulltable_name
	, SCHEMA_NAME(t.schema_id) AS SCHEMA_NAME, t.name AS table_name
	, i.rows
FROM sys.tables AS t 
	INNER JOIN sys.sysindexes AS i 
			ON t.object_id = i.id AND i.indid < 2
ORDER BY table_name