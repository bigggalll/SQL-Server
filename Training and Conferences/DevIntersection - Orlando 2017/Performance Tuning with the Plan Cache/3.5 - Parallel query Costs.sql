/*****************************************************************************
*   Presentation: DBA 246 - Performance Tuning with the Plan Cache 
*   FileName:  3.5 - Parallel Query Costs.sql
*
*   Summary: Demonstrates how to find the cost estimates for queries using 
*			 parallelism by parsing XML Plans stored in the plan cache.
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

