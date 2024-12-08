-- GENERATING DATA

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
