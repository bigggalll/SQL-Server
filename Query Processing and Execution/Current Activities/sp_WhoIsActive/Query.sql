select * from dba_log..WhoIsActive 
where collection_time between '2016-09-29 22:40:00' and '2016-09-29 22:50:00'
and program_name like '%SQLAgent%'
and session_id = 76
order by collection_time

select * from dba_log..WhoIsActive 
where collection_time between '2016-09-29 22:40:00' and '2016-09-29 22:50:00'
--and program_name like '%SQLAgent%'
and session_id = 71
order by collection_time
