USE AdventureWorks2014
GO
SET NOCOUNT ON
IF OBJECT_ID('Sales.Tmp_SalesOrderDetail') IS NOT NULL
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

-- Implicit column conversion
SET NOCOUNT ON

DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

SELECT *
FROM Sales.Tmp_SalesOrderDetail
WHERE CarrierTrackingNumber = N'4911-403C-98'
print 'Duration with implicit conversion: ' + CAST(DATEDIFF(ms, @StartTime, getdate()) as varchar(10)) + ' ms'

SET @StartTime = GETDATE()

SELECT *
FROM Sales.Tmp_SalesOrderDetail
WHERE CarrierTrackingNumber = '4911-403C-98'
print 'Duration without conversion: ' + CAST(DATEDIFF(ms, @StartTime, getdate()) as varchar(10)) + ' ms'
