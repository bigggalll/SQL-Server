SELECT 
	g.group_id, 
	GroupName = g.name,
	ConnectedSessions = COALESCE(s.SessionCount, 0),
	ActiveRequests = g.active_request_count
FROM
	sys.dm_resource_governor_workload_groups AS g
LEFT OUTER JOIN
(
	SELECT group_id, SessionCount = COUNT(*)
	FROM sys.dm_exec_sessions
	GROUP BY group_id
) AS s
ON
	g.group_id = s.group_id;
