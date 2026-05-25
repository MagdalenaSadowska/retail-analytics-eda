--Zmiana  typów danych

SELECT TOP 5 *
FROM sales_orders; 


--zamiana typu z danych w kolumnie order_date

ALTER TABLE sales_orders
ALTER COLUMN order_date date;--zamiana typu z nvarchar(50) na date

SELECT DISTINCT order_date
FROM sales_orders
WHERE TRY_CAST(order_date AS date) IS NULL
AND order_date IS NOT NULL -- ponieważ wyskoczył komunikat, że są jeszcze jakieś wartości których
						   --nie da się zamienić sprawdzamczy są jakieś błędne wartości.
						   --wyszło, że jest data 2024-13-40. Nie ma takiego miesiąca i dnia do przeanalizowania co zrobić z tą wartością
SELECT *
FROM sales_orders
WHERE order_date = '2024-13-40'; -- ta błędna wartość nie ma żadnego powiązania z innymi kolumnami


DELETE FROM sales_orders
WHERE order_date = '2024-13-40'; -- Removed 598 rows (0.23% of total) with invalid order_date value 2024-13-40. 
							     --Investigation of original data showed no systematic pattern 
								 -- rows represent random countries, products and order values. Data loss considered acceptable.


--zmiana typu danych w kolumnie product_id

ALTER TABLE sales_orders
ALTER COLUMN product_id int; --zamiana typu z smalint na int

--zmiana typu danych w kolumnie unit_price

ALTER TABLE sales_orders
ALTER COLUMN unit_price decimal(10,2); --zmiana z nvarchar na decimal

--zmiana typu danych w kolumnie discount_pct 

ALTER TABLE sales_orders
ALTER COLUMN discount_pct decimal(10,2); --zmiana z nvarchar(50) na decimal, są jakieś wartości w których nie można zmienić na liczbę


SELECT TOP 1000 discount_pct
FROM sales_orders
WHERE TRY_CAST(discount_pct AS decimal(10,2)) IS NULL; -- sprawdzam jakie to są wartości. Isą to watości 10% trzeba to zmienić na bez znaku %


SELECT TOP 10000 discount_pct,
	REPLACE (discount_pct, '%', '') AS without_%
FROM sales_orders
WHERE TRY_CAST(discount_pct AS decimal(10,2)) IS NULL -- sprawdzam czy zmiana przebiega poprawnie

UPDATE sales_orders
SET discount_pct = REPLACE (discount_pct, '%', '')
WHERE discount_pct LIKE '%[%]%';

-------------------------

SELECT TOP 5 *
FROM products_mmmgmeum;
 

--zmiana typu danych w base_price z nvarchar(50) na decimal

ALTER TABLE products_mmmgmeum
ALTER COLUMN base_price decimal(10,2);

--zmiana typu danych w launch_date z navrchar(50) na date.

ALTER TABLE products_mmmgmeum
ALTER COLUMN launch_date date; -- pokazuje bład, że nie możemy zmienić wszystkich danych. <usze sprawdzić co to za dane


SELECT DISTINCT launch_date
FROM products_mmmgmeum
WHERE TRY_CAST (launch_date AS date) IS NULL
AND launch_date IS NOT NULL; -- W kolumnie jest nie istniejąca data 2024-13-40 muszę sprawdzić czy jest ona z czymś powiązana

SELECT *
FROM products_mmmgmeum
WHERE launch_date = '2024-13-40'; -- mamy 4 wyniki

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
FROM inventory_mmmgkubv; -- sprawdzam jaka jest nawieksza wartość w kolumnie iczy jest sens zmieniać z smallint na int.
			             -- wyszła mi wartość 567 czyli zostawiam tak jajk jest.

SELECT *
FROM sales_orders
INNER JOIN products_mmmgmeum ON sales_orders.product_id=products_mmmgmeum.product_id
INNER JOIN inventory_mmmgkubv ON sales_orders.product_id=inventory_mmmgkubv.product_id;--połączenie wyszstkich tabel
																					   --zauważyłam, zę zamóienia się duplikują ponieważ te same produkty są gromadzone w rózńych magazynach
																					   --fajnie by bybyło gdyby była informacjia z jakiego magazynu zrealizowano dane zamóienie.
------------------------------------------------

SELECT sales_orders.product_id,order_date, quantity, unit_price,base_price, status
FROM sales_orders
INNER JOIN products_mmmgmeum ON sales_orders.product_id=products_mmmgmeum.product_id; -- pytanie 4

CREATE VIEW seasonality_VS_margin AS
SELECT sales_orders.product_id,order_date, quantity, unit_price,base_price, status
FROM sales_orders
INNER JOIN products_mmmgmeum ON sales_orders.product_id=products_mmmgmeum.product_id;

SELECT TOP 10 *
FROM seasonality_VS_margin;

ALTER VIEW seasonality_VS_margin AS
SELECT sales_orders.product_id,order_date, quantity, unit_price,base_price, discount_pct, status
FROM sales_orders
INNER JOIN products_mmmgmeum ON sales_orders.product_id=products_mmmgmeum.product_id;-- dodanie kolumny discount_pct dal analizy pytania nr. 5

SELECT *
FROM sales_orders
INNER JOIN inventory_mmmgkubv ON sales_orders.product_id=inventory_mmmgkubv.product_id; -- pytanie 3,6

SELECT sales_orders.product_id, order_date, quantity,country, warehouse_country,stock_quantity, last_stock_update
FROM sales_orders
INNER JOIN inventory_mmmgkubv ON sales_orders.product_id=inventory_mmmgkubv.product_id -- sprawdzam wygląd tabeli

CREATE VIEW sales_inventory AS
SELECT sales_orders.product_id, order_date, quantity,country, warehouse_country,stock_quantity, last_stock_update
FROM sales_orders
INNER JOIN inventory_mmmgkubv ON sales_orders.product_id=inventory_mmmgkubv.product_id

SELECT TOP 10 *
FROM sales_inventory;

ALTER VIEW seasonality_VS_margin AS
SELECT sales_orders.product_id,order_date, quantity, unit_price,base_price, discount_pct,unit_price*quantity AS revenue, status
FROM sales_orders
INNER JOIN products_mmmgmeum ON sales_orders.product_id=products_mmmgmeum.product_id