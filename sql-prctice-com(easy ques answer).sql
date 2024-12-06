--                                                                    HOSPITAL.DB
                                                             
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






--                                                                NORTHWIND.DB

-- Show the category_name and description from the categories table sorted by category_name.
select category_name,description from categories order by category_name;

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

-- Show the city, company_name, and and contact_name from the merged customer and supplier table.
-- Create a column that contains 'customers' or 'suppliers' depending on the table it came from.
select city,company_name,contact_name,'customers' as relationship from customers
union 
select city,company_name,contact_name,'suppliers' as relationship from suppliers

-- Show all the contact_name, address, city of all customers which are not from 'Germany', 'Mexico', 'Spain'
select contact_name,address,city from customers where country not in ('Germany','Mexico','Spain')

-- Show order_date, shipped_date, customer_id, Freight of all orders placed on 2018 Feb 26
select order_date,shipped_date,customer_id,freight from orders where order_date = '2018-02-26';

-- Show the employee_id, order_id, customer_id, required_date, shipped_date from all orders shipped later than the required date
select employee_id,order_id,customer_id,required_date,shipped_date from orders
where date(shipped_date) > date(required_date)

-- Show all the even numbered Order_id from the orders table
select order_id from orders where order_id%2 = 0

-- Show the city, company_name, contact_name of all customers from cities which contains the letter 'L' in the city name, sorted by contact_name
select city,company_name,contact_name from customers where city like '%L%' order by contact_name

-- Show the company_name, contact_name, fax number of all customers that has a fax number. (not null)
select company_name,contact_name,fax from customers where fax is not null

-- Show the first_name, last_name. hire_date of the most recently hired employee.
select first_name,last_name,hire_date from employees order by hire_date desc limit 1
