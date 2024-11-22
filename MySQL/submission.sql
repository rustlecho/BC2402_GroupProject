-- Q1
set SQL_SAFE_UPDATES = 0; -- Disable safe update mode
delete from customer_support where category not in ('CONTACT', 'CANCEL', 'FEEDBACK', 'INVOICE', 'ORDER', 'PAYMENT', 'REFUND', 'SHIPPING');
set SQL_SAFE_UPDATES = 1; -- Enable safe update mode
select distinct category, count(*) as cnt from customer_support group by category;

-- Q2 find tag Q and W
select count(*) as cnt from customer_support
where flags like '%Q%' and flags like '%W%';

-- Q3

-- Q4
with mdelay as (
	select substring(Date, 4, 2) as Month, Origin, Dest, count(ArrDelay) as Cnt
    from flight_delay
    where ArrDelay > 0
	group by Month, Origin, Dest
)
select Month, Origin, Dest, Cnt from mdelay
where (Month, Cnt) in (
	select Month, max(Cnt) from mdelay
    group by Month
);

-- Q5


-- Using flight duration.
-- Q6
-- First checked the data for NUll values and rows to be cleaned. Dataset was already clean with no NULL values or values needing to be removed.

-- Average rations requested by the Question.
select
	sales_channel,
    route,
    avg(wants_extra_baggage) / avg(flight_duration) as avg_wants_extra_baggage_per_flight_hour,
    avg(wants_in_flight_meals) / avg(flight_duration) as avg_wants_in_flight_meals_per_flight_hour,
    avg(length_of_stay) / avg(flight_duration) as avg_length_of_stay_per_flight_hour,
    avg(wants_preferred_seat) / avg(flight_duration) as avg_wants_preferred_seat_per_flight_hour
from customer_booking
group by sales_channel, route;

-- Overall Average ratios with no group by.
SELECT
    AVG(wants_extra_baggage) / AVG(flight_duration) AS avg_wants_extra_baggage_per_flight_hour,
    AVG(wants_in_flight_meals) / AVG(flight_duration) AS avg_wants_in_flight_meals_per_flight_hour,
    AVG(length_of_stay) / AVG(flight_duration) AS avg_length_of_stay_per_flight_hour,
    AVG(wants_preferred_seat) / AVG(flight_duration) AS avg_wants_preferred_seat_per_flight_hour
FROM customer_booking;

-- Ratios grouped by Sales Channel only.
SELECT
    sales_channel,
    AVG(wants_extra_baggage) / AVG(flight_duration) AS avg_wants_extra_baggage_per_flight_hour,
    AVG(wants_in_flight_meals) / AVG(flight_duration) AS avg_wants_in_flight_meals_per_flight_hour,
    AVG(length_of_stay) / AVG(flight_duration) AS avg_length_of_stay_per_flight_hour,
    AVG(wants_preferred_seat) / AVG(flight_duration) AS avg_wants_preferred_seat_per_flight_hour
FROM customer_booking
GROUP BY sales_channel;

-- Statistical distribution of flight_duration.
SELECT
    AVG(flight_duration) AS mean_flight_duration,
    MIN(flight_duration) AS min_flight_duration,
    MAX(flight_duration) AS max_flight_duration,
    STD(flight_duration) AS std_dev_flight_duration,
    COUNT(flight_duration) AS total_flights
FROM customer_booking;

-- Variables split by Short and Long flights.
SELECT 
    CASE 
        WHEN flight_duration <= 7 THEN 'Short Flights'
        WHEN flight_duration > 7 THEN 'Long Flights'
    END AS flight_segment,
    AVG(wants_extra_baggage) AS avg_extra_baggage,
    AVG(wants_preferred_seat) AS avg_preferred_seat,
    AVG(wants_in_flight_meals) AS avg_in_flight_meals,
    AVG(length_of_stay) AS avg_length_of_stay
FROM customer_booking
GROUP BY flight_segment;

-- Meal preference rattio split by flight hour
SELECT 
    ROUND(flight_duration, 0) AS rounded_flight_duration,
    SUM(wants_in_flight_meals) AS total_meals,
    COUNT(*) AS total_flights,
    SUM(wants_in_flight_meals) / COUNT(*) AS meal_preference_ratio
FROM customer_booking
GROUP BY rounded_flight_duration
ORDER BY rounded_flight_duration;

-- Overall rations split by flight duration.
SELECT 
    ROUND(flight_duration, 0) AS rounded_flight_duration,
    AVG(wants_extra_baggage) AS avg_extra_baggage_preference,
    AVG(wants_preferred_seat) AS avg_preferred_seat_preference,
    AVG(wants_in_flight_meals) AS avg_in_flight_meal_preference,
    AVG(length_of_stay) AS avg_length_of_stay
FROM customer_booking
GROUP BY rounded_flight_duration
ORDER BY rounded_flight_duration;

-- Correlation of Length of stay and Flight Duration
SELECT 
    (AVG((flight_duration - (SELECT AVG(flight_duration) FROM customer_booking)) *
         (length_of_stay - (SELECT AVG(length_of_stay) FROM customer_booking))) /
    (SQRT(
        AVG(POW(flight_duration - (SELECT AVG(flight_duration) FROM customer_booking), 2)) *
        AVG(POW(length_of_stay - (SELECT AVG(length_of_stay) FROM customer_booking), 2))
    ))) AS correlation_flight_duration_length_of_stay
FROM customer_booking;

-- Q7
(
select 'Seasonal' as Periods, Airline, Class, avg(SeatComfort), avg(FoodnBeverages), avg(InflightEntertainment), avg(ValueForMoney), avg(OverallRating)
from airlines_reviews
where substring(MonthFlown, 1, 3) in ('Jun', 'Jul', 'Aug', 'Sep')
group by Airline, Class
)
union all
(
select 'Non-Seasonal' as Periods, Airline, Class, avg(SeatComfort), avg(FoodnBeverages), avg(InflightEntertainment), avg(ValueForMoney), avg(OverallRating)
from airlines_reviews
where substring(MonthFlown, 1, 3) not in ('Jun', 'Jul', 'Aug', 'Sep')
group by Airline, Class
);

-- percentage differences in averages between non seasonal and seasonal periods
WITH SeasonalData AS (
    SELECT 
        'Seasonal' AS Periods,
        Airline, 
        Class, 
        AVG(SeatComfort) AS SeatComfortAvg,
        AVG(FoodnBeverages) AS FoodnBeveragesAvg,
        AVG(InflightEntertainment) AS InflightEntertainmentAvg,
        AVG(ValueForMoney) AS ValueForMoneyAvg,
        AVG(OverallRating) AS OverallRatingAvg
    FROM airlines_reviews
    WHERE SUBSTRING(MonthFlown, 1, 3) IN ('Jun', 'Jul', 'Aug', 'Sep')
    GROUP BY Airline, Class
),
NonSeasonalData AS (
    SELECT 
        'Non-Seasonal' AS Periods,
        Airline, 
        Class, 
        AVG(SeatComfort) AS SeatComfortAvg,
        AVG(FoodnBeverages) AS FoodnBeveragesAvg,
        AVG(InflightEntertainment) AS InflightEntertainmentAvg,
        AVG(ValueForMoney) AS ValueForMoneyAvg,
        AVG(OverallRating) AS OverallRatingAvg
    FROM airlines_reviews
    WHERE SUBSTRING(MonthFlown, 1, 3) NOT IN ('Jun', 'Jul', 'Aug', 'Sep')
    GROUP BY Airline, Class
)
SELECT 
    s.Airline, 
    s.Class, 
    ROUND(((s.SeatComfortAvg - n.SeatComfortAvg) / n.SeatComfortAvg) * 100, 2) AS SeatComfortDiffPercent,
    ROUND(((s.FoodnBeveragesAvg - n.FoodnBeveragesAvg) / n.FoodnBeveragesAvg) * 100, 2) AS FoodnBeveragesDiffPercent,
    ROUND(((s.InflightEntertainmentAvg - n.InflightEntertainmentAvg) / n.InflightEntertainmentAvg) * 100, 2) AS InflightEntertainmentDiffPercent,
    ROUND(((s.ValueForMoneyAvg - n.ValueForMoneyAvg) / n.ValueForMoneyAvg) * 100, 2) AS ValueForMoneyDiffPercent,
    ROUND(((s.OverallRatingAvg - n.OverallRatingAvg) / n.OverallRatingAvg) * 100, 2) AS OverallRatingDiffPercent
FROM SeasonalData s
JOIN NonSeasonalData n
ON s.Airline = n.Airline AND s.Class = n.Class;

-- Q8 
-- Our initial approach to finding complaints before we analysed it to find its limitations
select * 
from airlines_reviews
where Recommended='no' or OverallRating<=5;

--polarity done in python - please run the cleaned sql file
--after running the sql script, there should be a table called cleaned_reviews
--we set complaints as polarity as <= 0 
SET SQL_SAFE_UPDATES = 0;
update cleaned_reviews
set complaints = "yes"
where polarity <= 0;

-- Check proportion of Verified -> quite a significant proportion, disregard this row
select case when Verified = "TRUE" then "Verified" else "Non-Verified" end as Status, count(*) as Count,
round(count(*)*100.0/sum(count(*)) over (), 2) as Proportion
from cleaned_reviews
where complaints = "yes"
group by Status;

-- dropping of irrelevant rows to achieve a focused dataset
alter table cleaned_reviews
drop column Name,
drop column Verified,
drop column FIELD1,
drop column _id,
drop column Route,
drop column cleaned_title;

#--Extract top 100 words from the Title column
WITH filtered_reviews AS (
    SELECT Title
    FROM cleaned_reviews
    WHERE complaints = 'yes'
),
split_words AS (
    SELECT 
        LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(Title, ' ', n), ' ', -1)) AS word
    FROM filtered_reviews
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL 
        SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL 
        SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    ) AS numbers
    ON CHAR_LENGTH(Title) - CHAR_LENGTH(REPLACE(Title, ' ', '')) >= n - 1
),
filtered_words AS (
    SELECT word
    FROM split_words
    WHERE word NOT IN (
        'down', 'as', 'too', 'felt', 'up', 'their', 'them', 'than', 
        'they', 'have', 'are', 'us', 'by', 'that', 'this', 'it', 
        'not', 'very', 'no', 'me', 'at', 'has', 'an', 'the', 
        'is', 'and', 'in', 'to', 'a', 'of', 'with', 'was', 'i', 
        '', 'on', 'for', 'my', 'were', 'we'
    )
)
SELECT 
    word AS word, 
    COUNT(*) AS count
FROM filtered_words
GROUP BY word
ORDER BY count DESC
LIMIT 100;

-- Full text search using associated words on the Reviews column to find common complaints
ALTER TABLE cleaned_reviews ADD FULLTEXT(Reviews);

-- delay
SELECT COUNT(*) AS count
FROM cleaned_reviews
WHERE complaints = 'yes'
  AND MATCH(Reviews) AGAINST('delay late' IN NATURAL LANGUAGE MODE);


-- food
SELECT COUNT(*) AS count
FROM cleaned_reviews
WHERE complaints = 'yes'
  AND MATCH(Reviews) AGAINST('tasteless food meal' IN NATURAL LANGUAGE MODE);

-- service
SELECT COUNT(*) AS count
FROM cleaned_reviews
WHERE complaints = 'yes'
  AND MATCH(Reviews) AGAINST('service' IN NATURAL LANGUAGE MODE);

-- seat
SELECT COUNT(*) AS count
FROM cleaned_reviews
WHERE complaints = 'yes'
  AND MATCH(Reviews) AGAINST('seat uncomfortable seats seating' IN NATURAL LANGUAGE MODE);

-- entertainment
SELECT COUNT(*) AS count
FROM cleaned_reviews
WHERE complaints = 'yes'
  AND MATCH(Reviews) AGAINST('entertainment' IN NATURAL LANGUAGE MODE);

-- compensation
SELECT COUNT(*) AS count
FROM cleaned_reviews
WHERE complaints = 'yes'
  AND MATCH(Reviews) AGAINST('compensation refund' IN NATURAL LANGUAGE MODE);

-- baggage
SELECT COUNT(*) AS count
FROM cleaned_reviews
WHERE complaints = 'yes'
  AND MATCH(Reviews) AGAINST('baggage luggage' IN NATURAL LANGUAGE MODE);


-- by rating 
with Ratings as (
    (
    select 
        Airline, 
        TypeofTraveller,
        'SeatComfort' as RatingType, 
        sum(case when SeatComfort < 3 then 1 else 0 end) as Negative,
        sum(case when SeatComfort = 3 then 1 else 0 end) as Neutral,
        sum(case when SeatComfort > 3 then 1 else 0 end) as Positive
    from airlines_reviews
    group by Airline, TypeofTraveller
    )
    union all
    (
    select 
        Airline, 
        TypeofTraveller,
        'StaffService' as RatingType, 
        sum(case when StaffService < 3 then 1 else 0 end) as Negative,
        sum(case when StaffService = 3 then 1 else 0 end) as Neutral,
        sum(case when StaffService > 3 then 1 else 0 end) as Positive
    from airlines_reviews
    group by Airline, TypeofTraveller
    )
    union all
    (
    select 
        Airline, 
        TypeofTraveller,
        'FoodnBeverages' as RatingType, 
        sum(case when FoodnBeverages < 3 then 1 else 0 end) as Negative,
        sum(case when FoodnBeverages = 3 then 1 else 0 end) as Neutral,
        sum(case when FoodnBeverages > 3 then 1 else 0 end) as Positive
    from airlines_reviews
    group by Airline, TypeofTraveller
    )
    union all
    (
    select 
        Airline, 
        TypeofTraveller,
        'InflightEntertainment' as RatingType, 
        sum(case when InflightEntertainment < 3 then 1 else 0 end) as Negative,
        sum(case when InflightEntertainment = 3 then 1 else 0 end) as Neutral,
        sum(case when InflightEntertainment > 3 then 1 else 0 end) as Positive
    from airlines_reviews
    group by Airline, TypeofTraveller
    )
    union all
    (
    select 
        Airline, 
        TypeofTraveller,
        'ValueForMoney' as RatingType, 
        sum(case when ValueForMoney < 3 then 1 else 0 end) as Negative,
        sum(case when ValueForMoney = 3 then 1 else 0 end) as Neutral,
        sum(case when ValueForMoney > 3 then 1 else 0 end) as Positive
    from airlines_reviews
    group by Airline, TypeofTraveller
    )
)
select 
    Airline, 
    TypeofTraveller, 
    RatingType, 
    Negative, 
    Neutral, 
    Positive, 
    round(Negative * 100.0 / (Negative + Neutral + Positive), 2) as NegativePercentage,
    round(Neutral * 100.0 / (Negative + Neutral + Positive), 2) as NeutralPercentage,
    round(Positive * 100.0 / (Negative + Neutral + Positive), 2) as PositivePercentage
from Ratings
order by Airline, TypeofTraveller, RatingType;

-- Top 5 Issues for each Airline and Type of Traveller

-- Delay
SELECT 
    Airline, 
    TypeofTraveller, 
    COUNT(*) AS count
FROM 
    cleaned_reviews
WHERE 
    MATCH(Reviews) AGAINST('delay late' IN NATURAL LANGUAGE MODE)
    AND complaints = 'yes'
GROUP BY 
    Airline, 
    TypeofTraveller;

-- Food
SELECT 
    Airline, 
    TypeofTraveller, 
    COUNT(*) AS count
FROM 
    cleaned_reviews
WHERE 
    MATCH(Reviews) AGAINST('tasteless food meal' IN NATURAL LANGUAGE MODE)
    AND complaints = 'yes'
GROUP BY 
    Airline, 
    TypeofTraveller;

-- Service
SELECT 
    Airline, 
    TypeofTraveller, 
    COUNT(*) AS count
FROM 
    cleaned_reviews
WHERE 
    MATCH(Reviews) AGAINST('service' IN NATURAL LANGUAGE MODE)
    AND complaints = 'yes'
GROUP BY 
    Airline, 
    TypeofTraveller;

-- Seat
SELECT 
    Airline, 
    TypeofTraveller, 
    COUNT(*) AS count
FROM 
    cleaned_reviews
WHERE 
    MATCH(Reviews) AGAINST('seat uncomfortable ' IN NATURAL LANGUAGE MODE)
    AND complaints = 'yes'
GROUP BY 
    Airline, 
    TypeofTraveller;

-- Entertainment
SELECT 
    Airline, 
    TypeofTraveller, 
    COUNT(*) AS count
FROM 
    cleaned_reviews
WHERE 
    MATCH(Reviews) AGAINST('entertainment' IN NATURAL LANGUAGE MODE)
    AND complaints = 'yes'
GROUP BY 
    Airline, 
    TypeofTraveller;

-- Compensation
SELECT 
    Airline, 
    TypeofTraveller, 
    COUNT(*) AS count
FROM 
    cleaned_reviews
WHERE 
    MATCH(Reviews) AGAINST('compensation refund' IN NATURAL LANGUAGE MODE)
    AND complaints = 'yes'
GROUP BY 
    Airline, 
    TypeofTraveller;

-- Baggage
SELECT 
    Airline, 
    TypeofTraveller, 
    COUNT(*) AS count
FROM 
    cleaned_reviews
WHERE 
    MATCH(Reviews) AGAINST('baggage luggage' IN NATURAL LANGUAGE MODE)
    AND complaints = 'yes'
GROUP BY 
    Airline, 
    TypeofTraveller;
    



-- Q9
-- Number of Reviews pre and post covid
SELECT 
    CASE 
        WHEN ReviewDate < '2020-03-01' THEN 'Pre-COVID'
        ELSE 'Post-COVID'
    END AS Period,
    COUNT(*) AS ReviewCount
FROM airlines_reviews
WHERE Airline = 'Singapore Airlines'
GROUP BY Period;



-- When rating <= 2, considered as complaints
SELECT 
    CASE 
        WHEN ReviewDate < '2020-03-01' THEN 'Pre-COVID'
        ELSE 'Post-COVID'
    END AS Period,
    COUNT(CASE WHEN SeatComfort <= 2 THEN 1 ELSE NULL END) AS SeatComfortComplaints,
    COUNT(CASE WHEN StaffService <= 2 THEN 1 ELSE NULL END) AS StaffServiceComplaints,
    COUNT(CASE WHEN FoodnBeverages <= 2 THEN 1 ELSE NULL END) AS FoodComplaints,
    COUNT(CASE WHEN InflightEntertainment <= 2 THEN 1 ELSE NULL END) AS EntertainmentComplaints,
    COUNT(CASE WHEN ValueForMoney <= 2 THEN 1 ELSE NULL END) AS ValueComplaints
FROM airlines_reviews
WHERE Airline = 'Singapore Airlines'
GROUP BY Period;




-- When rating <= 2, considered as complaints (As a proportion of reviews)
SELECT 
    CASE 
        WHEN ReviewDate < '2020-03-01' THEN 'Pre-COVID'
        ELSE 'Post-COVID'
    END AS Period,
    COUNT(*) AS TotalReviews,
    COUNT(CASE WHEN SeatComfort <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS SeatComfortComplaintRate,
    COUNT(CASE WHEN StaffService <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS StaffServiceComplaintRate,
    COUNT(CASE WHEN FoodnBeverages <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS FoodComplaintRate,
    COUNT(CASE WHEN InflightEntertainment <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS EntertainmentComplaintRate,
    COUNT(CASE WHEN ValueForMoney <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS ValueComplaintRate
FROM airlines_reviews
WHERE Airline = 'Singapore Airlines'
GROUP BY Period;




-- When rating <= 2, considered as complaints (As a proportion of reviews) -- Group by BOTH Period and Class
SELECT 
    CASE 
        WHEN ReviewDate < '2020-03-01' THEN 'Pre-COVID'
        ELSE 'Post-COVID'
    END AS Period,
    Class,
    COUNT(*) AS TotalReviews,
    COUNT(CASE WHEN SeatComfort <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS SeatComfortComplaintRate,
    COUNT(CASE WHEN StaffService <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS StaffServiceComplaintRate,
    COUNT(CASE WHEN FoodnBeverages <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS FoodComplaintRate,
    COUNT(CASE WHEN InflightEntertainment <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS EntertainmentComplaintRate,
    COUNT(CASE WHEN ValueForMoney <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS ValueComplaintRate
FROM airlines_reviews
WHERE Airline = 'Singapore Airlines'
GROUP BY Period, Class;




-- When rating <= 2, considered as complaints (As a proportion of reviews) -- Group by BOTH Period and Type of Traveller
SELECT 
    CASE 
        WHEN ReviewDate < '2020-03-01' THEN 'Pre-COVID'
        ELSE 'Post-COVID'
    END AS Period,
    TypeofTraveller,
    COUNT(*) AS TotalReviews,
    COUNT(CASE WHEN SeatComfort <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS SeatComfortComplaintRate,
    COUNT(CASE WHEN StaffService <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS StaffServiceComplaintRate,
    COUNT(CASE WHEN FoodnBeverages <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS FoodComplaintRate,
    COUNT(CASE WHEN InflightEntertainment <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS EntertainmentComplaintRate,
    COUNT(CASE WHEN ValueForMoney <= 2 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS ValueComplaintRate
FROM airlines_reviews
WHERE Airline = 'Singapore Airlines'
GROUP BY Period, TypeofTraveller;






-- Average Ratings and Rating Components
SELECT 
    CASE 
        WHEN ReviewDate < '2020-03-01' THEN 'Pre-COVID'
        ELSE 'Post-COVID'
    END AS Period,
    AVG(SeatComfort) AS Avg_SeatComfort,
    AVG(StaffService) AS Avg_StaffService,
    AVG(FoodnBeverages) AS Avg_FoodnBeverages,
    AVG(InflightEntertainment) AS Avg_InflightEntertainment,
    AVG(ValueForMoney) AS Avg_ValueForMoney,
    AVG(OverallRating) AS Avg_OverallRating
FROM airlines_reviews
WHERE Airline = 'Singapore Airlines'
GROUP BY Period;





-- When Overall rating <= 3, considered as Overall complaints (Verified vs Non-Verified)
SELECT 
    CASE 
        WHEN ReviewDate < '2020-03-01' THEN 'Pre-COVID'
        ELSE 'Post-COVID'
    END AS Period,
    Verified,
    COUNT(*) AS TotalReviews,
    AVG(OverallRating) AS AvgOverallRating,
    COUNT(CASE WHEN OverallRating <= 3 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS ComplaintRate
FROM airlines_reviews
WHERE Airline = 'Singapore Airlines'
GROUP BY Period, Verified;






-- Analyse Changes in Ratings and Number of Reviews Pre and Post COVID Across Months --> Data exported for visualization
SELECT 
    MonthFlown, 
    CASE 
        WHEN ReviewDate < '2020-03-01' THEN 'Pre-COVID' 
        ELSE 'Post-COVID' 
    END AS Period, 
    COUNT(*) AS TotalReviews, 
    AVG(OverallRating) AS AvgOverallRating, 
    COUNT(CASE WHEN OverallRating <= 3 THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS ComplaintRate
FROM airlines_reviews
WHERE Airline = 'Singapore Airlines'
  AND YEAR(STR_TO_DATE(ReviewDate, '%d/%m/%Y')) BETWEEN 2018 AND 2024  -- Filters reviews between 2018 and 2024
GROUP BY MonthFlown, Period
ORDER BY FIELD(MonthFlown, 
    'Jan-18', 'Feb-18', 'Mar-18', 'Apr-18', 'May-18', 'Jun-18', 'Jul-18', 'Aug-18', 'Sep-18', 'Oct-18', 'Nov-18', 'Dec-18',
    'Jan-19', 'Feb-19', 'Mar-19', 'Apr-19', 'May-19', 'Jun-19', 'Jul-19', 'Aug-19', 'Sep-19', 'Oct-19', 'Nov-19', 'Dec-19',
    'Jan-20', 'Feb-20', 'Mar-20', 'Apr-20', 'May-20', 'Jun-20', 'Jul-20', 'Aug-20', 'Sep-20', 'Oct-20', 'Nov-20', 'Dec-20',
    'Jan-21', 'Feb-21', 'Mar-21', 'Apr-21', 'May-21', 'Jun-21', 'Jul-21', 'Aug-21', 'Sep-21', 'Oct-21', 'Nov-21', 'Dec-21',
    'Jan-22', 'Feb-22', 'Mar-22', 'Apr-22', 'May-22', 'Jun-22', 'Jul-22', 'Aug-22', 'Sep-22', 'Oct-22', 'Nov-22', 'Dec-22',
    'Jan-23', 'Feb-23', 'Mar-23', 'Apr-23', 'May-23', 'Jun-23', 'Jul-23', 'Aug-23', 'Sep-23', 'Oct-23', 'Nov-23', 'Dec-23',
    'Jan-24', 'Feb-24', 'Mar-24', 'Apr-24', 'May-24', 'Jun-24', 'Jul-24', 'Aug-24', 'Sep-24', 'Oct-24', 'Nov-24', 'Dec-24');





-- Recommended percentage group by period
SELECT 
    CASE 
        WHEN ReviewDate < '2020-03-01' THEN 'Pre-COVID'
        ELSE 'Post-COVID'
    END AS Period,
    COUNT(CASE WHEN Recommended = 'yes' THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS PercentageRecommended
FROM airlines_reviews
WHERE Airline = 'Singapore Airlines'
GROUP BY Period;




-- Recommended percentage group by period among different types of travellers
SELECT 
    CASE 
        WHEN ReviewDate < '2020-03-01' THEN 'Pre-COVID'
        ELSE 'Post-COVID'
    END AS Period,
    TypeofTraveller,
    COUNT(CASE WHEN Recommended = 'yes' THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS RecommendationRate
FROM airlines_reviews
WHERE Airline = 'Singapore Airlines'
GROUP BY Period, TypeofTraveller;







-- Q10
--Find the problems passnegers face during exceptional circumstances
-- New column to denote whether the reviews are due to exceptional circumstances -- use associated words with exceptional circumstances
ALTER TABLE cleaned_reviews ADD COLUMN exceptional BOOLEAN DEFAULT FALSE;

UPDATE cleaned_reviews
SET exceptional = TRUE
WHERE MATCH(Reviews) AGAINST('late weather condition prevent disaster strikes security restrictions delay miss defects typhoon wind turbulence control unrest' IN NATURAL LANGUAGE MODE)
  AND Airline = 'Singapore Airlines'
  AND complaints = 'yes';

-- Extract top 100 words for reviews which talked about Exceptional Circumstances

WITH FilteredReviews AS (
  SELECT Title
  FROM cleaned_reviews
  WHERE exceptional = TRUE
    AND Airline = 'Singapore Airlines'
    AND complaints = 'yes'
),
Words AS (
  SELECT
    LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(Title, ' ', n), ' ', -1)) AS word
  FROM FilteredReviews
  JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10 -- Adjust for max number of words per title
  ) numbers
  ON CHAR_LENGTH(Title) - CHAR_LENGTH(REPLACE(Title, ' ', '')) + 1 >= n
),
FilteredWords AS (
  SELECT word
  FROM Words
  WHERE word NOT IN ('down', 'as', 'too', 'felt', 'up', 'their', 'them', 'than',
                     'they', 'have', 'are', 'us', 'by', 'that', 'this', 'it', 
                     'not', 'very', 'no', 'me', 'at', 'has', 'an', 'the', 'is', 
                     'and', 'in', 'to', 'a', 'of', 'with', 'was', 'i', '', 'on', 
                     'for', 'my', 'were', 'we')
),
WordCounts AS (
  SELECT
    word AS _id,
    COUNT(*) AS count
  FROM FilteredWords
  GROUP BY word
)
SELECT _id, count
FROM WordCounts
ORDER BY count DESC
LIMIT 100;

-- Through this, we saw a significant number complaining about service, compensation and delays
-- Counting the number of negative reviews on each respective issue

-- Compensation
SELECT COUNT(*) AS count
FROM cleaned_reviews
WHERE complaints = 'yes' AND exceptional  = TRUE
  AND MATCH(Reviews) AGAINST('compensation refund remunerate pay' IN NATURAL LANGUAGE MODE);

-- Communication
SELECT COUNT(*) AS count
FROM cleaned_reviews
WHERE complaints = 'yes' AND exceptional  = TRUE
  AND MATCH(Reviews) AGAINST('communication information customer' IN NATURAL LANGUAGE MODE);

-- Delay
SELECT COUNT(*) AS count
FROM cleaned_reviews
WHERE complaints = 'yes' AND exceptional  = TRUE
  AND MATCH(Reviews) AGAINST('late delay' IN NATURAL LANGUAGE MODE);


-- clean data
set SQL_SAFE_UPDATES = 0; -- Disable safe update mode
DELETE FROM customer_support_with_tone WHERE category NOT IN ('CONTACT', 'CANCEL', 'FEEDBACK', 'INVOICE', 'ORDER', 'PAYMENT', 'REFUND', 'SHIPPING');
set SQL_SAFE_UPDATES = 1; -- Enable safe update mode

-- counting number of row in customer_support_with_tone
SELECT count(*) FROM customer_support_with_tone;

-- Percentage of Each Instruction Tone
select tone_instruction as instruction_tone, count(*)/9074*100 as percentage from customer_support_with_tone group by tone_instruction order by percentage desc;

-- Percentage of Each Response Tone
select tone as response_tone, count(*)/9074*100 as percentage from customer_support_with_tone group by tone order by percentage desc;

-- Responses that has fear tone
select response from customer_support_with_tone where tone = 'fear' or 'sadness'; 

-- Number of Instruction tone and Respond tone
select tone_instruction as instruction_tone ,tone as response_tone,count(*) as cnt from customer_support_with_tone where tone_instruction in ('anger','neutral','sadness','surprise')
group by tone,tone_instruction order by  tone_instruction, cnt desc;

-- Response tone that has complaint intent
select intent,tone as response_tone,count(*) as cnt from customer_support_with_tone where category = 'FEEDBACK' 
group by intent,tone order by intent, cnt desc;
