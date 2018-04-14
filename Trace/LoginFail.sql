select te.name as [event], e.applicationname, e.textdata, e.spid,  e.starttime, e.databasename as db, e.loginname as [login], e.hostname as host, e.clientprocessid as pid, (select [path] from sys.traces where is_default = 1 and is_shutdown=0) as tracefile
from fn_trace_gettable((select [path] from sys.traces where is_default = 1 and is_shutdown=0), default) e
inner join sys.trace_events te on e.eventclass=te.trace_event_id
where e.eventclass = 20
order by e.starttime