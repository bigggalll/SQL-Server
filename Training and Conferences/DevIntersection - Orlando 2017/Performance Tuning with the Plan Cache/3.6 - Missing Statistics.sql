/*****************************************************************************
*   Presentation: DBA 246 - Performance Tuning with the Plan Cache 
*   FileName:  3.6 - Missing Statistics.sql
*
*   Summary: Demonstrates how to find missing statistics information and the 
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

/*
USE [AdventureWorks2014]
GO

SELECT 'DROP STATISTICS [' + SCHEMA_NAME(o.schema_id) +'].['+ OBJECT_NAME(s.object_id) + '].[' + s.name + '] 
GO'
FROM sys.stats AS s
INNER JOIN sys.objects AS o ON s.object_id = o.object_id
WHERE o.is_ms_shipped = 0
  AND NOT EXISTS (SELECT 1 FROM sys.indexes AS i WHERE i.object_id = s.object_id AND i.name = s.name)

USE [master]
GO
ALTER DATABASE [AdventureWorks2014] SET AUTO_CREATE_STATISTICS OFF
GO

DBCC FREEPROCCACHE
-- Start workload


SELECT P.Weight AS Weight, S.Name AS BikeName  
FROM Production.Product AS P  
    JOIN Production.ProductSubcategory AS S   
    ON P.ProductSubcategoryID = S.ProductSubcategoryID  
WHERE P.ProductSubcategoryID IN (1,2,3) AND P.Weight > 25  
ORDER BY P.Weight;  
GO  


*/



WITH XMLNAMESPACES  
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT st.text, 
	cp.cacheobjtype,
	cp.objtype,
	st.dbid,
	qp.query_plan
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
WHERE  qp.query_plan.exist('//ColumnsWithNoStatistics') = 1
