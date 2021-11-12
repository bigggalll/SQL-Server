
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET QUOTED_IDENTIFIER ON;
SET ARITHABORT ON;
SELECT    SERVERPROPERTY('SERVERNAME') AS ServerName,
          P.Class_desc AS PermissionClass,
          P.state_desc AS PermissionState,
          ISNULL(LEFT(PL.PermissionList, LEN(PL.PermissionList) - 1), '') AS PermissionList,
          SM.name AS UserName,
          SP.type_desc AS LoginType,
          CAST(SP.is_disabled AS BIT) AS isDisabled
INTO #tempPer
FROM
(
    SELECT SP.principal_id,
           SP.name COLLATE SQL_Latin1_General_CP437_CI_AS name
    FROM   sys.server_principals AS SP
    WHERE  SP.type IN
(
      'S'
    , 'U'
    , 'G'
)
           AND SP.type <> 'R'                       

/* AND SP.name NOT LIKE '##%'*/

) AS SM
INNER JOIN sys.server_principals AS SP ON SM.principal_id = SP.principal_id
INNER JOIN
(
    SELECT DISTINCT
           class,
           class_desc COLLATE SQL_Latin1_General_CP437_CI_AS AS Class_desc,
           major_id,
           minor_id,
           grantee_principal_id,
           grantor_principal_id,
           state_desc COLLATE SQL_Latin1_General_CP437_CI_AS AS state_desc
    FROM   sys.server_permissions
) AS P ON SP.principal_id = P.grantee_principal_id
CROSS APPLY
(
    SELECT permission_name COLLATE SQL_Latin1_General_CP437_CI_AS+', '
    FROM   sys.server_permissions
    WHERE  class = P.class
           AND class_desc = P.Class_desc
           AND major_id = P.major_id
           AND minor_id = P.minor_id
           AND grantee_principal_id = P.grantee_principal_id
           AND grantor_principal_id = P.grantor_principal_id
           AND state_desc COLLATE SQL_Latin1_General_CP437_CI_AS = P.state_desc COLLATE SQL_Latin1_General_CP437_CI_AS
    ORDER BY permission_name COLLATE SQL_Latin1_General_CP437_CI_AS FOR XML PATH('')
) AS PL(PermissionList);
SELECT *
FROM   #tempPer;
DROP TABLE #tempPer;