-- Total revenue 
select round(sum(payment_value), 2) as total_revenue 
from payments;


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
where  order_status = 'delivered'
  and order_delivered_customer_date is not null
  and order_estimated_delivery_date is not null;
  

-- Top product categories based on the number of delivered orders
select 
    p.product_category_name,
    count(distinct o.order_id) AS total_orders
from order_items o
join products p on o.product_id = p.product_id
join orders ord on o.order_id = ord.order_id
where ord.order_status = 'delivered'
group by p.product_category_name
order by total_orders DESC
limit 10;

-- top product category  using CTE+ window function
with category_orders as (
     select p.product_category_name,
            count(distinct oi.order_id) as total_orders
     from order_items oi
     join products p on oi.product_id = p.product_id
     join orders o on oi.order_id = o.order_id
     where o.order_status = 'delivered'
     group by p.product_category_name)
select 
    product_category_name,
    total_orders,
    rank() over(order by total_orders desc) as rank_orders
from category_orders
order by rank_orders
limit 10;

-- top states by revenue
select c.customer_state,
       round(sum(p.payment_value),2) as total_payments
from customers c
join orders o on c.customer_id = o.customer_id
join payments p on o.order_id = p.order_id
where o.order_status = 'delivered'
group by c.customer_state
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
select o.order_id, SUM(oi.freight_value) AS total_freight
from order_items oi
join orders o on oi.order_id = o.order_id
group by o.order_id
order by total_freight desc
limit 1;

--  Percentage of each order status
select 
    order_status,
    count(order_id) as total_orders,
    round(count(order_id) / total_orders.total * 100, 2) as percentage
from orders
join (
    select count(*) as total
    from orders
) as total_orders
group by order_status, total_orders.total
order by total_orders desc;

-- Rank cities by total orders
select 
    customer_city,
    count(order_id) as total_orders,
    rank() over(order by count(order_id) desc) as city_rank
from orders o
join customers c on o.customer_id = c.customer_id
group by customer_city
order by city_rank
limit 10; 

-- Monthly revenue trend with running total
with monthly_revenue AS (
    select date_format(o.order_purchase_timestamp, '%Y-%m') as month,
           round(sum(p.payment_value), 2) as revenue
    from orders o
    join payments p on o.order_id = p.order_id
    group by month)
select month,
       revenue,
       sum(revenue) over (order by month) as running_total
from monthly_revenue
order by month;

-- States with revenue above average
with state_revenue as (
    select
        c.customer_state,
        round(sum(p.payment_value), 2) as total_payments
    from customers c
    join orders o on c.customer_id = o.customer_id
    join payments p on o.order_id = p.order_id
    where o.order_status = 'delivered'
    group by c.customer_state
    order by total_payments desc
)
select *
from state_revenue
where total_payments > (
    select avg(total_payments) 
    from state_revenue
);
