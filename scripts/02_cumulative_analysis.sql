/*
===============================================================================
Cumulative Analysis
===============================================================================

Objective:
    - To calculate cumulative revenue growth (running total)
    - To analyze average revenue trends over time (moving average)
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
    - Aggregate Functions: SUM(), AVG()
    - Date Functions: DATE_TRUNC()


===============================================================================
*/

-- Yearly Trend Analysis
with yearly_revenue as
(
	select
		date_trunc('year', order_date) as year,
		sum(sales_amount) as total_revenue
	from fact_sales
	where order_date is not null
	group by 1
)
select
	year,
	total_revenue,
	-- Running Total
	sum(total_revenue) over(order by year) as running_total,
	-- Moving Avg (2-Year Trend)
	round(avg(total_revenue) over(order by year rows between 1 preceding and current row),2) as moving_avg_2yr
from yearly_revenue
order by year
;


-- Monthly Trend Analysis
with monthly_revenue as
(
	select 
		date_trunc('month', order_date) as order_date,
		sum(sales_amount) as total_revenue
	from fact_sales
	where order_date is not null
	group by 1
)
select
	order_date,
	total_revenue,
	-- Running Total
	sum(total_revenue) over (order by order_date) as running_total,
	-- Moving Avg (3-Month Trend)
	round(avg(total_revenue) over (order by order_date rows between 1 preceding and current row),2) as moving_avg_2m
from monthly_revenue
order by order_date
;

