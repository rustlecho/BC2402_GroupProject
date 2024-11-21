-- You may add the code for Q8, Q9, Q10 here




















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




