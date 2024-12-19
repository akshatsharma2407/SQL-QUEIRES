-- Write a solution to find the ids of products that are both low fat and recyclable.
select product_id from products where low_fats = 'y' and recyclable = 'y';




-- Find the names of the customer that are not referred by the customer with id = 2.
-- Return the result table in any order.
select name from customer where referee_id is null or referee_id <> 2;




-- Write a solution to find the name, population, and area of the big countries.
select name,population,area from World
where area >= 3000000 or population >= 25000000;




-- Write a solution to find all the authors that viewed at least one of their own articles.
select distinct(author_id) as id from views where views.author_id = views.viewer_id
order by id;



-- Write a solution to find the IDs of the invalid tweets. The tweet is invalid if the number of characters used in the content of the tweet is strictly greater than 15.
select tweet_id from tweets where length(content) > 15;



-- Write a solution to show the unique ID of each user, If a user does not have a unique ID replace just show null.
select t2.unique_id,t1.name from employees t1
left join 
EmployeeUNI t2
on t1.id = t2.id;



-- Write a solution to report the product_name, year, and price for each sale_id in the Sales table.
select t2.product_name,t1.year,sum(t1.price) as price from sales t1
join product t2
on t1.product_id = t2.product_id
group by t1.sale_id,t1.year;



-- Write a solution to find the IDs of the users who visited without making any transactions and the number of times they made these types of visits.
select customer_id,count(*) as count_no_trans from visits where visit_id in(
select visit_id from visits
except
select visit_id from transactions)
group by customer_id;



-- Write a solution to find all dates' id with higher temperatures compared to its previous dates (yesterday).
select t2.id from weather t1
cross join 
weather t2
on DATEDIFF(t1.recordDate,t2.recordDate) = -1 and t1.temperature < t2.temperature;



 -- Write a solution to find the average time each machine takes to complete a process.
select machine_id,round(avg(processing),3) as processing_time from (
select machine_id,process_id,max(timestamp)-min(timestamp) as processing
from Activity
group by machine_id,process_id) A
group by machine_id;



-- Write a solution to report the name and bonus amount of each employee with a bonus less than 1000.
select name,bonus from employee t1
left join Bonus t2
on t1.empId = t2.empId 
where bonus < 1000 or bonus is null;



-- Write a solution to find the number of times each student attended each exam.
-- A VERY CHALLENGING QUSES, IT TOOK ME AROUND 2+ HOURS TO WRITE THIS QUERY.
select student_id,student_name,subject_name,
case 
    when attended_exams between 1 and 9 then attended_exams
    else 0
end as attended_exams from (
select B.student_id,B.student_name,B.subject_name,attended_exams from 
(select student_id,subject_name,count(*) as attended_exams from examinations 
group by student_id,subject_name) A
right join 
(
select * from students t1
cross join subjects t2
) B
on A.student_id = B.student_id and A.subject_name = B.subject_name
order by B.student_id, B.subject_name
) z;



-- Write a solution to find managers with at least five direct reports.
select t1.name from employee t1
join employee t2
on t1.id = t2.managerId
group by t1.id
having count(*) > 4;



-- Write a solution to find the confirmation rate of each user.
select t1.user_id,round((select count(*) from confirmations m1 where action = 'confirmed'
and m1.user_id = t2.user_id)/count(*),2) as confirmation_rate
from signups t1
left join confirmations t2
on t1.user_id = t2.user_id
group by t1.user_id
order by confirmation_rate;



-- Write a solution to report the movies with an odd-numbered ID and a description that is not "boring".
select * from cinema where id% 2 <> 0 and description <> 'boring'
order by rating desc;



-- Write a solution to find the average selling price for each product. average_price should be rounded to 2 decimal places.
-- If a product does not have any sold units, its average selling price is assumed to be 0.
select product_id,
case 
    when average_prices is null then 0
    else average_prices
end as average_price
from (
select product_id,round(sum(total)/sum(units),2) as average_prices from (
select t1.product_id,price,units,price*units as total from prices t1
left join unitssold t2
on t1.product_id = t2.product_id and t2.purchase_date between t1.start_date and t1.end_date
) Z group by product_id) T;



-- Write an SQL query that reports the average experience years of all the employees for each project, rounded to 2 digits.
select project_id,round(avg(experience_years),2) as average_years from (
select t1.project_id,t2.employee_id,name,experience_years from project t1
join employee t2
on t1.employee_id = t2.employee_id)
z group by project_id;



-- Write a solution to find the percentage of the users registered in each contest rounded to two decimals.
-- Return the result table ordered by percentage in descending order. In case of a tie, order it by contest_id in ascending order.
select contest_id,round(count(*)/(select count(distinct user_id) from users),4)*100 as percentage from register group by contest_id
order by percentage desc,contest_id ;



-- We define query quality as:
-- The average of the ratio between query rating and its position.
-- We also define poor query percentage as:
-- The percentage of all queries with rating less than 3.
-- Write a solution to find each query_name, the quality and poor_query_percentage.
-- Both quality and poor_query_percentage should be rounded to 2 decimal places.
select n.query_name,quality,poor_query_percentage from (
select query_name,round(avg(rating/position),2) as 'quality' from queries group by query_name
) m
right join (
select t2.query_name,
case 
    when below_3 is null then 0
    else round((below_3/all_)*100,2)
end as 'poor_query_percentage'
from (
select 
query_name,count(*) as 'below_3' from queries t1 where rating < 3 group by query_name
) t1
right join (
select query_name,count(*) as 'all_' from queries group by query_name
) t2
on t1.query_name = t2.query_name) n
on m.query_name = n.query_name

 


-- Write an SQL query to find for each month and country, the number of transactions and their total amount, the number of approved transactions and their total amount.
select date_format(trans_date,'%Y-%m') month ,country,
count(*) as trans_count,
sum(case when state = 'approved' then 1 else 0 end) as 'approved_count',
sum(amount) as 'trans_total_amount',
sum(case when state = 'approved' then amount else 0 end) as 'approved_total_amount' from Transactions
group by date_format(trans_date,'%Y-%m'),country

 

-- Write a solution to find the percentage of immediate orders in the first orders of all customers, rounded to 2 decimal places.
select 
round((count(distinct(t2.customer_id))/(select count(distinct(customer_id)) from delivery))*100,2)
as immediate_percentage from (
select * from delivery
) t1
join 
(
select customer_id,
min(order_date) as 'x'
from delivery
group by customer_id
) t2
on t1.customer_pref_delivery_date = t2.x and t1.customer_id = t2.customer_id

 

-- Write a solution to report the fraction of players that logged in again on the day after the day they first logged in, rounded to 2 decimal places. In other words, you need to count the number of players that logged in for at least two consecutive days starting from their first login date, then divide that number by the total number of players.Write a solution to report the fraction of players that logged in again on the day after the day they first logged in, rounded to 2 decimal places. In other words, you need to count the number of players that logged in for at least two consecutive days starting from their first login date,
-- then divide that number by the total number of players.
select round(count(*)/(select count(distinct player_id) from activity),2) as 'fraction' from (
select *,datediff(event_date,first_login) as 'diff' from (
select *,
lag(event_date) over(partition by player_id order by event_date) as 'lagged'
from (
select *,min(event_date) over(partition by player_id) as 'first_login'
from activity
) z
) temp 
where first_login = lagged
) temp2
where diff = 1

 

-- Write a solution to calculate the number of unique subjects each teacher teaches in the university.
select teacher_id,count(distinct(subject_id)) as cnt from teacher group by teacher_id

 

-- Write a solution to find the daily active user count for a period of 30 days ending 2019-07-27 inclusively. 
--A user was active on someday if they made at least one activity on that day.
select activity_date as 'day',count(distinct(user_id)) as 'active_users' from (
select 
*,
DATE_FORMAT('2019-06-28', '%Y-%m-%d') as 'start_date',
date_format('2019-07-27','%Y-%m-%d') as 'end_date'
from activity) t1
where activity_date >= start_date and activity_date <= end_date
group by activity_date;



-- Write a solution to select the product id, year,
--quantity, and price for the first year of every product sold.
select t1.product_id,year as first_year,quantity,price from (
select t1.product_id,year,quantity,price,
rank() over(partition by product_id order by year) as 'ranks' from sales t1
join product t2
on t1.product_id = t2.product_id
) t1 where ranks = 1

 

-- Write a solution to find all the classes that have at least five students.
select class from courses group by class having count(*) > 4

 

-- Write a solution that will, for each user, return the number of followers.
select user_id,count(*) as 'followers_count' from followers group by user_id
order by user_id

 

-- Find the largest single number. If there is no single number, report null.
select max(num) as num from (
select num from mynumbers group by num having count(*) = 1) t

 

-- Write a solution to report the customer ids from the Customer table that bought
-- all the products in the Product table.
select customer_id from customer group by customer_id having count(distinct product_key) = (select count(*) from product)


 
-- Write a solution to report the ids and the names of all managers,
-- the number of employees who report directly to them,
-- and the average age of the reports rounded to the nearest integer.
select t1.reports_to as 'employee_id',t2.name,reports_count,average_age from (
select * from (
select reports_to,count(*) as reports_count,round(avg(age)) as average_age from employees group by reports_to
) t where reports_to is not null
) t1
join
(select * from employees) t2 on t1.reports_to = t2.employee_id
order by employee_id

 

-- Write a solution to report all the employees with their primary department.
--For employees who belong to one department, report their only department.
select employee_id,department_id from (
select *,
rank() over(partition by employee_id order by primary_flag) as 'ranks'
from employee
) z where ranks = 1

-- Report for every three line segments whether they can form a triangle.
select x,y,z,
case 
    when remaining_two > maxx then 'Yes'
    else 'No'
end as 'triangle'
from (
select *,
case 
    when x >= y and x >= z then x
    when y >= x and y >= z then y
    when z >= y and z >= x then z
end as maxx,
case 
    when x >= y and x >= z then y+z
    when y >= x and y >= z then x+z
    when z >= y and z >= x then y+x
end as remaining_two
from triangle
) t

-- Find all numbers that appear at least three times consecutively.
select distinct(num) as ConsecutiveNums from (
select *,
lag(num) over() as 'lags', lead(num) over() as 'leads'
from logs
) z where lags-leads = 0 and lags = num

 

-- Write a solution to find the prices of all products on 2019-08-16.
-- Assume the price of all products before any change is 10.
select product_id,
case
    when date('2019-08-16') = any(select change_date from products t4 where t4.product_id = t2.product_id) then (select new_price from products t5 where t5.product_id = t2.product_id and t5.change_date = '2019-08-16')
    when date('2019-08-16') > any(select change_date from products t3 where t3.product_id = t2.product_id)
    then (select new_price from products t1 where t1.product_id = t2.product_id and t1.change_date < '2019-08-16' order by change_date desc limit 1)
    else 10
end as 'price'
from products t2
group by product_id

 

-- Write a solution to find the person_name of the last person that can fit on the bus without exceeding the weight limit.
-- The test cases are generated such that the first person does not exceed the weight limit.
select person_name from (
select *,sum(weight) over(order by turn rows between unbounded preceding and current row) as 'sw' from queue
) z where sw <= 1000
order by turn desc limit 1;



-- Write a solution to calculate the number of bank accounts for each salary category. The salary categories are:
-- "Low Salary": All the salaries strictly less than $20000.
-- "Average Salary": All the salaries in the inclusive range [$20000, $50000].
-- "High Salary": All the salaries strictly greater than $50000.
with temp as (
select sum(`Low Salary`) as x,sum(`Average Salary`) as y,sum(`High Salary`) as z
from (
select 
(case when income < 20000 then 1 else 0 end) as 'Low Salary',
(case when income between 20000 and 50000 then 1 else 0 end) as 'Average Salary',
(case when income > 50000 then 1 else 0 end) as 'High Salary'
from accounts
) z
)
select category,value as 'accounts_count' from (
select 'Low Salary' as category, x as value from temp
union all
select 'Average Salary' as category, y as value from temp
union all
select 'High Salary' as category, z as value from temp
) m
order by value desc

 

-- Find the IDs of the employees whose salary is strictly less than $30000 and whose manager left the company. When a manager leaves the company,
-- their information is deleted from the Employees table,
-- but the reports still have their manager_id set to the manager that left
select employee_id as employee_id from employees
where salary < 30000 and manager_id not in (select employee_id from employees)
order by employee_id

 

-- Write a solution to swap the seat id of every two consecutive students.
-- If the number of students is odd, the id of the last student is not swapped.
with temp as (
select * from (
select id,leads from (
select *,
lag(student) over(rows between 1 preceding and current row) as 'leads'
from seat
) z where id%2 = 0
) t1
union
select * from (
select id,leads from (
select *,
lead(student) over(rows between 1 preceding and current row) as 'leads'
from seat
) z where id%2 <> 0
) t2)

select id,
case
    when leads is null then (select student from seat order by id desc limit 1)
    else leads
end as student from temp
order by id

 

-- Write a solution to:
-- Find the name of the user who has rated the greatest number of movies. In case of a tie, return the lexicographically smaller user name.
-- Find the movie name with the highest average rating in February 2020. In case of a tie, return the lexicographically smaller movie name.
with temp as (
select t1.movie_id,t1.title,t2.user_id,name,rating,created_at from movies t1
join
(
    select * from movierating
) t2
on t1.movie_id = t2.movie_id
join 
(
    select user_id,name from users
) t3
on t2.user_id = t3.user_id)
select * from (
select name as 'results' from temp
group by user_id having count(*) = (select count(*) from temp group by user_id order by count(*) desc limit 1)
order by name limit 1
) x
union all
select * from (
select * from (
select title as 'results' from temp where 
created_at >= date('2020-02-01') and created_at <= date('2020-02-29')
group by movie_id 
order by avg(rating) desc,title limit 1
)m ) y

 

-- Compute the moving average of how much the customer paid in a seven days window (i.e., current day + 6 days before).
-- average_amount should be rounded to two decimal places.
with min_date as (
select date_add(min(visited_on),interval 6 day) from customer)

select visited_on,x as amount,round(x/7,2) as 'average_amount' from (
select visited_on,
sum(summed) over(order by visited_on rows between 6 preceding and current row) as 'x' from (
select visited_on,sum(amount) as summed
from customer
group by visited_on
) z ) p
where visited_on >=(select * from min_date)

 

-- Write a solution to find the people who have the most friends and the most friends number.
with temp as (
select * from (
select Requester_id as 'accepter_id',count(*) as 'A' from requestAccepted 
group by Requester_id
) t1
union all 
select * from (
select accepter_id,count(*) as 'A' from requestAccepted 
group by accepter_id
) t2
)
select accepter_id as id,sum(A) as num from temp group by accepter_id order by sum(A) desc limit 1

-- Write a solution to report the sum of all total investment values in 2016 tiv_2016, for all policyholders who:
-- have the same tiv_2015 value as one or more other policyholders, and
-- are not located in the same city as any other policyholder (i.e., the (lat, lon) attribute pairs must be unique).
select round(sum(tiv_2016),2) as 'tiv_2016'
from insurance
where tiv_2015 in (
    select tiv_2015 from insurance group by tiv_2015 having count(*) > 1
)
and 
(lat,lon) in (
    select lat,lon from insurance group by lat,lon having count(*) = 1
)

 

-- Write a solution to find the employees who are high earners in each of the departments.
select t2.name as 'Department',t1.name as 'Employee',salary from (
select name,salary,departmentid from (
select *,
dense_rank() over(partition by departmentid order by salary desc) as 'ranks'
from employee
) z where ranks <= 3
) t1
join 
(
    select * from department
) t2
on t1.departmentid = t2.id

 

-- Write a solution to fix the names so that only the first character is uppercase and the rest are lowercase.
-- Return the result table ordered by user_id.
select user_id,concat(upper(substr(name,1,1)),lower(substr(name,2))) as name from users
order by user_id

 

-- Write a solution to find the patient_id, patient_name, and conditions of the patients who have Type I Diabetes.
-- Type I Diabetes always starts with DIAB1 prefix.
select patient_id,patient_name,conditions from (
SELECT patient_id,patient_name,conditions, idx,
CASE
    when idx = 0 then 0
    WHEN idx <> 1 THEN IF(conditions LIKE '% DIAB1%', 1, 0)
    ELSE 1
END AS 'ax'
FROM (
    SELECT patient_id, patient_name, conditions, LOCATE('DIAB1', conditions) AS idx 
    FROM patients
) z
) temp where ax = 1

 


-- Write a solution to delete all duplicate emails, keeping only one unique email with the smallest id.
delete p1 
from person p1
join person p2
on p1.email = p2.email
and p1.id > p2.id
 


-- Write a solution to find the second highest distinct salary from the Employee table. If there is no second highest salary, return null
select 
case
    when count(*) > 0 then SecondHighestSalary_
    else null
end as SecondHighestSalary
from (
select salary as 'SecondHighestSalary_' from (
select *,
dense_rank() over(order by salary desc) as 'x'
from employee ) z
where x = 2) p;



-- Write a solution to find for each date the number of different products sold and their names.
-- The sold products names for each date should be sorted lexicographically.
-- Return the result table ordered by sell_date.
select t1.sell_date,num_sold,products from (
select sell_date,group_concat(distinct product) as products from activities
group by sell_date
) t1
join
(
select sell_date,count(distinct product) as num_sold from activities
group by sell_date
) t2
on t1.sell_date = t2.sell_date

-- Write a solution to get the names of products that have at least 100 units ordered in February 2020 and their amount.
with temp as (
select product_id,sum(unit) as z from (
select *,str_to_date('01-02-2020','%d-%m-%Y') as 'first_date',
last_day(str_to_date('01-02-2020','%d-%m-%Y')) as 'lastday' from orders 
) t
where order_date >= first_date and order_date <= lastday
group by product_id
having sum(unit) > 99)

select product_name,z as unit from temp t1
join
(
    select * from products
) t2
on t1.product_id = t2.product_id

 

-- Write a solution to find the users who have valid emails.
-- A valid e-mail has a prefix name and a domain where:
-- The prefix name is a string that may contain letters (upper or lower case), digits, underscore '_', period '.', and/or dash '-'. The prefix name must start with a letter.
-- The domain is '@leetcode.com'.
select * from users where mail regexp'^[a-zA-Z][a-zA-Z0-9_.-]*@leetcode[.]com$'


-- =============================================================== COMPLETED =====================================================================================
