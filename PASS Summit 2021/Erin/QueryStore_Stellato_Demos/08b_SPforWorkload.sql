/*============================================================================
  File:     08b_SPforWorkload.sql

  SQL Server Versions: 2016, 2017, 2019
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

DROP PROCEDURE IF EXISTS [SPRandomSelects];  
GO

CREATE PROCEDURE [SPRandomSelects]
	@NumRows INT
AS

DECLARE @Val1 INT;
DECLARE @Val2 INT;
DECLARE @Val3 INT;
DECLARE @Val4 INT;
DECLARE @ConcatString NVARCHAR(200);
DECLARE @QueryString NVARCHAR(1000);
DECLARE @RowLoop INT = 1;



	SET @ConcatString = '1089'

	SELECT TOP 1 o.SalesPersonPersonID, o.OrderDate, ol.StockItemID
	FROM Sales.Orders o WITH (INDEX(FK_Sales_Orders_CustomerID))
	JOIN Sales.OrderLines ol
	ON o.OrderID = ol.OrderID
	WHERE o.CustomerID = @ConcatString

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
		
		SELECT w.ColorID, s.StockItemName
		FROM Warehouse.Colors w
		JOIN Warehouse.StockItems s
			ON w.ColorID = s.ColorID
		WHERE w.ColorName = @ConcatString 
		
		SET @ConcatString = SUBSTRING(@ConcatString,1, 5)

		SELECT TOP 1 o.SalesPersonPersonID, o.OrderDate, ol.StockItemID
		FROM Sales.Orders o WITH (INDEX(FK_Sales_Orders_CustomerID))
		JOIN Sales.OrderLines ol
			ON o.OrderID = ol.OrderID
		WHERE o.CustomerID = @ConcatString 

		SELECT @RowLoop = @RowLoop + 1
	END
GO


