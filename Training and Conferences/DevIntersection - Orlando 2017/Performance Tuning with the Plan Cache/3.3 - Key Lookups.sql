/*****************************************************************************
*   Presentation: DBA 246 - Performance Tuning with the Plan Cache 
*   FileName:  3.3 - Key Lookups.sql
*
*   Summary: Demonstrates how to find key lookup information and the 
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

/*

-- This demo requires that the appropriate problem be available for it to work.
-- If you run this demo and it returns no results, the following code will 
-- create an example of the problem.


USE [AdventureWorks2014]
GO

SELECT NationalIDNumber, HireDate, MaritalStatus
FROM HumanResources.Employee
WHERE NationalIDNumber = 14417807
GO

SELECT NationalIDNumber, HireDate, MaritalStatus
FROM HumanResources.Employee
WHERE NationalIDNumber = '14417807'
*/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE [AdventureWorks2014]
GO

WITH XMLNAMESPACES  
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
    
SELECT 
	n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS sql_text,
	n.query('.'),
	i.value('(@PhysicalOp)[1]', 'VARCHAR(128)') AS PhysicalOp,
	i.value('(./IndexScan/Object/@Database)[1]', 'VARCHAR(128)') AS DatabaseName,
	i.value('(./IndexScan/Object/@Schema)[1]', 'VARCHAR(128)') AS SchemaName,
	i.value('(./IndexScan/Object/@Table)[1]', 'VARCHAR(128)') AS TableName,
	i.value('(./IndexScan/Object/@Index)[1]', 'VARCHAR(128)') as IndexName,
	i.query('.'),
	(SELECT DISTINCT cg.value('(@Column)[1]', 'VARCHAR(128)') + ', ' 
	   FROM i.nodes('./OutputList/ColumnReference') AS t(cg) 
	   FOR  XML PATH('')) AS output_columns,
	(SELECT DISTINCT cg.value('(@Column)[1]', 'VARCHAR(128)') + ', ' 
	   FROM i.nodes('./IndexScan/SeekPredicates/SeekPredicate//ColumnReference') AS t(cg) 
	   FOR  XML PATH('')) AS seek_columns,
	i.value('(./IndexScan/Predicate/ScalarOperator/@ScalarString)[1]', 'VARCHAR(4000)') as Predicate          
FROM (	SELECT query_plan 
		FROM (  SELECT DISTINCT plan_handle 
				FROM sys.dm_exec_query_stats WITH(NOLOCK)) AS qs 
		OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) tp
	  ) as tab (query_plan)
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/*') AS q(n) 
CROSS APPLY n.nodes('.//RelOp[IndexScan[@Lookup="1"] and IndexScan/Object[@Schema!="[sys]"]]') as s(i)



