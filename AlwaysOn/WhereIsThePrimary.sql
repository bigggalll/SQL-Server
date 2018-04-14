SELECT
  AGC.name as [Availability Group]
, RCS.replica_server_name as [SQL cluster node name]
, ARS.role_desc as [Replica Role]
, AGL.dns_name as [Listener Name]
FROM
sys.availability_groups_cluster AS AGC
  INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS RCS
   ON
    RCS.group_id = AGC.group_id
  INNER JOIN sys.dm_hadr_availability_replica_states AS ARS
   ON
    ARS.replica_id = RCS.replica_id
  INNER JOIN sys.availability_group_listeners AS AGL
   ON
    AGL.group_id = ARS.group_id
WHERE ARS.role_desc = 'PRIMARY'