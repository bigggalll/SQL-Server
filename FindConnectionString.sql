USE SSISDB

SELECT pr.name AS [ProjectName]
    , pr.description AS [ProjectDescription]
    , pr.last_deployed_time AS [ProjectLastValidated]
    , pr.validation_status AS [ProjectValidationStatus]
    , op.object_name AS [PackageName]
    , op.design_default_value AS [DefaultConnectionString]
FROM [internal].[object_parameters] op
INNER JOIN [internal].[projects] pr
ON pr.project_id = op.project_id
AND pr.object_version_lsn = op.project_version_lsn
WHERE op.parameter_name LIKE '%.ConnectionString'