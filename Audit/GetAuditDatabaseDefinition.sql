SELECT
details.audit_action_name AS [AuditActionType],
ISNULL(case when s.class_desc != 'DATABASE' and s.class_desc != 'SCHEMA' then 'OBJECT' else s.class_desc end,'') AS [ObjectClass],
ISNULL(SCHEMA_NAME(o.schema_id), '') AS [ObjectSchema],
ISNULL(case when details.is_group = 0 and details.class_desc = 'DATABASE' then db_name() when details.class_desc = 'SCHEMA' then sch.name else o.name end,'') AS [ObjectName],
ISNULL(p.name, '') AS [Principal]
FROM
sys.database_audit_specifications AS das
INNER JOIN sys.database_audit_specification_details AS details ON details.database_specification_id=das.database_specification_id
LEFT OUTER JOIN sys.securable_classes as s ON details.is_group = 0 and s.class = details.class
LEFT OUTER JOIN sys.all_objects AS o ON details.is_group = 0 and o.object_id = details.major_id and details.class_desc != 'SCHEMA' and details.class_desc != 'DATABASE'
LEFT OUTER JOIN sys.schemas as sch ON details.is_group = 0 and sch.schema_id = details.major_id and details.class_desc = 'SCHEMA'
LEFT OUTER JOIN sys.database_principals as p ON details.is_group = 0 and p.principal_id = details.audited_principal_id