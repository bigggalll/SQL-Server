--select * from sys.dm_db_log_info(5)

select d.name,l.file_id,l.vlf_active,l.vlf_size_mb,l.vlf_status,l.vlf_sequence_number from sys.databases d
 cross apply sys.dm_db_log_info(d.database_id) l
where d.name='testdb'
order by l.vlf_sequence_number

 dbcc loginfo('metro_prod')