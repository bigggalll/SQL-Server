USE AdventureWorks2014
GO
SET NOCOUNT ON

CREATE TABLE #scrappedItems 
(ProductNumber varchar(10), 
 OverDue int)

DECLARE @ProductID int, @DueDate datetime, @ModDate datetime
DECLARE @StartTime DATETIME

DECLARE curQuantity CURSOR FOR

SELECT ProductID, ModifiedDate, DueDate 
FROM Production.WorkOrder
ORDER BY ModifiedDate

SET @StartTime = GETDATE()

OPEN curQuantity
FETCH NEXT FROM curQuantity INTO @ProductID, @DueDate, @ModDate

WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #scrappedItems (ProductNumber, OverDue)
		SELECT ProductNumber, datediff(dd,@dueDate, @ModDate)
		FROM Production.Product where ProductID = @ProductID

		FETCH NEXT FROM curQuantity into @ProductID, @DueDate, @ModDate
	END
CLOSE curQuantity
DEALLOCATE curQuantity

print 'Duration with cursor: ' + CAST(DATEDIFF(ms, @StartTime, getdate()) as varchar(10)) + ' ms'

SELECT count(*) from #scrappedItems

TRUNCATE TABLE #scrappedItems

-- fast

SET @StartTime = GETDATE()

INSERT INTO #scrappedItems (ProductNumber, OverDue)
SELECT ProductNumber, datediff(dd,DueDate, wo.ModifiedDate)
FROM Production.Product p 
JOIN Production.WorkOrder wo on p.ProductID = wo.ProductID

PRINT 'Duration without cursor: ' + CAST(DATEDIFF(ms, @StartTime, getdate()) as varchar(10)) + ' ms'

SELECT count(*) from #scrappedItems

DROP TABLE #scrappedItems

