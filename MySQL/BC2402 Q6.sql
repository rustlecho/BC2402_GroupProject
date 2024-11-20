# Q6

select
	sales_channel,
    route,
    avg(wants_extra_baggage) / avg(flight_hour) as avg_wants_extra_baggage_per_flight_hour,
    avg(wants_in_flight_meals) / avg(flight_hour) as avg_wants_in_flight_meals_per_flight_hour,
    avg(length_of_stay) / avg(flight_hour) as avg_length_of_stay_per_flight_hour,
    avg(wants_preferred_seat) / avg(flight_hour) as avg_wants_preferred_seat_per_flight_hour
from customer_booking
group by sales_channel, route;



