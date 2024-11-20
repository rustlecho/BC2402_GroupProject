# Q4

select 
	month(STR_TO_DATE(Date, '%d-%m-%Y')) as month,
    CONCAT(Origin, ' - ', Dest) as Route,
    COUNT(*) as DelayCount
from flight_delay
where ArrDelay > 0
group by month, Route
order by month, DelayCount desc;

