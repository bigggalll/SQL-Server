DECLARE @FileName VARCHAR(255)

SELECT @FileName = SUBSTRING(path, 0, LEN(path) - CHARINDEX('\', REVERSE(path)) + 1) + '\Log.trc'
FROM sys.traces
WHERE is_default = 1;

DECLARE @starttime DATETIME = getdate() - 7

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
FROM [fn_trace_gettable](@FileName, DEFAULT) gt
JOIN master.sys.trace_events te ON gt.EventClass = te.trace_event_id
WHERE EventClass IN (
		92 --Data File Auto Grow
		,93 -- Log File Auto Grow
		,94 -- Data File Auto Shrink
		,95 -- Log File Auto Shrink
		)
	AND -- AutoGrow
	gt.StartTime >= @starttime
--and gt.LoginName not in ('NT AUTHORITY\NETWORK SERVICE') 
--AND gt.DatabaseName = 'tempdb'
ORDER BY StartTime DESC;
