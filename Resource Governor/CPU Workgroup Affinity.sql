SELECT drgrp.name,
       drgrpa.scheduler_mask,
	  DBA_SQL00P.[dbo].[DecimalToBinary](drgrpa.scheduler_mask) AS scheduler_used
FROM sys.dm_resource_governor_resource_pool_affinity drgrpa
     INNER JOIN sys.dm_resource_governor_resource_pools drgrp ON drgrpa.pool_id = drgrp.pool_id;

SELECT drgrp.name pool_name, drgrpa.pool_id,
       drgrpa.scheduler_mask,
	  DBA_SQL00P.[dbo].[DecimalToBinary_V2](drgrpa.scheduler_mask) AS scheduler_used
FROM sys.dm_resource_governor_resource_pool_affinity drgrpa
     INNER JOIN sys.dm_resource_governor_resource_pools drgrp ON drgrpa.pool_id = drgrp.pool_id;
