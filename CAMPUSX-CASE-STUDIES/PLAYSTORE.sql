-- You're working as a market analyst for a mobile app development company.
-- Your task is to identify the most promising categories (TOP 5) for launching new free apps based on their average ratings.
select category,avg(rating) from playstore where type = 'free'
group by category
order by avg(rating) desc
limit 5;

-- your objective is to pinpoint the three categories that generate the most revenue from paid apps.
-- This calculation is based on the product of the app price and its number of installations.
select category,avg(Installs*price) as revenue from playstore where type = 'paid' group by category
order by revenue desc limit 3;

-- As a data analyst for a gaming company, you're tasked with calculating the percentage of games within each category.
-- This information will help the company understand the distribution of gaming apps across different categories.
select t1.category,(gamecount/overall)*100 from (
select category,count(*) as 'gamecount' from playstore where app like '%game%' group by category
) t1
join (
select category,count(*) as 'overall' from playstore group by category ) t2
on t1.category = t2.category;

-- As a data analyst at a mobile app-focused market research firm 
-- you’ll recommend whether the company should develop paid or free apps for each category
-- based on the ratings of that category.

select t2.category,free_rating,paid_rating,
case 
	when free_rating > paid_rating then 'free'
    else 'paid'
end as 'decision'
from (
select category,round(avg(rating),2) as 'free_rating' from playstore 
where type = 'free'
group by category,type
) t1
join 
(
select category,round(avg(rating),2) as 'paid_rating' from playstore 
where type = 'paid'
group by category,type
) t2
on t1.category = t2.Category;

-- As a data person you are assigned the task of investigating the correlation between two numeric factors:
-- app ratings and the quantity of reviews.
set @x = (select round(avg(rating),2) from playstore);
set @y = (select round(avg(reviews),2) from playstore);

select sum(`x-x_mean` * `y-y_mean`)/sqrt((sum((`x-x_mean`*`x-x_mean`)) * sum((`y-y_mean`*`y-y_mean`)))) from (
select rating - (select @x) as 'x-x_mean',reviews - (select @y) as 'y-y_mean' from playstore) t;

-- Your boss noticed  that some rows in genres columns have multiple genres in them, 
-- which was creating issue when developing the  recommender system from the data
-- he/she assigned you the task to clean the genres column and make two genres out of it, 
-- rows that have only one genre will have other column as blank.

alter table playstore add column genre1 varchar(255) after genres;
alter table playstore add column genre2 varchar(255) after genre1;

update playstore set genre1 = 
case
	when genres like '%;%' then substring_index(genres,';',1)
    else genres 
end;

update playstore set genre2 = 
case
	when genres like '%;%' then substring_index(genres,';',-1)
    else null 
end;

select * from playstore
