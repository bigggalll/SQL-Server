;with ResGroupCpu as
(
	select
		instance_name as group_name,
		counter_name,
		cntr_value
	from sys.dm_os_performance_counters
	where object_name like '%Workload Group Stats%'
	and counter_name like 'CPU usage *% %' escape '*'
)
,resource_groups as
(
	select
		rgrp.name as pool_name,
		rgrp.pool_id as pool_id,
		rgwg.group_id,
		rgwg.name as group_name,
		rgwg.queued_request_count,
		rgwg.active_parallel_thread_count,
		a.scheduler_mask
	from sys.dm_resource_governor_resource_pools rgrp
	inner join sys.dm_resource_governor_workload_groups rgwg
		on rgrp.pool_id = rgwg.pool_id
	left outer join sys.dm_resource_governor_resource_pool_affinity  a
		on rgrp.pool_id = a.pool_id
	--where rgrp.name <> 'internal'
)
select 
	resource_groups.pool_name,
	resource_groups.pool_id,
	resource_groups.group_name,
	--case resource_groups.group_name 
	--	when 'BAOS_group' then 'Batch' 
	--	when 'EPAOS_group' then 'Batch' 
	--	when 'RAOS_group' then 'OLTP'
	--	when 'CAOS_group' then 'OLTP'
	--	else 'Autre'
	--	end as famille,
	rp_sessions.sessions_count,
	rp_requests.requests_count,
	rp_requests.coeur_count,
	cpu.cpu_usage,
	resource_groups.queued_request_count,
	resource_groups.active_parallel_thread_count,
	resource_groups.scheduler_mask
from resource_groups 
inner join
(
	select
		rp.group_id,
		count(s.session_id) as sessions_count
	from resource_groups rp
	left join sys.dm_exec_sessions s
	on rp.group_id = s.group_id
	group by rp.group_id
) rp_sessions on rp_sessions.group_id = resource_groups.group_id

inner join
(
	select
		rp.group_id,
		count(distinct scheduler_id) as coeur_count,
		count(r.session_id) as requests_count
	from resource_groups rp
	left join sys.dm_exec_requests r
	on rp.group_id = r.group_id
	group by rp.group_id
) rp_requests on rp_requests.group_id = resource_groups.group_id
inner join
(
	select
		rcp1.group_name,
		convert (decimal(5, 4), (rcp1.cntr_value * 1.0 / rcp2.cntr_value)) as cpu_usage
	from ResGroupCpu rcp1
	inner join ResGroupCpu rcp2
	on rcp1.group_name = rcp2.group_name
	where rcp1.counter_name not like '%base%'
	and rcp2.counter_name like '%base%'
) cpu on cpu.group_name = resource_groups.group_name

order by pool_name asc, --famille, 
group_name;


SELECT der.session_id,der.scheduler_id,der.group_id FROM sys.dm_exec_requests der