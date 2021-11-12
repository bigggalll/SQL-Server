SELECT qp.query_plan,
       qt.text,
       st.*
FROM sys.dm_exec_query_stats st
     CROSS APPLY sys.dm_exec_sql_text(sql_handle) qt 
	 CROSS APPLY sys.dm_exec_query_plan(plan_handle) qp
where qt.text like '%update IdealiV2_Export set%'
--order by last_execution_time;

ALTER INDEX [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID] ON [Sales].[SalesOrderDetail] REBUILD WITH (MAXDOP=2, online=on)

SELECT usecounts, cacheobjtype, objtype, text   
FROM sys.dm_exec_cached_plans   
CROSS APPLY sys.dm_exec_sql_text(plan_handle) qt
where qt.text like '%rebuild%'


--DBCC FREEPROCCACHE
go
SELECT * FROM sys.dm_exec_cached_plans   CROSS APPLY sys.dm_exec_sql_text(plan_handle)
