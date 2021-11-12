USE Credit
go

-- Let's create some duplicate indexes?
CREATE INDEX MemberCovering1 
ON member(firstname)
INCLUDE(region_no, member_no)

CREATE INDEX MemberCovering2
ON member(firstname)
INCLUDE(member_no,region_no)

CREATE INDEX MemberCovering3 
ON member(firstname)
INCLUDE(region_no)

CREATE INDEX MemberCovering4
ON member(firstname, member_no)
INCLUDE(region_no)
go

-- Can we see that they're duplicate?
exec sp_helpindex member
-- No with sp_helpindex... they look completely the same!

exec sp_SQLskills_SQL2008_helpindex member
go

-- And, what about different include lists?
CREATE INDEX MemberCovering5
ON member(firstname, lastname)
INCLUDE(region_no, city, phone_no)


TRUNCATE TABLE sp_tablepages;
INSERT sp_tablepages
EXEC ('DBCC IND (Credit, Member, 21)');
go

SELECT IndexLevel
    , PageFID
    , PagePID
    , PrevPageFID
    , PrevPagePID
    , NextPageFID
    , NextPagePID
FROM sp_tablepages
ORDER BY IndexLevel DESC, PrevPagePID;
GO

DBCC TRACEON  (3604) 
go

DBCC PAGE (Credit, 1, 24274, 3)
go

CREATE INDEX MemberCovering6
ON member(firstname, lastname)
INCLUDE(city, phone_no, region_no)

TRUNCATE TABLE sp_tablepages;
INSERT sp_tablepages
EXEC ('DBCC IND (Credit, Member, 22)');
go

SELECT IndexLevel
    , PageFID
    , PagePID
    , PrevPageFID
    , PrevPagePID
    , NextPageFID
    , NextPagePID
FROM sp_tablepages
ORDER BY IndexLevel DESC, PrevPagePID;
GO

DBCC TRACEON  (3604) 
go

DBCC PAGE (Credit, 1, 24498, 3)
go

-- So, how can we remove them??

exec sp_sqlskills_sql2008_finddupes member
go

DROP INDEX [dbo].[member].[MemberCovering1]
DROP INDEX [dbo].[member].[MemberCovering2]
DROP INDEX [dbo].[member].[MemberCovering3]
DROP INDEX [dbo].[member].[MemberCovering4]
DROP INDEX [dbo].[member].[MemberCovering5]
DROP INDEX [dbo].[member].[MemberCovering6]
