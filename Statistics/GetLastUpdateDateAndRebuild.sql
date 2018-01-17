SELECT name AS Stats,
STATS_DATE(object_id, stats_id) AS LastStatsUpdate
FROM sys.stats
WHERE 
--object_id = OBJECT_ID('Sales.SalesOrderDetail')
--and 
left(name,4)!='_WA_'
order by 2 desc