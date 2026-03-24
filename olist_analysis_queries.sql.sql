-- Total revenue 
select round(sum(payment_value), 2) as total_revenue from payments;

-- Montly orders
select date_format(order_purchase_timestamp, '%Y-%M') AS month,
	count(order_id) as total_orders
from orders
group by month
order by month;

-- late delivery rate
select round(sum(if (order_delivered_customer_date > order_estimated_delivery_date, 1,0 )) / count(order_id) * 100, 2) 
as late_delivery_rate 
from orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
  
-- top product categories
select p.product_category_name,
       count(o.order_id) as total_orders
from order_items o
join products p on o.product_id = p.product_id
group by p.product_category_name
order by total_orders desc
limit 10;

-- top product category  using CTE+ window function
with category_orders as (
     select p.product_category_name,
            count(oi.order_id) as total_orders
     from order_items oi
     join products p on oi.product_id = p.product_id
     group by p.product_category_name)
select 
    product_category_name,
    total_orders,
    rank() over(order by total_orders desc) as rank_orders
from category_orders
order by rank_orders
limit 10;

-- top states by revenue
select s.customer_state,
       sum(p.payment_value) as total_payments
from customers s
join orders o on s.customer_id = o.customer_id
join payments p on o.order_id = p.order_id
group by s.customer_state
order by total_payments desc
limit 10;

-- payment method split
select payment_type,
       count(*) as total
from payments
group by payment_type
order by total desc;

-- top cities by orders
select g.geolocation_city,
       count(o.order_id) as total_orders
from orders o
join customers c on o.customer_id =c.customer_id
join geolocation g on c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
group by g.geolocation_city
order by total_orders desc
limit 10;

-- Average freight value per city
select c.customer_city,
       avg(oi.freight_value) as average_freight
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
group by c.customer_city
order by average_freight desc;

-- Orders by status
select order_status,
       count(order_id) as total
from orders
group by order_status
order by total desc;

-- Highest order by shipping cost
SELECT o.order_id, SUM(oi.freight_value) AS total_freight
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.order_id
ORDER BY total_freight DESC
LIMIT 1;

--  Percentage of each order status
SELECT 
    order_status,
    COUNT(order_id) AS total_orders,
    ROUND(COUNT(order_id) / total_orders.total * 100, 2) AS percentage
FROM orders
JOIN (
    SELECT COUNT(*) AS total
    FROM orders
) AS total_orders
GROUP BY order_status, total_orders.total
ORDER BY total_orders DESC;

-- Rank cities by total orders
SELECT 
    customer_city,
    COUNT(order_id) AS total_orders,
    RANK() OVER(ORDER BY COUNT(order_id) DESC) AS city_rank
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY customer_city
ORDER BY city_rank
LIMIT 10; 

-- Monthly revenue trend with running total
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
           ROUND(SUM(p.payment_value), 2) AS revenue
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY month)
SELECT month,
       revenue,
       SUM(revenue) OVER (ORDER BY month) AS running_total
FROM monthly_revenue
ORDER BY month;

-- States with revenue above average
SELECT customer_state, total_payments
FROM (
    SELECT c.customer_state,
           ROUND(SUM(p.payment_value), 2) AS total_payments
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_state
) AS state_revenue
WHERE total_payments > (SELECT AVG(payment_value) FROM payments);