if (!(Get-PSSnapin -Name SQLServerCmdletSnapin100 -ErrorAction SilentlyContinue)) {
   Add-PSSnapin SQLServerCmdletSnapin100
}

if (!(Get-PSSnapin -Name SqlServerProviderSnapin100 -ErrorAction SilentlyContinue)) {
   Add-PSSnapin SqlServerProviderSnapin100
}


$Stmt=@"
SET NOCOUNT ON
GO
SET quoted_identifier OFF
DECLARE @dbname AS VARCHAR(80)
DECLARE @msgdb AS VARCHAR(100)
DECLARE @dbbkpname AS VARCHAR(80)
DECLARE @dypart1 AS VARCHAR(2)
DECLARE @dypart2 AS VARCHAR(3)
DECLARE @dypart3 AS VARCHAR(4)
DECLARE @currentdate AS VARCHAR(10)
DECLARE @server_name AS VARCHAR(30)
SELECT @server_name = @@servername
SELECT @dypart1 = DATEPART(dd,GETDATE())
SELECT @dypart2 = DATENAME(mm,GETDATE())
SELECT @dypart3 = DATEPART(yy,GETDATE())
SELECT @currentdate= @dypart1 + @dypart2 + @dypart3
PRINT "#####################################################################"
PRINT "# SERVERNAME : "+ @server_name + " DATE : "+ @currentdate +"#"
PRINT "#####################################################################"
PRINT "DatabaseName Full Diff TranLog"
PRINT "##########################################################################################################################################"
SELECT SUBSTRING(s.name,1,50) AS DB_Name,
b.backup_start_date AS Full_DB_Backup_Status,
c.backup_start_date AS Differential_DB_Backup_Status,
d.backup_start_date AS Transaction_Log_Backup_Status
FROM MASTER..sysdatabases s
LEFT OUTER JOIN msdb..backupset b
ON s.name = b.database_name
AND b.backup_start_date =
(SELECT MAX(backup_start_date)AS 'Full DB Backup Status'
FROM msdb..backupset
WHERE database_name = b.database_name
AND TYPE = 'D') -- full database backups only, not log backups
LEFT OUTER JOIN msdb..backupset c
ON s.name = c.database_name
AND c.backup_start_date =
(SELECT MAX(backup_start_date)'Differential DB Backup Status'
FROM msdb..backupset
WHERE database_name = c.database_name
AND TYPE = 'I')
LEFT OUTER JOIN msdb..backupset d
ON s.name = d.database_name
AND d.backup_start_date =
(SELECT MAX(backup_start_date)'Transaction Log Backup Status'
FROM msdb..backupset
WHERE database_name = d.database_name
AND TYPE = 'L')
WHERE s.name NOT IN ('tempdb','master','msdb','model')
ORDER BY s.name
"@

$Query=invoke-sqlcmd -Query $Stmt 

$MsgBody = $Query | Select-object DB_Name,Full_DB_Backup_Status,Differential_DB_Backup_Status,Transaction_Log_Backup_Status | ConvertTo-HTML

$mailmsg = new-object Net.Mail.MailMessage
$smtp = New-Object Net.Mail.SmtpClient("CPT-EXCH01-P.magrit.int")
$mailmsg.From= "cpt-app04w-p@acceo.com"
$mailmsg.To.Add("alain.martin@acceo.com")
$mailmsg.subject = "Backup Status"
$mailmsg.IsBodyHTML = $true
$mailmsg.Body = $MsgBody 
$smtp.Send($mailmsg) 
