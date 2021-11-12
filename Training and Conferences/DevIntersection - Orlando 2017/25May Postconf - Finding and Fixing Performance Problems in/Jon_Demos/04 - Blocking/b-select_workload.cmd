start /B sqlcmd -S. -d LockEscalations -q"WHILE 1=1 BEGIN EXECUTE dbo.SelectNextEvent 1; END"
start /B sqlcmd -S. -d LockEscalations -q"WHILE 1=1 BEGIN EXECUTE dbo.SelectNextEvent 2; END"
start /B sqlcmd -S. -d LockEscalations -q"WHILE 1=1 BEGIN EXECUTE dbo.SelectNextEvent 1; END"
start /B sqlcmd -S. -d LockEscalations -q"WHILE 1=1 BEGIN EXECUTE dbo.SelectNextEvent 2; END"
start /B sqlcmd -S. -d LockEscalations -q"WHILE 1=1 BEGIN EXECUTE dbo.SelectNextEvent 3; END"
start /B sqlcmd -S. -d LockEscalations -q"WHILE 1=1 BEGIN EXECUTE dbo.SelectNextEvent 0; END"
exit