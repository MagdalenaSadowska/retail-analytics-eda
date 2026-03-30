-- ============================================================================================================

-- SPRAWDZENIE LICZBY WIERSZY

SELECT COUNT (*) AS total_rows 
FROM sales_orders               -- 260780

SELECT COUNT (*) AS total_rows 
FROM inventory_mmmgkubv         -- 3741

SELECT COUNT (*) AS total_rows 
FROM products_mmmgmeum          --2500

-- ============================================================================================================

-- SPRAWDZENIE NAZW KOLUMN DLA sales_orders
SELECT TOP 5 *
FROM sales_orders 


--SPRAWDZENIE WARTOŚCI NULLOWYCH sales_orders

SELECT COUNT (*) AS total_rows, -
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
	SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
	SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS null_country,
	SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
	SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END)AS null_quantity,
	SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS null_quantity,
	SUM(CASE WHEN discount_pct IS NULL THEN 1 ELSE 0 END) AS null_discount_pct,
	SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) AS null_status
FROM sales_orders;
	-- mamy 629 wartości nullowych w kolumnie order_date, co stanowi 0,2% 
	-- oraz 31322 wrtości nullowe w kolumnie discound_pct, co stanowi 12%.
	-- Braki danych w  tym wypadku najprawdopododobnie mówią o braku rabatu więc brak danych nie wpłynie na wynik analizy


--SPRAWDZENIE DUPLIKATÓW order_id

SELECT COUNT(*) AS total_rows,
	COUNT(DISTINCT order_id) AS unique_orders
FROM sales_orders;
	--mamy 780 duplikatów


--SPRAWDZAMY CO SIĘ DUPLIKUJE W ORDER_ID

SELECT order_id, COUNT(*) AS quantity_duplicates
FROM sales_orders
GROUP BY order_id
HAVING COUNT(*)>1;
	--DUPLIKATY: 780 order_id powtarza się 2 razy
	-- DO decyzji: czy usunąć duplikaty?


--SPRAWDZAMY DUPLIKATY W status
SELECT COUNT(*) AS total_rows,
	COUNT(DISTINCT status) AS unique_status
FROM sales_orders;
	--mamy 6 unikalnych wartości


--SPRAWDZAMYJAKIE TO WARTOŚCI I CZY NIE MA LITERÓWEK

SELECT status, COUNT(*) AS name_duplicates
FROM sales_orders
GROUP BY status

	-- STATUS: 6 unikalnych wartości, niespójne wielkości liter
	-- 'complete' vs 'COMPLETED' - prawdopodobnie ten sam status
	-- 'SHIP' vs "Shipped" - równiez prawdopodobnie ten sam status
	-- Do standaryzacji: ujednolicić wielkość liter oraz nazewnictwo


--SPRAWDZAMY DUPLIKATY W country
SELECT COUNT(*) AS total_rows,
	COUNT(DISTINCT country) AS unique_status
FROM sales_orders;
	--mamy 28 unikalnych wartości


--SPRAWDZAMYJAKIE TO WARTOŚCI I CZY NIE MA LITERÓWEK

SELECT country, COUNT(*) AS name_duplicates
FROM sales_orders
GROUP BY country

	-- country: 26 unikalnych wartości, niespójne wielkości liter, skróty pańśtw
	-- duplikaty państw jak np. 'DE' vs Germany VS Deuchland 
	-- Do standaryzacji: ujednolicić nazewnictwo państw


--SPRAWDZENIE ZAKRESÓW LICZBOWYCH

SELECT
	MAX (quantity) AS max_value,
	MIN (quantity) AS min_value,
	MAX (unit_price) AS max_unite_price,
	MIN (unit_price) AS min_unite_price
FROM sales_orders
WHERE quantity IS NOT NULL AND unit_price IS NOT NULL;

--ZAKRESY LICZBOWE:
	-- quantity: MIN=0, MAX=608
	-- unit_price: MIN=0.0, MAX=99.99
	-- quantity=0 i unit_price=0 wymagają weryfikacji biznesowej
	-- możliwe przyczyny: anulowane zamówienia, gratisy, reklamacje
	-- Do sprawdzenia: czy quantity=0 i unit_price=0 pokrywają się ze statusem CANCELLED

SELECT quantity,status
FROM sales_orders
WHERE quantity=0;

	-- quantity=0 występuje przy WSZYSTKICH statusach, nie tylko CANCELLED
	-- To błąd w danych - zamówienie nie może być COMPLETED z ilością 0

SELECT unit_price, status
FROM sales_orders
WHERE CAST(unit_price AS decimal(10,2)) = 0

	-- unit_price=0 również występuje przy wszystkich statusach
	-- To błąd w danych - COMPLETED/SHIPPED nie powinno mieć ceny 0
	-- Wyjątek: CANCELLED może mieć cenę 0

--SPRAWDZENIE DATY

SELECT DISTINCT 
    LEFT(order_date, 5) AS first_4_signs,
    LEN(order_date) AS lenght,
    COUNT(*) AS liczba
FROM sales_orders
WHERE order_date IS NOT NULL
GROUP BY LEFT(order_date, 5), LEN(order_date)
ORDER BY liczba DESC
	-- order_date: 3 formaty dat
	-- Dominujący: YYYY-MM-DD (większość wierszy) 
	-- Mniejszość: DD-MM-YYYY MM-DD-YYYY
	-- Do naprawy: ujednolicić do YYYY-MM-DD i zmienić typ na DATE

SELECT DISTINCT order_date
FROM sales_orders
WHERE TRY_CAST(order_date AS date) IS NULL
AND order_date IS NOT NULL
AND order_date NOT LIKE '__/__/____'
AND order_date NOT LIKE '____-__-__'
AND order_date NOT LIKE '__-__-____'
	-- Błędne wartości w order_date:
		-- 120 dat w formacie YYYY-MM (brak dnia)
		-- 1 wartość tekstowa: 'not_a_date'
		-- Pozostałe ~40 000 to daty w różnych formatach DD/MM/YYYY i DD-MM-YYYY
		-- Do naprawy przy czyszczeniu danych


-- ============================================================================================================================================================

-- SPRAWDZENIE NAZW KOLUMN products_mmmgmeum 
SELECT TOP 5 *
FROM products_mmmgmeum 


--SPRAWDZENIE WARTOŚCI NULLOWYCH products_mmmgmeum

SELECT COUNT (*) AS total_rows, 
SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
SUM(CASE WHEN sub_category IS NULL THEN 1 ELSE 0 END) AS null_sub_category,
SUM(CASE WHEN base_price IS NULL THEN 1 ELSE 0 END) AS base_price,
SUM(CASE WHEN launch_date IS NULL THEN 1 ELSE 0 END) AS launch_date
FROM products_mmmgmeum; 
-- wartości nullowe występują w kolumnie launch_date i jest ich 91, co stanowi 3,64%, co jest nie wielką ilością któa nie powinna wpłynąć negatywnie na dalszą analize

--SPRAWDZAM CZY NIE MA DUPIKATÓW W PRODUCT_ID

SELECT 
	COUNT(*) as all_rows,
	COUNT(DISTINCT product_id) AS unique_product_id
FROM products_mmmgmeum; 
	--nie ma duplikatów

--SPRAWDZAMY UNIKALNE WARTOŚCI 

	--KOLUMNA CATEGORY
SELECT category, COUNT(*) AS all_rows
FROM products_mmmgmeum
GROUP BY ROLLUP(category)
ORDER BY all_rows
		--Brak literówek mamy 5 kategori:

	--KOLUMNA SUB_CATEGORY
SELECT sub_category, COUNT(*) AS all_rows
FROM products_mmmgmeum
GROUP BY ROLLUP (sub_category)
ORDER BY all_rows;
		--Brak literówek i błędó mamy 22 subkategorie

--SPRAWDZENIE kolumny base_price

SELECT base_price
FROM products_mmmgmeum
WHERE CAST(base_price AS decimal(10,2)) < 0.01;

SELECT 
	MIN(CAST(base_price AS decimal(10,2))) AS min_price,
	MAX(CAST(base_price AS decimal(10,2))) AS max_price
FROM products_mmmgmeum;
	--BRAK CEN UJEMNYCH I ZEROWYCH


--SZUKAMY EWENTUALNCYH BŁĘDNYCH WARTOŚCI DAT

SELECT DISTINCT launch_date
FROM products_mmmgmeum
WHERE TRY_CAST(launch_date AS date) IS NULL
AND launch_date IS NOT NULL
AND launch_date NOT LIKE '__/__/____'
AND launch_date NOT LIKE '____-__-__'
AND launch_date NOT LIKE '__-__-____';
		--Błędne wartości w launch_date:
			-- format YYYY-MM, wartość tektowa
		-- Do naprawy przy czyszczeniu danych

-- ============================================================================================================================================================

-- SPRAWDZENIE NAZW KOLUMN inventory_mmmgkubv
SELECT TOP 105 *
FROM inventory_mmmgkubv

--SPRAWDZENIE WARTOŚCI NULLOWYCH inventory_mmmgkubv

SELECT COUNT (*) AS total_rows, 
SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
SUM(CASE WHEN warehouse_country IS NULL THEN 1 ELSE 0 END) AS null_warehouse_country,
SUM(CASE WHEN stock_quantity IS NULL THEN 1 ELSE 0 END) AS null_stock_quantity,
SUM(CASE WHEN last_stock_update IS NULL THEN 1 ELSE 0 END) AS last_stock_update
FROM inventory_mmmgkubv; 
	--Tu mamy 26 wartości nullowych w kolumnie stock_update, co stanowi 0,7% co również nie powinno mnieć negatywnego wpływu na dalszą analizę

--SPRAWDZAM CZY W product_id NIE MA WARTOŚCI UJEMNYCH ORAZ CZY NIE MA TAM TEKSTU

SELECT product_id
FROM inventory_mmmgkubv
WHERE product_id<0;
	-- BARAK WARTOŚCI UJEMNYCH

SELECT product_id
FROM inventory_mmmgkubv
WHERE TRY_CAST(product_id AS NUMERIC) IS NULL;
	-- BARAK WARTOŚCI innych niż numeryczne

-- SPRAWDZAMY UNIKALNE WARTOŚCI DLA warehouse_country

SELECT DISTINCT warehouse_country
FROM inventory_mmmgkubv;
	-- ujednolicić nazwy krajów np. mamy Polska vs POL vs PL

--SPRAWDZAM CZY W stock_quantity nie ma wartości ujemnych

SELECT stock_quantity
FROM inventory_mmmgkubv
WHERE stock_quantity<0;
	-- nie ma wartości ujemnych

--SPRAWDZAM POPRAWNOŚĆ DAT

SELECT DISTINCT last_stock_update
FROM inventory_mmmgkubv
WHERE TRY_CAST( last_stock_update AS date) IS NULL
AND last_stock_update IS NOT NULL
AND last_stock_update LIKE '____-__-__'
AND last_stock_update LIKE '__-__-____'
AND last_stock_update LIKE '____/__/__'
AND last_stock_update LIKE '__/__/____'
	--wszytkie daty są w odpowienim formacie