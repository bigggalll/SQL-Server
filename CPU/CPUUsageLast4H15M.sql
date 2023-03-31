
-- utiliser cette version lorsque le # de cores est élevé (ax)
DECLARE @ts_now BIGINT = (
    SELECT
        cpu_ticks / ( cpu_ticks / ms_ticks )
    FROM
        sys.dm_os_sys_info
);
with processor_Info_cte as (
	select (cpu_count / hyperthread_ratio) as number_of_physical_cpus
	from sys.dm_os_sys_info
	),
	utilization_cte as (
		select top 1000 record_id
			,sql_process_utilization
			,system_idle
			,100 - system_idle - sql_process_utilization as other_process_utilization
			,[timestamp]
		from (
			select [timestamp],record.value('(./Record/@id)[1]', 'int') as record_id,
				record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') as system_idle,
							record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') as sql_process_utilization
			from (
				select convert(XML, record) as record,
				[timestamp]
				from sys.dm_os_ring_buffers
				where ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
						and record like '%<SystemHealth>%'
				) as x
		) as y order by record_id desc
	)

	select (case when other_process_utilization < 0 
			then
				sql_process_utilization/a.number_of_physical_cpus 
			else
				sql_process_utilization end) as sql_process_utilization
		,system_idle/1.0 system_idle
		,(case when other_process_utilization < 0 
			then
				100 - sql_process_utilization/a.number_of_physical_cpus -system_idle
			else
				other_process_utilization end) as other_process_utilization
		,DATEADD(ms, -1 * ( @ts_now - [timestamp] )
		,GETDATE()) AS [Event Time]
	from utilization_cte cross apply (
	select (number_of_physical_cpus*1.0) as number_of_physical_cpus from processor_Info_cte) as a





-- vielle version
DECLARE @ts_now BIGINT

SELECT @ts_now = ms_ticks
FROM sys.dm_os_sys_info

SELECT record_id
	,dateadd(ms, (y.[timestamp] - @ts_now), GETDATE()) AS EventTime
	,SQLProcessUtilization
	,SystemIdle
	,100 - SystemIdle - SQLProcessUtilization AS OtherProcessUtilization
FROM (
	SELECT record.value('(./Record/@id)[1]', 'int') AS record_id
		,record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle
		,record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS SQLProcessUtilization
		,TIMESTAMP
	FROM (
		SELECT TIMESTAMP
			,convert(XML, record) AS record
		FROM sys.dm_os_ring_buffers
		WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
			AND record LIKE '%<SystemHealth>%'
		) AS x
	) AS y
ORDER BY record_id DESC

