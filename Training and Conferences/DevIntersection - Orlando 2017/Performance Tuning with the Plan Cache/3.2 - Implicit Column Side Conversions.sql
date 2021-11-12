/*****************************************************************************
*   Presentation: DBA 246 - Performance Tuning with the Plan Cache 
*   FileName:  3.2 - Implicit Column Side Conversions.sql
*
*   Summary: Demonstrates how to find column side implicit conversions and the 
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

DROP TABLE Sales.Tmp_SalesOrderDetail
GO
CREATE TABLE Sales.Tmp_SalesOrderDetail
	(
	SalesOrderID int NOT NULL,
	SalesOrderDetailID int NOT NULL IDENTITY (1, 1),
	CarrierTrackingNumber varchar(25) NULL,
	OrderQty smallint NOT NULL,
	ProductID int NOT NULL,
	SpecialOfferID int NOT NULL,
	UnitPrice money NOT NULL,
	UnitPriceDiscount money NOT NULL,
	LineTotal  AS (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))),
	rowguid uniqueidentifier NOT NULL ROWGUIDCOL,
	ModifiedDate datetime NOT NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT Sales.Tmp_SalesOrderDetail ON
GO
IF EXISTS(SELECT * FROM Sales.SalesOrderDetail)
	 EXEC('INSERT INTO Sales.Tmp_SalesOrderDetail (SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate)
		SELECT SalesOrderID, SalesOrderDetailID, CONVERT(varchar(25), CarrierTrackingNumber), OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate FROM Sales.SalesOrderDetail WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT Sales.Tmp_SalesOrderDetail OFF
GO
ALTER TABLE Sales.Tmp_SalesOrderDetail ADD CONSTRAINT
	PK_Tmp_SalesOrderDetail_SalesOrderID_SalesOrderDetailID PRIMARY KEY CLUSTERED 
	(
	SalesOrderID,
	SalesOrderDetailID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX AK_Tmp_SalesOrderDetail_rowguid ON Sales.Tmp_SalesOrderDetail
	(
	rowguid
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX IX_Tmp_SalesOrderDetail_ProductID ON Sales.Tmp_SalesOrderDetail
	(
	ProductID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SELECT *
FROM Sales.Tmp_SalesOrderDetail
WHERE CarrierTrackingNumber = N'4911-403C-98'
GO

SELECT NationalIDNumber, HireDate, MaritalStatus
FROM HumanResources.Employee
WHERE NationalIDNumber = 14417807

*/

USE [AdventureWorks2014]
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

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
