-- DATA -> https://docs.google.com/spreadsheets/d/1JgNHxTixDA50W1l6pNFmHKRaX1a9QnXrpGLsJtzo6Gg/edit?gid=0#gid=0


use zomato;

-- Total rows in tables
select count(*) from menus;
select count(*) from user;

-- Random sample of 5 users
select * from user order by rand() limit 5;

-- Orders with null restaurant ratings
select * from `order` where restaurant_rating = 0;

-- Number of orders placed by each customer
select t1.name, count(*) as 'num_of_orders' 
from user t1
join `order` t2 on t1.user_id = t2.user_id
group by t1.user_id;

-- Number of menu items per restaurant
select r_name, count(f_id) 
from restaurant t1
join menus t2 on t1.r_id = t2.r_id
group by t2.r_id;

-- Votes and average ratings for restaurants
select r_name, count(*) as votes, round(avg(restaurant_rating), 1) as avg_rating 
from restaurant t1
join `order` t2 on t1.r_id = t2.r_id
where restaurant_rating <> 0
group by t2.r_id;

-- Food sold at the most restaurants
select f_name, count(*) as counts 
from menus t2
join foods t3 on t3.f_id = t2.f_id
group by t3.f_id
order by counts desc limit 1;

-- Restaurant with highest revenue in a given month
select r_name, sum(amount) as revenue 
from restaurant t1
join `order` t2 on t1.r_id = t2.r_id 
where monthname(date) = 'july'
group by t1.r_id
order by revenue desc limit 1;

-- Monthly revenue for all restaurants
select r_name, monthname(date), sum(amount) as revenue 
from restaurant t1
join `order` t2 on t1.r_id = t2.r_id 
group by t1.r_id, month(date)
order by revenue desc;

-- Restaurants with total sales > 1500
select r_name, sum(amount) as sales 
from restaurant t1
join `order` t2 on t1.r_id = t2.r_id
group by t1.r_id
having sales > 1500;

-- Customers who have never ordered
select user_id, name 
from user 
where user_id not in (select user_id from `order`);

-- Order details for a customer in a date range
select t1.order_id, f_name, date 
from `order` t1
join order_detail t2 on t1.order_id = t2.order_id
join foods t3 on t3.f_id = t2.f_id
where user_id = 1 and date between '2022-05-01' and '2022-06-01';

-- Restaurants with the highest average menu price
select r_name, round(avg(price), 2) as avg_price 
from restaurant t1
join menus t2 on t1.r_id = t2.r_id
group by t1.r_id
order by avg_price desc;

-- Delivery partner compensation
select t1.partner_name, (count(*) * 100) + (1000 * avg(delivery_rating)) as compensation 
from delivery_partners t1
join `order` t2 on t1.partner_id = t2.partner_id
group by t1.partner_id
order by compensation desc;

-- All vegetarian restaurants
select * 
from restaurant t1
join menus t2 on t1.r_id = t2.r_id
join foods t3 on t3.f_id = t2.f_id
where t1.r_id not in (
    select t1.r_id 
    from restaurant t1
    join menus t2 on t1.r_id = t2.r_id
    join foods t3 on t3.f_id = t2.f_id 
    where type like 'Non%'
);

-- Min and max order value for each customer
select name, max(amount), min(amount) 
from user t1
join `order` t2 on t1.user_id = t2.user_id
group by t1.user_id;
