-- Find the top 5 months with the highest number of flights available
SELECT MONTH(date_of_journey), COUNT(*) 
FROM flights
GROUP BY MONTH(date_of_journey) 
ORDER BY COUNT(*) DESC 
LIMIT 5;

-- Determine which day of the week has the highest average flight price
SELECT DAYNAME(date_of_journey), AVG(price) 
FROM flights
GROUP BY DAYNAME(date_of_journey)
ORDER BY AVG(price) DESC 
LIMIT 1;

-- Count the number of Indigo flights per month
SELECT MONTHNAME(date_of_journey), COUNT(*) 
FROM flights 
WHERE airline = 'Indigo'
GROUP BY MONTHNAME(date_of_journey)
ORDER BY COUNT(*) DESC;

-- List all flights departing between 10:00 AM and 2:00 PM between Bangalore and Delhi
SELECT * 
FROM flights
WHERE source = 'Bangalore' AND destination = 'Delhi' 
AND dep_time BETWEEN '10:00:00' AND '14:00:00';

-- Count the number of flights departing on weekends from Bangalore
SELECT COUNT(*) 
FROM flights 
WHERE source = 'Bangalore' AND DAYNAME(date_of_journey) IN ('Saturday', 'Sunday');

-- Calculate the arrival time by adding the duration to the departure time
ALTER TABLE flights ADD COLUMN departure DATETIME;
UPDATE flights SET departure = STR_TO_DATE(CONCAT(date_of_journey, ' ', dep_time), '%Y-%m-%d %H:%i');

ALTER TABLE flights 
ADD COLUMN duration_mins INTEGER,
ADD COLUMN arrival DATETIME;

UPDATE flights 
SET duration_mins = 
  CASE
    WHEN duration NOT LIKE '%m%' THEN REPLACE(duration, 'h', '') * 60
    WHEN duration LIKE '%m%' AND duration LIKE '%h%' THEN 
      REPLACE(SUBSTRING_INDEX(duration, ' ', 1), 'h', '') * 60 + REPLACE(SUBSTRING_INDEX(duration, ' ', -1), 'm', '')
    ELSE duration
  END;

UPDATE flights 
SET arrival = DATE_ADD(departure, INTERVAL duration_mins MINUTE);

SELECT TIME(arrival) FROM flights;

-- Calculate the arrival date for all flights
SELECT DATE(arrival) FROM flights;

-- Count the number of flights traveling on multiple dates
SELECT COUNT(*) 
FROM flights 
WHERE DATE(date_of_journey) <> DATE(arrival);

-- Calculate the average flight duration between all city pairs
SELECT source, destination, TIME_FORMAT(SEC_TO_TIME((AVG(duration)) * 60), '%Hh %im') 
FROM flights
GROUP BY source, destination;

-- Find the number of flights per quarter for each airline
SELECT airline, QUARTER(departure), COUNT(*) 
FROM flights
GROUP BY airline, QUARTER(departure);

-- Average flight duration for flights with no stops vs. flights with stops
WITH df AS (
  SELECT *,
    CASE
      WHEN total_stops = 'non-stop' THEN 'non-stop'
      ELSE 'with-stops'
    END AS temp
  FROM flights
)
SELECT temp, COUNT(*) AS number_of_flights, AVG(duration) AS average_duration 
FROM df 
GROUP BY temp;

-- List all Air India flights originating from Delhi between March 15 and March 21, 2019
SELECT * 
FROM flights
WHERE source = 'Delhi'
AND DATE(departure) BETWEEN '2019-03-15' AND '2019-03-21';

-- Find the longest flight duration for each airline
SELECT airline, MAX(duration_mins) 
FROM flights 
GROUP BY airline
ORDER BY MAX(duration_mins) DESC;

-- Create a weekday vs. time grid showing flight frequency between Bangalore and Delhi
SELECT DAYNAME(departure),
  SUM(CASE WHEN TIME(departure) BETWEEN '00:00:00' AND '06:00:00' THEN 1 ELSE 0 END) AS '0-6',
  SUM(CASE WHEN TIME(departure) BETWEEN '06:00:00' AND '12:00:00' THEN 1 ELSE 0 END) AS '6-12',
  SUM(CASE WHEN TIME(departure) BETWEEN '12:00:00' AND '18:00:00' THEN 1 ELSE 0 END) AS '12-18',
  SUM(CASE WHEN TIME(departure) BETWEEN '18:00:00' AND '24:00:00' THEN 1 ELSE 0 END) AS '18-24'
FROM flights
WHERE source = 'Bangalore' AND destination = 'Delhi'
GROUP BY DAYOFWEEK(departure);

-- Create a weekday vs. time grid showing the average flight price between Bangalore and Delhi
SELECT DAYNAME(departure),
  SUM(CASE WHEN TIME(departure) BETWEEN '00:00:00' AND '06:00:00' THEN price ELSE 0 END) / SUM(CASE WHEN TIME(departure) BETWEEN '00:00:00' AND '06:00:00' THEN 1 ELSE 0 END) AS '0-6',
  SUM(CASE WHEN TIME(departure) BETWEEN '06:00:00' AND '12:00:00' THEN price ELSE 0 END) / SUM(CASE WHEN TIME(departure) BETWEEN '06:00:00' AND '12:00:00' THEN 1 ELSE 0 END) AS '6-12',
  SUM(CASE WHEN TIME(departure) BETWEEN '12:00:00' AND '18:00:00' THEN price ELSE 0 END) / SUM(CASE WHEN TIME(departure) BETWEEN '12:00:00' AND '18:00:00' THEN 1 ELSE 0 END) AS '12-18',
  SUM(CASE WHEN TIME(departure) BETWEEN '18:00:00' AND '24:00:00' THEN price ELSE 0 END) / SUM(CASE WHEN TIME(departure) BETWEEN '18:00:00' AND '24:00:00' THEN 1 ELSE 0 END) AS '18-24'
FROM flights
WHERE source = 'Bangalore' AND destination = 'Delhi'
GROUP BY DAYOFWEEK(departure);
