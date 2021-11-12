DECLARE @filename VARCHAR(255)

SELECT @FileName = SUBSTRING(path, 0, LEN(path) - CHARINDEX('\', REVERSE(path)) + 1) + '\Log.trc'
FROM sys.traces
WHERE is_default = 1;

DECLARE @starttime DATETIME = getdate() - 7

SET @starttime = '2016-06-15 10:00:00.000'

SELECT gt.HostName
	,gt.ApplicationName
	,gt.NTUserName
	,gt.NTDomainName
	,gt.LoginName
	,gt.SPID
	,gt.EventClass
	,te.NAME
	,gt.EventSubClass
	,gt.TEXTData
	,gt.StartTime
	,gt.ObjectName
	,gt.DatabaseName
	,gt.TargetLoginName
	,gt.TargetUserName
FROM [fn_trace_gettable](@filename, DEFAULT) gt
JOIN master.sys.trace_events te ON gt.EventClass = te.trace_event_id
WHERE --EventClass in (164, 46,47,108, 110, 152) and 
	--EventClass in (92, 93, 94, 95, 96, 97) and -- AutoGrow
	gt.StartTime >= @starttime
	AND gt.LoginName NOT IN ('NT AUTHORITY\NETWORK SERVICE')
	--AND OBJECTNAME = 'ECORESCATEGORY'
--and gt.DatabaseName='tempdb' 
ORDER BY StartTime ASC;
