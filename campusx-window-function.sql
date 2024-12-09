-- ZOMATO DATA - https://drive.google.com/drive/folders/1xCNbO_LJIkr7bi9YDa7hUFYgJ-IZ01A-

-- STUDENTS TOY DATA-->
CREATE TABLE students (
 student_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    branch VARCHAR(255),
    marks INTEGER
);

INSERT INTO students (name,branch,marks)VALUES 
('Nitish','EEE',82),
('Rishabh','EEE',91),
('Anukant','EEE',69),
('Rupesh','EEE',55),
('Shubham','CSE',78),
('Ved','CSE',43),
('Deepak','CSE',98),
('Arpan','CSE',95),
('Vinay','ECE',95),
('Ankit','ECE',88),
('Anand','ECE',81),
('Rohit','ECE',95),
('Prashant','MECH',75),
('Amit','MECH',69),
('Sunny','MECH',39),
('Gautam','MECH',51);


-- find all students who have marks higher than the avg marks of their respective branch
select * from (select *,avg(marks) over(partition by branch) as avg_ from students) A
where marks > avg_;

-- give rank to student by their branch.
select *,rank() over(partition by branch order by marks desc) from students;

-- find top 2 customer of each month (based on amount they spent)
select * from (
select *,rank() over(partition by months order by total desc) as ranks from (
select monthname(date) as months,user_id,sum(amount) as total from `order` 
group by monthname(date),user_id
order by month(date))
A ) 
z where ranks in (1,2);

-- find name of student with highest marks.
select *,first_value(name) over(order by marks desc) from students;

-- find name of student with lowest marks.
select *,first_value(name) over(order by marks) from students;

-- 2nd highest marks from student
select *,nth_value(name,2) over(order by marks desc) from students;

-- topper of each branch, branch name, marks
select name,branch,marks from (
select *,first_value(name) over(partition by branch order by marks desc) as 'topper_name',
first_value(marks) over(partition by branch order by marks desc) as 'topper_marks',
first_value(branch) over(partition by branch order by marks desc) as 'topper_branch'
from students) A
where A.name = A.topper_name and A.marks = A.topper_marks and A.branch = A.topper_branch;

-- show month on month revenue growth
select months,current_revenue,current_revenue-past_month_revenue from (
select *,lag(current_revenue) over(order by month(months)) as 'past_month_revenue' from (
select monthname(date) as months,sum(amount) as current_revenue from `order` group by month(date)) A
) Z;


-- find top 5 batsman of each ipl team
select * from (
select battingteam,batter,sum(batsman_run) as 'total_runs',
dense_rank() over(partition by battingteam order by total_runs desc) as ranks from ipl
group by battingteam,batter
order by battingteam, ranks) Z
where ranks < 6;

-- what is total run scored by v kohli after 50th,100th,200th match
select * from (
select *,
sum(per_match_run) over(order by match_id rows between unbounded preceding and current row)  as 'carrier_runs'
from (
select row_number() over(order by ID) as match_id,sum(batsman_run) as 'per_match_run'
from ipl
where batter = 'V kohli'
group by ID) z) T
where match_id in (50,100,200);

-- find median value of student
select *,percentile_disc(0.5) within group(order by marks) over() from students;

-- find branch wise median value
select *,percentile_disc(0.5) within group(order by marks) 
over(partition by branch) from students;

-- difference between the above and below approch is 
-- percentile_disc return value which is present in data.
-- percentile_cont return value which may not be present in data as it consider entire data to be continuous

-- find branch wise median value
select *,percentile_cont(0.5) within group(order by marks) 
over(partition by branch) from students;


-- removing outlier student
-- explicitly adding a outlier student

insert into students values(18,'umesh','EEE',1);

select * from (
select *,
percentile_cont(0.25) within group(order by marks) over() as 'q1',
percentile_cont(0.75) within group(order by marks) over() AS 'Q3'
FROM students)
z where marks > (q1 - (1.5*(q3-q1))) and marks < (q3 + (1.5*(q3-q1)));

-- divide student into 3 bucket based on marks
select *,ntile(3) over(order by marks desc) from students;

-- divide all the laptops into 3 segments based on price
use laptops;
select company,typename,price,
case 
	when ranks = 1 then 'premium'
    when ranks = 2 then 'mid-range'
    else 'budget'
end as 'category'
from (
select company,typename,price,
ntile(3) over(order by price desc) as ranks from laptop) z;

-- find percentile using CDF
select *,
cume_dist() over(order by marks) 
from students;

-- What are the top 5 patients who claimed the highest insurance amounts?
use sql_case_studies;
select *,rank() over(order by claim desc) from insurance limit 5;

-- What is the average insurance claimed by patients based on the number of children they have?
select distinct(children),avg(claim) over(partition by children) from insurance;

-- What is the highest and lowest claimed amount by patients in each region?
select distinct(region),min(claim) over(partition by region),
max(claim) over(partition by region) from insurance;

-- what is difference between the claimed amount of each patient
-- and the claimed amount of first patient?
select *,claim-first_value(claim) over(order by patientId) from insurance;

--  For each patient, calculate the difference between their claimed amount 
-- and the average claimed amount of patients with the same number of children.
select *,claim - avg(claim) over(partition by children) from insurance;

-- Show the patient with the highest BMI in each region and their respective overall rank.
select m.region,m.patientID,m.bmi,
rank() over(order by max_in_region desc) as overall from (
select distinct(region),max(bmi) over(partition by region) as 'max_in_region' from insurance) z
join insurance m
on z.region = m.region and z.max_in_region = m.bmi;

-- For each patient, find the maximum BMI value among their next three records 
-- (ordered by age).
select *,max(bmi) 
over(order by age rows between current row and 3 following) from insurance;

--  For each patient, find the rolling average of the last 2 claims
select *,
avg(claim) over(rows between 2 preceding and 1 following) from insurance;

-- Find the first claimed insurance value for male and female patients,
-- within each region order the data by patient age in ascending order,
-- and only include patients who are non-diabetic and have a bmi value between 25 and 30.
with filtered_data as (select * from insurance where diabetic = 'No' and 
bmi between 25 and 30)

select gender,region,first_claim from (
select *,first_value(claim) over(partition by region,gender order by age) as first_claim,
row_number() over(partition by region,gender order by age) as rownumber from 
filtered_data) z
where rownumber = 1;
