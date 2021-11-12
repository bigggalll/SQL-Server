WITH task_space_usage AS (
	-- Utilisation des objets internes ==> TempDB 
	-- CTE inspirée par Alain Martin
	SELECT 
		session_id,
		SUM(internal_objects_alloc_page_count)		as alloc_pages,
		SUM(internal_objects_dealloc_page_count)	as dealloc_pages
	FROM 
		sys.dm_db_task_space_usage WITH (NOLOCK)	
	WHERE 
		session_id <> @@SPID
	GROUP BY 
		session_id
)
select 
	subString(
		sqlTxt.TEXT, 
		(requests.statement_start_offset / 2) + 1, 
		((	CASE	requests.statement_end_offset 
			WHEN	- 1 
			THEN	Datalength(sqlTxt.TEXT) 
			ELSE	requests.statement_end_offset 
			END - requests.statement_start_offset) / 2) + 1)	as Statement,

	coalesce(
		Object_name(sqlTxt.objectid, sqlTxt.dbid),
		'** AdHoc **')											as [Stored Proc],			-- Si ce n'est pas une stored proc, c'est AdHoc
	
	execSession.login_name										as LoginName,

	'|-->'														as [KPI],					
	convert(varChar, 
		dateAdd(
			ss, 
			requests.total_elapsed_time / (1000.0), 
			0), 
		108) 													as TotalTime,
	convert(varChar,
		dateadd(
			ss,
			(requests.total_elapsed_time - requests.wait_time)/1000,
		0),
	108) 														as ProcessTime,
	convert(varChar,
		dateadd(
			ss,
			requests.wait_time/1000,
		0),
	108)									as WaitTime,
	requests.wait_type											as WaitType,
	execSession.session_id										as SID,						-- Session ID
	requests.blocking_session_id								as Blocker,					-- SID bloquant
	cast((MemGrant.requested_memory_kb * 100.0 
		/ RessSemaphore.total_memory_kb) as decimal (5,2))		as [Requested RAM (%)],			-- Mémoire demandée versus total dispo SQL
	TSU.alloc_pages  / 128										as [Reserved TempDB (MB)],			-- Espace réservé dans TempDB

	'|-->'														as [Stats],					
	MemGrant.dop												as DOP,						-- DOP utilisé
	Groups.name													as GroupName,				-- Groupe de "Resource Governor"
	Pools.name													as PoolName,				-- Pool de la requête géré par "Resource Governor"
	Pools.max_memory_kb/1024/1024								as MaxMemoryGB,				-- RAM maximum en GB disponible selon le pool
	Pools.max_memory_percent									as MaxPctMemory,			-- RAM maximum en % disponible selon le pool
	Pools.max_cpu_percent										as MaxPctCPU,				-- RAM maximum en GB disponible selon le pool
	
	'|-->'														as [RAM],
	MemGrant.requested_memory_kb / 1024							as [Requested(MB)],			-- Mémoire demandée, selon le plan
	cast((MemGrant.requested_memory_kb * 100.0 
		/ RessSemaphore.total_memory_kb) as decimal (5,2))		as [Requested (%)],			-- Mémoire demandée versus total dispo SQL
	MemGrant.used_memory_kb / 1024								as [Used(MB)],				-- Mémoire réellement utilisée
	cast((MemGrant.used_memory_kb * 100.0
		/ memGrant.granted_memory_kb) as decimal (5,2))			as [Used(%)],				-- Taux d'utilisation de la REM vs demandé
	RessSemaphore.available_memory_kb / 1024					as [Available(MB)],			-- Mémoire libre de SQL
	
	'|-->'														as [TempDB],
	TSU.alloc_pages  / 128										as [Reserved (MB)],			-- Espace réservé dans TempDB
    (TSU.alloc_pages-TSU.dealloc_pages) / 128					as [Used (MB)],				-- Espace utilisé dans TempDB
	
	
	'|-->'														as [Other],
	requests.STATUS												as [Status],
	execSession.login_time										as LogTime,	
	execSession.last_request_end_time							as LastRequest,

	--CHECKSUM(
	--	cast(queryPlan.query_plan as varchar(max)))				as PlanCheckSum,
	queryPlan.query_plan										as [Plan],
	requests.writes												as Writes,
    requests.reads												as Reads,
	requests.logical_reads										as [Logical Reads],
	requests.cpu_time											as [CPU time],
	
	execSession.host_name,
	execSession.program_name,
	requests.open_transaction_count,
	requests.percent_complete									as [Completion%]
from 
	sys.dm_exec_sessions									as execSession
	left outer join sys.dm_exec_requests					as requests 
	on	requests.session_id = execSession.session_id
	left outer join sys.dm_exec_query_memory_grants			as MemGrant 
	on	execSession.session_id = MemGrant.session_id 
	left outer join task_space_usage						as TSU 
	on	execSession.Session_ID = TSU.Session_ID
	left outer join sys.dm_exec_query_resource_semaphores	as RessSemaphore
	on	RessSemaphore.pool_id =	2 and
		RessSemaphore.resource_semaphore_id = 0
	cross apply sys.dm_exec_sql_text
		(requests.sql_handle)								as sqlTxt
	cross apply sys.dm_exec_query_plan
		(requests.plan_handle)								as queryPlan
	-- Ajout 2017-09-08 >>
	join sys.resource_governor_workload_groups				as Groups
	on	MemGrant.group_id = Groups.group_id
	join sys.dm_resource_governor_resource_pools			as Pools
	on MemGrant.pool_id = Pools.pool_id
	-- Ajout 2017-09-08 <<
where 
	requests.session_id != @@SPID			 -- On ignore cette requête