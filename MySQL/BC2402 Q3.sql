# Q3

select Airline, 'Cancellation' as type, 
COUNT(*) as Instances
from flight_delay
where Cancelled = 1
group by Airline

union all

select Airline, 'Delay' as type, 
COUNT(*) as Instances
from flight_delay
where ArrDelay > 0
group by Airline;
