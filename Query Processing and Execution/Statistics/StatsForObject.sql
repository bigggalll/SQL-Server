--INSERT INTO DBA_SQL01P.dbo.t_Stat_AX
       SELECT GETDATE() AS date_info,
              OBJECT_NAME(s.object_id) AS table_name,
              s.name AS stats_name,
              s.auto_created,
              s.no_recompute,
              s.is_temporary,
              sp.last_updated,
              sp.rows,
              sp.rows_sampled,
              sp.unfiltered_rows,
              sp.modification_counter,
              LEFT(SColumns, LEN(Scolumns) - 1) AS stats_columns
       FROM sys.stats AS s
            CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp 
		  CROSS APPLY
			(
			    SELECT cc.name+', '
			    FROM sys.stats_columns AS sc
				    JOIN sys.columns AS cc ON sc.object_id = cc.object_id
										AND sc.column_id = cc.column_id
			    WHERE s.object_id = sc.object_id
					AND s.stats_id = sc.stats_id
			    ORDER BY SC.stats_column_id
			    FOR XML PATH('')
			) AS cl(SColumns)
       WHERE s.object_id IN(  OBJECT_ID('dbo.RETAILASSORTMENTLOOKUPCHANNELGROUP ')
					   , OBJECT_ID('dbo.RETAILASSORTMENTLOOKUP')
					   , OBJECT_ID('dbo.RETAILGROUPMEMBERLINE')
					   , OBJECT_ID('dbo.RETAILCHANNELTABLE'))
       ORDER BY last_updated DESC;