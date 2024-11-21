-- Source CSV Data File: https://data.gov.sg/datasets?query=singapore+airlines&page=1&resultId=d_a430153d90c8c0ad964fa822bd1d6b2b

-- In this script is the database implementation / deployment procedure for "Singapore Airlines Monthly Aircraft and Passenger Movement"

-- Refers to Changi Airport only. Data covers scheduled passenger flight services from Changi Airport only.
-- Other aircraft service types like non-scheduled and scheduled cargo are excluded.
-- Local Airline refers to Singapore International Airlines (SQ), Silk Air (MI), Jetstar Asia (3K) and Scoot (TR). Foreign Airline refers to the airlines that are not included in 'Local Airline'.

-- Create Database
CREATE DATABASE ChangiAirport;
USE ChangiAirport;


-- Create Table
CREATE TABLE ScheduledAircraftAndTransitPassengers (
    DataSeries VARCHAR(255),
    Aug2024 INT,
    Jul2024 INT,
    Jun2024 INT,
    May2024 INT,
    Apr2024 INT,
    Mar2024 INT,
    Feb2024 INT,
    Jan2024 INT,
    Dec2023 INT,
    Nov2023 INT,
    Oct2023 INT,
    Sep2023 INT,
    Aug2023 INT,
    Jul2023 INT,
    Jun2023 INT,
    May2023 INT,
    Apr2023 INT,
    Mar2023 INT,
    Feb2023 INT,
    Jan2023 INT,
    Dec2022 INT,
    Nov2022 INT,
    Oct2022 INT,
    Sep2022 INT,
    Aug2022 INT,
    Jul2022 INT,
    Jun2022 INT,
    May2022 INT,
    Apr2022 INT,
    Mar2022 INT,
    Feb2022 INT,
    Jan2022 INT,
    Dec2021 INT,
    Nov2021 INT,
    Oct2021 INT,
    Sep2021 INT,
    Aug2021 INT,
    Jul2021 INT,
    Jun2021 INT,
    May2021 INT,
    Apr2021 INT,
    Mar2021 INT,
    Feb2021 INT,
    Jan2021 INT,
    Dec2020 INT,
    Nov2020 INT,
    Oct2020 INT,
    Sep2020 INT,
    Aug2020 INT,
    Jul2020 INT,
    Jun2020 INT,
    May2020 INT,
    Apr2020 INT,
    Mar2020 INT,
    Feb2020 INT,
    Jan2020 INT,
    Dec2019 INT,
    Nov2019 INT,
    Oct2019 INT,
    Sep2019 INT,
    Aug2019 INT,
    Jul2019 INT,
    Jun2019 INT,
    May2019 INT,
    Apr2019 INT,
    Mar2019 INT,
    Feb2019 INT,
    Jan2019 INT,
    Dec2018 INT,
    Nov2018 INT,
    Oct2018 INT,
    Sep2018 INT,
    Aug2018 INT,
    Jul2018 INT,
    Jun2018 INT,
    May2018 INT,
    Apr2018 INT,
    Mar2018 INT,
    Feb2018 INT,
    Jan2018 INT,
    Dec2017 INT,
    Nov2017 INT,
    Oct2017 INT,
    Sep2017 INT,
    Aug2017 INT,
    Jul2017 INT,
    Jun2017 INT,
    May2017 INT,
    Apr2017 INT,
    Mar2017 INT,
    Feb2017 INT,
    Jan2017 INT,
    Dec2016 INT,
    Nov2016 INT,
    Oct2016 INT,
    Sep2016 INT,
    Aug2016 INT,
    Jul2016 INT,
    Jun2016 INT,
    May2016 INT,
    Apr2016 INT,
    Mar2016 INT,
    Feb2016 INT,
    Jan2016 INT,
    Dec2015 INT,
    Nov2015 INT,
    Oct2015 INT,
    Sep2015 INT,
    Aug2015 INT,
    Jul2015 INT,
    Jun2015 INT,
    May2015 INT,
    Apr2015 INT,
    Mar2015 INT,
    Feb2015 INT,
    Jan2015 INT,
    Dec2014 INT,
    Nov2014 INT,
    Oct2014 INT,
    Sep2014 INT,
    Aug2014 INT,
    Jul2014 INT,
    Jun2014 INT,
    May2014 INT,
    Apr2014 INT,
    Mar2014 INT,
    Feb2014 INT,
    Jan2014 INT,
    Dec2013 INT,
    Nov2013 INT,
    Oct2013 INT,
    Sep2013 INT,
    Aug2013 INT,
    Jul2013 INT,
    Jun2013 INT,
    May2013 INT,
    Apr2013 INT,
    Mar2013 INT,
    Feb2013 INT,
    Jan2013 INT,
    Dec2012 INT,
    Nov2012 INT,
    Oct2012 INT,
    Sep2012 INT,
    Aug2012 INT,
    Jul2012 INT,
    Jun2012 INT,
    May2012 INT,
    Apr2012 INT,
    Mar2012 INT,
    Feb2012 INT,
    Jan2012 INT,
    Dec2011 INT,
    Nov2011 INT,
    Oct2011 INT,
    Sep2011 INT,
    Aug2011 INT,
    Jul2011 INT,
    Jun2011 INT,
    May2011 INT,
    Apr2011 INT,
    Mar2011 INT,
    Feb2011 INT,
    Jan2011 INT,
    Dec2010 INT,
    Nov2010 INT,
    Oct2010 INT,
    Sep2010 INT,
    Aug2010 INT,
    Jul2010 INT,
    Jun2010 INT,
    May2010 INT,
    Apr2010 INT,
    Mar2010 INT,
    Feb2010 INT,
    Jan2010 INT
);



-- Show where to place CSV data file
SHOW VARIABLES LIKE 'secure_file_priv';



-- Load CSV Data Into Table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ScheduledAircraftAndTransitPassengersMonthly.csv'
INTO TABLE ScheduledAircraftAndTransitPassengers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;  -- This ignores the header row


SELECT * FROM ScheduledAircraftAndTransitPassengers;



-- Analysis for foreign airline transit passengers
SELECT 
    SUBSTRING(DataSeries, 1, 50) AS Category,
    SUM(Jan2018 + Feb2018 + Mar2018 + Apr2018 + May2018 + Jun2018 + Jul2018 + Aug2018 + Sep2018 + Oct2018 + Nov2018 + Dec2018) AS Total_2018,
    SUM(Jan2019 + Feb2019 + Mar2019 + Apr2019 + May2019 + Jun2019 + Jul2019 + Aug2019 + Sep2019 + Oct2019 + Nov2019 + Dec2019) AS Total_2019,
    SUM(Jan2020 + Feb2020 + Mar2020 + Apr2020 + May2020 + Jun2020 + Jul2020 + Aug2020 + Sep2020 + Oct2020 + Nov2020 + Dec2020) AS Total_2020,
    SUM(Jan2021 + Feb2021 + Mar2021 + Apr2021 + May2021 + Jun2021 + Jul2021 + Aug2021 + Sep2021 + Oct2021 + Nov2021 + Dec2021) AS Total_2021,
    SUM(Jan2022 + Feb2022 + Mar2022 + Apr2022 + May2022 + Jun2022 + Jul2022 + Aug2022 + Sep2022 + Oct2022 + Nov2022 + Dec2022) AS Total_2022
FROM 
    ScheduledAircraftAndTransitPassengers
WHERE 
    DataSeries = 'Foreign Airline - Transit Passengers'
GROUP BY 
	Category;




-- Analysis for foreign airline aircraft arrivals
SELECT 
    SUBSTRING(DataSeries, 1, 50) AS Category,
    SUM(Jan2018 + Feb2018 + Mar2018 + Apr2018 + May2018 + Jun2018 + Jul2018 + Aug2018 + Sep2018 + Oct2018 + Nov2018 + Dec2018) AS Total_2018,
    SUM(Jan2019 + Feb2019 + Mar2019 + Apr2019 + May2019 + Jun2019 + Jul2019 + Aug2019 + Sep2019 + Oct2019 + Nov2019 + Dec2019) AS Total_2019,
    SUM(Jan2020 + Feb2020 + Mar2020 + Apr2020 + May2020 + Jun2020 + Jul2020 + Aug2020 + Sep2020 + Oct2020 + Nov2020 + Dec2020) AS Total_2020,
    SUM(Jan2021 + Feb2021 + Mar2021 + Apr2021 + May2021 + Jun2021 + Jul2021 + Aug2021 + Sep2021 + Oct2021 + Nov2021 + Dec2021) AS Total_2021,
    SUM(Jan2022 + Feb2022 + Mar2022 + Apr2022 + May2022 + Jun2022 + Jul2022 + Aug2022 + Sep2022 + Oct2022 + Nov2022 + Dec2022) AS Total_2022
FROM 
    ScheduledAircraftAndTransitPassengers
WHERE 
    DataSeries = 'Foreign Airline - Aircraft Arrivals'
GROUP BY 
    Category;




-- Analysis for foreign airline aircraft departures
SELECT 
    SUBSTRING(DataSeries, 1, 50) AS Category,
    SUM(Jan2018 + Feb2018 + Mar2018 + Apr2018 + May2018 + Jun2018 + Jul2018 + Aug2018 + Sep2018 + Oct2018 + Nov2018 + Dec2018) AS Total_2018,
    SUM(Jan2019 + Feb2019 + Mar2019 + Apr2019 + May2019 + Jun2019 + Jul2019 + Aug2019 + Sep2019 + Oct2019 + Nov2019 + Dec2019) AS Total_2019,
    SUM(Jan2020 + Feb2020 + Mar2020 + Apr2020 + May2020 + Jun2020 + Jul2020 + Aug2020 + Sep2020 + Oct2020 + Nov2020 + Dec2020) AS Total_2020,
    SUM(Jan2021 + Feb2021 + Mar2021 + Apr2021 + May2021 + Jun2021 + Jul2021 + Aug2021 + Sep2021 + Oct2021 + Nov2021 + Dec2021) AS Total_2021,
    SUM(Jan2022 + Feb2022 + Mar2022 + Apr2022 + May2022 + Jun2022 + Jul2022 + Aug2022 + Sep2022 + Oct2022 + Nov2022 + Dec2022) AS Total_2022
FROM 
    ScheduledAircraftAndTransitPassengers
WHERE 
    DataSeries = 'Foreign Airline - Aircraft Departures'
GROUP BY 
    Category;
    
    
    
-- Analysis for local airline transit passengers
SELECT 
    SUBSTRING(DataSeries, 1, 50) AS Category,
    SUM(Jan2018 + Feb2018 + Mar2018 + Apr2018 + May2018 + Jun2018 + Jul2018 + Aug2018 + Sep2018 + Oct2018 + Nov2018 + Dec2018) AS Total_2018,
    SUM(Jan2019 + Feb2019 + Mar2019 + Apr2019 + May2019 + Jun2019 + Jul2019 + Aug2019 + Sep2019 + Oct2019 + Nov2019 + Dec2019) AS Total_2019,
    SUM(Jan2020 + Feb2020 + Mar2020 + Apr2020 + May2020 + Jun2020 + Jul2020 + Aug2020 + Sep2020 + Oct2020 + Nov2020 + Dec2020) AS Total_2020,
    SUM(Jan2021 + Feb2021 + Mar2021 + Apr2021 + May2021 + Jun2021 + Jul2021 + Aug2021 + Sep2021 + Oct2021 + Nov2021 + Dec2021) AS Total_2021,
    SUM(Jan2022 + Feb2022 + Mar2022 + Apr2022 + May2022 + Jun2022 + Jul2022 + Aug2022 + Sep2022 + Oct2022 + Nov2022 + Dec2022) AS Total_2022
FROM 
    ScheduledAircraftAndTransitPassengers
WHERE 
    DataSeries = 'Local Airline - Transit Passengers'
GROUP BY 
    Category;
    


-- Analysis for local airline aircraft arrivals
SELECT 
    SUBSTRING(DataSeries, 1, 50) AS Category,
    SUM(Jan2018 + Feb2018 + Mar2018 + Apr2018 + May2018 + Jun2018 + Jul2018 + Aug2018 + Sep2018 + Oct2018 + Nov2018 + Dec2018) AS Total_2018,
    SUM(Jan2019 + Feb2019 + Mar2019 + Apr2019 + May2019 + Jun2019 + Jul2019 + Aug2019 + Sep2019 + Oct2019 + Nov2019 + Dec2019) AS Total_2019,
    SUM(Jan2020 + Feb2020 + Mar2020 + Apr2020 + May2020 + Jun2020 + Jul2020 + Aug2020 + Sep2020 + Oct2020 + Nov2020 + Dec2020) AS Total_2020,
    SUM(Jan2021 + Feb2021 + Mar2021 + Apr2021 + May2021 + Jun2021 + Jul2021 + Aug2021 + Sep2021 + Oct2021 + Nov2021 + Dec2021) AS Total_2021,
    SUM(Jan2022 + Feb2022 + Mar2022 + Apr2022 + May2022 + Jun2022 + Jul2022 + Aug2022 + Sep2022 + Oct2022 + Nov2022 + Dec2022) AS Total_2022
FROM 
    ScheduledAircraftAndTransitPassengers
WHERE 
    DataSeries = 'Local Airline - Aircraft Arrivals'
GROUP BY 
    Category;
    
    

-- Analysis for local airline aircraft departures
SELECT 
    SUBSTRING(DataSeries, 1, 50) AS Category,
    SUM(Jan2018 + Feb2018 + Mar2018 + Apr2018 + May2018 + Jun2018 + Jul2018 + Aug2018 + Sep2018 + Oct2018 + Nov2018 + Dec2018) AS Total_2018,
    SUM(Jan2019 + Feb2019 + Mar2019 + Apr2019 + May2019 + Jun2019 + Jul2019 + Aug2019 + Sep2019 + Oct2019 + Nov2019 + Dec2019) AS Total_2019,
    SUM(Jan2020 + Feb2020 + Mar2020 + Apr2020 + May2020 + Jun2020 + Jul2020 + Aug2020 + Sep2020 + Oct2020 + Nov2020 + Dec2020) AS Total_2020,
    SUM(Jan2021 + Feb2021 + Mar2021 + Apr2021 + May2021 + Jun2021 + Jul2021 + Aug2021 + Sep2021 + Oct2021 + Nov2021 + Dec2021) AS Total_2021,
    SUM(Jan2022 + Feb2022 + Mar2022 + Apr2022 + May2022 + Jun2022 + Jul2022 + Aug2022 + Sep2022 + Oct2022 + Nov2022 + Dec2022) AS Total_2022
FROM 
    ScheduledAircraftAndTransitPassengers
WHERE 
    DataSeries = 'Local Airline - Aircraft Departures'
GROUP BY 
    Category;
    


