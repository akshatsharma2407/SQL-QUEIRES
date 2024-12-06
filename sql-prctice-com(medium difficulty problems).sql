--                                                                                      HOSPITAL.DB




-- Show unique birth years from patients and order them by ascending.
select distinct(year(birth_date)) from patients order by year(birth_date)

-- Show unique first names from the patients table which only occurs once in the list.
-- For example, if two or more people are named 'John' in the first_name column then don't include their name in the output list. If only 1 person is named 'Leo' then include them in the output.
select first_name from patients group by first_name having count(first_name) = 1

-- Show patient_id and first_name from patients where their first_name start and ends with 's' and is at least 6 characters long.
select patient_id,first_name from patients where first_name like 's%' and first_name like '%s' and len(first_name) > 5

-- Show patient_id, first_name, last_name from patients whos diagnosis is 'Dementia'.
-- Primary diagnosis is stored in the admissions table.
select t1.patient_id,first_name,last_name from patients t1
join admissions t2
on t1.patient_id = t2.patient_id
and diagnosis = 'Dementia'

-- Display every patient's first_name.
-- Order the list by the length of each name and then by alphabetically.
select first_name from patients order by len(first_name),first_name

-- Show the total number of male patients and the total number of female patients on the patient's table.
-- Display the two results in the same row.
-- FAILED TO SOLVE THIS PROBLEM BUT SOLUTION WAS QUITE INTRESETING
select 
	(select count(*) from patients where gender = 'M') as Male_count,
    (select count(*) from patients where gender = 'M') as female_count

-- Show first and last name, allergies from patients which have allergies to either 'Penicillin' or 'Morphine'. Show results ordered ascending by allergies then by first_name then by last_name.
select first_name,last_name,allergies from patients 
where allergies in ('Penicillin','Morphine')
order by allergies,first_name,last_name;

-- Show patient_id, diagnosis from admissions. Find patients admitted multiple times for the same diagnosis.
select patient_id,diagnosis from admissions
group by patient_id,diagnosis having count(*) > 1

-- Show the city and the total number of patients in the city.
-- Order from most to least patients and then by city name ascending.
select city,count(*) from patients group by city order by count(*) desc,city;

-- Show first name, last name and role of every person that is either patient or doctor.
-- The roles are either "Patient" or "Doctor"
select first_name,last_name,'Patient' as role from patients
union all 
select first_name,last_name,'Doctor' as role from doctors;

-- Show all allergies ordered by popularity. Remove NULL values from query.
select allergies,count(*) from patients where allergies is not null
group by allergies
order by count(*) desc

-- Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. Sort the list starting from the earliest birth_date.
select first_name,last_name,birth_date from patients where year(birth_date) between 1970 and 1979
order by birth_date;

-- We want to display each patient's full name in a single column. Their last_name in all upper letters must appear first, then first_name in all lower case letters.
-- Separate the last_name and first_name with a comma. Order the list by the first_name in decending order
-- EX: SMITH,jane
select concat(upper(last_name),',',lower(first_name)) from patients order by first_name desc;

-- Show the province_id(s), sum of height; where the total sum of its patient's height is greater than or equal to 7,000.
select province_id,sum(height) from patients group by province_id having sum(height) > 7000

-- Show the difference between the largest weight and smallest weight for patients with the last name 'Maroni'
select max(weight)-min(weight) from patients where last_name like 'Maroni';

-- Show all of the days of the month (1-31) and how many admission_dates occurred on that day. Sort by the day with most admissions to least admissions.
select day(admission_date),count(*) from admissions
group by day(admission_date) 
order by count(*) desc

-- Show all columns for patient_id 542's most recent admission_date.
select * from admissions where patient_id = 542 and admission_date = (select max(admission_date) from admissions where patient_id = 542);

-- Show patient_id, attending_doctor_id, and diagnosis for admissions that match one of the two criteria:
-- 1. patient_id is an odd number and attending_doctor_id is either 1, 5, or 19.
-- 2. attending_doctor_id contains a 2 and the length of patient_id is 3 characters.
select patient_id,attending_doctor_id,diagnosis from admissions 
where ((patient_id%2 <> 0 and attending_doctor_id in (1,5,19) or attending_doctor_id like '%2%' and len(patient_id) = 3))

-- Show first_name, last_name, and the total number of admissions attended for each doctor.
-- Every admission has been attended by a doctor.
select t2.first_name,t2.last_name,count(*) from admissions t1
join doctors t2
on t1.attending_doctor_id = t2.doctor_id
group by t2.doctor_id;

-- For each doctor, display their id, full name, and the first and last admission date they attended.
select doctor_id,concat(t2.first_name,' ',t2.last_name),max(t1.admission_date),min(t1.admission_date) 
from admissions t1
join doctors t2
on t1.attending_doctor_id = t2.doctor_id
group by t2.doctor_id

-- Display the total amount of patients for each province. Order by descending.
select province_name,count(*) from patients t1
join province_names t2
on t1.province_id = t2.province_id
group by t1.province_id
order by count(*) desc

-- For every admission, display the patient's full name, their admission diagnosis, and their doctor's full name who diagnosed their problem
select concat(t1.first_name,' ',t1.last_name) as patient_name,t2.diagnosis,concat(t3.first_name,' ',t3.last_name) from patients t1
join admissions t2 
on t1.patient_id = t2.patient_id
join doctors t3
on t2.attending_doctor_id = t3.doctor_id

-- display the first name, last name and number of duplicate patients based on their first name and last name.
-- Ex: A patient with an identical name can be considered a duplicate.
select first_name,last_name,count(*) from patients group by first_name,last_name having count(*) > 1

-- Display patient's full name,
-- height in the units feet rounded to 1 decimal,
-- weight in the unit pounds rounded to 0 decimals,
-- birth_date,
-- gender non abbreviated.
-- Convert CM to feet by dividing by 30.48.
-- Convert KG to pounds by multiplying by 2.205.
select concat(first_name,' ',last_name),round(height/30.48,1),round(weight*2.205),birth_date,
'male' as gender from patients where gender = 'M'
union
select concat(first_name,' ',last_name),round(height/30.48,1),round(weight*2.205),birth_date,
'Female' as gender from patients where gender = 'F'

-- Show patient_id, first_name, last_name from patients whose does not have any records in the admissions table. (Their patient_id does not exist in any admissions.patient_id rows.)
select patient_id,first_name,last_name from patients
where patient_id not in (select patient_id from admissions)








--                                                                                             NORHTWIND.DB


-- Show the ProductName, CompanyName, CategoryName from the products, suppliers, and categories table
select product_name,company_name,category_name from categories t1
join products t2
on t1.category_id = t2.category_id
join suppliers t3
on t2.supplier_id = t3.supplier_id;

-- Show the category_name and the average product unit price for each category rounded to 2 decimal places.
select category_name,round(avg(unit_price),2) from categories t1
join products t2 on
t1.category_id = t2.category_id
group by t1.category_id

-- Show the city, company_name, contact_name from the customers and suppliers table merged together.
-- Create a column which contains 'customers' or 'suppliers' depending on the table it came from.
select city,company_name,contact_name,'customers' as relationship from customers
union
select city,company_name,contact_name,'suppliers' as relationship from suppliers
