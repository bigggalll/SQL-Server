-- Here's the dropbox link to the backup of this database
https://www.dropbox.com/sh/wbvcjsdnbj7hcw6/AAB6LRvEyghxn9qZv0zDI0gPa?dl=0

USE AdventureWorksDW2008_ModifiedSalesKey
go

-- Some clean up to get the DB to the same state I use in class
DROP INDEX factinternetsales.[ShipDateOrderDateInd];
DROP INDEX factinternetsales.[ShipDateOrderDateInd_SeekableForMin];
GO

-- An additional table I use in only a couple of demos... this might
-- take a TREMENDOUS amount of time. BEWARE!

--DROP TABLE factinternetsales2
SELECT [ProductKey]
      ,[OrderDateKey]
      ,[DueDateKey]
      ,[ShipDateKey]
      ,[CustomerKey]
      ,[PromotionKey]
      ,[CurrencyKey]
      ,[SalesTerritoryKey]
      , CONVERT (nvarchar(20), 
			'SO' + convert(nvarchar, [SalesOrderNumber])) 
				AS [SalesOrderNumber]
      ,[SalesOrderLineNumber]
	  ,[RevisionNumber]
      ,[OrderQuantity]
      ,[UnitPrice]
      ,[ExtendedAmount]
      ,[UnitPriceDiscountPct]
      ,[DiscountAmount]
      ,[ProductStandardCost]
      ,[TotalProductCost]
      ,[SalesAmount]
      ,[TaxAmt]
      ,[Freight]
      ,[CarrierTrackingNumber]
      ,[CustomerPONumber]
INTO [dbo].[FactInternetSales2]
FROM [dbo].[FactInternetSales];
GO  -- 23 secs

-- Modify the newly created table to make it 
-- non-nullable (required for a PK)
ALTER TABLE [dbo].[FactInternetSales2]
ALTER COLUMN [SalesOrderNumber] 
	nvarchar(20) NOT NULL;
GO  -- 1:51

-- Create the clustered index
ALTER TABLE [dbo].[FactInternetSales2]
ADD CONSTRAINT [FactInternetSales2_PK] 
	PRIMARY KEY CLUSTERED 
		( [SalesOrderNumber] ASC,
		  [SalesOrderLineNumber] ASC );
GO  -- 10 secs

-- Create the (7) nonclustered indexes
CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_CurrencyKey] 
ON [dbo].[FactInternetSales2] ([CurrencyKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_CustomerKey] 
ON [dbo].[FactInternetSales2] ([CustomerKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_DueDateKey] 
ON [dbo].[FactInternetSales2] ([DueDateKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_OrderDateKey] 
ON [dbo].[FactInternetSales2] ([OrderDateKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_ProductKey] 
ON [dbo].[FactInternetSales2] ([ProductKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_PromotionKey] 
ON [dbo].[FactInternetSales2] ([PromotionKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_ShipDateKey] 
ON [dbo].[FactInternetSales2] ([ShipDateKey]); 
GO  -- 1:41

exec sp_sqlskills_helpindex factinternetsales;
exec sp_sqlskills_helpindex factinternetsales2;
GO