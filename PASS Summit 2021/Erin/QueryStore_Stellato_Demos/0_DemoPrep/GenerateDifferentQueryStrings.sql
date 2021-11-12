SET NOCOUNT ON;
/*
USE [msdb];
GO

DROP TABLE IF EXISTS [msdb].[dbo].[OrderLinesList];

DROP TABLE IF EXISTS [msdb].[dbo].[InvoiceLinesList];

DROP TABLE IF EXISTS [msdb].[dbo].[PurchaseOrderLinesList];

SELECT 
	DISTINCT [Description], 
	DENSE_RANK() OVER (ORDER BY [Description]) AS RowNum
INTO [msdb].[dbo].[OrderLinesList]
FROM [WideWorldImporters].[Sales].[OrderLines]

SELECT 
	DISTINCT [Description], 
	DENSE_RANK() OVER (ORDER BY [Description]) AS RowNum
INTO [msdb].[dbo].[InvoiceLinesList]
FROM [WideWorldImporters].[Sales].[InvoiceLines]

SELECT 
	DISTINCT [Description], 
	DENSE_RANK() OVER (ORDER BY [Description]) AS RowNum
INTO [msdb].[dbo].[PurchaseOrderLinesList]
FROM [WideWorldImporters].[Purchasing].[PurchaseOrderLines]

select * from [msdb].[dbo].[OrderLinesList]
select max(rownum) from [msdb].[dbo].[OrderLinesList]

select * from [msdb].[dbo].[InvoiceLinesList]
select max(rownum) from [msdb].[dbo].[InvoiceLinesList]

select * from [msdb].[dbo].[PurchaseOrderLinesList]
select max(rownum) from [msdb].[dbo].[PurchaseOrderLinesList]


*/

USE [WideWorldImporters];

DECLARE @RowNum INT = 1;
DECLARE @Description NVARCHAR(100);
DECLARE @RandomDescription NVARCHAR(8);
DECLARE @SQLstring NVARCHAR(MAX);


WHILE 1=1
BEGIN

	SELECT @RandomDescription = (
		SELECT LEFT(NEWID(), 8))


	SELECT @Description = (
		SELECT [Description] 
		FROM [msdb].[dbo].[OrderLinesList]
		WHERE RowNum = @RowNum)

	IF CHARINDEX('''',@Description) > 0
	BEGIN
		SET @Description = REPLACE(@Description, '''', '''''')
	END

	SET @SQLstring = '
	SELECT [ol].[StockItemID], [ol].[Description], [ol].[UnitPrice],
		[o].[CustomerID], [o].[SalespersonPersonID]
	FROM [Sales].[OrderLines] [ol]
	JOIN [Sales].[Orders] [o]
		ON [ol].[OrderID] = [o].[OrderID]
	WHERE [ol].[Description] = ''' + @Description + ''''

	EXEC (@SQLstring)

	SET @SQLstring = '
	SELECT [ol].[StockItemID], [ol].[Description], [ol].[UnitPrice],
		[o].[CustomerID], [o].[SalespersonPersonID]
	FROM [Sales].[OrderLines] [ol]
	JOIN [Sales].[Orders] [o]
		ON [ol].[OrderID] = [o].[OrderID]
	WHERE [ol].[Description] = ''' + @RandomDescription + ''''

	EXEC (@SQLstring)


	SELECT @Description = (
	SELECT [Description] 
	FROM [msdb].[dbo].[InvoiceLinesList]
	WHERE RowNum = @RowNum)

	IF CHARINDEX('''',@Description) > 0
	BEGIN
		SET @Description = REPlACE(@Description, '''', '''''')
	END

	SET @SQLstring = '
		SELECT [il].[InvoiceLineID], [il].[Description], [il].[UnitPrice],
			[i].[CustomerID], [i].[SalespersonPersonID]
		FROM [Sales].[InvoiceLines] [il]
		JOIN [Sales].[Invoices] [i]
			ON [il].[InvoiceID] = [i].[InvoiceID]
		WHERE [il].[Description] = ''' + @Description + ''''

	EXEC (@SQLstring)

	SET @SQLstring = '
		SELECT [il].[InvoiceLineID], [il].[Description], [il].[UnitPrice],
			[i].[CustomerID], [i].[SalespersonPersonID]
		FROM [Sales].[InvoiceLines] [il]
		JOIN [Sales].[Invoices] [i]
			ON [il].[InvoiceID] = [i].[InvoiceID]
		WHERE [il].[Description] = ''' + @RandomDescription + ''''

	EXEC (@SQLstring)


	SELECT @Description = (
	SELECT [Description] 
	FROM [msdb].[dbo].[PurchaseOrderLinesList]
	WHERE RowNum = @RowNum)

	IF CHARINDEX('''',@Description) > 0
	BEGIN
		SET @Description = REPlACE(@Description, '''', '''''')
	END

	SET @SQLstring = '
		SELECT [pl].[PurchaseOrderLineID], [pl].[Description], [pl].[LastEditedWhen],
			[p].[OrderDate], [p].[ExpectedDeliveryDate]
		FROM [Purchasing].[PurchaseOrderLines] [pl]
		JOIN [Purchasing].[PurchaseOrders] [p]
			ON [pl].[PurchaseOrderID] = [p].[PurchaseOrderID]
		WHERE [pl].[Description] = ''' + @Description + ''''

	EXEC (@SQLstring)

	SET @SQLstring = '
		SELECT [pl].[PurchaseOrderLineID], [pl].[Description], [pl].[LastEditedWhen],
			[p].[OrderDate], [p].[ExpectedDeliveryDate]
		FROM [Purchasing].[PurchaseOrderLines] [pl]
		JOIN [Purchasing].[PurchaseOrders] [p]
			ON [pl].[PurchaseOrderID] = [p].[PurchaseOrderID]
		WHERE [pl].[Description] = ''' + @RandomDescription + ''''

	EXEC (@SQLstring)

	IF @RowNum < 228
	BEGIN
		SET @RowNum = @RowNum + 1
	END
	ELSE
	BEGIN
		SET @RowNum = 1
	END
END
GO
