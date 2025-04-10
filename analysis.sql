select * from orders o 

-- Remove duplicates

with DuplicatedRows
as
(
	select 
		order_id,
		row_number() over (partition by order_id) as row_Num
	from orders o 
)
delete from DuplicatedRows
where rowNum > 1


-- The 10 cities with the highest order returns

select 
	delivery_city,
	sum(order_return) as nr_of_returns
from orders o
group by delivery_city
order by nr_of_returns desc
limit 10

-- The 10 cities with the smallest order returns

select 
	delivery_city,
	sum(order_return) as nr_of_returns
from orders o
group by delivery_city
order by nr_of_returns asc
limit 10

-- Which customer returned the most?

select 	
	o.customer_id,
	c.customer_name,
	sum(o.order_return) as returns
from orders o 
inner join customers c on o.customer_id = c.customer_id 
group by o.customer_id, c.customer_name
order by returns desc
limit 1

-- How does it look returns in shipping mode?

select 
	shipping_mode
	,sum(order_return) as returns
from orders
group by shipping_mode

-- Check the first and the last order in shipping mode = Standard Class and the earliest date is smaller than 01/01/2021.

select 
	delivery_state
	,max(order_date) as last_order
	,min(order_date) as first_order
from orders 
where shipping_mode = 'Standard Class'
group by 1
having max(order_date) < date('2021-01-01')

-- Show the ratio of number of orders in delivery country and shipping mode.

select 
	o.delivery_country 
	,o.shipping_mode 
	,ds.nr_of_orders_ds 
	,count(o.order_id) as nr_of_orders
	,round((count(o.order_id)/ds.nr_of_orders_ds) * 100, 1) as ds_radio 
from orders o
inner join
	(
	select 
	 delivery_country
	,count(order_id) as nr_of_orders_ds
	from orders
	group by 1
	) ds on ds.delivery_country = o.delivery_country
group by 1, 2, 3
order by delivery_country

-- I will show total sales in every year and I will also show percentage of sales for each value of sales. It shows which sales were the highest or the lowest.

select
	cost_year 
	,sales
	,sum(sales) over(partition by cost_year) as value_of_sales 
	,round(sales/sum(sales) over(partition by cost_year) * 100, 2) as percantage_of_sales
from cost_forecast cf 
order by value_of_sales desc

-- Show the ranking with greatest number of returns in each year

select 
	year(order_date) as year_of_return
	,sum(order_return) as returns
	,dense_rank() over(partition by year(order_date) order by sum(order_return) desc) as ranking_of_returns
from orders o 
group by order_date

--  Show the number of orders for years
select 
	date_format(order_date, "%Y") as o_date
	,count(order_id) as nr_of_orders
from orders
group by o_date
order by o_date

-- Show the number of returns for years
select 
	date_format(order_date, "%Y") as o_date
	,sum(order_return) as returns
from orders
group by o_date
order by o_date
