CREATE INDEX Test1 ON dbo.Member (LastName) 
INCLUDE (FirstName, MiddleInitial); 

CREATE INDEX Test2 ON Member (LastName) 
INCLUDE (MiddleInitial, FirstName); 

CREATE INDEX Test3 ON Member (LastName, member_no) 
INCLUDE (MiddleInitial, FirstName); 

CREATE INDEX Test4 ON Member (LastName) 
INCLUDE (MiddleInitial, FirstName, member_no); 

sp_sqlskills_sql2008_helpindex member

sp_sqlskills_sql2008_finddupes member