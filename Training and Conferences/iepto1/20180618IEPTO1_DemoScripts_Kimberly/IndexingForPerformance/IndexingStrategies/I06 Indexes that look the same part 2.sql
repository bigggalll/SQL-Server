drop index member.MemberCovering 
drop index member.MemberCovering2 
drop index member.MemberCovering3 

CREATE INDEX MemberCovering 
ON member(firstname)
INCLUDE(region_no, member_no)

CREATE INDEX MemberCovering2 
ON member(firstname, member_no)
INCLUDE(region_no)

CREATE INDEX MemberCovering3 
ON member(firstname)
INCLUDE(region_no)