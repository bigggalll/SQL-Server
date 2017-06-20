-- Utilisation de la fonction analystique LAG qui retourne la (les) rangée précédente
-- 

WITH RG_resource
     AS (SELECT ttrgs.GroupName
			  , ttrgs.DateStamp
              , LAG(ttrgs.DateStamp, 1, 0) OVER(ORDER BY ttrgs.DateStamp) AS DateStamp_previous
              , ttrgs.total_cpu_usage_ms
              , total_cpu_usage_ms - LAG(ttrgs.total_cpu_usage_ms, 1, 0) OVER(ORDER BY ttrgs.DateStamp) AS interval_cpu_usage_ms
              , ttrgs.total_request_count
              , total_request_count - LAG(ttrgs.total_request_count, 1, 0) OVER(ORDER BY ttrgs.DateStamp) AS interval_request_count
              , total_lock_wait_count
              , total_lock_wait_count - LAG(ttrgs.total_lock_wait_count, 1, 0) OVER(ORDER BY ttrgs.DateStamp) AS interval_lock_wait_count
              , total_lock_wait_time_ms
              , total_lock_wait_time_ms - LAG(ttrgs.total_lock_wait_time_ms, 1, 0) OVER(ORDER BY ttrgs.DateStamp) AS interval_lock_wait_time_ms
              , total_query_optimization_count
              , total_query_optimization_count - LAG(ttrgs.total_query_optimization_count, 1, 0) OVER(ORDER BY ttrgs.DateStamp) AS interval_query_optimization_count
              , total_suboptimal_plan_generation_count
              , total_suboptimal_plan_generation_count - LAG(ttrgs.total_suboptimal_plan_generation_count, 1, 0) OVER(ORDER BY ttrgs.DateStamp) AS interval_suboptimal_plan_generation_count
         FROM DBA_log.dbo.t_Track_ResGovStats ttrgs WITH (NOLOCK)
        WHERE 
		ttrgs.GroupName = 'RockSolidSQL'
		and 
		ttrgs.DateStamp > getdate()-1
	    )
	SELECT *
	          , CAST(ROUND(100.0 * (interval_cpu_usage_ms) / (2.0 * capture_duration_ms), 2) AS    FLOAT) AS pct_cpu_use_pool_s
          , CAST(ROUND(100.0 * (interval_cpu_usage_ms) / (24.0 * capture_duration_ms), 2) AS    FLOAT) AS pct_cpu_use_server_s

	FROM (
     SELECT RG_resource.GroupName
		  , RG_resource.DateStamp
          , RG_resource.interval_cpu_usage_ms
          , DATEDIFF(ms, IIF(DateStamp_previous = '1900-01-01 00:00:00.000', DateStamp, DateStamp_previous), DateStamp) AS capture_duration_ms
          , CONVERT( VARCHAR, RG_resource.DateStamp - (LAG(RG_resource.DateStamp, 1, 0) OVER(ORDER BY RG_resource.DateStamp)), 108) AS capture_duration
          , RG_resource.interval_request_count
          , RG_resource.interval_lock_wait_count
          , RG_resource.interval_lock_wait_time_ms
          , RG_resource.interval_query_optimization_count
          , RG_resource.interval_suboptimal_plan_generation_count
     FROM RG_resource
	 ) x
     where capture_duration_ms <> 0 
	 ORDER BY 2 DESC;