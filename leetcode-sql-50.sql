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

