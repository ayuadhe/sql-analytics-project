/*
================================================================================
Performance Analysis
================================================================================

Objective:
     - To measure Month-over-Month (MoM) revenue growth trends
     - To measure Year-over-Year (YoY) revenue growth trends
     - To compare yearly product revenue to its historical average

SQL Functions Used:
     - Window Functions : LAG() OVER(), AVG() OVER()
     - Aggregate Functions : SUM(), COUNT()
     - Date Functions : DATE_TRUNC(), EXTRACT()
     - Date Functions : DATE_TRUNC(), EXTRACT()
     - Joins : LEFT JOIN
     - Conditional : CASE WHEN, NULLIF()

================================================================================
*/

-- 1. MoM Growth
with monthly_revenue as(
	select 
		date_trunc('month', order_date) as order_date,
		count(distinct customer_key) as total_customers,
		sum(quantity) as total_orders,
		sum(sales_amount) as total_revenue,
		lag(sum(sales_amount)) over(order by date_trunc('month', order_date)) as prev_month_revenue
	from fact_sales
	where order_date is not null
	group by 1
)
select 
	order_date,
	total_customers,
	total_orders,
	total_revenue,
	prev_month_revenue,
	-- absolute MoM growth
	total_revenue - prev_month_revenue as mom_growth,
	-- pct MoM growth
	round((total_revenue - prev_month_revenue) :: numeric
		/ nullif(prev_month_revenue, 0) * 100, 2)
	as mom_pct_growth
from monthly_revenue
order by order_date;


-- 2. YoY Growth
with yearly_revenue as(
	select
		date_trunc('year', order_date) as year,
		count(distinct date_trunc('month', order_date)) as months_count,
		count(distinct customer_key) as total_customers,
		sum(quantity) as total_orders,
		sum(sales_amount) as current_revenue,
		lag(sum(sales_amount)) over (order by date_trunc('year', order_date)) as prev_revenue
	from fact_sales
	where order_date is not null
	group by 1
)
select 
	year,
	total_customers,
	total_orders,
	current_revenue,
	prev_revenue,
	-- absolute YoY growth
	current_revenue - prev_revenue as yoy_growth,
	-- pct YoY growth
	round(
		(current_revenue - prev_revenue) :: numeric
			/ nullif(prev_revenue, 0) * 100
	, 2) as yoy_pct_growth
from yearly_revenue
where months_count = 12
order by year;


-- 3. Yearly Product Revenue vs Historical Avg
with yearly_product_revenue as(
	select
		extract(year from f.order_date) as year,
		p.product_name as product,
		sum(f.sales_amount) as total_revenue
	from fact_sales f
	left join dim_products p
		using (product_key)
	where f.order_date is not null
	group by 1,2
),
with_avg as(
	select *,
		avg(total_revenue) over (partition by product) as avg_revenue
	from yearly_product_revenue
)
select 
	year,
	product,
	total_revenue,
	round(avg_revenue:: numeric, 2) as avg_revenue,
	total_revenue - round(avg_revenue:: numeric, 2) as diff_avg,
	case
		when total_revenue > avg_revenue then 'Above Average'
		when total_revenue < avg_revenue then 'Below Average'
		else 'No Change'
	end as growth
from with_avg
order by product, year;


