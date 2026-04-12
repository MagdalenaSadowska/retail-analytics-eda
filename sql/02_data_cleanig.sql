--CZYSZCZENIE DANYCH W TABELI sales_orders

	--SPRAWDZENIE CZY NIEMA POWIĄZANIA Z NULLAMI W KOLUMNIE ORDER_DATE z innymi kolumnami
	SELECT *
	FROM sales_orders
	WHERE order_date IS NULL;

	SELECT *
	FROM sales_orders
	WHERE order_date  IS NULL
	AND  discount_pct IS NULL; -- zauważyłam że nule częściowo występują razem w dwuch tabelach sprawdzam jak w dużej cześci. Wyszło mi , ze tylko 79 pozycjach

	DELETE FROM sales_orders
	WHERE order_date IS NULL; -- Usuwam wiersze z NULLami w kolumnie order_date (629 wierszy)

	SELECT COUNT (*)
	FROM sales_orders; -- 260 780 - 629 = 260 151 wartości się zgadzają 

	--SPRAWDZENIE CZY NIEMA POWIĄZANIA Z NULLAMI W KOLUMNIE discount_pct z innymi kolumnami

	SELECT *
	FROM sales_orders
	WHERE discount_pct is NULL;

	SELECT *
	FROM sales_orders
	WHERE TRY_CAST(discount_pct AS decimal(10,2)) = 0 -- sprawdzam jak wyglądają rekordy gdzie jest discount_pct równy 0
	
	SELECT COUNT(*)
	FROM sales_orders
	WHERE TRY_CAST(discount_pct AS decimal(10,2)) = 0 -- sprawdzam ile jest rekordów z discount_pct równym 0

	UPDATE sales_orders
	SET discount_pct = 0
	WHERE discount_pct IS NULL;-- zmieniam null na wartość 0 

	--DUPLIKATY W  order_id

	SELECT *
	FROM sales_orders
	WHERE order_id IN (
		SELECT order_id
		FROM sales_orders
		GROUP BY order_id
		HAVING COUNT(*) > 1
		)
	ORDER BY order_id;

	-- UJEDNOLICAMY NAZWY W KOLUMNIE status

	UPDATE sales_orders
	SET status = 'SHIPPED'
	WHERE status IN ('Ship','Shipped');--Ship i Shipped ujednolicam do SHIPPED

	UPDATE sales_orders
	SET status = 'COMPLETED'
	WHERE status IN ('complete','Completed'); -- complete ujednolicam do completed

	UPDATE sales_orders
	SET status = 'DONE'
	WHERE status = 'done';-- done ujednolicam do DONE



	-- UJEDNOLICAM NAZWY W country na skróty ISO

	UPDATE sales_orders
	SET country = 'DE'
	WHERE country IN ('Germany','Deutschland','GER');

	UPDATE sales_orders
	SET country = 'CZ'
	WHERE country IN ('Czech', 'Cz', 'Czechia', 'Czech Republic');

	UPDATE sales_orders
	SET country = 'SE'
	WHERE country = 'Sweden';

	UPDATE sales_orders
	SET country = 'SK'
	WHERE country IN ('slovak', 'SLOVAKIA');

	UPDATE sales_orders
	SET country = 'NL'
	WHERE country IN ('Holland','netherlands');

	UPDATE sales_orders
	SET country = 'PL'
	WHERE country IN ('POL','poland','pl','Polska');

	UPDATE sales_orders
	SET country = 'FR'
	WHERE country = 'France';

	UPDATE sales_orders
	SET country = 'ES'
	WHERE country = 'Spain';

	UPDATE sales_orders
	SET country = 'IT'
	WHERE country = 'italy';

	UPDATE sales_orders
	SET country = 'AT'
	WHERE country = 'austria';

	--CZYSZCZENIE I UJEDNOLICENIE DAT

	SELECT *
	FROM sales_orders
	WHERE order_date LIKE '____-__'
	      OR order_date = 'not_a_date' -- sprawdzam czy nie widzę jakiś zależności między niepełnymidatami a rwszta kolumn.

	SELECT  count(*) AS number
	FROM sales_orders
	WHERE order_date LIKE '____-__'; -- 697 dat z formatem YYYY-MM to 0,3%

	SELECT  count(*) AS number
	FROM sales_orders
	WHERE order_date LIKE 'not_a_date'; -- 661 dat z formatem 'not_a_date' to 0,3%

		--Ponieważ błędne daty to poniżej 1% dlatego je usóamy 

	DELETE FROM sales_orders
	WHERE order_date LIKE '____-__'
	OR order_date = 'not_a_date'

	 --UJEDNOLICANIE FORMATÓW DAT
	 SELECT order_date,
	 CASE
	 WHEN order_date LIKE '__/__/____'
		THEN SUBSTRING (order_date, 7,4) + '-'
			 + SUBSTRING (order_date, 4,2) + '-'
			 + SUBSTRING (order_date, 1,2)
	WHEN order_date LIKE '__-__-____'
		THEN SUBSTRING (order_date, 7,4) + '-'
			 + SUBSTRING (order_date, 4,2) + '-'
			 + SUBSTRING (order_date, 1,2)
	WHEN order_date LIKE '____/__/__'
		THEN SUBSTRING (order_date, 1,4) + '-'
			 + SUBSTRING (order_date, 6,2) + '-'
			 + SUBSTRING (order_date, 9,2)
	ELSE order_date
	END
	FROM sales_orders; -- sprawdzam jak będą wyglądały dane po zmianach

	UPDATE sales_orders
	SET order_date = CASE
	WHEN order_date LIKE '__/__/____'
		THEN SUBSTRING (order_date, 7,4) + '-'
			 + SUBSTRING (order_date, 4,2) + '-'
			 + SUBSTRING (order_date, 1,2)
	WHEN order_date LIKE '__-__-____'
		THEN SUBSTRING (order_date, 7,4) + '-'
			 + SUBSTRING (order_date, 4,2) + '-'
			 + SUBSTRING (order_date, 1,2)
	WHEN order_date LIKE '____/__/__'
		THEN SUBSTRING (order_date, 1,4) + '-'
			 + SUBSTRING (order_date, 6,2) + '-'
			 + SUBSTRING (order_date, 9,2)
	WHEN order_date LIKE '____.__.__'
		THEN SUBSTRING(order_date, 1, 4) + '-'
			+ SUBSTRING(order_date, 6, 2) + '-'
		    + SUBSTRING(order_date, 9, 2)
	ELSE order_date
	END; -- wprowadzenie zmian

	SELECT DISTINCT order_date
	FROM sales_orders
	WHERE order_date LIKE '__/__/____'
		OR order_date LIKE '__-__-____' 
		OR order_date LIKE '____/__/__'
		OR order_date LIKE '____.__.__'
		OR order_date LIKE '__.__.____'; -- Sprawdzam czy coś zostało jeszcze ze starych formatów lub takich któych teoretycznie nie było. Znalazłąm jeszcze format  YYYY.MM.DD dodaje to do powyższej komendy






	






----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--CZYSZCZENIE DANYCH W TABELI products_mmmgmeum

	--OGARNIANIE NULLI w kolumnie launch_date

	SELECT *
	FROM products_mmmgmeum
	WHERE launch_date is NULL; -- Sprawdzam czy istnieje jakaś korelacja między wartością NULL w kolumnie launch_date a resztą.
		-- WArtości NULL w kolumnie launch_date nie mają żadnej korelacji w pozostałymi wartościami. ponieważ jest ich tylko 91 co stanowi 3,64% postanawiam je usunąć.

	DELETE FROM products_mmmgmeum
	WHERE launch_date is NULL;

	--SPRAWDZANIE NIEKOMPLETNYCH REKORDÓW

	SELECT launch_date, COUNT (*) AS how_many_wrog_date
	FROM products_mmmgmeum
	WHERE launch_date  LIKE '____-__' 
	      OR launch_date  LIKE '____/__' 
		  OR launch_date  LIKE 'not_a_date'
	GROUP BY launch_date
	ORDER BY how_many_wrog_date; -- sprawdzam ile jest wartości z błędną datą
	  -- Jest ich 9 stanowią bardzo małą część związku z czym usówam je

	DELETE FROM products_mmmgmeum
	WHERE launch_date  LIKE '____-__' 
	      OR launch_date  LIKE '____/__' 
		  OR launch_date  LIKE 'not_a_date';

	--UJEDNOLICENIE FORMATU DAT
	
SELECT launch_date,
CASE
WHEN launch_date LIKE '__-__-____'
THEN SUBSTRING(launch_date, 7, 4) + '-'
+SUBSTRING(launch_date, 4, 2) + '-'
+SUBSTRING(launch_date, 1, 2)
WHEN launch_date LIKE '__/__/____'
THEN SUBSTRING(launch_date, 7, 4) + '-'
+SUBSTRING(launch_date, 4, 2) + '-'
+SUBSTRING(launch_date, 1, 2)
WHEN launch_date LIKE '__.__.____'
THEN SUBSTRING(launch_date, 7, 4) + '-'
+SUBSTRING(launch_date, 4, 2) + '-'
+SUBSTRING(launch_date, 1, 2)
WHEN launch_date LIKE '____/__/__'
THEN SUBSTRING(launch_date, 1, 4) + '-'
+SUBSTRING(launch_date, 6, 2) + '-'
+SUBSTRING(launch_date, 9, 2)
WHEN launch_date LIKE '____.__.__'
THEN SUBSTRING(launch_date, 1, 4) + '-'
+SUBSTRING(launch_date, 6, 2) + '-'
+SUBSTRING(launch_date, 9, 2)
ELSE launch_date
END AS new_launch_date
FROM products_mmmgmeum; -- sprawdzenie zmiany formatów

UPDATE products_mmmgmeum
SET launch_date = CASE
WHEN launch_date LIKE '__-__-____'
THEN SUBSTRING(launch_date, 7, 4) + '-'
+SUBSTRING(launch_date, 4, 2) + '-'
+SUBSTRING(launch_date, 1, 2)
WHEN launch_date LIKE '__/__/____'
THEN SUBSTRING(launch_date, 7, 4) + '-'
+SUBSTRING(launch_date, 4, 2) + '-'
+SUBSTRING(launch_date, 1, 2)
WHEN launch_date LIKE '__.__.____'
THEN SUBSTRING(launch_date, 7, 4) + '-'
+SUBSTRING(launch_date, 4, 2) + '-'
+SUBSTRING(launch_date, 1, 2)
WHEN launch_date LIKE '____/__/__'
THEN SUBSTRING(launch_date, 1, 4) + '-'
+SUBSTRING(launch_date, 6, 2) + '-'
+SUBSTRING(launch_date, 9, 2)
WHEN launch_date LIKE '____.__.__'
THEN SUBSTRING(launch_date, 1, 4) + '-'
+SUBSTRING(launch_date, 6, 2) + '-'
+SUBSTRING(launch_date, 9, 2)
ELSE launch_date
END; -- ujednolicenie formatów daty

		
SELECT DISTINCT launch_date
	FROM products_mmmgmeum
WHERE launch_date NOT LIKE '____-__-__';	-- sprawdzenie czy napweno wszytkie formaty zostały zmienione.	  




-- ============================================================================================================================================================
-- NAPRAWA DANYCH inventory_mmmgkubv

	--UJEDNOLICENIE NAZW KRAJÓW W KOLUMNIE warehouse_country


	UPDATE inventory_mmmgkubv
	SET warehouse_country = 'DE'
	WHERE warehouse_country IN ('Germany', 'germany','GER', 'Deutschland');

	UPDATE inventory_mmmgkubv
	SET warehouse_country = 'PL'
	WHERE warehouse_country IN ('Polska', 'pl', 'poland', 'Poland', 'POL');
	
	UPDATE inventory_mmmgkubv
	SET warehouse_country = 'CZ'
	WHERE warehouse_country IN ('Czech', 'Czech Republic', 'Czechia');

	SELECT DISTINCT warehouse_country
		FROM inventory_mmmgkubv;
		-- UJEDNOLICIŁAM WSZYTKIE KRAJE OBECNIE MAMY: DE, PL, CZ


	--OGARNIANIE NULLI w last_stock_update

	SELECT *
	FROM inventory_mmmgkubv
	WHERE last_stock_update IS NULL;
		--NULLE w kolumnie last_stock_update są losowe, nie mają powiązania z żadną z kolumn,
		--ponieważ są losowe i jest ich mało (0,7%) to usówam je z tabeli to nie powinno wpłynąć na dalszą analizę

	DELETE FROM inventory_mmmgkubv
	WHERE last_stock_update IS NULL; -- Usuwam wiersze z NULLami w kolumnie last_stock_update

	SELECT COUNT (*) 
	FROM inventory_mmmgkubv;
		-- SPRAWDZAM CZY ZOSTAŁA USUNIĘTA ODPOWIEDNIA ILOŚĆ KOLUMN (3741-26=3715)

	-- ============================================================================================================================================================

