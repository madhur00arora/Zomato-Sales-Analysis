use zomato;
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
VALUES (1,'2017-09-22'),
(3,'2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


# Total amount each user spent on zomato
select * from product;
select * from sales;
select userid,sum(price) as amt_spent from sales s inner join product p
on s.product_id=p.product_id
group by userid
order by userid;

# How many times each customer visited zomato
select * from sales;
select userid,count(distinct created_date) as no_of_visits
from sales
group by userid
order by userid;

# What was the first product purchased by each customer
select * from sales;
with cte as 
(select *, rank() over(partition by userid order by created_date) as rnk
from sales)
select userid,product_name from cte c 
join product p
on c.product_id=p.product_id
where rnk=1;

# What is the most purchased item in the menu and how many times was it purchased by all the users.

select product_id,count(1) as purchase_count
from sales
group by product_id;
select userid,count(product_id) as purchase_count
from sales
where product_id=(select product_id from sales 
group by product_id
order by count(product_id) desc
limit 1)
group by userid
order by userid;

# What is the most popular item for each customer
select userid, product_id from(
select *, rank() over(partition by userid order by purchase_count desc)
as rnk
from(
select userid,product_id,count(product_id) as purchase_count
from sales
group by userid,product_id
order by userid,product_id)a)b
where rnk=1;

# Which item was purchased first by the customer after they became a member
Select a.userid,a.product_id
from(
select s.userid,s.product_id,dense_rank() over(partition by s.userid order by s.created_date)
as rnk from
sales s join goldusers_signup g
on s.userid=g.userid
and s.created_date>g.gold_signup_date
order by s.userid)a
where rnk=1;

# Which item was purchased just before the customer became  member
select a.userid,a.product_id from(
select s.userid,s.product_id, dense_rank() over(partition by s.userid order by s.created_date desc)
as rnk
from sales s join goldusers_signup g
on s.userid=g.userid
and s.created_date<g.gold_signup_date)a
where rnk=1;


# Rank all the transactions of the customer
select *, rank() over(partition by userid order by created_date) as rnk
from sales;

# Rank all the transactions for each member whwnever they are a zomato gold member for every non gold member transaction
#mark as na
select s.*,rank() over(partition by userid order by created_date) rnk
from sales s 
join goldusers_signup g
on s.userid=g.userid
and s.userid<g.gold_signup_date;

