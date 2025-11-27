-- Я тут очень много поудалял в исходных таблицах вручную

CREATE TABLE customer (
customer_id int PRIMARY KEY,
first_name VARCHAR(100),
last_name VARCHAR(100),
gender VARCHAR(100),
DOB date,
job_title VARCHAR(100),
job_industry_category VARCHAR(100),
wealth_segment VARCHAR(100),
deceased_indicator VARCHAR(10),
owns_car VARCHAR(10),
address VARCHAR(100),
postcode VARCHAR(20),
state VARCHAR(100),
country VARCHAR(100),
property_valuation INT
);

create table product (
product_id int primary key,
brand VARCHAR(100),
product_line VARCHAR(100),
product_class VARCHAR(100),
product_size VARCHAR(100),
list_price float,
standard_cost float
);


CREATE TABLE orders (
order_id int PRIMARY KEY,
customer_id int not null,
order_date varchar(100),
online_order bool,
order_status varchar(100),
FOREIGN KEY (customer_id)
REFERENCES customer (customer_id)
ON DELETE CASCADE
);


create table order_items (
order_item_id int primary key,
order_id int not null,
product_id int not null,
quantity float,
item_list_price_at_sale float,
item_standard_cost_at_sale float,
FOREIGN KEY (order_id)
REFERENCES orders (order_id)
ON DELETE cascade,
FOREIGN KEY (product_id)
REFERENCES product (product_id)
ON DELETE CASCADE
);

-- 1 задание

SELECT p.brand
FROM product as p
JOIN order_items as o_i on o_i.product_id = p.product_id
WHERE p.standard_cost > 1500
GROUP BY p.brand
HAVING SUM(o_i.quantity) >= 1000;


-- 2 задание

SELECT d::date as order_date,
COUNT(o.order_id) as online_orders,
COUNT(DISTINCT o.customer_id) as uniq_cust
FROM generate_series('2017-04-01'::date,
'2017-04-09'::date,
'1 day') as d
LEFT JOIN orders o
ON o.order_date::date = d::date
AND o.online_order = TRUE
AND o.order_status = 'Approved'
GROUP BY d
ORDER BY order_date;

-- 3 задание


SELECT job_title
FROM customer
WHERE job_industry_category = 'IT'
AND job_title ILIKE 'Senior%'
AND DATE_PART('year', AGE(DOB)) > 35

UNION ALL

SELECT job_title
FROM customer
WHERE job_industry_category = 'Financial Services'
AND job_title ILIKE 'Lead%'
AND DATE_PART('year', AGE(DOB)) > 35;


-- 6 задание


WITH rec as (
SELECT DISTINCT customer_id
FROM orders
WHERE online_order = TRUE
AND order_status = 'Approved'
AND order_date::date >= CURRENT_DATE - INTERVAL '1 year' -- тут подсмотрел функ
)
SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
LEFT JOIN rec r ON r.customer_id = c.customer_id
WHERE r.customer_id IS NULL
AND c.owns_car = 'Yes'
AND c.wealth_segment <> 'Mass Customer';


-- 7 задание


WITH top as (
SELECT product_id
FROM product
WHERE product_line = 'Road'
ORDER BY list_price desc
LIMIT 5
),
cnt as (
SELECT o.customer_id,
COUNT(DISTINCT oi.product_id) as cnt
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE oi.product_id IN (SELECT product_id FROM top)
GROUP BY o.customer_id
HAVING COUNT(DISTINCT oi.product_id) = 2
)
SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
JOIN cnt cc on cc.customer_id = c.customer_id
WHERE c.job_industry_category = 'IT';

-- 8 задание

WITH per as (
SELECT o.order_id, o.customer_id
FROM orders o
WHERE o.order_status = 'Approved'
AND o.order_date::date BETWEEN '2017-01-01' AND '2017-03-01'
),
cust_rev as (
SELECT p.customer_id,
COUNT(DISTINCT p.order_id) as ord_cnt,
SUM(oi.item_list_price_at_sale * oi.quantity) as rev
FROM per p
JOIN order_items oi ON oi.order_id = p.order_id
GROUP BY p.customer_id
HAVING COUNT(DISTINCT p.order_id) >= 3
AND SUM(oi.item_list_price_at_sale * oi.quantity) > 10000
),
eli as (
SELECT c.customer_id,
c.first_name,
c.last_name,
c.job_industry_category
FROM customer c
JOIN cust_rev cr ON cr.customer_id = c.customer_id
WHERE c.job_industry_category IN ('IT','Health')
)
SELECT customer_id, first_name, last_name, job_industry_category
FROM eli
WHERE job_industry_category = 'IT'

UNION

SELECT customer_id, first_name, last_name, job_industry_category
FROM eli
WHERE job_industry_category = 'Health';
