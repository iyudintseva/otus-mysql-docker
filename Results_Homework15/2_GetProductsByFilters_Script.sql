USE otus;
-- Создать процедуру выборки товаров с использованием различных фильтров: 
-- категория, цена, производитель, различные дополнительные параметры
-- Также в качестве параметров передавать по какому полю сортировать выборку, и параметры постраничной выдачи

drop procedure if exists Get_ProductsByFilters;
delimiter //
CREATE 
PROCEDURE Get_ProductsByFilters(
	category VARCHAR(50), minPrice NUMERIC(15,2), maxPrice NUMERIC(15,2),
    vendorName VARCHAR(500), productType VARCHAR(20), season VARCHAR(20), size VARCHAR(8),
    sortByCategory BOOL, sortByPrice BOOL, sortByVendor BOOL, 
    pageNumber INT, recordsPerPage INT)
BEGIN
 SET @categoryCteStatement = CreateCategoryCteStatement(category);
 SET @selectStatement = CreateSelectStatement(category, vendorName, sortByCategory, sortByPrice, sortByVendor);
 SET @whereStatement = CreateWhereStatement(minPrice, maxPrice, productType, season, size);
 SET @groupByStatement = CreateGroupByStatement(sortByCategory, sortByPrice, sortByVendor);
 SET @orderbyStatement = CONCAT(' ORDER BY ',
						IF(sortByCategory, 'c.FullName ,', ''),
						IF(sortByPrice, 'pv.UnitCost ,', ''),
						IF(sortByVendor, 'v.Name ,', ''),
                        ' p.Name '); 

 SET @limitStatement = CreateLimitStatement(pageNumber, recordsPerPage);

 SET @queryForSelect = CONCAT(@categoryCteStatement, @selectStatement, 
                       IF(@whereStatement <> '', @whereStatement, ''),  
                       IF(@groupByStatement <> '', @groupByStatement, ''),  
                       IF(@orderbyStatement <> '', @orderbyStatement, ''),  
                       IF(@limitStatement <> '', @limitStatement, ''),
                       '; ');

 -- select @queryForSelect;
 PREPARE myquery FROM @queryForSelect;
 EXECUTE myquery;

END;
//
delimiter ;

drop function if exists CreateCategoryCteStatement;
delimiter //
CREATE 
FUNCTION CreateCategoryCteStatement(category VARCHAR(50))
RETURNS VARCHAR(1000) DETERMINISTIC
BEGIN

SET @categoryCteStatement = '';
IF (category IS NOT NULL AND category <> '') THEN
  SET @categoryCteStatement = CONCAT(
  'WITH RECURSIVE category_cte (Id, Name, ParentCategoryId, FullName) AS (
   SELECT    Id, Name, ParentCategoryId, Name AS FullName
   FROM      Category
   WHERE     Name = "', category, '"',
  'UNION ALL
   SELECT    cc.Id, cc.Name, cc.ParentCategoryId, cc.FullName
   FROM      Category cc
   INNER JOIN category_cte
           ON cc.ParentCategoryId = category_cte.Id
   ) 
   ');
END IF;
RETURN @categoryCteStatement;
END;
//
delimiter ;

drop function if exists CreateGroupByStatement;
delimiter //
CREATE 
FUNCTION CreateGroupByStatement(sortByCategory BOOL, sortByPrice BOOL, sortByVendor BOOL)
RETURNS VARCHAR(3000) DETERMINISTIC
BEGIN
 SET @groupBy = CONCAT(' 
    GROUP BY ',
    IF(sortByCategory, 'c.FullName, ', ''),
    IF(sortByVendor, ' v.Name, ', ''),
    'p.Name, p.ProductCode, ',
	IF(sortByVendor, '', ' v.Name, '), 'pv.UnitCost ');

 RETURN @groupBy;
END;
//
delimiter ;

drop function if exists CreateSelectStatement;
delimiter //
CREATE 
FUNCTION CreateSelectStatement(category VARCHAR(50), vendorName VARCHAR(500), sortByCategory BOOL, 
                                       sortByPrice BOOL, sortByVendor BOOL)
RETURNS VARCHAR(3000) DETERMINISTIC
BEGIN
	
 SET @vendorId = -1;
  IF (vendorName IS NOT NULL AND vendorName <> '') THEN
	 SET @vendorId = (SELECT Id FROM Vendor WHERE Name = vendorName LIMIT 1);
 END IF;
 
 SET @selectStatement = CONCAT('SELECT ', 
    IF(sortByCategory, 'c.FullName AS Category, ', ''),
    IF(sortByVendor, ' v.Name AS Vendor, ', ''),
    'p.Name AS Product, p.ProductCode, ',
	IF(sortByVendor, '', ' v.Name AS Vendor, '), 'pv.UnitCost AS Price, '
    'SUM(pb.ProductCount) AS Count, ', 
	'p.ProductType, p.Season, p.Size, p.Description 
    FROM Product AS p 
    INNER JOIN ProductCategory AS pc ON pc.ProductId = p.Id 
    INNER JOIN ',IF(category IS NOT NULL AND category <> '', 'category_cte', 'Category'),' AS c ON c.Id = pc.CategoryId 
    INNER JOIN ProductVendor AS pv ON ',
       IF(@vendorId > 0, CONCAT(' pv.VendorId = ', @vendorId, ' AND '), ''), 'pv.ProductId = p.Id 
    INNER JOIN Vendor AS v ON pv.VendorId  = v.Id  
    INNER JOIN ProductBin as pb ON pb.VendorId = pv.VendorID AND pb.ProductID = pv.ProductId ');
RETURN @selectStatement;
END;
//
delimiter ;

drop function if exists CreateWhereStatement;
delimiter //
CREATE 
FUNCTION CreateWhereStatement(minPrice NUMERIC(15,2), maxPrice NUMERIC(15,2),
    productType VARCHAR(20), season VARCHAR(20), size VARCHAR(8))
RETURNS VARCHAR(3000) DETERMINISTIC
BEGIN
 SET @whereProductStatement = CONCAT('',
 IF(season IS NOT NULL AND season <> '', CONCAT('AND p.Season = "', season, '" '), ''),
 IF(productType IS NOT NULL AND productType <> '', CONCAT('AND p.ProductType LIKE "%', productType, '%" '), ''),
 IF(size IS NOT NULL AND size <> '', CONCAT('AND p.Size = "', size, '" '), ''),
 IF(minPrice > 0, CONCAT('AND pv.UnitCost > ', minPrice, ' '), ''),
 IF(maxPrice > 0, CONCAT('AND pv.UnitCost < ', maxPrice, ' '), ''));

 SET @whereProductStatement = IF(@whereProductStatement <> '', 
                                CONCAT(' WHERE ', SUBSTR(@whereProductStatement, 4)), '');
 RETURN @whereProductStatement;
END;
//
delimiter ;

drop function if exists CreateLimitStatement;
delimiter //
CREATE 
FUNCTION CreateLimitStatement(pageNumber INT, recordsPerPage INT)
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
	SET @skipStatement = '';
    IF pageNumber > 0 AND recordsPerPage > 0 THEN
      SET @skipStatement = CONCAT( ' LIMIT ', recordsPerPage,
                 IF(pageNumber > 1, CONCAT(' OFFSET ', (pageNumber - 1) * recordsPerPage, ' ' ), ' '));
    END IF;
    RETURN @skipStatement;
END;
//
delimiter ;

-- Get_ProductsByFilters(category, minPrice, maxPrice, vendor, productType, season, size, 
--                       sortByCategory, sortByVendor, sortByPrice, pageNumber, recordsPerPage) 
CALL Get_ProductsByFilters('', 0, 500, '1-100', '', '', '', true, false, false, 1, 1000);
CALL Get_ProductsByFilters('', 500, 2000, '', '', '', '', false, false, false, 2, 4);
CALL Get_ProductsByFilters('rings', 0, 0, '', '', '', 'Small', false, true, true, 1, 1000);
CALL Get_ProductsByFilters('', 0, 0, '', 'women''s dresses', '', '', true, true, true, 1, 1000);
