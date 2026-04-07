/*
===============================================================================
Pareto Analysis (80/20 Rule) 
===============================================================================

Objective:
    - To identify top products contributing to 80% of total revenue
    - Useful for prioritizing high-impact products in business decisions

SQL Functions Used:
    - Window Functions    : SUM() OVER(), COUNT() OVER()
    - Aggregate Functions : SUM()
    - Numeric Functions   : ROUND()
    - Conditional         : WHERE
    - Joins               : LEFT JOIN

===============================================================================
*/

-- Calculate total revenue per product
with product_revenue as (
	select
		p.product_id,
		p.product_name,
		sum(f.sales_amount) as total_revenue
	from fact_sales f
	left join dim_products p
		using (product_key)
	group by 1, 2
),

-- Pareto calculation
pareto_calc as (
	select
		product_id,
		product_name,
		total_revenue,
	
		-- Cumulative revenue
		sum(total_revenue) over (order by total_revenue desc) as cumulative_revenue,
	
		-- Overall revenue
		sum(total_revenue) over () as overall_revenue,
	
		-- Cumulative pct
		round(
		sum(total_revenue) over (order by total_revenue desc) 
			/ sum(total_revenue) over () :: numeric 
		, 2) as cumulative_pct,

		-- Cumulative product count
		count(*) over(order by total_revenue desc) as cumulative_products
	from product_revenue
)

-- Filter top contributors (80% Revenue)
select *
from pareto_calc
where cumulative_pct <= 0.8
order by total_revenue desc;
