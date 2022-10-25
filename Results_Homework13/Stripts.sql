-- для выполнения задания вынесла данные из поля GoogleShoppingGoogleProductCategory в таблицу ExtProductCategory
SELECT FullName, Id, ParentId FROM ExtProductCategory;

-- 1. вывести список продуктов с максимальной и минимальной ценой и кол-во предложений
WITH
  prices  AS (SELECT MAX(pv.Price) AS MaxPrice, MIN(pv.Price) AS MinPrice 
                  FROM ExtProductVariant as pv
                  WHERE pv.Price > 0 LIMIT 1) 
SELECT
	p1.Handle AS Product, 
	pv1.Option1Value AS Color, 
	pv1.Option2Value AS Size, 
	pv1.Price AS Price, 
	pv1.InventoryQty AS Quantity,
	CASE pv1.Price
	    WHEN prices.MinPrice  THEN 'With Min Price'
	    WHEN prices.MaxPrice THEN 'With Max Price'
	    ELSE ''
	END AS Criteria
FROM ExtProduct as p1 
INNER JOIN ExtProductVariant  as pv1
ON  pv1.ExtProductId = p1.Id 
INNER JOIN prices
ON pv1.Price = prices.MaxPrice OR pv1.Price = prices.MinPrice
ORDER BY Price, Product; 


-- 2. сделать выборку, показывающую самый дорогой и самый дешевый товар в каждой категории
WITH
  cpv AS (SELECT c1.FullName as Category, p1.Handle AS Product, p1.Id AS ProductId, 
			MAX(pv1.Price) AS MaxPrice, MIN(pv1.Price) AS MinPrice
			FROM ExtProductCategory as c1 
			INNER JOIN ExtProduct as p1
			ON  p1.GoogleShoppingGoogleProductCategory = c1.FullName
			INNER JOIN ExtProductVariant  as pv1
			ON  pv1.ExtProductId = p1.Id AND pv1.Price > 0
			GROUP BY c1.FullName, p1.Handle, p1.Id),
  cpvPrices AS (SELECT Category, MAX(MaxPrice) AS MaxPrice, MIN(MinPrice) AS MinPrice
                FROM cpv 
				GROUP BY Category)
  SELECT c.FullName AS Category,
         cpv1.Product AS Product_With_Max_Price,
         cpvPrices.MaxPrice AS Max_Price,
         cpv2.Product AS Product_With_Min_Price,
         cpvPrices.MinPrice AS Min_Price
FROM (ExtProductCategory as c 
INNER JOIN cpvPrices 
  ON cpvPrices.Category = c.FullName
INNER JOIN cpv as cpv1
  ON  cpv1.Category = c.FullName AND cpv1.ProductId = 
	(SELECT cpv_with_MaxPrice.ProductId FROM cpv as cpv_with_MaxPrice 
     WHERE cpv_with_MaxPrice.Category = c.FullName 
		AND cpv_with_MaxPrice.MaxPrice = cpvPrices.MaxPrice LIMIT 1))
INNER JOIN cpv as cpv2
  ON  cpv2.Category = c.FullName AND cpv2.ProductId = 
	(SELECT cpv_with_MinPrice.ProductId FROM cpv as cpv_with_MinPrice 
     WHERE cpv_with_MinPrice.Category = c.FullName 
		AND cpv_with_MinPrice.MinPrice = cpvPrices.MinPrice LIMIT 1)
ORDER BY c.FullName;

-- 3. сделать rollup с количеством товаров по категориям
WITH
  catLev1 AS (SELECT c1.FullName AS Category, c1.ParentId AS ParentId, c1.Id AS Id
              FROM ExtProductCategory AS c1
              WHERE c1.ParentId = 0),
  catLev2 AS (SELECT c2.FullName AS Category, c2.ParentId AS ParentId, c2.Id AS Id
              FROM ExtProductCategory AS c2 RIGHT JOIN catLev1 ON c2.ParentId = catLev1.Id),
  catLev3 AS (SELECT c3.FullName AS Category, c3.ParentId AS ParentId, c3.Id AS Id
              FROM ExtProductCategory AS c3 RIGHT JOIN catLev2 ON c3.ParentId = catLev2.Id),
  catLev4 AS (SELECT c4.FullName AS Category, c4.ParentId AS ParentId, c4.Id AS Id
              FROM ExtProductCategory AS c4 RIGHT JOIN catLev3 ON c4.ParentId = catLev3.Id),
  categories AS (SELECT DISTINCT catLev1.Category AS Category_Level1,              
				 IF(catLev2.Category IS NULL, '-', catLev2.Category)  AS Category_Level2,	
				 IF(catLev3.Category IS NULL, '-', catLev3.Category) AS Category_Level3,
				 IF(catLev4.Category IS NULL, '-', catLev4.Category) AS Category_Level4
				FROM (catLev1 
				LEFT JOIN catLev2 ON (catLev1.Id = catLev2.ParentId OR (catLev2.ParentId IS NULL))
				LEFT JOIN catLev3 ON (catLev2.Id = catLev3.ParentId OR (catLev3.ParentId IS NULL))
				LEFT JOIN catLev4 ON (catLev3.Id = catLev4.ParentId OR catLev4.ParentId IS NULL))
				ORDER BY Category_Level1, Category_Level2, Category_Level3, Category_Level4)
SELECT IF(GROUPING(categories.Category_Level1),'TOTAL', categories.Category_Level1) AS Category_Level1,              
	   IF(GROUPING(categories.Category_Level2),'TOTAL', categories.Category_Level2) AS Category_Level2,	
       IF(GROUPING(categories.Category_Level3),'TOTAL', categories.Category_Level3) AS Category_Level3,
       IF(GROUPING(categories.Category_Level4),'TOTAL', categories.Category_Level4) AS Category_Level4,
       SUM(pv.InventoryQty) AS Quantity
FROM categories
INNER JOIN ExtProduct as p ON 
	((p.GoogleShoppingGoogleProductCategory = categories.Category_Level4) or
	 (p.GoogleShoppingGoogleProductCategory = categories.Category_Level3 AND categories.Category_Level4 = '-') or
     (p.GoogleShoppingGoogleProductCategory = categories.Category_Level2 AND categories.Category_Level3 = '-') or
     (p.GoogleShoppingGoogleProductCategory = categories.Category_Level1 AND categories.Category_Level2 = '-'))
INNER JOIN ExtProductVariant AS pv ON p.Id = pv.ExtProductId
GROUP BY Category_Level1, Category_Level2, Category_Level3, Category_Level4 WITH ROLLUP ;

-- 4. use Having
-- вывести категории товаров имеющих более 10-ти товаров в наличии
SELECT cat.FullName AS Category, SUM(pv.InventoryQty) AS Quantity
FROM ExtProductCategory AS cat
INNER JOIN ExtProduct as p ON p.GoogleShoppingGoogleProductCategory = cat.FullName
INNER JOIN ExtProductVariant AS pv ON p.Id = pv.ExtProductId
GROUP BY Category
HAVING Quantity > 10
ORDER BY Category;


