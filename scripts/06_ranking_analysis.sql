/*
================================================================================
Ranking Analysis
================================================================================

Objective:
     - To identify top and bottom performing products by revenue
     - To identify top customers by revenue
     - To identify low-engagement customers based on order frequency
     - To support business decisions such as product optimization and customer targeting

SQL Functions Used:
     - Window Functions    : RANK() OVER()
     - Aggregate Functions : SUM(), COUNT()
     - Joins               : LEFT JOIN
     - Conditional         : LIMIT, WHERE

================================================================================
*/

-- 1. Top 5 Products by Revenue (Simple Ranking)
select
	p.product_key,
	p.product_name,
	sum(f.sales_amount) as total_revenue
from fact_sales f
left join dim_products p 
	using (product_key)
group by 1, 2
order by total_revenue desc
limit 5;


-- 2. Top 5 Products by Revenue (Using RANK)
select *
from (
	select 
		p.product_key,
		p.product_name,
		sum(f.quantity) as total_orders,
		sum(f.sales_amount) as total_revenue,
		rank() over(order by sum(f.sales_amount) desc) as top_rnk
	from fact_sales f
	left join dim_products p
		using (product_key)
	group by 1,2
)t
where top_rnk <= 5;


-- 3. Bottom 5 Products by Revenue (Using RANK)
select *
from (
	select
		p.product_key,
		p.product_name,
		sum(f.quantity) as total_orders,
		sum(f.sales_amount) as total_revenue,
		rank() over(order by sum(f.sales_amount) asc) as bottom_rnk
	from fact_sales f
	left join dim_products p
		using (product_key)
	group by 1, 2
) t
where bottom_rnk <= 5;


-- 4. 7 Customers with Lowest Order Frequency
select
	c.customer_id,
	c.first_name,
	c.last_name,
	count(distinct order_number) as total_orders
from fact_sales f
left join dim_customers c
	using (customer_key)
group by 1, 2, 3
order by count(distinct order_number) asc
limit 7;


-- 5. Top 15 Customers by Total Revenue
select
	c.customer_id,
	c.first_name,
	c.last_name,
	sum(f.sales_amount) as total_revenue
from fact_sales f
left join dim_customers c
	using (customer_key)
group by 1, 2, 3
order by sum(f.sales_amount) desc
limit 15;



