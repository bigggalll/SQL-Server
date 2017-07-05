SELECT st.*,
       qp.query_plan,
       qt.text
FROM sys.dm_exec_query_stats st
     CROSS APPLY sys.dm_exec_sql_text(sql_handle) qt CROSS APPLY sys.dm_exec_query_plan(plan_handle) qp
WHERE qp.query_plan.exist('declare namespace 
qplan="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
            //qplan:RelOp[@LogicalOp="Index Scan"
            or @LogicalOp="Clustered Index Scan"
            or @LogicalOp="Table Scan"]') = 1
AND execution_count > 1000
AND max_elapsed_time - min_elapsed_time > 1000;