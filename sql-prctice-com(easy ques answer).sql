-- Show first name of patients that start with the letter 'C'
select first_name,last_name from patients where allergies is null;

-- Show first name of patients that start with the letter 'C'
select first_name from patients where first_name like 'c%';

-- Show first name and last name of patients that weight within the range of 100 to 120 (inclusive)
SELECT first_name,last_name FROM patients WHERE weight BETWEEN 100 AND 120;

-- Update the patients table for the allergies column. If the patient's allergies is null then replace it with 'NKA'
update  patients set allergies = 'NKA' where allergies is null;

-- Show first name and last name concatinated into one column to show their full name.
select concat(first_name,' ',last_name) from patients;

-- Show first name, last name, and the full province name of each patient.
select t1.first_name,t1.last_name,t2.province_name from patients t1 join province_names t2
on t1.province_id = t2.province_id;

-- Show how many patients have a birth_date with 2010 as the birth year.
select count(*) from patients where year(birth_date) = 2010;

-- Show the first_name, last_name, and height of the patient with the greatest height.
select first_name,last_name,height from patients where height = (select max(height) from patients);

-- Show all columns for patients who have one of the following patient_ids:
-- 1,45,534,879,1000
select * from patients where patient_id in (1,45,534,879,1000);

-- show count of all of addmissions 
select count(*) from admissions;

-- Show all the columns from admissions where the patient was admitted and discharged on the same day.
select  * from admissions where admission_date = discharge_date;

-- Show the patient id and the total number of admissions for patient_id 579.
select patient_id,count(*) from admissions where patient_id = 579;

-- Based on the cities that our patients live in, show unique cities that are in province_id 'NS'?
select distinct(city) from patients where
province_id = 'NS';

-- Write a query to find the first_name, last name and birth date of patients who has height greater than 160 and weight greater than 70
select first_name,last_name,birth_date from patients where height > 160 and weight > 70;

-- Write a query to find list of patients first_name, last_name, and allergies where allergies are not null and are from the city of 'Hamilton'
select first_name,last_name,allergies from patients where allergies is not null and city = 'Hamilton';