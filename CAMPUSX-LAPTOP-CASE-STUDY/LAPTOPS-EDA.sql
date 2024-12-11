--                                             EXPLORATORY DATA ANALYSIS

-- Fetching the first 5 rows
SELECT * FROM laptops LIMIT 5;

-- Fetching the last 5 rows
SELECT * FROM laptops ORDER BY id DESC LIMIT 5;

-- Fetching 5 random rows
SELECT * FROM laptops ORDER BY RAND() LIMIT 5;

--                                           UNIVARIATE ANALYSIS

-- Summary statistics for 'price'
SELECT 
    COUNT(*) OVER() AS counts,
    MAX(price) OVER() AS max,
    MIN(price) OVER() AS min,
    STD(price) OVER() AS std,
    PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY price) OVER() AS Q1,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY price) OVER() AS Q2,
    PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY price) OVER() AS Q3
FROM laptops 
WHERE price IS NOT NULL LIMIT 1;

-- Counting missing values in 'price'
SELECT COUNT(*) AS missing_count FROM laptops WHERE price IS NULL;

-- Dropping rows with all NULL values
DELETE FROM laptops WHERE id IS NULL;

-- Identifying outliers in 'price'
SELECT * FROM (
    SELECT *,
           PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY price) OVER() AS q3,
           PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY price) OVER() AS q1
    FROM laptops
) t
WHERE price < q1 - (1.5 * (q3 - q1)) OR price > q3 + (1.5 * (q3 - q1));

-- Generating a histogram for 'price' buckets
SELECT buckets, REPEAT('-', COUNT(*) / 10) AS histogram FROM (
    SELECT price,
           CASE
               WHEN price BETWEEN 0 AND 25000 THEN '0-25k'
               WHEN price BETWEEN 25001 AND 50000 THEN '25-50k'
               WHEN price BETWEEN 50001 AND 75000 THEN '50-75k'
               WHEN price BETWEEN 75001 AND 100000 THEN '75-100k'
               ELSE '100k+'
           END AS buckets
    FROM laptops
) z
GROUP BY buckets;

-- Companies with the highest occurrences
SELECT company, COUNT(*) AS count
FROM laptops
GROUP BY company
ORDER BY count DESC;

--                                           ANALYSIS ON 'INCHES' COLUMN

-- Replacing invalid 'inches' values with NULL
UPDATE laptops SET inches = NULL WHERE inches = '?';

-- Modifying 'inches' column to decimal type
ALTER TABLE laptops MODIFY COLUMN inches DECIMAL(10,3);

-- Summary statistics for 'inches'
SELECT 
    COUNT(inches) OVER() AS counts,
    MAX(inches) OVER() AS max,
    MIN(inches) OVER() AS min,
    STD(inches) OVER() AS std,
    PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY inches) OVER() AS Q1,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY inches) OVER() AS Q2,
    PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY inches) OVER() AS Q3
FROM laptops 
WHERE inches IS NOT NULL LIMIT 1;

-- Identifying outliers in 'inches'
SELECT * FROM (
    SELECT *,
           PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY inches) OVER() AS q3,
           PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY inches) OVER() AS q1
    FROM laptops
) t
WHERE inches < q1 - (1.5 * (q3 - q1)) OR inches > q3 + (1.5 * (q3 - q1));

-- Operating systems arranged by frequency
SELECT opsys, COUNT(*) AS frequency
FROM laptops
GROUP BY opsys
ORDER BY frequency DESC;

--                                     BIVARIATE ANALYSIS

-- Touchscreen distribution by company
SELECT company,
       SUM(CASE WHEN touchscreen = 1 THEN 1 ELSE 0 END) AS touchscreen_yes,
       SUM(CASE WHEN touchscreen = 0 THEN 1 ELSE 0 END) AS touchscreen_no
FROM laptops
GROUP BY company;

-- HD presence by company
SELECT company,
       SUM(CASE WHEN HD = 1 THEN 1 ELSE 0 END) AS HD_YES,
       SUM(CASE WHEN HD = 0 THEN 1 ELSE 0 END) AS HD_NO
FROM laptops
GROUP BY company;

-- IPS panel distribution by company
SELECT company,
       SUM(CASE WHEN IPS = 1 THEN 1 ELSE 0 END) AS IPS_YES,
       SUM(CASE WHEN IPS = 0 THEN 1 ELSE 0 END) AS IPS_NO
FROM laptops
GROUP BY company;

-- CPU brand distribution by company
SELECT company,
       SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS Intel,
       SUM(CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END) AS AMD,
       SUM(CASE WHEN cpu_brand = 'Samsung' THEN 1 ELSE 0 END) AS Samsung
FROM laptops
GROUP BY company;

-- Primary storage distribution by company
SELECT company,
       SUM(CASE WHEN primary_storage = 128 THEN 1 ELSE 0 END) AS storage_128GB,
       SUM(CASE WHEN primary_storage = 256 THEN 1 ELSE 0 END) AS storage_256GB,
       SUM(CASE WHEN primary_storage = 512 THEN 1 ELSE 0 END) AS storage_512GB,
       SUM(CASE WHEN primary_storage = 1024 THEN 1 ELSE 0 END) AS storage_1TB
FROM laptops
GROUP BY company;

-- Memory type distribution by company
SELECT company,
       SUM(CASE WHEN memory_type = 'SSD' THEN 1 ELSE 0 END) AS SSD,
       SUM(CASE WHEN memory_type = 'HDD' THEN 1 ELSE 0 END) AS HDD,
       SUM(CASE WHEN memory_type = 'Flash storage' THEN 1 ELSE 0 END) AS flash_storage
FROM laptops
GROUP BY company;

-- GPU brand distribution by company
SELECT company,
       SUM(CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END) AS Intel,
       SUM(CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END) AS AMD,
       SUM(CASE WHEN gpu_brand = 'ARM' THEN 1 ELSE 0 END) AS ARM,
       SUM(CASE WHEN gpu_brand = 'Nvidia' THEN 1 ELSE 0 END) AS Nvidia
FROM laptops
GROUP BY company;

-- Summary statistics for 'cpu_speed'
SELECT 
    COUNT(cpu_speed) OVER() AS counts,
    MAX(cpu_speed) OVER() AS max,
    MIN(cpu_speed) OVER() AS min,
    STD(cpu_speed) OVER() AS std,
    PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY cpu_speed) OVER() AS Q1,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY cpu_speed) OVER() AS Q2,
    PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY cpu_speed) OVER() AS Q3
FROM laptops 
WHERE cpu_speed IS NOT NULL LIMIT 1;

-- Identifying outliers in 'cpu_speed'
SELECT * FROM (
    SELECT *,
           PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY cpu_speed) OVER() AS q3,
           PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY cpu_speed) OVER() AS q1
    FROM laptops
) t
WHERE cpu_speed < q1 - (1.5 * (q3 - q1)) OR cpu_speed > q3 + (1.5 * (q3 - q1));

-- Typename distribution by company
SELECT company,
       SUM(CASE WHEN typename = 'Ultrabook' THEN 1 ELSE 0 END) AS Ultrabook,
       SUM(CASE WHEN typename = 'Notebook' THEN 1 ELSE 0 END) AS Notebook,
       SUM(CASE WHEN typename = 'Gaming' THEN 1 ELSE 0 END) AS Gaming,
       SUM(CASE WHEN typename = 'Workstation' THEN 1 ELSE 0 END) AS Workstation,
       SUM(CASE WHEN typename = '2 in 1 Convertible' THEN 1 ELSE 0 END) AS Convertible
FROM laptops
GROUP BY company;

--                                         NUMERICAL TO CATEGORICAL BIVARIATE ANALYSIS

-- CPU speed by company
SELECT DISTINCT(company),
       MAX(cpu_speed) OVER(PARTITION BY company) AS max,
       MIN(cpu_speed) OVER(PARTITION BY company) AS min,
       STD(cpu_speed) OVER(PARTITION BY company) AS std,
       PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY cpu_speed) OVER(PARTITION BY company) AS Q1,
       PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY cpu_speed) OVER(PARTITION BY company) AS Q2,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY cpu_speed) OVER(PARTITION BY company) AS Q3
FROM laptops 
WHERE cpu_speed IS NOT NULL;

-- Price by company
SELECT DISTINCT(company),
       MAX(price) OVER(PARTITION BY company) AS max,
       MIN(price) OVER(PARTITION BY company) AS min,
       STD(price) OVER(PARTITION BY company) AS std,
       PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY price) OVER(PARTITION BY company) AS Q1,
       PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY price) OVER(PARTITION BY company) AS Q2,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY price) OVER(PARTITION BY company) AS Q3
FROM laptops 
WHERE price IS NOT NULL;

-- CREATING NEW FEATURES

-- Adding a column for PPI
ALTER TABLE laptops ADD COLUMN ppi INTEGER AFTER resolution_height;

UPDATE laptops 
SET ppi = ROUND(SQRT(POW(resolution_width, 2) + POW(resolution_height, 2)) / inches);

-- Adding a new column named 'screen_size' to categorize screen sizes based on inches
alter table laptops add column screen_size varchar(244) after inches;

-- Updating the 'screen_size' column with bucket values based on screen size
update laptops 
set screen_size = 
case 
    when inches < 14 then 'small'        -- If screen size is less than 14 inches, categorize as 'small'
    when inches < 20 then 'medium'      -- If screen size is between 14 and 20 inches, categorize as 'medium'
    else 'large'                        -- If screen size is 20 inches or more, categorize as 'large'
end;

-- Adding new columns for one-hot encoding the 'cpu_brand' column
alter table laptops add column intel_cpu integer;   -- Column to indicate if the CPU brand is Intel
alter table laptops add column AMD_cpu integer;     -- Column to indicate if the CPU brand is AMD
alter table laptops add column Samsung_cpu integer; -- Column to indicate if the CPU brand is Samsung

-- Updating the one-hot encoding columns based on the 'cpu_brand' column values
update laptops set intel_cpu = case when cpu_brand = 'Intel' then 1 else 0 end;   -- Set '1' if CPU brand is Intel, otherwise '0'
update laptops set AMD_cpu = case when cpu_brand = 'AMD' then 1 else 0 end;       -- Set '1' if CPU brand is AMD, otherwise '0'
update laptops set Samsung_cpu = case when cpu_brand = 'Samsung' then 1 else 0 end; -- Set '1' if CPU brand is Samsung, otherwise '0'

-- Dropping the original 'cpu_brand' column as it has been encoded into one-hot columns
alter table laptops drop column cpu_brand;
