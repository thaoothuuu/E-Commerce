
/* Table Salestarget
		target: sale target amount
*/

/* Table OrderDetails
		Amount: price of order
		Profit: profit made by the purchase
		quantity: quantity of purchase
*/

/* Table ListofOrrder */



/*SET DATE FORMAT*/
set dateformat dmy;

/*SALESTARGET*/
select top 20 * from Salestarget;

/*ORDERDETAILS*/
select top 20 * from OrderDetails;

/*LISTOFORDER*/
select top 20 * from ListofOrders;



/*CHECK NUMBER OF STATE*/
select COUNT(distinct State) as number_of_state
from ListofOrders;





/*CHECK NUMBER OF CITY*/
select COUNT(distinct City) as number_of_city
from ListofOrders;





/*FIND PERCENT OF MISSING VALUES IN ORDERDETAILS*/
select SUM(CAST(( case when  Amount = '' then 1 else 0 end) AS float))/COUNT(*) as mising_rate
from OrderDetails;





/*FIND PERCENT OF MISSING VALUES IN SALESTARGET*/
select SUM(CAST(( case when Target = '' then 1 else 0 end) AS float))/COUNT(*) as mising_rate
from Salestarget;






/*FIND PERCENT OF MISSING VALUES IN LISTOFORDER*/
select SUM(CAST(( case when State = '' then 1 else 0 end) AS float))/COUNT(*) as mising_rate
from ListofOrders;

select SUM(CAST(( case when State = '' then 1 else 0 end) AS float)) as mising
from ListofOrders;

select *
from ListofOrders 
where State = ''

delete from ListofOrders where State = ''

/*CHECK NUMBER OF MISSING VALUES AFTER DELETE ROW WITH ALL VALUES MISSING*/
select SUM(CAST(( case when State = '' then 1 else 0 end) AS float)) as mising
from ListofOrders;







/*JOIN ORDERDETAILS AND LISTOFORDER*/
select top 20 *
from OrderDetails od inner join ListofOrders lo
	on od.[Order ID] = lo.[Order ID];






/*TOP 5 ORDERID HAVE HIGHEST SALES AMOUNT*/
select top 5 od.[Order ID], lo.CustomerName, lo.[Order Date], lo.State,lo.City,
			SUM(CAST(od.Amount as float)) as Total_amount,
			SUM(CAST(od.Profit as float)) as Total_profit
from OrderDetails od inner join ListofOrders lo
	on od.[Order ID] = lo.[Order ID]
group by od.[Order ID], lo.CustomerName, lo.[Order Date], lo.State,lo.City
order by SUM(CAST(od.Amount as float)) desc








/*MONTHLY SALES AMOUNT, PROFIT, CACULATE RETURN ON SALE */
select  YEAR(CAST(lo.[Order Date] as date)) as year_order,
		MONTH(CAST(lo.[Order Date] as date)) as month_order,
		SUM(CAST(od.Amount AS float)) as Amount,
		SUM(CAST(od.Profit as float)) as Profit,
		ROUND(SUM(CAST(od.Profit as float))/SUM(CAST(od.Amount AS float)), 3) as ROS
from OrderDetails od inner join ListofOrders lo
		on od.[Order ID] = lo.[Order ID]
group by GROUPING SETS(
		(YEAR(CAST(lo.[Order Date] as date))),
		(YEAR(CAST(lo.[Order Date] as date)),MONTH(CAST(lo.[Order Date] as date)))
)order by 1, 2;






/*TOP 3 MONTH HAVE HIGHEST SALES AMOUNT*/
select top 3 CONVERT(nvarchar(7), CAST(lo.[Order Date] as date), 120) as month_order, 
			 SUM(CAST(od.Amount as float)) as Amonut,
			 SUM(CAST(od.Profit as float)) as Profit
from OrderDetails od inner join ListofOrders lo
			 on od.[Order ID] = lo.[Order ID]
group by CONVERT(nvarchar(7), CAST(lo.[Order Date] as date), 120)
order by SUM(CAST(od.Amount as float)) desc;







/*TOP 3 MONTH HAVE HIGHEST PROFIT*/
select top 3 CONVERT(nvarchar(7), CAST(lo.[Order Date] as date), 120) as month_order, 
			 SUM(CAST(od.Profit as float)) as Profit,
			 SUM(CAST(od.Amount as float)) as Amonut
from OrderDetails od inner join ListofOrders lo
			 on od.[Order ID] = lo.[Order ID]
group by CONVERT(nvarchar(7), CAST(lo.[Order Date] as date), 120)
order by SUM(CAST(od.Profit as float)) desc;








/*SALES GROWTH RATE IN 2018*/
with monthly_sale2018 as (	select	MONTH(CAST(lo.[Order Date] as date)) as Month_order, 
									SUM(CAST(od.Amount as float)) as Amount
							from OrderDetails od inner join ListofOrders lo
									on od.[Order ID] = lo.[Order ID]
							where YEAR(CAST(lo.[Order Date] as date)) = 2018
							group by MONTH(CAST(lo.[Order Date] as date))
), moving_sale2018 as (		select	Month_order,Amount, 
									LAG(Amount, 1) over(order by Month_order) as Amount_lastmonth
							from monthly_sale2018
), sale_growth_rate2018 as( select	Month_order, 
									Amount, 
									Amount_lastmonth, 
									ROUND(((Amount-Amount_lastmonth)/Amount_lastmonth),3) as Growth_rate
							from moving_sale2018
) select Month_order, Amount, Amount_lastmonth, Growth_rate
  from sale_growth_rate2018;








/*SALES GROWTH RATE IN 2019*/
with monthly_sale2019 as (  select  MONTH(CAST(lo.[Order Date] as date)) as Month_order, 
									SUM(CAST(od.Amount as float)) as Amount
							from OrderDetails od inner join ListofOrders lo
									on od.[Order ID] = lo.[Order ID]
							where YEAR(CAST(lo.[Order Date] as date)) = 2019
							group by MONTH(CAST(lo.[Order Date] as date))
), moving_sale2019 as    (  select  Month_order,Amount, 
									LAG(Amount, 1) over(order by Month_order) as Amount_lastmonth
							from monthly_sale2019
), sale_growth_rate2019 as( select  Month_order, 
									Amount, 
									Amount_lastmonth, 
									ROUND(((Amount-Amount_lastmonth)/Amount_lastmonth),3) as Growth_rate
							from moving_sale2019
) select Month_order, Amount, Amount_lastmonth, Growth_rate
  from sale_growth_rate2019;








/*MONTHLY SALES AMOUNT AND PROFIT BY STATE AND CITY*/
select  YEAR(CAST(lo.[Order Date] as date)) as year_order,
		MONTH(CAST(lo.[Order Date] as date)) as month_order,
		lo.State,
		lo.City,
		SUM(CAST(od.Amount AS float)) as Amount,
		SUM(CAST(od.Profit as float)) as Profit
from OrderDetails od inner join ListofOrders lo
		on od.[Order ID] = lo.[Order ID]
group by GROUPING SETS(
		(YEAR(CAST(lo.[Order Date] as date))),
		(YEAR(CAST(lo.[Order Date] as date)),MONTH(CAST(lo.[Order Date] as date))),
		(YEAR(CAST(lo.[Order Date] as date)),MONTH(CAST(lo.[Order Date] as date)), lo.State),
		(YEAR(CAST(lo.[Order Date] as date)),MONTH(CAST(lo.[Order Date] as date)), lo.State,lo.City)
)order by 1, 2, 3, 4;






/*MONTHLY SALES AMOUNT, PROFIT, QUANTITY BY CATEGORY AND SUB-CATEGORY*/
select  YEAR(CAST(lo.[Order Date] as date)) as year_order,
		MONTH(CAST(lo.[Order Date] as date)) as month_order,
		od.Category, 
		od.[Sub-Category],
		SUM(CAST(od.Amount AS float)) as Amount,
		SUM(CAST(od.Profit as float)) as Profit,
		SUM(CAST(od.Quantity as float)) as Quantity
from OrderDetails od inner join ListofOrders lo
		on od.[Order ID] = lo.[Order ID]
group by GROUPING SETS(
		(YEAR(CAST(lo.[Order Date] as date))),
		(YEAR(CAST(lo.[Order Date] as date)),MONTH(CAST(lo.[Order Date] as date))),
		(YEAR(CAST(lo.[Order Date] as date)),MONTH(CAST(lo.[Order Date] as date)), od.Category),
		(YEAR(CAST(lo.[Order Date] as date)),MONTH(CAST(lo.[Order Date] as date)), od.Category, od.[Sub-Category])
)order by 1, 2, 3, 4;







/*SALES AMOUNT, PROFIT, QUANTITY, RETURN ON SALE BY CATEGORY AND SUB-CATEGORY */
select  od.Category,
		od.[Sub-Category],
		SUM(CAST(od.Amount AS float)) as Amount,
		SUM(CAST(od.Profit as float)) as Profit,
		ROUND(SUM(CAST(od.Profit as float))/SUM(CAST(od.Amount AS float)), 3) as ROS,
		SUM(CAST(od.Quantity as float)) as Quantity
from OrderDetails od inner join ListofOrders lo
		on od.[Order ID] = lo.[Order ID]
group by GROUPING SETS(
		(od.Category),
		(od.Category, od.[Sub-Category])
)order by 1, 2;







/*SALES AMOUNT, PROFIT, RETURN ON SALES BY STATE AND CITY*/
select  lo.State,
		lo.City,
		SUM(CAST(od.Amount AS float)) as Amount,
		SUM(CAST(od.Profit as float)) as Profit,
		ROUND(SUM(CAST(od.Profit as float))/SUM(CAST(od.Amount AS float)),3) as ROS
from OrderDetails od inner join ListofOrders lo
		on od.[Order ID] = lo.[Order ID]
group by GROUPING SETS(
		(lo.State),
		(lo.State, lo.City)
)order by 1, 2;







/*SALES AMOUNT, PROFIT OF CATEGORY AND SUB-CATEGORY BY STATE AND CITY*/
select  lo.State,
		lo.City,
		od.Category, 
		od.[Sub-Category],
		SUM(CAST(od.Amount AS float)) as Amount,
		SUM(CAST(od.Profit as float)) as Profit
from OrderDetails od inner join ListofOrders lo
		on od.[Order ID] = lo.[Order ID]
group by GROUPING SETS(
		(lo.State),
		(lo.State, lo.City),
		(lo.State, lo.City, od.Category),
		(lo.State, lo.City, od.Category, od.[Sub-Category])
)order by 1, 2, 3, 4;






/*SALES AMOUNT OF CLOTHING COMPARE TO SALES TARGET*/
with Clothing_monthly_sales as ( select CONVERT(nvarchar(7), CAST(lo.[Order Date] as date), 120) as month_order,
										SUM(CAST(od.Amount as float)) as Amount
								 from OrderDetails od inner join ListofOrders lo
										on od.[Order ID] = lo.[Order ID]
								 where od.Category = 'Clothing'
								 group by CONVERT(nvarchar(7), CAST(lo.[Order Date] as date), 120)
), Clothing_target_sales as    ( select CAST(Target AS float) as Target,
										CONVERT(nvarchar(7), cast( CONVERT( nvarchar(3), [Month of Order Date] ,120) + (case when [Month of Order Date] like '%18%' then '2018' else '2019' end) as date), 120) as month_order
								 from Salestarget
								 where Category = 'Clothing'
)   select ms.month_order, ms.Amount, ts.Target, ROUND(ms.Amount/ts.Target,3) as Achieve
	from Clothing_monthly_sales ms inner join Clothing_target_sales ts 
		on ms.month_order = ts.month_order;






/*SALES AMOUNT OF ELECTRONICS COMPARE TO SALES TARGET*/
with Electronics_monthly_sales as ( select CONVERT(nvarchar(7), CAST(lo.[Order Date] as date), 120) as month_order,
										SUM(CAST(od.Amount as float)) as Amount
								 from OrderDetails od inner join ListofOrders lo
										on od.[Order ID] = lo.[Order ID]
								 where od.Category = 'Electronics'
								 group by CONVERT(nvarchar(7), CAST(lo.[Order Date] as date), 120)
), Electronics_target_sales as    ( select CAST(Target AS float) as Target,
										CONVERT(nvarchar(7), cast( CONVERT( nvarchar(3), [Month of Order Date] ,120) + (case when [Month of Order Date] like '%18%' then '2018' else '2019' end) as date), 120) as month_order
								 from Salestarget
								 where Category = 'Electronics'
)   select ms.month_order, ms.Amount, ts.Target, ROUND(ms.Amount/ts.Target,3) as Achieve
	from Electronics_monthly_sales ms inner join Electronics_target_sales ts 
		on ms.month_order = ts.month_order;










/*SALES AMOUNT OF FURNITURE COMPARE TO SALES TARGET*/
with Furniture_monthly_sales as ( select CONVERT(nvarchar(7), CAST(lo.[Order Date] as date), 120) as month_order,
										SUM(CAST(od.Amount as float)) as Amount
								 from OrderDetails od inner join ListofOrders lo
										on od.[Order ID] = lo.[Order ID]
								 where od.Category = 'Furniture'
								 group by CONVERT(nvarchar(7), CAST(lo.[Order Date] as date), 120)
), Furniture_target_sales as    ( select CAST(Target AS float) as Target,
										CONVERT(nvarchar(7), cast( CONVERT( nvarchar(3), [Month of Order Date] ,120) + (case when [Month of Order Date] like '%18%' then '2018' else '2019' end) as date), 120) as month_order
								 from Salestarget
								 where Category = 'Furniture'
)   select ms.month_order, ms.Amount, ts.Target, ROUND(ms.Amount/ts.Target,3) as Achieve
	from Furniture_monthly_sales ms inner join Furniture_target_sales ts 
		on ms.month_order = ts.month_order;
