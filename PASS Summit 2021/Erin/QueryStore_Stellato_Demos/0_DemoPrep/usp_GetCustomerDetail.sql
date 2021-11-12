USE [WideWorldImporters];
GO
p
DECLARE @CustomerID INT = 801
DECLARE @CustomerName NVARCHAR(100)

WHILE 1=1
BEGIN

	SELECT @CustomerName = SUBSTRING([CustomerName], 1, 10) + '%'
	FROM [Sales].[Customers]
	WHERE [CustomerID] = @CustomerID;

	EXEC [Sales].[usp_GetCustomerDetail] @CustomerName;

	IF @CustomerID < 1092
	BEGIN
		SET @CustomerID = @CustomerID + 1
	END
	ELSE
	BEGIN
		SET @CustomerID = 801
	END

END