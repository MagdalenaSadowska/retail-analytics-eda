--Data Type Conversion

SELECT TOP 5 *
FROM sales_orders; 


--Converting the data type of the order_date column

ALTER TABLE sales_orders
ALTER COLUMN order_date date;--Converting data type from nvarchar(50) to date

SELECT DISTINCT order_date
FROM sales_orders
WHERE TRY_CAST(order_date AS date) IS NULL
AND order_date IS NOT NULL;-- A message appeared indicating that some values could not be converted,
						   -- so we check for any invalid values.
						   -- It turned out that there is a date 2024-13-40. This month and day do not exist
						   -- and need to be analyzed to decide what to do with this value.
SELECT *
FROM sales_orders
WHERE order_date = '2024-13-40'; -- This invalid value has no correlation with other columns.


DELETE FROM sales_orders
WHERE order_date = '2024-13-40'; -- Removed 598 rows (0.23% of total) with invalid order_date value 2024-13-40. 
							     --Investigation of original data showed no systematic pattern 
								 -- rows represent random countries, products and order values. Data loss considered acceptable.


-- Converting the data type of the product_id column

ALTER TABLE sales_orders
ALTER COLUMN product_id int; -- Converting data type from smallint to int

-- Corventing the data type of the unit_price column

ALTER TABLE sales_orders
ALTER COLUMN unit_price decimal(10,2); --Converting data type from nvarchar to decimal

--Converting the data type of the discount_pct column 

ALTER TABLE sales_orders
ALTER COLUMN discount_pct decimal(10,2); --Converting data type from nvarchar(50) to decimal. There are some values that cannot be converted to a number.


SELECT TOP 1000 discount_pct
FROM sales_orders
WHERE TRY_CAST(discount_pct AS decimal(10,2)) IS NULL; -- Checking what these values are. 
													   -- They contain the "%" sign 
													   -- these need to be converted to values without the "%" sign.


SELECT TOP 10000 discount_pct,
	REPLACE (discount_pct, '%', '') AS without_%
FROM sales_orders
WHERE TRY_CAST(discount_pct AS decimal(10,2)) IS NULL -- Checking if the conversion is working correctly.

UPDATE sales_orders
SET discount_pct = REPLACE (discount_pct, '%', '')
WHERE discount_pct LIKE '%[%]%';

-------------------------

SELECT TOP 5 *
FROM products_mmmgmeum;
 

--Converting the data type of the base_price  column from nvarchar(50) to decimal

ALTER TABLE products_mmmgmeum
ALTER COLUMN base_price decimal(10,2);

-- Converting the data type of the launch_date  column from nvarchar(50) to date

ALTER TABLE products_mmmgmeum
ALTER COLUMN launch_date date; -- An error appears indicating that not all values can be converted. I need to check what these values are.


SELECT DISTINCT launch_date
FROM products_mmmgmeum
WHERE TRY_CAST (launch_date AS date) IS NULL
AND launch_date IS NOT NULL; -- The column contains a non-existent date 2024-13-40. I need to check if it is correlated with any other columns.

SELECT *
FROM products_mmmgmeum
WHERE launch_date = '2024-13-40'; -- We have 4 results.

SELECT *
FROM sales_orders
WHERE product_id IN ('412','1611','2212','2398');

DELETE FROM products_mmmgmeum
WHERE launch_date = '2024-13-40';-- Removed 4 rows with invalid launch_date value '2024-13-40'.
								 -- Products (product_id: 412, 1611, 2212, 2398) had related orders in sales_orders,
								 -- but those orders were already removed during sales_orders cleaning.
				                 -- Data loss considered acceptable (less than 0.1% of total).

----------------------------------------------

SELECT TOP 5 *
FROM inventory_mmmgkubv;

SELECT MAX(stock_quantity)
FROM inventory_mmmgkubv; -- Checking the maximum value in the column to determine whether it makes sense to convert from smallint to int.
						 -- The maximum value is 567, so I will leave it as it is.

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

CREATE VIEW seasonality_VS_margin AS
SELECT sales_orders.product_id,order_date, quantity, unit_price,base_price, status
FROM sales_orders
INNER JOIN products_mmmgmeum ON sales_orders.product_id=products_mmmgmeum.product_id;

SELECT TOP 10 *
FROM seasonality_VS_margin;

ALTER VIEW seasonality_VS_margin AS
SELECT sales_orders.product_id,order_date, quantity, unit_price,base_price, discount_pct, status
FROM sales_orders
INNER JOIN products_mmmgmeum ON sales_orders.product_id=products_mmmgmeum.product_id;-- Adding the discount_pct column for the analysis of question no. 5

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
SELECT sales_orders.product_id, order_date, quantity, unit_price, base_price, discount_pct,
       unit_price*quantity AS revenue, status
FROM sales_orders
INNER JOIN products_mmmgmeum ON sales_orders.product_id = products_mmmgmeum.product_id

SELECT YEAR(order_date) AS year, CAST(ROUND(AVG(revenue),2)AS decimal(10,2)) AS average 
FROM seasonality_VS_margin
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) ASC;--Q1: Are prices really growing? (YoY)
								-- Result: Average revenue grows YoY from 1042 (2015) to 1501 (2024)
								-- Exception: slight drop in 2022 vs 2021

SELECT YEAR(order_date) AS year,SUM(quantity) AS SUM_QUANTITY, CAST(ROUND(AVG(unit_price),2)AS decimal(10,2)) AS AVG_UNIT_PRICE
FROM seasonality_VS_margin
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) ASC;-- Revenue growth is mainly driven by rising prices, not volume.
							  -- Quantities are fairly stable (ranging between 161k and 174k),
						      -- while the average price increases consistently from 155 in 2015 to 212 in 2024.

SELECT product_id,order_date, SUM(quantity)AS SUM_quantity_product, SUM(stock_quantity) AS SUM_STOCK, last_stock_update
FROM sales_inventory
WHERE YEAR(order_date) IN (2024)
GROUP BY product_id, order_date, last_stock_update
ORDER BY product_id ASC; -- A fully reliable analysis is not entirely possible, because the data in last_stock_update does not align with order_date
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



