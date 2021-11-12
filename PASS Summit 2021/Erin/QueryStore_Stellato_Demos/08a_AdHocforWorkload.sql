/*============================================================================
  File:     08a_AdHocforWorkload.sql

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

USE [WideWorldImporters];
GO

DROP PROCEDURE IF EXISTS [RandomSelects];  
GO

CREATE PROCEDURE [RandomSelects]
	@NumRows INT
AS

DECLARE @Val1 INT;
DECLARE @Val2 INT;
DECLARE @Val3 INT;
DECLARE @Val4 INT;
DECLARE @ConcatString NVARCHAR(200);
DECLARE @QueryString NVARCHAR(1000);
DECLARE @RowLoop INT = 1;

WHILE (@RowLoop < @NumRows)
	BEGIN

		SET @Val1 = CONVERT (INT, RAND () * 1000) + 1;
		SET @Val2 = CONVERT (INT, RAND () * 100) + 1;
		SET @Val3 = CONVERT (INT, RAND () * 850) + 1
		SET @Val4 = CONVERT (INT, RAND () * 2300) + 1

		SET @ConcatString = CAST(@Val1 AS NVARCHAR(50))
							+ CAST(@Val2 AS NVARCHAR(50))
							+ CAST(@Val3 AS NVARCHAR(50))
							+ CAST(@Val4 AS NVARCHAR(50))
		
		SELECT @QueryString = N'SELECT w.ColorID, s.StockItemName
								FROM Warehouse.Colors w
								JOIN Warehouse.StockItems s
									ON w.ColorID = s.ColorID
								WHERE w.ColorName = ''' + @ConcatString + ''''
		
		EXEC (@QueryString)

		SELECT @QueryString = N'SELECT TOP 1 o.SalesPersonPersonID, o.OrderDate, ol.StockItemID
								FROM Sales.Orders o
								JOIN Sales.OrderLines ol
									ON o.OrderID = ol.OrderID
								WHERE o.CustomerID = ' + SUBSTRING(@ConcatString,1, 5) + ''

		EXEC (@QueryString)

		SELECT @RowLoop = @RowLoop + 1
	END
GO


