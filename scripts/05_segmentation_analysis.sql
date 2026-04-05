/*
===============================================================================
Segmentation Analysis 
===============================================================================

Objective:
    - To segment products into cost ranges for pricing analysis
    - To segment customers based on their purchase lifespan
    - To support targeted strategies such as pricing, retention, and marketing

SQL Functions Used:
    - Conditional Logic: CASE WHEN
    - Aggregate Functions: SUM(), COUNT(), MIN(), MAX()
    - Date Functions: AGE(), EXTRACT()
    - Joins: LEFT JOIN

===============================================================================
*/

-- 1. Product Segmentation by Cost
-- Segment products based on cost range
with product_segments as (
	select 
		product_key,
		product_name,
		cost,
		case
			when cost < 100 then 'Below 100'
			when cost between 100 and 500 then '100-500'
			when cost between 501 and 1000 then '500-1000'
			else 'Above 1000'
		end as cost_range
	from dim_products
)
-- Count number of products in each cost segment
select
	cost_range,
	count(distinct product_key) as total_products
from product_segments
group by cost_range
order by total_products desc;


-- 2. Customer Segmentation by Lifespan
-- Calculate customer lifespan and total spending
with customer_lifespan as (
    select
        c.customer_key,
        sum(f.sales_amount) as total_spending,
        min(order_date) as first_order,
        max(order_date) as last_order,
        extract(year from age(max(order_date), min(order_date))) * 12 +
		extract(month from age(max(order_date), min(order_date))) as life_span
    from fact_sales f
    left join dim_customers c
        on f.customer_key = c.customer_key
    group by c.customer_key
),
-- Segment customers based on lifespan
segment as (
	select *,
		case
			when life_span = 0 then 'One Time'
			when life_span between 1 and 3 then 'Short_term'
			when life_span between 4 and 12 then 'Mid-term'
			else 'Long-term'
		end as customer_segment
	from customer_lifespan
)
-- Count number of customers in each segment
select
	customer_segment,
	count(customer_key) as total_customers
from segment
group by 1
order by total_customers desc;

