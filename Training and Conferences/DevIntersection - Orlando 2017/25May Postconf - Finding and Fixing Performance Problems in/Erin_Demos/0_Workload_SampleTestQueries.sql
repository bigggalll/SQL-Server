/*============================================================================
  File:     0_Workload_SampleTestQueries.sql

  SQL Server Versions: 2012, 2014
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

USE [AdventureWorks2016];
GO

SET NOCOUNT ON;

IF EXISTS (
	SELECT * FROM sys.objects WHERE TYPE = 'P' AND [Name] = 'SQLskills_ProductTransactionHistory'
	)
BEGIN
	DROP PROCEDURE dbo.SQLskills_ProductTransactionHistory
END
GO


CREATE PROCEDURE dbo.SQLskills_ProductTransactionHistory @ProductID INT
AS

BEGIN
	SELECT [t].[TransactionID], [t].[TransactionDate], [p].[ProductID], [p].[Name]
	FROM [Production].[TransactionHistory] [t]
	JOIN [Production].[Product] [p] ON [t].ProductID = [p].ProductID
	WHERE [p].[ProductID]= @ProductID
END
GO

DECLARE @ProductID INT;
DECLARE @FirstName NVARCHAR(50);
DECLARE @LastName NVARCHAR(50);
DECLARE @SQLstring NVARCHAR(1000);

WHILE 1=1
BEGIN
	SELECT @ProductID = (SELECT TOP 1 [ProductID] 
	FROM [Production].[Product]
	ORDER BY NEWID())

	SELECT @FirstName = (SELECT TOP 1 [FirstName]
	FROM [Person].[Person]
	ORDER BY NEWID())

	SELECT @LastName = (SELECT TOP 1 [LastName]
	FROM [Person].[Person]
	ORDER BY NEWID()) 

	SET @SQLstring = '
		SELECT [ProductID], [OrderQty]
		FROM [Sales].[SalesOrderDetail]
		WHERE [ProductID] = ' + CAST (@ProductID AS NVARCHAR(5)) +
		'ORDER BY [ProductID];'

	EXEC (@SQLstring)

	SET @SQLstring = 'SELECT [c].[CustomerID], [c].[AccountNumber], [p].[FirstName], [p].[LastName], [a].[AddressLine1], [a].[City] 
		FROM [Person].[Person] [p]
		JOIN [Sales].[Customer] [c] ON [p].[BusinessEntityID] = [c].[PersonID]
		JOIN [Person].[BusinessEntityAddress] [ba] ON [ba].BusinessEntityID = [c].PersonID
		JOIN [Person].[Address] [a] ON [a].AddressID = [ba].AddressID
		WHERE [p].[FirstName] = ''' + @FirstName + ''' AND [p].[LastName] = ''' + @LastName + ''''

	EXEC (@SQLstring)

	EXEC SQLskills_ProductTransactionHistory @ProductID
END
GO

