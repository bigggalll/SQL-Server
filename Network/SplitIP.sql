DECLARE @Ip varchar(20)
select @Ip = CONVERT(varchar(20),CONNECTIONPROPERTY('local_net_address') )
  
SELECT   
CAST(SUBSTRING(@Ip, 1, CHARINDEX('.', @Ip) - 1) as int) AS FirstOctetFrom,  
CAST(SUBSTRING(@Ip, CHARINDEX('.', @Ip) + 1,CHARINDEX('.', @Ip, CHARINDEX('.', @Ip) + 1) - CHARINDEX('.', @Ip) - 1) as int) as SecondOctetFrom,  
CAST(REVERSE(SUBSTRING(REVERSE(@Ip), CHARINDEX('.', REVERSE(@Ip)) + 1,CHARINDEX('.', REVERSE(@Ip), CHARINDEX('.', REVERSE(@Ip)) + 1) -CHARINDEX('.', REVERSE(@Ip)) - 1)) as int) AS ThirdOctetFrom,  
CAST(REVERSE(SUBSTRING(REVERSE(@Ip), 1, CHARINDEX('.', REVERSE(@Ip)) - 1)) as int) as FourthOcetFrom 