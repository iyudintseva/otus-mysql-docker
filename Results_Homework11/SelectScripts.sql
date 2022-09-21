use otus;

# INNER JOIN запрос
-- отобразить текущие цены на товары в заказах
SELECT ord.OrderNumber, dtl.OrderLine , 
       p.Name AS Product, v.Name AS Vendor,
       pv.UnitCost AS Price, dtl.DiscountPercent AS DiscountPercent,
       (1 - dtl.DiscountPercent / 100) * pv.UnitCost AS Total  
FROM (((SalesOrder AS ord 
	 INNER JOIN OrderDtl AS dtl ON ord.Id = dtl.SalesOrderId) 
       INNER JOIN Product AS p ON p.Id = dtl.ProductId) 
       INNER JOIN Vendor AS v ON v.Id = dtl.VendorId) 
       INNER JOIN ProductVendor AS pv ON
			pv.VendorId = dtl.VendorId AND
			pv.ProductId = dtl.ProductId
ORDER BY ord.OrderNumber, dtl.OrderLine;

# LEFT JOIN запрос
-- отобразить количество товара на складах
SELECT p.Name AS Product,
       IF (v.Name IS NULL, '?', v.Name) AS Vendor,
       IF(pv.UnitCost IS NULL, 0.00, pv.UnitCost) AS Price,
       IF(wb.Bin IS NULL, 'Товар отсутствует', wb.Bin) as Bin,
       IF (pb.ProductCount Is Null OR pb.ProductCount <= 0, 'Товар отсутствует', pb.ProductCount) 
           AS Count
FROM Product AS p 
     LEFT JOIN ProductVendor AS pv ON p.Id = pv.ProductId 
     LEFT JOIN Vendor as v ON v.Id = pv.VendorId 
     LEFT JOIN ProductBin as pb ON pb.VendorId = pv.VendorID AND pb.ProductId = pv.ProductId 
     LEFT JOIN WarehouseBin as wb ON wb.Id = pb.BinId; 

# WHERE запрос
-- найти товар по типу и диапазону цен
SELECT p.Id, p.ProductCode, p.Name, p.Size, p.Description 
FROM Product AS p
WHERE p.ProductType = 'Куртка' AND 
      p.Id IN (SELECT pv.ProductId FROM ProductVendor AS pv 
               WHERE pv.UnitCost BETWEEN 5000 AND 10000);

-- найти заказы пользователя за текущий месяц
SELECT s.Id, s.OrderNumber, date(s.OrderDate) AS OrderDate, s.DeliveryDate, c.FullName as Customer 
FROM SalesOrder AS s
INNER JOIN Customer as c ON s.CustomerId = c.Id
WHERE CustomerId = 3 AND
      extract(YEAR FROM OrderDate) = extract(YEAR FROM CURDATE()) AND
      extract(MONTH FROM OrderDate) = extract(MONTH FROM CURDATE());

--  найти товыры по части наименования     
SELECT p.Id, p.ProductCode, p.Name, p.Size, p.ProductType, p.Season,
       p.Specifications->>'$.Age' as Age
FROM Product as p
WHERE p.Name like '%Брюки%';

-- найти товары с наименьшей ценой
SELECT p.Id, p.ProductCode, p.Name, p.Size, pv.UnitCost as Price
FROM Product as p 
INNER JOIN ProductVendor as pv ON p.Id = pv.ProductId
WHERE pv.UnitCost = (SELECT MIN(pv2.UnitCost) FROM ProductVendor as pv2);

-- найти товары в наличии (проверка работы EXISTS)
SELECT p.Id, p.ProductCode, p.Name  
FROM Product as p
WHERE p.ProductType = 'Платье' 
  AND EXISTS ( SELECT 1 FROM ProductBin as pb
                        WHERE pb.ProductId = p.Id AND
                              pb.ProductCount > 0);
  
  
