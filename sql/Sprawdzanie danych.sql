-- SPRAWDZENIE LICZBY WIERSZY

SELECT COUNT (*) AS total_rows 
FROM sales_orders

SELECT COUNT (*) AS total_rows 
FROM inventory_mmmgkubv

SELECT COUNT (*) AS total_rows 
FROM products_mmmgmeum

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

-- SPRAWDZENIE NAZW KOLUMN inventory_mmmgkubv
SELECT TOP 5 *
FROM inventory_mmmgkubv

--SPRAWDZENIE WARTOŚCI NULLOWYCH inventory_mmmgkubv

SELECT COUNT (*) AS total_rows, 
SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
SUM(CASE WHEN warehouse_country IS NULL THEN 1 ELSE 0 END) AS null_warehouse_country,
SUM(CASE WHEN stock_quantity IS NULL THEN 1 ELSE 0 END) AS null_stock_quantity,
SUM(CASE WHEN last_stock_update IS NULL THEN 1 ELSE 0 END) AS last_stock_update
FROM inventory_mmmgkubv; 