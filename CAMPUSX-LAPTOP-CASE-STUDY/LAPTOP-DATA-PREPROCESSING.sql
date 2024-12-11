
-- ===========================
-- DATA CLEANING PROCESS
-- ===========================

-- Step 1: Backup Creation
-- Creating a backup of the `laptops` table to preserve the original data.
CREATE TABLE laptops_backup LIKE laptops;
INSERT INTO laptops_backup SELECT * FROM laptops;

-- Step 2: Analyzing Data Size
-- Checking the size of the `laptops` table in KB for data size analysis.
SELECT Data_length/1024 AS size_kb
FROM information_schema.Tables
WHERE table_schema = 'test'
  AND table_name = 'laptops';

-- Step 3: Removing Rows with All NULL Values
-- Deleting rows where all column values are NULL to clean up the dataset.
DELETE FROM laptops
WHERE company IS NULL 
  AND typename IS NULL 
  AND inches IS NULL 
  AND screenresolution IS NULL
  AND cpu IS NULL 
  AND ram IS NULL 
  AND memory IS NULL 
  AND gpu IS NULL 
  AND opsys IS NULL
  AND weight IS NULL 
  AND price IS NULL;

-- Step 4: Renaming Columns
-- Changing column name from 'unnamed: 0' to 'ID' for better readability.
ALTER TABLE laptops CHANGE `unnamed: 0` `ID` INT;

-- Step 5: Identifying Duplicate Rows
-- Displaying duplicate rows based on all key columns.
SELECT *, COUNT(*)
FROM laptops
GROUP BY company, typename, inches, screenresolution, cpu, ram, memory, gpu, opsys, weight, price
HAVING COUNT(*) > 1;

-- Step 6: Viewing Distinct Company Names
-- Listing all unique company names in the dataset.
SELECT DISTINCT(company) FROM laptops;

-- Step 7: Cleaning the RAM Column
-- Removing the 'GB' suffix from RAM values.
UPDATE laptops t1
SET ram = (
  SELECT REPLACE(ram, 'GB', '') FROM laptops t2 WHERE t1.ID = t2.ID
);

-- Changing the RAM column data type to integer for numeric analysis.
ALTER TABLE laptops MODIFY ram INTEGER;

-- Step 8: Cleaning the Weight Column
-- Removing the 'kg' suffix from weight values and converting to decimal format.
UPDATE laptops t1
SET weight = (
  SELECT REPLACE(weight, 'kg', '') FROM laptops t2 WHERE t1.ID = t2.ID
);

ALTER TABLE laptops MODIFY weight DECIMAL(20,2);

-- Step 9: Rounding Price Values
-- Rounding price values to the nearest integer for simplification.
UPDATE laptops t1
SET price = (
  SELECT ROUND(price) FROM laptops t2 WHERE t1.ID = t2.ID
);

-- Changing the price column data type to integer.
ALTER TABLE laptops MODIFY price INTEGER;

-- Step 10: Cleaning Operating System Column
-- Standardizing the `opsys` column values.
UPDATE laptops SET opsys = CASE
  WHEN opsys LIKE '%mac%' THEN 'mac'
  WHEN opsys LIKE '%window%' THEN 'windows'
  WHEN opsys = 'NO OS' THEN 'not available'
  WHEN opsys LIKE 'linux' THEN 'linux'
  ELSE 'other'
END;

-- Step 11: Cleaning GPU Column
-- Splitting the `gpu` column into `gpu_brand` and `gpu_name` for detailed analysis.
ALTER TABLE laptops
ADD COLUMN gpu_brand VARCHAR(255) AFTER gpu,
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;

UPDATE laptops t1 SET gpu_brand = (
  SELECT SUBSTRING_INDEX(gpu, ' ', 1) FROM laptops t2 WHERE t1.ID = t2.ID
);

UPDATE laptops t1 SET gpu_name = (
  SELECT REPLACE(gpu, gpu_brand, '') FROM laptops t2 WHERE t1.ID = t2.ID
);

-- Step 12: Cleaning CPU Column
-- Splitting the `cpu` column into `cpu_brand`, `cpu_name`, and `cpu_speed`.
ALTER TABLE laptops
ADD COLUMN cpu_brand VARCHAR(255) AFTER cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed VARCHAR(255) AFTER cpu_name;

UPDATE laptops t1 SET cpu_brand = (
  SELECT SUBSTRING_INDEX(cpu, ' ', 1) FROM laptops t2 WHERE t1.ID = t2.ID
);

UPDATE laptops t1 SET cpu_speed = (
  SELECT SUBSTRING_INDEX(cpu, ' ', -1) FROM laptops t2 WHERE t1.ID = t2.ID
);

UPDATE laptops t1 SET cpu_name = (
  SELECT REPLACE(REPLACE(cpu, cpu_brand, ''), cpu_speed, '') FROM laptops t2 WHERE t1.ID = t2.ID
);

-- Removing the 'GHz' suffix from `cpu_speed` and changing its data type to decimal.
UPDATE laptops t1 SET cpu_speed = (
  SELECT REPLACE(cpu_speed, 'GHz', '') FROM laptops t2 WHERE t1.ID = t2.ID
);

ALTER TABLE laptops MODIFY cpu_speed DECIMAL(20,2);

-- Dropping the original `cpu` column as it has been decomposed.
ALTER TABLE laptops DROP COLUMN cpu;

-- Step 13: Cleaning Screen Resolution
-- Splitting the `screenresolution` column into width, height, touchscreen, and IPS flags.
ALTER TABLE laptops
ADD COLUMN resolution_width INTEGER AFTER screenresolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width;

UPDATE laptops t1 SET resolution_width = (
  SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(screenresolution, ' ', -1), 'x', 1)
  FROM laptops t2 WHERE t1.ID = t2.ID
);

UPDATE laptops t1 SET resolution_height = (
  SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(screenresolution, 'x', -1), 'x', 1)
  FROM laptops t2 WHERE t1.ID = t2.ID
);

-- Adding columns for touchscreen, IPS, and HD features.
ALTER TABLE laptops
ADD COLUMN touchscreen INTEGER AFTER resolution_height,
ADD COLUMN ips INTEGER AFTER touchscreen,
ADD COLUMN HD INTEGER AFTER ips;

-- Setting flags for touchscreen, IPS, and HD features based on screen resolution text.
UPDATE laptops SET touchscreen = CASE WHEN screenresolution LIKE '%Touchscreen%' THEN 1 ELSE 0 END;
UPDATE laptops SET ips = CASE WHEN screenresolution LIKE '%ips%' THEN 1 ELSE 0 END;
UPDATE laptops SET HD = CASE WHEN screenresolution LIKE '%HD%' THEN 1 ELSE 0 END;

-- Dropping the original `screenresolution` column.
ALTER TABLE laptops DROP COLUMN screenresolution;

-- Step 14: Cleaning Memory Column
-- Splitting the `memory` column into memory type, primary storage, and secondary storage.
ALTER TABLE laptops
ADD COLUMN memory_type VARCHAR(255) AFTER memory,
ADD COLUMN primary_storage VARCHAR(255) AFTER memory_type,
ADD COLUMN secondary_storage VARCHAR(255) AFTER primary_storage;

-- Identifying the memory type.
UPDATE laptops SET memory_type = CASE
  WHEN memory LIKE '%+%' THEN 'hybrid'
  WHEN memory LIKE '%SSD%' THEN 'SSD'
  WHEN memory LIKE '%Flash storage%' THEN 'Flash storage'
  WHEN memory LIKE '%HDD%' THEN 'HDD'
  ELSE 'other'
END;

-- Extracting primary and secondary storage values.
UPDATE laptops t1 SET primary_storage = (
  SELECT SUBSTRING_INDEX(memory, ' ', 1) FROM laptops t2 WHERE t1.ID = t2.ID
);

UPDATE laptops t2 SET secondary_storage = CASE
  WHEN memory_type = 'hybrid' THEN SUBSTRING_INDEX(memory, '+', -1)
  ELSE 'N/A'
END;

-- Converting storage values from TB to GB for consistency.
UPDATE laptops SET primary_storage = CASE
  WHEN primary_storage LIKE '%TB%' THEN (REPLACE(primary_storage, 'TB', '')) * 1024
  ELSE REPLACE(primary_storage, 'GB', '')
END;

UPDATE laptops SET secondary_storage = CASE
  WHEN secondary_storage LIKE '%TB%' THEN (SUBSTRING_INDEX(secondary_storage, 'TB', 1)) * 1024
  WHEN secondary_storage LIKE '%GB%' THEN SUBSTRING_INDEX(secondary_storage, 'GB', 1)
  ELSE secondary_storage
END;

-- Dropping the original `memory` column as it has been decomposed.
ALTER TABLE laptops DROP COLUMN memory;

-- Step 15: Final Output
-- Display the cleaned `laptops` table.
SELECT * FROM laptops;
