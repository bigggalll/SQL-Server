SELECT OBJECT_NAME(object_id) AS ObjectName,
    STATS_DATE(object_id, stats_id) AS StatisticsDate,
    *
FROM sys.stats
where name
--order by 3 desc
--where  STATS_DATE(object_id, stats_id) < '2016-08-07'

--DBCC SHOW_STATISTICS ('DIMENSIONATTRIBUTEVALUEGROUPSTATUS', 'I_529DIMENSIONATTRIBUTEVALUEGROUPIDX') 