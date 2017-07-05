SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
DBCC TRACEON (8666);
GO
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' as p)
SELECT qt.text AS SQLCommand,
qp.query_plan,
StatsUsed.XMLCol.value('@FieldValue','NVarChar(500)') AS StatsName
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
CROSS APPLY sys.dm_exec_sql_text (cp.plan_handle) qt
CROSS APPLY query_plan.nodes('//p:Field[@FieldName="wszStatName"]') StatsUsed(XMLCol)
--WHERE qt.text LIKE '%UPDATE%'
--AND qt.text LIKE '%ProductID%';
GO
DBCC TRACEOFF(8666);
GO
