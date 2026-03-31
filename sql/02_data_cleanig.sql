--CZYSZCZENIE DANYCH W TABELI launch_date

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

