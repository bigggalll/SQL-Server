


DECLARE @today date = GetDate()
  
  --Semaine courante – Semaine précédente = 
  --         croissance des données dans la dernière semaine au cours du dernier mois
SELECT      w1.DateInfo, w1.dbName, w1.Type_file,
            SUM(w1.Used_size_MB) as Total_used_size_MB,
            SUM(w1.total_size_mb) as total_size_MB,
            (SUM(w1.Used_size_MB) - SUM(w2.Used_size_MB)) AS croissance_used_MB
  FROM DBA_SQL01P.[dbo].[t_DBSizes] as w1
      inner join DBA_SQL01P.[dbo].[t_DBSizes] as w2 
            on    cast(w2.DateInfo as DATE) = cast(DATEADD(dd, -7,w1.DateInfo) as DATE) And
                  w2.dbName = w1.dbName And w2.Type_file=w1.Type_file
  where w1.dbName not in('master', 'msdb', 'tempdb', 'model', 'DBA_SQL')
   and w1.Type_file = 'DATA' and DATENAME(WEEKDAY, w1.DateInfo) = 'Thursday'
   And w1.DateInfo >= DateAdd(WEEK, -1, @today)
  group by w1.DateInfo, w1.dbName, w1.Type_file
  order by croissance_used_MB desc, w1.dbName, w1.DateInfo desc, w1.Type_file
  GO