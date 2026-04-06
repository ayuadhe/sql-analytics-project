/*
===============================================================================
Change Over Time Analysis 
===============================================================================

Objective:
    - To analyze how revenue changes over time (yearly and monthly trends).
    - To identify seasonality patterns in sales performance.

SQL Functions Used:
    - Date Functions: DATE_TRUNC(), EXTRACT(), TO_CHAR()
    - Aggregate Functions: SUM(), COUNT()
===============================================================================
*/

-- 1. Yearly Revenue Trend
select 
	extract(year from order_date) as year,
	sum(sales_amount) as total_revenue,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_orders
from fact_sales
where order_date is not null
group by 1
order by 1 desc;

-- 2. Monthly Revenue Trend by Year
-- DATE_TRUNC (DATE)
select 
	date_trunc('month', order_date) as order_date,
	sum(sales_amount) as total_revenue,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_orders
from fact_sales
where order_date is not null
group by 1
order by 1 desc;

-- EXTRACT (INT)
select 
	extract(year from order_date) as year,
	extract(month from order_date) as month,
	sum(sales_amount)as total_revenue,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_orders
from fact_sales
where order_date is not null
group by 1, 2
order by 1 desc, 2 desc;

-- TO_CHAR (TEXT)
select 
	to_char(order_date, 'YYYY Month') as order_date,
	sum(sales_amount) as total_revenue,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_orders
from fact_sales
where order_date is not null
group by 1
order by 1 desc;


