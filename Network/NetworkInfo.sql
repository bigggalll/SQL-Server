USE master;
GO
SELECT @@servername InstanceName,
        DEFAULT_DOMAIN() DomainName,
       CONNECTIONPROPERTY('net_transport') AS net_transport,
       CONNECTIONPROPERTY('protocol_type') AS protocol_type,
       CONNECTIONPROPERTY('auth_scheme') AS auth_scheme,
       CONNECTIONPROPERTY('local_net_address') AS local_net_address,
       CONNECTIONPROPERTY('local_tcp_port') AS local_tcp_port,
       CONNECTIONPROPERTY('client_net_address') AS client_net_address;
GO
xp_readerrorlog
 0,
 1,
 N'Server is listening on';
GO

DECLARE @Domain varchar(100), @key varchar(100)
SET @key = 'SYSTEM\ControlSet001\Services\Tcpip\Parameters\'
EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE', @key=@key,@value_name='Domain',@value=@Domain OUTPUT 
SELECT @@servername as ServerName,convert(varchar(100),@Domain) as DomainName

SELECT servicename, service_account
FROM sys.dm_server_services WITH (NOLOCK)
WHERE servicename like 'SQL Server%'
OPTION (RECOMPILE);

select @@version Version,@@SERVERNAME ServerName,DEFAULT_DOMAIN() DomainName