-- Instruction pour diviser le CPU
ALTER RESOURCE POOL [default] WITH (AFFINITY SCHEDULER = (0 to 3, 12 to 15)) -- 8 coeurs
ALTER RESOURCE POOL [webwise_pool] WITH (AFFINITY SCHEDULER = (4 to 7, 16 to 19)) -- 8 coeurs
ALTER RESOURCE POOL [report_pool] WITH (AFFINITY SCHEDULER = (8 to 9, 20 to 21)) -- 4 coeurs
ALTER RESOURCE POOL [maintenance_pool] WITH (AFFINITY SCHEDULER = (10 to 1, 22 to 23)) -- 4 coeurs
ALTER RESOURCE GOVERNOR RECONFIGURE;

Select p.name pool_name, a.* from sys.dm_resource_governor_resource_pool_affinity a join sys.resource_governor_resource_pools p on a.pool_id=p.pool_id

-- Inactiver affinity
--ALTER RESOURCE POOL [default] WITH (AFFINITY SCHEDULER = AUTO)
--ALTER RESOURCE POOL [webwise_pool] WITH (AFFINITY SCHEDULER = AUTO)
--ALTER RESOURCE POOL [report_pool] WITH (AFFINITY SCHEDULER = AUTO)
--ALTER RESOURCE POOL [maintenance_pool] WITH (AFFINITY SCHEDULER = AUTO)
--ALTER RESOURCE GOVERNOR RECONFIGURE; 



