-- This gives a breakdown of how much data is stored in the SQL Monitor Data Repository. This is useful info when
--	   - Data is missing due to a large number of data insertion timeouts
--     - The UI is unresponsive
--     - There's high disk usage, disk IO or memory for the SQL Monitor Base Monitor
--     - many other cases too.
IF OBJECT_ID('tempdb..#Data') IS NOT NULL
	DROP TABLE #Data;

CREATE TABLE #Data (
	tableName VARCHAR(100)
	,numberofRows VARCHAR(100)
	,reservedSize VARCHAR(50)
	,dataSize VARCHAR(50)
	,indexSize VARCHAR(50)
	,unusedSize VARCHAR(50)
	)

INSERT #Data
EXEC sp_msforeachtable 'sp_spaceused ''?'''

SELECT s.NAME
	,d.tableName
	,CAST(d.numberofRows AS BIGINT) [numberofRows]
	,CAST(SUBSTRING(d.reservedSize, 0, LEN(d.reservedSize) - 2) AS BIGINT) [reservedSize (KB)]
	,CAST(SUBSTRING(d.dataSize, 0, LEN(d.dataSize) - 2) AS BIGINT) [dataSize (KB)]
	,CAST(SUBSTRING(d.indexSize, 0, LEN(d.indexSize) - 2) AS BIGINT) [indexSize (KB)]
	,CAST(SUBSTRING(d.unusedSize, 0, LEN(d.unusedSize) - 2) AS BIGINT) [unusedSize (KB)]
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN #Data d ON t.NAME = d.tableName
