select * from salaries;

-- You're a Compensation analyst employed by a multinational corporation.
-- Your Assignment is to Pinpoint Countries who give work fully remotely, 
-- for the title 'managers’ Paying salaries Exceeding $90,000 USD
SELECT DISTINCT
    (company_location)
FROM
    salaries
WHERE
    job_title LIKE '%manager%'
        AND salary_in_usd > 90000
        AND remote_ratio = '100';

-- AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms.
-- you're tasked WITH Identifying top 5 Country Having greatest count of large (company size)
-- number of companies.
SELECT 
    company_location, COUNT(*)
FROM
    salaries
WHERE
    company_size = 'L'
        AND experience_level = 'EN'
GROUP BY company_location
ORDER BY COUNT(*) DESC;

-- Picture yourself AS a data scientist Working for a workforce management platform.
-- Your objective is to calculate the percentage of employees. Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD,
-- Shedding light ON the attractiveness of high-paying remote positions IN today's job market.
select round((count(*)/(select count(*) from salaries where salary_in_usd > 100000))*100,2) from salaries where salary_in_usd > 100000 and remote_ratio = 100;

-- Imagine you're a data analyst Working for a global recruitment agency.
-- Your Task is to identify the Locations where entry-level average salaries exceed the average salary
-- for that job title IN market, helping your agency guide candidates towards lucrative opportunities.

select t2.company_location,t1.job_title,overall_avg,avg_per_country from (
select job_title,avg(salary_in_usd) as overall_avg from salaries group by job_title
) t1
join 
(
select job_title,company_location,avg(salary_in_usd) avg_per_country from salaries 
group by job_title,company_location
) t2
on t1.job_title = t2.job_title
where avg_per_country > overall_avg;

-- You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries.
-- Your job is to Find out for each job title which. Country pays the maximum average salary.
-- This helps you to place your candidates IN those countries.

with temp as (
select company_location,job_title,avg(salary_in_usd) as 'all_salary' from salaries group by company_location,job_title)

select * from temp t1 where all_salary = (
select max(all_salary) from temp t2 group by job_title having t2.job_title = t1.job_title);

-- AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations.
-- Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data is available for 3 years Only
-- (present year and past two years) providing Insights into Locations experiencing Sustained salary growth.

with temp as (
select *,lag(average) over(partition by company_location order by work_year) as previous_year from (
select work_year,company_location,avg(salary_in_usd) as average from salaries
group by work_year,company_location) t )

select * from temp where company_location not in (select company_location from temp where average < previous_year);

 -- Picture yourself AS a workforce strategist employed by a global HR tech startup. 
 -- Your Mission is to Determine the percentage of fully remote work for each experience level IN 2021 and compare it
 -- WITH the corresponding figures for 2024, Highlighting any significant Increases or
 -- decreases IN remote work Adoption over the years.

SELECT 
    t3.experience_level, percent_2021, percent_2024
FROM
    (SELECT 
        t1.experience_level,
            (remote_2021 / all_2021) * 100 AS percent_2021
    FROM
        (SELECT 
        experience_level, COUNT(*) AS remote_2021
    FROM
        salaries
    WHERE
        work_year = 2021 AND remote_ratio = 100
    GROUP BY experience_level) t1
    JOIN (SELECT 
        experience_level, COUNT(*) AS all_2021
    FROM
        salaries
    WHERE
        work_year = 2021
    GROUP BY experience_level) t2 ON t1.experience_level = t2.experience_level) t3
        JOIN
    (SELECT 
        t1.experience_level,
            (remote_2024 / all_2024) * 100 AS percent_2024
    FROM
        (SELECT 
        experience_level, COUNT(*) AS remote_2024
    FROM
        salaries
    WHERE
        work_year = 2024 AND remote_ratio = 100
    GROUP BY experience_level) t1
    JOIN (SELECT 
        experience_level, COUNT(*) AS all_2024
    FROM
        salaries
    WHERE
        work_year = 2024
    GROUP BY experience_level) t2 ON t1.experience_level = t2.experience_level) t4 ON t3.experience_level = t4.experience_level;

-- As a market researcher, your job is to Investigate the job market for a company that analyzes workforce data.
-- Your Task is to know how many people were employed IN different types of companies AS per their size IN 2021.
SELECT 
    company_size, COUNT(*)
FROM
    salaries
WHERE
    work_year = 2021
GROUP BY company_size;

-- Imagine you are a talent Acquisition specialist Working for an International recruitment agency.
-- Your Task is to identify the top 3 job titles that command the highest average salary Among part-time Positions.
SELECT 
    job_title, AVG(salary_in_usd)
FROM
    salaries
WHERE
    employment_type = 'PT'
GROUP BY job_title
ORDER BY AVG(salary_in_usd) DESC
LIMIT 3;

-- As a database analyst you have been assigned the task to Select Countries where average mid-level salary is higher than overall mid-level salary for the year 2023.
SELECT 
    *
FROM
    salaries
WHERE
    experience_level = 'MI'
GROUP BY company_location
HAVING AVG(salary_in_usd) > (SELECT 
        AVG(salary_in_usd)
    FROM
        salaries
    WHERE
        experience_level = 'MI'
            AND work_year = 2023);

-- As a database analyst you have been assigned the task to Identify the company locations with the highest and lowest average salary for 
-- senior-level (SE) employees in 2023.
SELECT 
    *
FROM
    (SELECT 
        company_location,
            'maximum' AS stat,
            AVG(salary_in_usd) AS 'avg_salary'
    FROM
        salaries
    WHERE
        work_year = 2023
            AND experience_level = 'SE'
    GROUP BY company_location
    ORDER BY AVG(salary_in_usd) DESC
    LIMIT 1) t1 
UNION (SELECT 
    company_location,
    'minimum' AS stat,
    AVG(salary_in_usd) AS 'avg_salary'
FROM
    salaries
WHERE
    work_year = 2023
        AND experience_level = 'SE'
GROUP BY company_location
ORDER BY AVG(salary_in_usd)
LIMIT 1);

-- You're a Financial analyst Working for a leading HR Consultancy, and your Task is to Assess the annual salary growth rate for various job titles. 
-- By Calculating the percentage Increase IN salary FROM previous year to this year, you aim to provide valuable Insights Into salary trends WITHIN different job roles.

SELECT 
    t1.job_title,
    `2023avg`,
    `2024avg`,
    ROUND(((`2024avg` - `2023avg`) / `2023avg`) * 100,
            2) AS percent_change
FROM
    (SELECT 
        work_year, job_title, AVG(salary_in_usd) AS '2023avg'
    FROM
        salaries
    WHERE
        work_year = 2023
    GROUP BY job_title) t1
        JOIN
    (SELECT 
        work_year, job_title, AVG(salary_in_usd) AS '2024avg'
    FROM
        salaries
    WHERE
        work_year = 2024
    GROUP BY job_title) t2 ON t1.job_title = t2.job_title;

-- You've been hired by a global HR Consultancy to identify Countries experiencing significant salary growth for entry-level roles. Your task is to list the top three 
-- Countries with the highest salary growth rate FROM 2020 to 2023, helping multinational Corporations identify  Emerging talent markets
SELECT 
    t1.company_location,
    avg2020,
    avg2024,
    ((avg2024 - avg2020) / avg2020) * 100 AS 'rate'
FROM
    (SELECT 
        company_location, AVG(salary_in_usd) AS 'avg2020'
    FROM
        salaries
    WHERE
        work_year = 2020
            AND experience_level = 'EN'
    GROUP BY company_location) t1
        JOIN
    (SELECT 
        company_location, AVG(salary_in_usd) AS 'avg2024'
    FROM
        salaries
    WHERE
        work_year = 2024
            AND experience_level = 'EN'
    GROUP BY company_location) t2 ON t1.company_location = t2.company_location
ORDER BY rate DESC
LIMIT 3;

-- Picture yourself as a data architect responsible for database management. Companies in US and AU(Australia) decided to create a hybrid model for employees 
-- they decided that employees earning salaries exceeding $90000 USD, will be given work from home. You now need to update the remote work ratio for eligible employees,
-- ensuring efficient remote work management while implementing appropriate error handling mechanisms for invalid input parameters.
update salaries set remote_ratio = 100 where company_location in ('US','AU') and salary_in_usd > 90000;

-- In year 2024, due to increase demand in data industry , there was  increase in salaries of data field employees.
--                  Entry Level-35%  of the salary.
--                Mid junior – 30% of the salary.
--              Immediate senior level- 22% of the salary.
--            Expert level- 20% of the salary.
--          Director – 15% of the salary.
-- you have to update the salaries accordingly and update it back in the original databases
UPDATE salaries 
SET 
    salary_in_usd = CASE
        WHEN experience_level = 'EN' THEN salary_in_usd + (salary_in_usd * 0.35)
        WHEN experience_level = 'MI' THEN salary_in_usd + (salary_in_usd * 0.30)
        WHEN experience_level = 'SE' THEN salary_in_usd + (salary_in_usd * 0.22)
        WHEN experience_level = 'EX' THEN salary_in_usd + (salary_in_usd * 0.20)
    END
WHERE
    work_year = 2024;

-- You are a researcher and you have been assigned the task to Find the year with the highest average salary for each job title
with t as (select job_title,work_year,avg(salary_in_usd) as 'avg_salary' from salaries group by job_title,work_year)

select * from t m1 where avg_salary = (select max(avg_salary) from t m2 where m2.job_title = m1.job_title);

-- You have been hired by a market research agency where you been assigned the task to show the percentage of different employment type (full time, part time) in 
-- Different job roles, in the format where each row will be job title, each column will be type of employment type and  cell value  for that row and column will show 
-- the % value
with t as (
select t1.job_title,employment_type,pertype/overall as 'rate' from (
select job_title,employment_type,count(*) as 'pertype' from salaries t1 group by job_title,employment_type
) t1
join
(
select job_title,count(*) as 'overall' from salaries group by job_title
) t2
on t1.job_title = t2.job_title) 

select job_title,
max(case when employment_type = 'FT' then rate end) as 'FT',
max(case when employment_type = 'CT' then rate end) as 'CT',
max(case when employment_type = 'PT' then rate end) as 'PT',
max(case when employment_type = 'FL' then rate end) as 'FL'
from t
group by job_title;
