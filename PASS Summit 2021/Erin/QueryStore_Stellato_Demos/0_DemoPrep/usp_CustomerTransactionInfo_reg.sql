DBCC FREEPROCCACHE;
GO
USE [WideWorldImporters];
GO
EXEC [Sales].[usp_CustomerTransactionInfo] 401;
GO
