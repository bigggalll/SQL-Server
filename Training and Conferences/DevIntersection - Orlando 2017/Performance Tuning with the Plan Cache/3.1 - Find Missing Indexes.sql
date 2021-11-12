/*****************************************************************************
*   Presentation: DBA 246 - Performance Tuning with the Plan Cache 
*   FileName:  3.1 - Find Missing Indexes.sql
*
*   Summary: Demonstrates how to find missing index information and the 
*			 statements that generated it by parsing XML Plans stored in the 
*			 plan cache.
*
*   Date: October 16, 2010 
*
*   SQL Server Versions:
*         2005, 2008, 2008 R2
*         
******************************************************************************
*   Copyright (C) 2010 Jonathan M. Kehayias
*   All rights reserved. 
*
*   For more scripts and sample code, check out 
*      http://sqlblog.com/blogs/jonathan_kehayias
*
*   You may alter this code for your own *non-commercial* purposes. You may
*   republish altered code as long as you include this copyright and give 
*	due credit. 
*
*
*   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
*   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
*   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
*   PARTICULAR PURPOSE. 
*
******************************************************************************/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE [AdventureWorks2014]
GO

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
       AS statement, 
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
WHERE n.exist('QueryPlan/MissingIndexes') = 1 
OPTION(MAXDOP 1, RECOMPILE)

-- Trim trailing comma from lists 
UPDATE #MissingIndexInfo 
SET equality_columns = LEFT(equality_columns,LEN(equality_columns)-1), 
   inequality_columns = LEFT(inequality_columns,LEN(inequality_columns)-1), 
   include_columns = LEFT(include_columns,LEN(include_columns)-1) 
    
SELECT * 
FROM #MissingIndexInfo 

DROP TABLE #MissingIndexInfo 