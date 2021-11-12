CREATE UNIQUE CLUSTERED INDEX IXCL
ON tname (c6, c8, c2)

CREATE NONCLUSTERED INDEX IXNC1
ON tname (c5, c2, c4)
Leaf level: 	c5, c2, c4, c6, c8
KEY/btree:  	c5, c2, c4, c6, c8

CREATE UNIQUE NONCLUSTERED INDEX IXNC1   
ON tname (c5, c2, c4)
Leaf level: 	c5, c2, c4, c6, c8
KEY/btree:  	c5, c2, c4

CREATE NONCLUSTERED INDEX IXNC1
ON tname (c5, c2, c4)
INCLUDE (c8)
Leaf level: 	c5, c2, c4, c6, c8

CREATE NONCLUSTERED INDEX IXNC1
ON tname (c5, c2, c4)
INCLUDE (c9)
Leaf level: 	c5, c2, c4, c6, c8, c9
key level: 	    c5, c2, c4, c6, c8

CREATE UNIQUE NONCLUSTERED INDEX IXNC1
ON tname (c5, c9, c2)
INCLUDE (c8)

Leaf level: 	c5, c9, c2, c6, c8
key level: 	    c5, c9, c2

CREATE UNIQUE NONCLUSTERED INDEX IXNC1
ON tname (c5, c9, c2)
INCLUDE (c10)

Leaf level: 	c5, c9, c2, c6, c8, c10
key level: 	    c5, c9, c2
