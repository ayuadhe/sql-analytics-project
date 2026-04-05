/*
===============================================================================
Contribution Analysis (Part-to-Whole)
===============================================================================

Objective:
    - To analyze how each product contributes to total revenue
    - To identify top-performing and low-performing products based on revenue share
    - To understand revenue distribution across products (part-to-whole analysis)

SQL Functions Used:
    - Window Functions: SUM() OVER()
    - Aggregate Functions: SUM()
    - Numeric Functions: ROUND()
    - Joins: LEFT JOIN

===============================================================================
*/

-- Revenue Contribution by Product
with category_revenue as(
	select
		p.product_id,
		p.product_name,
		sum(f.sales_amount) as total_revenue
	from fact_sales f
	left join dim_products p
		using (product_key)
	group by 1, 2
)
select *,
	sum(total_revenue) over() as overall_revenue,
	-- pct Contribution
	round(
		total_revenue / sum(total_revenue) over():: numeric * 100
	, 2) as pct_contrib
from  category_revenue
order by pct_contrib desc;

