--                                                                                   HOSPITAL.DB

-- # Show all of the patients grouped into weight groups.
-- # Show the total amount of patients in each weight group.
-- # Order the list by the weight group decending.
-- # For example, if they weight 100 to 109 they are placed in the 100 weight group, 110-119 = 110 weight group, etc.
  
select count(*),floor(weight/10)*10 as weight_group from patients 
group by floor(weight/10)*10 order by  floor(weight/10)*10 desc;

-- Show patient_id, weight, height, isObese from the patients table.
-- Display isObese as a boolean 0 or 1.
-- Obese is defined as weight(kg)/(height(m)2) >= 30.
-- weight is in units kg.
-- height is in units cm.
select patient_id,weight,height,0 as isObase from patients where weight / ( (height / 100.0) * (height / 100.0) ) < 30
union
select patient_id,weight,height,1 as isObase from patients where weight / ( (height / 100.0) * (height / 100.0) ) >= 30;

-- Show patient_id, first_name, last_name, and attending doctor's specialty.
-- Show only the patients who has a diagnosis as 'Epilepsy' and the doctor's first name is 'Lisa'
-- Check patients, admissions, and doctors tables for required information.
select t1.patient_id,t1.first_name,t1.last_name,t3.specialty from patients t1
join admissions t2
on t1.patient_id = t2.patient_id
join doctors t3
on t2.attending_doctor_id = t3.doctor_id
where diagnosis = 'Epilepsy'
and t3.first_name = 'Lisa';

-- All patients who have gone through admissions, can see their medical documents on our site. Those patients are given a temporary password after their first admission. Show the patient_id and temp_password.
-- The password must be the following, in order:
-- 1. patient_id
-- 2. the numerical length of patient's last_name
-- 3. year of patient's birth_date
select distinct(t1.patient_id),concat(t1.patient_id,len(t1.last_name),year(t1.birth_date)) from patients t1
join admissions t2
on t1.patient_id = t2.patient_id;


-- Each admission costs $50 for patients without insurance, and $10 for patients with insurance. All patients with an even patient_id have insurance.
-- Give each patient a 'Yes' if they have insurance, and a 'No' if they don't have insurance. Add up the admission_total cost for each has_insurance group.
select 'Yes' as has_insurance, count(*)*10 as cost_after_insurance
from admissions where patient_id%2 = 0
union
select 'No' as has_insurance, count(*)*50 as cost_after_insurance
from admissions where patient_id%2 <> 0;


-- Show the provinces that has more patients identified as 'M' than 'F'. Must only show full province_name
select province_name from patients t1
join province_names t2
on t1.province_id = t2.province_id
where gender = 'M'
group by t1.province_id
having count(*) > 
(select count(*) from patients m1 where gender = 'F' and m1.province_id = t2.province_id);


-- We are looking for a specific patient. Pull all columns for the patient who matches the following criteria:
-- - First_name contains an 'r' after the first two letters.
-- - Identifies their gender as 'F'
-- - Born in February, May, or December
-- - Their weight would be between 60kg and 80kg
-- - Their patient_id is an odd number
-- - They are from the city 'Kingston'
select * from patients where first_name 
like '__r%' and gender = 'F' 
and month(birth_date) in (2, 5, 12)
and weight between 60 and 80
and patient_id%2 <> 0 and city = 'Kingston';

-- Show the percent of patients that have 'M' as their gender. Round the answer to the nearest hundreth number and in percent form.
select concat(round(((count(*)+0.0) / (select count(*)+0.0 from patients))*100,2),'%') from patients where gender = 'M';

-- For each day display the total amount of admissions on that day. Display the amount changed from the previous date.
select admission_date,count(*),count(*)-lag(count(*)) over() from admissions group by admission_date;

-- Sort the province names in ascending order in such a way that the province 'Ontario' is always on top.
select 'Ontario' as province_name 
union all
select province_name from province_names where province_name <> 'Ontario';

-- We need a breakdown for the total amount of admissions each doctor has started each year. Show the doctor_id, doctor_full_name, specialty, year, total_admissions for that year.
with cleaned as (select * from admissions t1
join doctors t2
on t1.attending_doctor_id = t2.doctor_id)

select doctor_id,concat(first_name,' ',last_name),specialty,year(admission_date),count(*) from cleaned group by doctor_id,year(admission_date);









--                                                                              NORTHWIND.DB

-- Show the employee's first_name and last_name, a "num_orders" column with a count of the orders taken, and a column called "Shipped" that displays "On Time" if the order shipped_date is less or equal to the required_date, "Late" if the order shipped late.
-- Order by employee last_name, then by first_name, and then descending by number of orders.
with filtered as (select *,
case 
	WHEN shipped_date <= required_date then 'On Time'
    else 'Late'
end as shipped
from employees t1
join orders t2
on t1.employee_id = t2.employee_id)

select first_name,last_name,count(*) as num_orders,shipped from filtered
group by employee_id,shipped
order by last_name asc ,first_name  asc, num_orders desc


-- Show how much money the company lost due to giving discounts each year, order the years from most recent to least recent. Round to 2 decimal places
select year(order_date),round(sum((quantity*unit_price)*discount),2) from order_details t1
join orders t2
on t1.order_id = t2.order_id
join products t3
on t3.product_id = t1.product_id
group by year(order_date)
order by year(order_date) desc;

