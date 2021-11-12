/*============================================================================
  File:     2_Pageiolatch.sql

  Summary:  Generate some IO against a database on an external, slow drive

  SQL Server Versions: 2008 onwards
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com

  (c) 2017, SQLskills.com. All rights reserved.

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
	Clear waits
	DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR);
*/

WHILE 1=1
BEGIN

USE [AdventureWorks2012E];

DECLARE @SalesOrderID INT, @AccountNumber NVARCHAR(30), @TotalFreight MONEY, 
    @DistinctItemTotal INT, @TotalItemCount INT
	-- Create a significant I/O and tempdb query
	SELECT 
    @SalesOrderID = sod.SalesOrderID, 
    @AccountNumber = o.AccountNumber, 
    @TotalFreight = SUM(o.Freight),
    @DistinctItemTotal = COUNT(DISTINCT sod.ProductID),
	@TotalItemCount = SUM(OrderQty)
FROM Sales.SalesOrderHeader AS o
JOIN Sales.SalesOrderDetail AS sod
ON o.SalesOrderID = sod.SalesOrderID
WHERE o.OrderDate BETWEEN '01/01/2007' AND '01/01/2010'
GROUP BY sod.SalesOrderID, o.AccountNumber OPTION(MAXDOP 4)

DBCC DROPCLEANBUFFERS

END

