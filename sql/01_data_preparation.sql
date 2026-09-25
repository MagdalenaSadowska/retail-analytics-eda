
SELECT *
FROM sales_orders
INNER JOIN products_mmmgmeum ON sales_orders.product_id=products_mmmgmeum.product_id
INNER JOIN inventory_mmmgkubv ON sales_orders.product_id=inventory_mmmgkubv.product_id;-- Joining all tables.
																					   -- I noticed that orders are duplicating because the same products are stored 
																					   -- in different warehouses.
																					   -- It would be useful to have information about which warehouse fulfilled a given order.
------------------------------------------------

SELECT sales_orders.product_id,order_date, quantity, unit_price,base_price, status
FROM sales_orders
INNER JOIN products_mmmgmeum ON sales_orders.product_id=products_mmmgmeum.product_id; -- Join for question 4

CREATE OR ALTER VIEW seasonality_VS_margin AS
SELECT sales_orders.product_id, order_date, quantity, unit_price, base_price, status
FROM sales_orders
INNER JOIN products_mmmgmeum ON sales_orders.product_id = products_mmmgmeum.product_id;

SELECT TOP 10 *
FROM seasonality_VS_margin;

SELECT *
FROM sales_orders
INNER JOIN inventory_mmmgkubv ON sales_orders.product_id=inventory_mmmgkubv.product_id; -- Join for questions 3,6

SELECT sales_orders.product_id, order_date, quantity,country, warehouse_country,stock_quantity, last_stock_update
FROM sales_orders
INNER JOIN inventory_mmmgkubv ON sales_orders.product_id=inventory_mmmgkubv.product_id -- Checking the structure of the table.

CREATE VIEW sales_inventory AS
SELECT sales_orders.product_id, order_date, quantity,country, warehouse_country,stock_quantity, last_stock_update
FROM sales_orders
INNER JOIN inventory_mmmgkubv ON sales_orders.product_id=inventory_mmmgkubv.product_id

SELECT TOP 10 *
FROM sales_inventory;


ALTER VIEW seasonality_VS_margin AS
SELECT sales_orders.product_id, category, order_date, quantity, unit_price, base_price, discount_pct,
       unit_price*quantity AS revenue, status
FROM sales_orders
INNER JOIN products_mmmgmeum ON sales_orders.product_id = products_mmmgmeum.product_id

SELECT YEAR(order_date) AS year,SUM(revenue) AS year_revenue
FROM seasonality_VS_margin
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) ASC;--Q1: Are prices really growing? (YoY)
								-- Result:Total revenue grows from ~25.4M (2015) to ~37.0M (2024),

SELECT YEAR(order_date) AS year,SUM(quantity) AS SUM_QUANTITY, CAST(ROUND(AVG(unit_price),2)AS decimal(10,2)) AS AVG_UNIT_PRICE
FROM seasonality_VS_margin
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) ASC;-- Revenue growth is mainly driven by rising prices, not volume.
							  -- Quantities are fairly stable (ranging between 161k and 174k),
						      -- while the average price increases consistently from 155 in 2015 to 212 in 2024.

SELECT product_id,order_date, SUM(quantity)AS SUM_quantity_product, SUM(stock_quantity) AS SUM_STOCK, warehouse_country, last_stock_update
FROM sales_inventory
WHERE YEAR(order_date) IN (2024)
GROUP BY product_id, order_date, last_stock_update, warehouse_country
ORDER BY product_id, order_date ASC; -- A fully reliable analysis is not entirely possible, because the data in last_stock_update does not align with order_date
						 --for example, we have an order from 2024
						 -- but a stock update from 2023, or an order from 2022
						 -- with inventory levels from 2024, which makes it difficult to draw meaningful conclusions from this data.

SELECT CONCAT(YEAR(order_date), '-', MONTH(order_date)) AS year_month, SUM(quantity) AS SUM_QUANTITY
FROM seasonality_VS_margin
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date),  MONTH(order_date) ; --Seasonality of sales for all products

SELECT CONCAT(YEAR(order_date), '-', MONTH(order_date)) AS year_month,CAST(ROUND(AVG(discount_pct), 2) AS decimal(10,2)) AS AVG_DISCOUNT, SUM(revenue) AS SUM_REVENUE, SUM(quantity) AS SUM_QUANTITY
FROM seasonality_VS_margin
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date),  MONTH(order_date); -- The correlation between discount and sales is not clear based on this data.

SELECT
  (AVG(disc * rev) - AVG(disc) * AVG(rev)) / 
  (STDEVP(disc) * STDEVP(rev)) AS correlation
FROM (
  SELECT
    CONCAT(YEAR(order_date), '-', MONTH(order_date)) AS ym,
    AVG(discount_pct) AS disc,
    SUM(revenue) AS rev
  FROM seasonality_VS_margin
  GROUP BY YEAR(order_date), MONTH(order_date)
) correlation; --correlation between discount and revenue



SELECT COUNT(*) AS products_in_multiple_warehouses
FROM (
  SELECT product_id
  FROM inventory_mmmgkubv
  GROUP BY product_id
  HAVING COUNT(DISTINCT warehouse_country) > 1
) t; --How many types of products are there in more than one country? 1224


SELECT COUNT(DISTINCT product_id) AS total_products
FROM inventory_mmmgkubv; --How many types of products we have? 2491

SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN ABS(DATEDIFF(DAY, order_date, last_stock_update)) > 365 THEN 1 ELSE 0 END) AS rows_over_1_year,
  CAST(ROUND(
    100.0 * SUM(CASE WHEN ABS(DATEDIFF(DAY, order_date, last_stock_update)) > 365 THEN 1 ELSE 0 END) / COUNT(*)
  , 1) AS decimal(5,1)) AS pct_over_1_year
FROM sales_inventory;

SELECT total_rows, rows_over_1_year, 100.0*rows_over_1_year/total_rows AS pct_over_1_year
FROM(
     SELECT
     COUNT(*) AS total_rows,
     SUM(CASE WHEN ABS(DATEDIFF(DAY, order_date, last_stock_update))>365 THEN 1 ELSE 0 END) AS rows_over_1_year
     FROM sales_inventory
     )
     per; --number of rows where the gap is over 365 days → 312,923 of 378,536 (82.7%). Shows stock dates are not aligned with orders.

SELECT
  AVG(ABS(DATEDIFF(DAY, order_date, last_stock_update))) AS avg_gap_days,
  MAX(ABS(DATEDIFF(DAY, order_date, last_stock_update))) AS max_gap_days
FROM sales_inventory; --average and maximum gap between the dates → avg ~1,542 days (4.2 y), max 3,647 days (10 y). 
					  --Confirms inventory data is unreliable



-------------------------------------------------------------------------------------------------
--Brainstorming 

SELECT *
FROM seasonality_VS_margin;

SELECT category, YEAR(order_date) AS year,ROUND(AVG(unit_price),2) AS AVG_price
FROM seasonality_VS_margin
GROUP BY category, YEAR(order_date)
ORDER BY category,YEAR(order_date); -- AVG price for each category in a given year 


SELECT category, product_id, YEAR(order_date) AS YEAR ,ROUND(AVG(unit_price),2) AS AVG_price
FROM seasonality_VS_margin
WHERE product_id IN ('2059', '68', '802','1637','253','2094','114','2459','710')
GROUP BY category, product_id,YEAR(order_date)
ORDER BY category,product_id, YEAR(order_date);-- I am checking AVG price for randomly selected products to check when they went on sale
											   --and how their price has changed over the years


SELECT YEAR(launch_date) AS year, COUNT(product_id) AS product_count
FROM products_mmmgmeum
GROUP BY YEAR(launch_date); --  How many products were being introduced a given year. 

SELECT product_id
FROM products_mmmgmeum
GROUP BY product_id
HAVING COUNT(product_id)>1;

SELECT *
FROM products_mmmgmeum

SELECT YEAR(launch_date) AS year, ROUND(AVG(base_price),2) AS AVG_PRICE
FROM products_mmmgmeum
GROUP BY YEAR(launch_date);-- I am checking whether the new products being introduced are more expensive than those from previous years

SELECT *
FROM seasonality_VS_margin

SELECT product_id, ROUND(AVG(unit_price),2) AS AVG_unit_price
FROM seasonality_VS_margin
WHERE YEAR(order_date) = 2015
GROUP BY product_id; --average product price in 2015

SELECT product_id, ROUND(AVG(unit_price),2) AS AVG_unit_price
FROM seasonality_VS_margin
WHERE YEAR(order_date) = 2024
GROUP BY product_id; -- average product price in 2024


SELECT p2015.product_id, p2015.AVG_unit_price_2015,p2024.AVG_unit_price_2024,
(p2024.AVG_unit_price_2024-p2015.AVG_unit_price_2015) / p2015.AVG_unit_price_2015 * 100 AS price_growth_pct
FROM ( 
	SELECT product_id, ROUND(AVG(unit_price),2) AS AVG_unit_price_2015
	FROM seasonality_VS_margin
	WHERE YEAR(order_date) = 2015
	GROUP BY product_id) AS p2015
INNER JOIN ( SELECT product_id, ROUND(AVG(unit_price),2) AS AVG_unit_price_2024
			 FROM seasonality_VS_margin
			 WHERE YEAR(order_date) = 2024
			 GROUP BY product_id) AS p2024
ON p2015.product_id = p2024.product_id;

SELECT order_id
FROM sales_orders
GROUP BY order_id
HAVING COUNT(order_id)>1; -- I am cheking whether Order_ID more the 1 times

SELECT YEAR(order_date) AS year, COUNT(order_id) AS NUM_of_orders, SUM(quantity) AS Quantity_a_year
FROM sales_orders
GROUP BY YEAR(order_date); -- analyzing the distribution of order volumes over successive years by comparing the quantities

SELECT category, AVG(MIN_price) AS MIN_price_all, AVG(MAX_price) AS MAX_price_all
FROM (
	SELECT category, YEAR(order_date) AS year, MIN(unit_price) AS MIN_price, MAX(unit_price) AS MAX_price
	FROM seasonality_VS_margin
	WHERE category IN ('Men','Kids')
	GROUP BY category, YEAR(order_date)
	) AS t
GROUP BY category;
