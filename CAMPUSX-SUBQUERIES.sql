-- SUBQUERY CAN BE DIVIDED INTO THREE TYPES BASED ON TYPE OF DATA RETURNED BY THEM
-- 1. SCALAR SUBQUERIES (giving only a single number or string.
-- 2. ROW SUBQUERIES (return multiple value of a column)
-- 3. TABLE SUBQUERY (returns a table)


-- ON THE BASIS OF WORKING, SUBQUERY CAN BE DIVIDED INTO
-- 1. INDEPENDENT SUBQUERIES (subquries which do not require any data from outer query to work)
-- 2. DEPENDENT SUBQUERIES (subqueries which depends on outer query for their execution)


--                                                                     DATA USED
--  1. ZOMATO DATA -> https://docs.google.com/spreadsheets/d/1JgNHxTixDA50W1l6pNFmHKRaX1a9QnXrpGLsJtzo6Gg/edit?gid=0#gid=0
--  2. MOVIES -> https://drive.google.com/file/d/17TXqIYnNmZYg9fd-raO3jIjFmXrYFH1z/view?usp=drive_link









--                                          SCALAR SUBQUERIES

-- find the movie with highest profit.
select * from movies where gross-budget = (select max(gross-budget) from movies);

-- find how many movies have rating > avg of all movie ratings.
select * from movies where score > (select avg(score) from movies);

-- find highest rated movie of 2000.
select * from movies where year = 2000 and score = (select max(score) from movies where year = 2000);

-- find the highest rated movie among all movies whose number of votes are > the dataset avg votes.
select * from movies where votes > (select avg(votes) from movies) order by score desc limit 1;






--                                        ROW SUBQUERY

use zomato;
use test;

-- find all those users who have never ordered.
select * from user where user_id not in (select user_id from `order`);

-- find all movies made by top 3 directors(in term of total gross income). 
with top_directors as 
(select director from movies group by director order by sum(gross) desc limit 3)

select * from movies where director in (select * from top_directors);

-- find all movies of all those actors where filmography's avg rating > 8.5 (take 25000 votes as cutoff)
select * from movies
where star in 
(select star from movies where votes > 25000 group by star having avg(score) > 8.5);







--                                     TABLE SUBQUERY

-- FIND THE MOST PROFITABLE MOVIE OF EACH YEAR
select * from movies where (year,gross-budget) in (
select year,max(gross-budget) as profit from movies group by year);

-- find all highest rated movie of each genre votes cutoff of 25000
select * from movies where (genre,score) in (
select genre,max(score) from movies where votes > 25000 group by genre)
and votes > 25000;

-- find the highest grossing movies of top actor/director combo
--  in terms of total gross income
with top_combo as 
(select star,director,max(gross) from movies group by star,director order by sum(gross) desc limit 5)
select * from movies where (star,director,gross) in (select * from top_combo);







--                                DEPENDENT OR CORRELATED SUBQUERY

-- find all movies that have a rating higher than the average rating of movies in same genre
select * from movies m1
where score > (select avg(score) from movies m2 where m2.genre = m1.genre);

-- Find the favorite food of each customer
with fav_food as (
select t1.user_id,name,f_name,count(*) as times_ordered from `user` t1
join `order` t2
on t1.user_id = t2.user_id
join order_detail t3 on t2.order_id = t3.order_id
join foods t4 on t3.f_id = t4.f_id
group by t1.user_id,t3.f_id)

select * from fav_food m1 where times_ordered = (select max(times_ordered) from fav_food m2
where m2.user_id = m1.user_id);








--                                     SUBQUERY WITH SELECT 
-- One should avoid using select subquery within select statement as it is highly inefficient

-- get the percentage of votes for each movie compared to total number of votes.
select name, (votes/(select sum(votes) from movies))*100 from movies;

-- SUBQURIES WITH SELECT
-- Display all movies names,genre,score and avg(score) of genre.
select name,genre,score,(select avg(score) from movies m2 where m2.genre = m1.genre) from movies m1;


--                                   SUBQUERY WITH FROM 

-- average rating of all restaurants
select r_name,ratings from (
select r_id,avg(restaurant_rating) as ratings from `order` where restaurant_rating <> '' group by r_id) t1
join restaurant t2 on t1.r_id = t2.r_id;


--                                    SUBQERY WITH HAVING
-- find genres having avg score > avg score of all the movies
select genre from movies group by genre having avg(score) > (select avg(score) from movies);


--                                    SUBQUERY IN INSERT
-- populate a already created loyal_customers table with records of only those customers who have ordered food move than 3 times. 
use zomato;
create table loyal_users(
	user_id integer,
    name varchar(255),
    money integer
    );

insert into loyal_users (user_id,name)
select t1.user_id,name from `order`t1 
join user t2 on t1.user_id = t2.user_id group by user_id having count(*) > 3;


--                                      SUBQUERY IN UPDATE

-- populate the money col of loyal_customer table using the orders table
-- provide a 10% app money to all customers based on their order value. 

update loyal_users t1
set money = (select sum(amount)*0.1 from `order` t2 where t1.user_id = t2.user_id );



--                                      SUBQUERY WITH DELETE
-- Delete all the customers record who have never ordered

delete from user where user_id in (
select user_id from user where user_id not in (select user_id from `order`)
);











--                                                        SOME ADDITIONAL QUESTIONS

-- DATA - https://drive.google.com/file/d/1S-EaktjCBAZNW0DcCSVrESUU76Hez08U/view

-- Display the names of athletes who won a gold medal in the 2008 Olympics 
-- and whose height is greater than the average height of all athletes in the 2008 Olympics. 
select * from olympic where year = 2008 and medal = 'Gold'
and height > (select avg(height) from olympic where year = 2008);

-- Display the names of athletes who won a medal in the sport of basketball in the 2016 Olympics
-- and whose weight is less than the average weight of all athletes who won a medal in the 2016 Olympics.
select * from olympic where sport = 'basketball' and year = 2016
and medal is not null and Weight < (select avg(weight) from olympic where medal is not null and year = 2016);

-- Display the names of all countries that have won more than 50 medals in a single year.
select country,year,count(*) from olympic where medal is not null 
group by country,year having count(*) > 50;

-- How many patients have claimed more than the average claim amount for patients who are smokers
-- and have at least one child, and belong to the southeast region?
select count(*) from insurance where claim > (select avg(claim) from insurance where smoker = 'yes'
and children >= 1 and region = 'southeast');

-- How many patients have claimed more than the average claim amount for patients 
-- who are not smokers and have a BMI greater than the average BMI for patients 
-- who have at least one child?
select count(claim) from insurance where claim > (select avg(claim) from insurance where 
smoker = 'No' and bmi > (select avg(bmi) from insurance where children >= 1));

-- How many patients have claimed more than the average claim amount for patients 
-- who have a BMI greater than the average BMI for patients who are diabetic,
-- have at least one child, and are from the southwest region?
select count(*) from insurance where claim > (select avg(claim) from insurance
where bmi > (select avg(bmi) from insurance where diabetic = 'yes' and children >= 1 
and region = 'southwest'));

-- What is the difference in the average claim amount between patients who are smokers
--  and patients who are non-smokers, 
-- and have the same BMI and number of children?
select A.bmi,A.children,A.non_smoker_claim-B.smoker_claim from 
(select bmi,children,avg(claim) as non_smoker_claim from insurance where smoker = 'No' 
group by bmi,children) A
join
(select bmi,children,avg(claim) as smoker_claim from insurance where smoker = 'Yes' 
group by bmi,children) B
on A.bmi = B.bmi and A.children = B.children;
