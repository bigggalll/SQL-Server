--Donne les informations à partir du nom de la job dans SQL Agent
SELECT 'EXEC ReportServer.dbo.AddEvent @EventType=''TimedSubscription'', @EventData=''' + CAST(a.SubscriptionID AS VARCHAR(40)) + '''' AS ReportCommand
,b.NAME AS JobName
,e.NAME as ReportName
,a.SubscriptionID
,e.Path
,d.Description
,d.LastStatus
,d.EventType
,d.LastRunTime
,b.date_created
,b.date_modified
FROM ReportServer.dbo.ReportSchedule AS a
INNER JOIN msdb.dbo.sysjobs AS b ON CAST(a.ScheduleID AS SYSNAME) = b.NAME
INNER JOIN ReportServer.dbo.ReportSchedule AS c ON b.NAME = CAST(c.ScheduleID AS SYSNAME)
INNER JOIN ReportServer.dbo.Subscriptions AS d ON c.SubscriptionID = d.SubscriptionID
INNER JOIN ReportServer.dbo.CATALOG AS e ON d.Report_OID = e.ItemID
WHERE b.name = '85ADD67A-1352-4A25-94A5-D4534F862F16'

--Donne les informations à partir du nom du rapport
SELECT 'EXEC ReportServer.dbo.AddEvent @EventType=''TimedSubscription'', @EventData=''' + CAST(a.SubscriptionID AS VARCHAR(40)) + '''' AS ReportCommand
,b.NAME AS JobName
,a.SubscriptionID
,e.NAME as ReportName
,e.Path
,d.Description
,d.LastStatus
,d.EventType
,d.LastRunTime
,b.date_created
,b.date_modified
FROM ReportServer.dbo.ReportSchedule AS a
INNER JOIN msdb.dbo.sysjobs AS b ON CAST(a.ScheduleID AS SYSNAME) = b.NAME
INNER JOIN ReportServer.dbo.ReportSchedule AS c ON b.NAME = CAST(c.ScheduleID AS SYSNAME)
INNER JOIN ReportServer.dbo.Subscriptions AS d ON c.SubscriptionID = d.SubscriptionID
INNER JOIN ReportServer.dbo.CATALOG AS e ON d.Report_OID = e.ItemID
WHERE e.name = 'tbg appro vp01'
