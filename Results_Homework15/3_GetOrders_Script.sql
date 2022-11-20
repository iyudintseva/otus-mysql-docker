USE otus;
-- Создать процедуру get_orders - которая позволяет просматривать отчет по продажам за определенный период (час, день, неделя)
-- с различными уровнями группировки (по товару, по категории, по производителю)

-- period can be hour, day, week, month, year;
-- startDatetime is min value of OrderDate for selection
-- groupByCategory, groupByProducts, groupByVendors are parameters for grouping in result selection 
drop procedure if exists Get_Orders;
delimiter //
CREATE 
PROCEDURE Get_Orders(period VARCHAR(10), startDatetime DATETIME, groupByCategory BOOL, groupByProducts BOOL, groupByVendors BOOL ) 
BEGIN
 SET @orderDateWhereSatement =  '';
 IF startDatetime IS NOT NULL AND startDatetime <> '' THEN
	SET @fromDateTime = startDatetime;
	SET @toDateTime = '';
 
	CASE period
	WHEN 'hour' THEN 
	SET @toDateTime = DATE_ADD(@fromDateTime, INTERVAL 1 HOUR);
	WHEN 'day' THEN 
	SET @toDateTime = DATE_ADD(@fromDateTime, INTERVAL 1 DAY);
	WHEN 'week' THEN 
	SET @toDateTime = DATE_ADD(@fromDateTime, INTERVAL 1 WEEK);
	WHEN 'month' THEN 
	SET @toDateTime = DATE_ADD(@fromDateTime, INTERVAL 1 MONTH);
	WHEN 'year' THEN 
	SET @toDateTime = DATE_ADD(@fromDateTime, INTERVAL 1 YEAR);
	END CASE;
 
	SET @orderDateWhereSatement = CONCAT(' o.OrderDate >= "', @fromDateTime, 
                                      '" AND o.OrderDate <= "', @toDateTime, '" ');
 END IF;
 SET @groupByStatement = '';
 SET @selectedFields = 'o.OrderDate, o.OrderNumber, dtl.OrderLine, p.Name AS Product, v.Name AS Vendor, c.Name AS Category , dtl.UnitCost AS Cost ';
 IF groupByCategory OR groupByProducts OR groupByVendors THEN
    SET @selectedFields = CONCAT(IF(groupByCategory, 'c.FullName AS Category, ', ''),
                                 IF(groupByProducts, 'p.Name AS Product, ', ''),  
                                 IF(groupByVendors, 'v.Name AS Vendor, ', ''), 'SUM(dtl.UnitCost) AS Total ');

    SET @groupByStatement = CONCAT(IF(groupByCategory, ', c.FullName', ''),
                                   IF(groupByProducts, ', p.Name', ''),  
                                   IF(groupByVendors, ', v.Name', ''));
                                   
    SET @groupByStatement = CONCAT('GROUP BY ', SUBSTR(@groupByStatement, 2));                               
 END IF;
 
 SET @selectStatement = CONCAT(
 'SELECT ', @selectedFields, 
 'FROM SalesOrder as o 
  INNER JOIN OrderDtl AS dtl ON o.Id = dtl.SalesOrderId 
  INNER JOIN Product AS p ON p.Id = dtl.ProductId
  INNER JOIN ProductCategory AS pc ON pc.ProductId = dtl.ProductId
  INNER JOIN Category AS c ON c.Id = pc.CategoryId
  INNER JOIN Vendor AS v ON v.Id = dtl.VendorId
  WHERE (o.OrderStatus = "Оплачен" OR o.OrderStatus = "Доставлен") AND 
   ', @orderDateWhereSatement, '
   ', IF(@groupByStatement <> '', @groupByStatement, ''));


  PREPARE myquery FROM @selectStatement;
  EXECUTE myquery;

END;
//
delimiter ;

-- Get_Orders(period, startDatetime, groupByCategory, groupByProducts, groupByVendors) 
CALL Get_Orders('month', '2022-11-01', true, true, false);
CALL Get_Orders('year', '2022-11-01', false, true, true);
CALL Get_Orders('month', '2022-11-01', false, false, true);
CALL Get_Orders('month', '2022-11-01', false, false, false);

