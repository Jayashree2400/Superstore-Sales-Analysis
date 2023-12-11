use Superstore

select * from Superstore
select * from category
select * from shipment

--- 1. Checking for null values ----

select [Order ID], count(*) as no_of_rows
from superstore
group by [Order ID]
having count(*) > 1
order by no_of_rows desc

--- Distinct Order ID ---

select count(distinct [Order ID])
from Superstore

--- 2. Region that makes more profit ---

select Region, sum(profit) as profit
from Superstore
group by Region
order by profit desc

--- 3. Which state makes more profit ---

select State, sum(profit) as profit
from Superstore
group by State
order by profit desc

--- 4. Which category makes more profit ---

select SUM(profit) as profit, Category
from Superstore s
join Category c on c.[Sub-Category] = s.[Sub-Category]
group by Category
order by profit desc


--- 5. Most purchased Items across all stores ---

select [Product ID], [Product Name], sum(Sales) as total_sales
from Superstore
group by [Product ID], [Product Name]
order by total_sales desc


--- 6. 20 most profitable products of the store ---

select *
from (
select [Product ID],[Product Name], Category, cast(sum(Profit) as decimal) total_profit,
ROW_NUMBER() over(order by sum(profit) desc) as rn
from Superstore s
join Category c on c.[Sub-Category] = s.[Sub-Category]
group by [Product ID],[Product Name],Category)x
where x.rn <= 20

--- 7. Top five sub Category by profit ---

select *
from (
select c.[Sub-Category], c.Category, cast(sum(Profit) as decimal) total_profit, 
ROW_NUMBER() over(order by sum(profit) desc) as rn
from Superstore s
join Category c on c.[Sub-Category] = s.[Sub-Category]
group by c.[Sub-Category], c.Category)x
where x.rn <= 5


-- 8. Top 5 products with highest Average sales ----

select  [Product ID], [Product Name], c.[Sub-Category],round(avg(sales),3) as AverageSales
from Superstore s
join Category c on c.[Sub-Category] = s.[Sub-Category]
group by [Product ID], [Product Name], c.[Sub-Category]
order by AverageSales desc


--- 9. Top 10 loss making Products ---

with cte as (
select [Product Name], c.[Sub-Category], c.category,
sum(profit) as total_profit,
ROW_NUMBER() over(order by sum(profit)) as rn
from Superstore s
join Category c on c.[Sub-Category] = s.[Sub-Category]
group by [Product Name],c.Category, c.[Sub-Category])


select *
from cte
where cte.rn <= 10


--- 10. Which segment has higher number of orders from each state ----

with cte1 as
(
select  Segment, State, count([Order ID]) as total_orders
from Superstore
group by Segment, State
),

cte2 as 
(
select state, max(total_orders) as max_orders
from cte1
group by State
)

select a.state, a.Segment, a.total_orders
from cte1 a 
join cte2 b on b.State = a.State
and a.total_orders = b.max_orders
order by state desc


--- 11. Total Sales and profit by region ---

select Region, sum(Sales) as total_sales, sum(Profit) as total_profit
from Superstore
group by Region



--- 12. Top 5 customer by total spending ----

select [Customer ID], [Customer Name], sum(Sales) as total_spending
, category, s.[Sub-Category] as total_spending
from Superstore s
join Category c on c.[Sub-Category] = s.[Sub-Category]
group by [Customer ID], [Customer Name], category, s.[Sub-Category]
order by 3 desc

--- 13. Most Revenue generating Category and Sub Category in Each Region ----

with  MostRevenue as (
select region, category, c.[Sub-Category],
sum(sales) as total_revenue,
row_number() over(partition by region order by sum(sales) desc) as rank
from Superstore s
join Category c on c.[Sub-Category] = s.[Sub-Category]
group by region, category, c.[Sub-Category]
)

select
region, category, [Sub-Category]
from MostRevenue
where rank = 1

--- 14. Which are the Top 15 States with the Most Orders including average order value and profit per order? ---

select top 15 state, region, count(*) as total_orders,
round(avg(sales),2) as avg_order_value,
round(avg(profit),2) as avg_profit_value
from Superstore 
group by state, region
order by 3 desc

--- 15. What is the wait time between placing an order and order shipment

select 
--distinct ss.[order ID],
avg(datediff(day, [Order Date], [Ship Date])) as shipping_days
from superstore ss  
join shipment sp on ss.[Order ID] = sp.[Order ID]

--- 16. which order category has the highest likehood of being shipped via first class --

select c.category, count(distinct sh.[order id]) as no_of_times
from shipment sh
join superstore ss on ss.[Order ID] = sh.[Order ID]
join Category c on c.[Sub-Category] = ss.[Sub-Category]
where sh.[ship Mode] = 'First Class'
group by c.category
order by count(*) desc

--- 17. What percentage of orders is associated with each shipment type? ---

select sp.[Ship Mode], count(*) as total_orders,
round((count(*)*100.00 / (select count(*) from superstore)),2) as '%'
from superstore s
join shipment sp on sp.[Order ID] = s.[Order ID]
group by [ship mode]
order by 3 desc


--- 18. Cal the profit for each state and sub category for year 2015---

select state, [Sub-Category],
sum(profit) as total_profit
from superstore
where year([Order date]) = '2015'
group by state, [Sub-category]
order by 3 desc

---- 19. Find 5 sub_categories which have performed low in 2014 ----

select top 5 region, [Sub-Category],
sum(profit) as total_profit
from superstore
where year([Order date]) = '2014'
group by region, [Sub-category]
order by 3 asc


--- 20. Marketing Manager of Furniture category wants to start a discount coupon. 
------- Find out which states need this type of strategy. ------------------


select 
state, 
c.category, 
sum(sales) as total_sales,
sum(profit) as total_profit
from superstore s
join category c on c.[Sub-category] = s.[Sub-Category]
where category = 'Furniture'
group by c.category,state
order by 3,4


--- 21. Find a region having maximum number of customers? -----
select * from Superstore


select Region, count(distinct [Customer Name]) as no_of_customers
from Superstore
group by region 
order by no_of_customers desc



--- 22. Calculating Frequency of each order id by each customer Name in descending order? ----

select [Order ID], [Customer Name], count([Order ID]) as total_order_id
from Superstore
group by [Order ID], [Customer Name]
order by total_order_id desc



--- 23.  Display the records for customers who live in state California and Have postal code 90032? ---

select *
from Superstore
where State = 'California' and [Postal Code] = '90032'


--- 24. Which states had the maximum and minimum sales in 2014? -----

select * from(
select top 1 state, sum(Sales) as total_sales
from Superstore
where year([Order Date]) = '2014'
group by State
order by 2 asc)x
union
select * from
(select top 1 state, sum(Sales) as total_sales
from Superstore
where year([Order Date]) = '2014'
group by State
order by 2 desc)y

--- 25. Top 5 subcategory that have max profit margin ---

select top 5 c.[Sub-Category], round((sum(profit)/sum(Sales))*100,2) as profit_margin
from Superstore s
join Category c on c.[Sub-Category] = s.[Sub-Category]
group by c.[Sub-Category]
order by profit_margin desc



--- 26. Compare the sales in 2014 and 2015 by Sub Category. ---


with sales2014 as(

select c.[Sub-Category], cast(sum(Sales) as int)  as total_sales_2014
from Superstore s
join Category c on c.[Sub-Category] = s.[Sub-Category]
where year([Order Date]) = '2014'
group by c.[Sub-Category]
),
sales2015 as(

select c.[Sub-Category], cast(sum(Sales) as int) as total_sales_2015
from Superstore s
join Category c on c.[Sub-Category] = s.[Sub-Category]
where year([Order Date]) = '2015'
group by c.[Sub-Category]
)

select s14.[Sub-Category], 
total_sales_2014, total_sales_2015, 
format((total_sales_2015 - total_sales_2014), 'C0') as diff_2014_2015
from
sales2014 s14
join sales2015 s15 on s15.[Sub-Category] = s14.[Sub-Category]
order by diff_2014_2015 desc



--- 27. What are the top 2 sub categories in every region by most sales? ----

select * from
(select *,
RANK() over(partition by region order by sales desc) as sales_rank
from
(select [Sub-Category], Region, sum(Sales) as sales
from Superstore
group by [Sub-Category], Region)x)y
where y.sales_rank < 3
order by Region, sales desc


--- 28. What are the 2 worst selling products in each region? ---
select * from (
select *,
rank() over(partition by region order by sales) as sales_rank
from(
select [Sub-Category], Region, sum(Sales) as sales
from superstore
group by [Sub-Category], Region)x)z
where z.sales_rank < 3
order by Region,sales 


--- 29.  How is Sales and Profit Growth YoY? -----

with cte as
(
select 
year([Order Date]) as year,
convert(decimal, sum(sales)) as total_sales,
cast(sum(profit) as decimal) as total_profit
from superstore
group by year([Order Date])
),

yoy as
(
select
year,
total_sales,
total_profit,
lag(total_sales) over(order by year) as previous_year_sales,
lag(total_profit) over(order by year) as previous_year_profit
from cte
),

yoy_percentage as
(
select 
year,
total_sales,
total_profit,
previous_year_sales,
previous_year_profit,
format((total_sales/previous_year_sales) *100,'P0') as sales_percentage,
format((total_profit/previous_year_profit) *100, 'P0')as profit_percentage
from yoy
)

select
year,
total_sales,
total_profit,
sales_percentage,
profit_percentage
from yoy_percentage

--- 30. How are Category and Region-wise YoY growth for the Superstore? -----
with bte as
(
select 
year([Order Date]) as year,
c.Category,
Region,
convert(decimal,sum(Sales)) as total_sales,
cast(sum(Profit) as decimal) as total_profit
from Superstore s
join Category c on c.[Sub-Category] = s.[Sub-Category]
group by YEAR([Order Date]), Category, Region
),

yoy as (
select
year,
Category,
region,
total_sales,
total_profit,
lag(total_sales) over(partition by region,category order by year) as previous_total_sales,
lag(total_profit) over(partition by region,category order by year) as previous_total_profit
from bte
),

yoy_percentage as(
select
year,
Category,
region,
total_sales,
total_profit,
previous_total_sales,
previous_total_profit,
format((total_sales/previous_total_sales-1)*100,'P0') as sales_percentage,
format((total_profit/previous_total_profit-1)*100,'P0') as profit_percentage
from yoy
)

select
year,
Category,
region,
total_sales,
total_profit,
previous_total_sales,
previous_total_profit,
sales_percentage,
profit_percentage
from yoy_percentage

--- 32. What is the Rolling average for the year 2015 ---

with cte as
(

select MONTH([Order Date]) as month,
round(cast(sum(sales) as float),2) as total_sales
from Superstore
where year([Order Date]) = '2015'
group by MONTH([Order Date])
)

select
month,
total_sales,
cast(AVG(total_sales) over(order by month) as decimal) as average
from cte















































































































































































