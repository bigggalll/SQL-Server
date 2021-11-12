use ClickStreamDemo
go
-- Write a query that takes clicks as input and outputs a table: 
-- SessionID, IP_Address, First_click_time, Last_click_time, Number_Of_Clicks
-- One row per session (session is a sequence of clicks from IP_address that are all less than 1 minute apart)  
with ClicksWithStartOfSession as (
	select currtime, ip, 
       case when datediff(minute, lag(currtime, 1) over (partition by ip order by currtime), currtime) > 60
              then 1 
              else 0 
       end start_of_session 
	from clickstream_row
), 
ClicksWithSession as (
	select currtime, ip, 
		sum(start_of_session) over (
			partition by ip order by currtime 
			rows between unbounded preceding and current row) sessionid 
	from ClicksWithStartOfSession) 
select ip, sessionid, min(currtime) first_click_time, max(currtime) last_click_time, 
		count(*) number_of_clicks, datediff(minute, min(currtime), max(currtime)) session_duration
from ClicksWithSession 
group by ip, sessionid
go