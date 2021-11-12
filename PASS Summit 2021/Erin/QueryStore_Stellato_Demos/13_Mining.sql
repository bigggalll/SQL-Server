/*============================================================================
  File:     13_Mining.sql

  SQL Server Versions: 2016+, Azure SQLDB
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2021, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

/*
	Mine the plan cache for missing indexes
	https://www.sqlskills.com/blogs/jonathan/digging-into-the-sql-plan-cache-finding-missing-indexes/
*/
WITH XMLNAMESPACES
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
 
SELECT query_plan,
       n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS sql_text,
       n.value('(//MissingIndexGroup/@Impact)[1]', 'FLOAT') AS impact,
       DB_ID(REPLACE(REPLACE(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)'),'[',''),']','')) AS database_id,
       OBJECT_ID(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' +
           n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' +
           n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)')) AS OBJECT_ID,
       n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' +
           n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' +
           n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)')
       AS object,
       (   SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
           FROM n.nodes('//ColumnGroup') AS t(cg)
           CROSS APPLY cg.nodes('Column') AS r(c)
           WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'EQUALITY'
           FOR  XML PATH('')
       ) AS equality_columns,
        (  SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
           FROM n.nodes('//ColumnGroup') AS t(cg)
           CROSS APPLY cg.nodes('Column') AS r(c)
           WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INEQUALITY'
           FOR  XML PATH('')
       ) AS inequality_columns,
       (   SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
           FROM n.nodes('//ColumnGroup') AS t(cg)
           CROSS APPLY cg.nodes('Column') AS r(c)
           WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INCLUDE'
           FOR  XML PATH('')
       ) AS include_columns
INTO #MissingIndexInfo
FROM
(
   SELECT query_plan
   FROM (
           SELECT DISTINCT plan_handle
           FROM sys.dm_exec_query_stats WITH(NOLOCK)
         ) AS qs
       OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) tp
   WHERE tp.query_plan.exist('//MissingIndex')=1
) AS tab (query_plan)
CROSS APPLY query_plan.nodes('//StmtSimple') AS q(n)
WHERE n.exist('QueryPlan/MissingIndexes') = 1;
 
-- Trim trailing comma from lists
UPDATE #MissingIndexInfo
SET equality_columns = LEFT(equality_columns,LEN(equality_columns)-1),
   inequality_columns = LEFT(inequality_columns,LEN(inequality_columns)-1),
   include_columns = LEFT(include_columns,LEN(include_columns)-1);
 
SELECT *
FROM #MissingIndexInfo;
 
DROP TABLE #MissingIndexInfo;



/*
	Plan is a VARCHAR(MAX) field...how to find the same information?
*/
USE [WideWorldImporters];
GO
SELECT 
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	OBJECT_NAME([qsq].[object_id]) AS [Object],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsp].[query_plan] LIKE '%Missing%';
GO




WITH XMLNAMESPACES
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')

SELECT
	query_plan,    
	n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS sql_text,
	n.value('(//MissingIndexGroup/@Impact)[1]', 'FLOAT') AS impact,
    DB_ID(REPLACE(REPLACE(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)'),'[',''),']','')) AS database_id,
    OBJECT_ID(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' +
        n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' +
        n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)')) AS OBJECT_ID,
    n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' +
        n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' +
        n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)')
    AS object,
	(   SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
        FROM n.nodes('//ColumnGroup') AS t(cg)
        CROSS APPLY cg.nodes('Column') AS r(c)
        WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'EQUALITY'
        FOR  XML PATH('')
    ) AS equality_columns,
    (  SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
        FROM n.nodes('//ColumnGroup') AS t(cg)
        CROSS APPLY cg.nodes('Column') AS r(c)
        WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INEQUALITY'
        FOR  XML PATH('')
    ) AS inequality_columns,
    (   SELECT DISTINCT c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
        FROM n.nodes('//ColumnGroup') AS t(cg)
        CROSS APPLY cg.nodes('Column') AS r(c)
        WHERE cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INCLUDE'
        FOR  XML PATH('')
    ) AS include_columns
FROM (
	SELECT query_plan
	FROM
	(
	  SELECT TRY_CONVERT(XML, [qsp].[query_plan]) AS [query_plan]
	  FROM sys.query_store_plan [qsp]) tp
	  WHERE tp.query_plan.exist('//MissingIndex')=1
	  ) AS tab (query_plan)
CROSS APPLY query_plan.nodes('//StmtSimple') AS q(n)
WHERE n.exist('QueryPlan/MissingIndexes') = 1;


 /*
	Finding plans that use a specific index
	https://www.sqlskills.com/blogs/jonathan/finding-what-queries-in-the-plan-cache-use-a-specific-index/
 */
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE @IndexName AS NVARCHAR(128) = '[IX_Sales_OrderLines_AllocatedStockItems]';

-- Make sure the name passed is appropriately quoted
IF (LEFT(@IndexName, 1) <> '[' AND RIGHT(@IndexName, 1) <> ']') SET @IndexName = QUOTENAME(@IndexName);
--Handle the case where the left or right was quoted manually but not the opposite side
IF LEFT(@IndexName, 1) <> '[' SET @IndexName = '['+@IndexName;
IF RIGHT(@IndexName, 1) <> ']' SET @IndexName = @IndexName + ']';

-- Dig into the plan cache and find all plans using this index
;WITH XMLNAMESPACES
    (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')   
SELECT
stmt.value('(@StatementText)[1]', 'varchar(max)') AS SQL_Text,
obj.value('(@Database)[1]', 'varchar(128)') AS DatabaseName,
obj.value('(@Schema)[1]', 'varchar(128)') AS SchemaName,
obj.value('(@Table)[1]', 'varchar(128)') AS TableName,
obj.value('(@Index)[1]', 'varchar(128)') AS IndexName,
obj.value('(@IndexKind)[1]', 'varchar(128)') AS IndexKind,
cp.plan_handle,
query_plan
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt)
CROSS APPLY stmt.nodes('.//IndexScan/Object[@Index=sql:variable("@IndexName")]') AS idx(obj)
OPTION(MAXDOP 1, RECOMPILE);

	
/*
	Get the same information from the Query Store plan cache
*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE @IndexName AS NVARCHAR(128) = '[IX_Sales_OrderLines_AllocatedStockItems]';

-- Make sure the name passed is appropriately quoted
IF (LEFT(@IndexName, 1) <> '[' AND RIGHT(@IndexName, 1) <> ']') SET @IndexName = QUOTENAME(@IndexName);
--Handle the case where the left or right was quoted manually but not the opposite side
IF LEFT(@IndexName, 1) <> '[' SET @IndexName = '['+@IndexName;
IF RIGHT(@IndexName, 1) <> ']' SET @IndexName = @IndexName + ']';


;WITH XMLNAMESPACES
(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')   
SELECT
	stmt.value('(@StatementText)[1]', 'varchar(max)') AS SQL_Text,
    obj.value('(@Database)[1]', 'varchar(128)') AS DatabaseName,
    obj.value('(@Schema)[1]', 'varchar(128)') AS SchemaName,
    obj.value('(@Table)[1]', 'varchar(128)') AS TableName,
    obj.value('(@Index)[1]', 'varchar(128)') AS IndexName,
    obj.value('(@IndexKind)[1]', 'varchar(128)') AS IndexKind,
	query_plan
FROM 	
(
	SELECT query_plan
	FROM
	(
		SELECT TRY_CONVERT(XML, [qsp].[query_plan]) AS [query_plan]
		FROM sys.query_store_plan [qsp]) tp
		) AS tab (query_plan)
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt)
CROSS APPLY stmt.nodes('.//IndexScan/Object[@Index=sql:variable("@IndexName")]') AS idx(obj)
OPTION(MAXDOP 1, RECOMPILE);


/*
	Determing CTP based on workload
	https://www.sqlskills.com/blogs/jonathan/tuning-cost-threshold-for-parallelism-from-the-plan-cache/
*/
WITH XMLNAMESPACES   
(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')  
SELECT  
     query_plan AS CompleteQueryPlan, 
     n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS StatementText, 
     n.value('(@StatementOptmLevel)[1]', 'VARCHAR(25)') AS StatementOptimizationLevel, 
     n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') AS StatementSubTreeCost, 
     n.query('.') AS ParallelSubTreeXML,  
     ecp.usecounts, 
     ecp.size_in_bytes 
FROM sys.dm_exec_cached_plans AS ecp 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS eqp 
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn(n) 
WHERE  n.query('.').exist('//RelOp[@PhysicalOp="Parallelism"]') = 1 

GO

/*
	Getting CTP information from Query Store
*/
WITH XMLNAMESPACES   
(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')  
SELECT  
     query_plan AS CompleteQueryPlan, 
     n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS StatementText, 
     n.value('(@StatementOptmLevel)[1]', 'VARCHAR(25)') AS StatementOptimizationLevel, 
     n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') AS StatementSubTreeCost, 
     n.query('.') AS ParallelSubTreeXML
FROM 
(
	SELECT query_plan
	FROM
	(
		SELECT TRY_CONVERT(XML, [qsp].[query_plan]) AS [query_plan]
		FROM sys.query_store_plan [qsp]) tp
		) AS tab (query_plan)
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn(n) 
WHERE  n.query('.').exist('//RelOp[@PhysicalOp="Parallelism"]') = 1 


/*
	Finding implicit conversions
	https://www.sqlskills.com/blogs/jonathan/finding-implicit-column-conversions-in-the-plan-cache/
*/
DECLARE @dbname SYSNAME
SET @dbname = QUOTENAME(DB_NAME());

WITH XMLNAMESPACES
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT
   stmt.value('(@StatementText)[1]', 'varchar(max)'),
   t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)'),
   t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)'),
   t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)'),
   ic.DATA_TYPE AS ConvertFrom,
   ic.CHARACTER_MAXIMUM_LENGTH AS ConvertFromLength,
   t.value('(@DataType)[1]', 'varchar(128)') AS ConvertTo,
   t.value('(@Length)[1]', 'int') AS ConvertToLength,
   query_plan
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt)
CROSS APPLY stmt.nodes('.//Convert[@Implicit="1"]') AS n(t)
JOIN INFORMATION_SCHEMA.COLUMNS AS ic
   ON QUOTENAME(ic.TABLE_SCHEMA) = t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)')
   AND QUOTENAME(ic.TABLE_NAME) = t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)')
   AND ic.COLUMN_NAME = t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)')
WHERE t.exist('ScalarOperator/Identifier/ColumnReference[@Database=sql:variable("@dbname")][@Schema!="[sys]"]') = 1


/*
	Implicit Conversions from Query Store plan cache
*/

DECLARE @dbname SYSNAME
SET @dbname = QUOTENAME(DB_NAME());

WITH XMLNAMESPACES
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT
   stmt.value('(@StatementText)[1]', 'varchar(max)'),
   t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)'),
   t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)'),
   t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)'),
   ic.DATA_TYPE AS ConvertFrom,
   ic.CHARACTER_MAXIMUM_LENGTH AS ConvertFromLength,
   t.value('(@DataType)[1]', 'varchar(128)') AS ConvertTo,
   t.value('(@Length)[1]', 'int') AS ConvertToLength,
   query_plan
FROM (
	SELECT query_plan
	FROM
	(
		SELECT TRY_CONVERT(XML, [qsp].[query_plan]) AS [query_plan]
		FROM sys.query_store_plan [qsp]) tp
		) AS tab (query_plan)
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt)
CROSS APPLY stmt.nodes('.//Convert[@Implicit="1"]') AS n(t)
JOIN INFORMATION_SCHEMA.COLUMNS AS ic
   ON QUOTENAME(ic.TABLE_SCHEMA) = t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)')
   AND QUOTENAME(ic.TABLE_NAME) = t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)')
   AND ic.COLUMN_NAME = t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)')
WHERE t.exist('ScalarOperator/Identifier/ColumnReference[@Database=sql:variable("@dbname")][@Schema!="[sys]"]') = 1