-- Bug not_healty secondary: https://support.microsoft.com/en-us/help/4013111/fix-dmv-sys-dm-hadr-availability-group-states-displays-not-healthy-in

SELECT primary_replica,
       synchronization_health_desc,
       primary_recovery_health_desc,
       secondary_recovery_health_desc
FROM sys.dm_hadr_availability_group_states;


SELECT replica_server_name,
       role_desc,
       synchronization_health_desc
FROM sys.dm_hadr_availability_replica_states a
     INNER JOIN sys.availability_replicas b ON a.replica_id = b.replica_id;