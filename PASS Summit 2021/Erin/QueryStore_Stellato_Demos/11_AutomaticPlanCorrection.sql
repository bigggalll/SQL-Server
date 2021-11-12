/*============================================================================
  File:     11_AutomaticPlanCorrection.sql

  SQL Server Versions: 2017+, Azure SQL DB
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

USE [master];
GO
RESTORE DATABASE [WideWorldImportersB] 
	FROM  DISK = N'C:\Backups\WWI_Standard.bak' 
		WITH  FILE = 1,  
	MOVE N'WWI_Primary' 
		TO N'C:\Databases\WideWorldImportersLarge\WideWorldImporters.mdf',  
	MOVE N'WWI_UserData' 
		TO N'C:\Databases\WideWorldImportersLarge\WideWorldImporters_UserData.ndf',  
	MOVE N'WWI_Log' 
		TO N'C:\Databases\WideWorldImportersLarge\WideWorldImporters.ldf',  
	NOUNLOAD,  
	REPLACE,  
	STATS = 5;
GO

/*
	Check status of Query Store 
*/
USE [WideWorldImportersB];
GO

SELECT *
FROM [sys].[database_query_store_options];
GO

/*
	Enable Query Store and clear anything that may be in there
*/
ALTER DATABASE [WideWorldImportersB] SET QUERY_STORE = ON;
GO

ALTER DATABASE [WideWorldImportersB] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE, 
	INTERVAL_LENGTH_MINUTES = 10
	);
GO

ALTER DATABASE [WideWorldImportersB] SET QUERY_STORE CLEAR;
GO


/*
	Check status again
*/
USE [WideWorldImportersB];
GO
SELECT *
FROM [sys].[database_query_store_options];
GO



/*
	Check other options
	*output here different than with Azure
*/
SELECT *
FROM [sys].[database_automatic_tuning_mode];
GO

SELECT *
FROM [sys].[database_automatic_tuning_options];
GO


/*
	Now enable Automatic Plan Correction
	https://docs.microsoft.com/en-us/azure/sql-database/sql-database-automatic-tuning-enable
	https://azure.microsoft.com/en-us/blog/automatic-tuning-will-be-a-new-default/
*/
ALTER DATABASE [WideWorldImportersB] 
	SET AUTOMATIC_TUNING (
		FORCE_LAST_GOOD_PLAN = ON
	);
GO


/*
	Check distribution of CustomerIDs
*/
USE [WideWorldImportersB];
GO

SELECT [CustomerID], COUNT([CustomerID])
FROM [WideWorldImportersB].[Sales].[CustomerTransactions]
GROUP BY [CustomerID]
ORDER BY COUNT([CustomerID]) DESC;
GO

/*
	Generate CustomerID list for SP to use
*/	
DROP TABLE IF EXISTS [WideWorldImportersB].[dbo].[CustomerIDs];
GO

SELECT 
	DISTINCT [CustomerID], 
	DENSE_RANK() OVER (ORDER BY [CustomerID]) AS RowNum
INTO [WideWorldImportersB].[dbo].[CustomerIDs]
FROM [WideWorldImportersB].[Sales].[CustomerTransactions];
GO

DELETE FROM [WideWorldImportersB].[dbo].[CustomerIDs]
WHERE [CustomerID] IN (1, 401);
GO

/*
	Create SP
*/
USE [WideWorldImportersB];
GO

DROP PROCEDURE IF EXISTS [Sales].[usp_CustomerTransactionInfo];
GO

CREATE PROCEDURE [Sales].[usp_CustomerTransactionInfo]
	@CustomerID INT
AS	

	SELECT [CustomerID], SUM([AmountExcludingTax])
	FROM [Sales].[CustomerTransactions]
	WHERE [CustomerID] = @CustomerID
	GROUP BY [CustomerID];
GO


/*
	Set up XE session!
	https://blogs.msdn.microsoft.com/sqlserverstorageengine/2017/07/18/monitoring-automatic-tuning-actions-using-xevents/ 
*/
CREATE EVENT SESSION [Track_AutoPlanCorrections] 
	ON SERVER 
	ADD EVENT qds.automatic_tuning_plan_regression_detection_check_completed(
		ACTION(package0.collect_system_time)),
	ADD EVENT qds.automatic_tuning_plan_regression_verification_check_completed(
		ACTION(package0.collect_system_time))
	ADD TARGET package0.event_file(
		SET filename=N'C:\temp\Track_AutoPlanCorrections',max_file_size=(256)
		)
WITH (MAX_MEMORY=16384 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=PER_NODE,TRACK_CAUSALITY=OFF,
	STARTUP_STATE=ON);
GO

ALTER EVENT SESSION [Track_AutoPlanCorrections]
	ON SERVER 
	STATE = START;
GO

/*
	Run external script to create workload
	Check to see what's in QS
*/


/*
	Create regression
	Check to see what's in QS
	What's in DMV?
*/
SELECT *
FROM [sys].[dm_db_tuning_recommendations];
GO

SELECT 
	[FP].[QueryId], 
	[Reason], 
	[Score],
	JSON_VALUE(state, '$.currentValue') [CurrentValue],
	[FP].[RegressedPlanId], 
	[FP].[ForcedPlanID],
	[execute_action_start_time],
	[execute_action_initiated_by],
	[revert_action_start_time],
	[revert_action_initiated_by],
	JSON_VALUE(details, '$.implementationDetails.script') [Script]
FROM [sys].[dm_db_tuning_recommendations]
CROSS APPLY OPENJSON (Details, '$.planForceDetails')
    WITH ( 
		[QueryId] INT '$.queryId',
        [RegressedPlanId] INT '$.regressedPlanId',
        [ForcedPlanID] INT '$.recommendedPlanId'
    ) AS [FP];
GO

/*
	Create recommended index
*/
CREATE NONCLUSTERED INDEX [NCI_SQLskills_CustomerTransactions]
	ON [Sales].[CustomerTransactions] ([CustomerID])
	INCLUDE ([AmountExcludingTax]);
GO

/*
	Check status
*/
SELECT 
	[FP].[QueryId], 
	[Reason], 
	[Score],
	JSON_VALUE(state, '$.currentValue') [CurrentValue],
	[FP].[RegressedPlanId], 
	[FP].[ForcedPlanID],
	[execute_action_start_time],
	[execute_action_initiated_by],
	[revert_action_start_time],
	[revert_action_initiated_by],
	JSON_VALUE(details, '$.implementationDetails.script') [Script]
FROM [sys].[dm_db_tuning_recommendations]
CROSS APPLY OPENJSON (Details, '$.planForceDetails')
    WITH ( 
		[QueryId] INT '$.queryId',
        [RegressedPlanId] INT '$.regressedPlanId',
        [ForcedPlanID] INT '$.recommendedPlanId'
    ) AS [FP];
GO

/*
	Check XE data
*/


/*
	Drop index
*/
DROP INDEX [NCI_SQLskills_CustomerTransactions] 
	ON [Sales].[CustomerTransactions];
GO

/*
	Start initial workload again and check QS
	Then create regression
	What shows up?
*/
SELECT 
	[FP].[QueryId], 
	[Reason], 
	[Score],
	JSON_VALUE(state, '$.currentValue') [CurrentValue],
	[FP].[RegressedPlanId], 
	[FP].[ForcedPlanID],
	[execute_action_start_time],
	[execute_action_initiated_by],
	[revert_action_start_time],
	[revert_action_initiated_by],
	JSON_VALUE(details, '$.implementationDetails.script') [Script]
FROM [sys].[dm_db_tuning_recommendations]
CROSS APPLY OPENJSON (Details, '$.planForceDetails')
    WITH ( 
		[QueryId] INT '$.queryId',
        [RegressedPlanId] INT '$.regressedPlanId',
        [ForcedPlanID] INT '$.recommendedPlanId'
    ) AS [FP];
GO


/*
	Recompile the SP
*/
sp_recompile 'Sales.usp_CustomerTransactionInfo'

/*
	What shows up?
*/
SELECT 
	[FP].[QueryId], 
	[Reason], 
	[Score],
	JSON_VALUE(state, '$.currentValue') [CurrentValue],
	[FP].[RegressedPlanId], 
	[FP].[ForcedPlanID],
	[execute_action_start_time],
	[execute_action_initiated_by],
	[revert_action_start_time],
	[revert_action_initiated_by],
	JSON_VALUE(details, '$.implementationDetails.script') [Script]
FROM [sys].[dm_db_tuning_recommendations]
CROSS APPLY OPENJSON (Details, '$.planForceDetails')
    WITH ( 
		[QueryId] INT '$.queryId',
        [RegressedPlanId] INT '$.regressedPlanId',
        [ForcedPlanID] INT '$.recommendedPlanId'
    ) AS [FP];
GO

/*
	Note: the recompile has to be due to a stats or schema change
	to cause automatic un-forcing
*/


/*
	Update stats job runs...
*/
UPDATE STATISTICS [Sales].[CustomerTransactions];


/*
	Now what do we see?
*/
SELECT 
	[FP].[QueryId], 
	[Reason], 
	[Score],
	JSON_VALUE(state, '$.currentValue') [CurrentValue],
	[FP].[RegressedPlanId], 
	[FP].[ForcedPlanID],
	[execute_action_start_time],
	[execute_action_initiated_by],
	[revert_action_start_time],
	[revert_action_initiated_by],
	JSON_VALUE(details, '$.implementationDetails.script') [Script]
FROM [sys].[dm_db_tuning_recommendations]
CROSS APPLY OPENJSON (Details, '$.planForceDetails')
    WITH ( 
		[QueryId] INT '$.queryId',
        [RegressedPlanId] INT '$.regressedPlanId',
        [ForcedPlanID] INT '$.recommendedPlanId'
    ) AS [FP];
GO



/*
	Clean up
*/
ALTER EVENT SESSION [Track_AutoPlanCorrections]
	ON SERVER 
	STATE = STOP;
GO

DROP EVENT SESSION [Track_AutoPlanCorrections]
	ON SERVER;
GO

