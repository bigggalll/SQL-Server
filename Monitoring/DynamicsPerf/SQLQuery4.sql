select distinct 'select COUNT(*) as '''+RTRIM(object_name)+'''from sys.dm_os_performance_counters where object_name='''+ RTRIM(object_name)+'''' from sys.dm_os_performance_counters
select @@servername