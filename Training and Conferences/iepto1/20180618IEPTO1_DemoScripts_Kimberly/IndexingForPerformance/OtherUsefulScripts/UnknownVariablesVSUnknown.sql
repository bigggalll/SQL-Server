USE credit;
go

create proc getlastname
(@lname varchar(15))
as
DECLARE @Lastname varchar(15)
set @lastname = @lname
SELECT [m].*
FROM [dbo].[Member] AS [m]
WHERE [m].[LastName] = @Lastname;
GO

create proc getlastname
(@lname varchar(15)
as
SELECT [m].*
FROM [dbo].[Member] AS [m]
WHERE [m].[LastName] = @Lname
OPTION (OPTIMIZE FOR UNKNOWN);
GO