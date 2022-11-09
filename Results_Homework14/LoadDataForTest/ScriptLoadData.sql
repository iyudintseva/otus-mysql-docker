use otus;

# Create tables for import products
drop table if exists ImportProductData;
create table if not exists ImportProductData 
(Id INT PRIMARY KEY AUTO_INCREMENT,
Handle VARCHAR(100),
Title VARCHAR(100),
BodyHTML TEXT,
Vendor VARCHAR(100),
Type  VARCHAR(100),
Tags  VARCHAR(500),
Published VARCHAR(50),
Option1Name VARCHAR(50),
Option1Value VARCHAR(50),
Option2Name VARCHAR(50),
Option2Value VARCHAR(50),
Option3Name VARCHAR(50),
Option3Value VARCHAR(50),
VariantSKU VARCHAR(100),
VariantGrams VARCHAR(100),
VariantInventoryTracker VARCHAR(100),
VariantInventoryQty VARCHAR(50),
VariantInventoryPolicy VARCHAR(50),
VariantFulfillmentService VARCHAR(50),
VariantPrice VARCHAR(50),
VariantCompareAtPrice VARCHAR(50),
VariantRequiresShipping VARCHAR(50),
VariantTaxable VARCHAR(50),
VariantBarcode VARCHAR(50),
ImageSrc VARCHAR(500),
ImageAltText VARCHAR(500),
GiftCard VARCHAR(50),
SEOTitle VARCHAR(50),
SEODescription VARCHAR(500),
GoogleShoppingGoogleProductCategory VARCHAR(500),
GoogleShoppingGender VARCHAR(500),
GoogleShoppingAgeGroup VARCHAR(500),
GoogleShoppingMPN VARCHAR(500),
GoogleShoppingAdWordsGrouping VARCHAR(500),
GoogleShoppingAdWordsLabels VARCHAR(500),
GoogleShoppingCondition VARCHAR(500),
GoogleShoppingCustomProduct VARCHAR(500),
GoogleShoppingCustomLabel0 VARCHAR(500),
GoogleShoppingCustomLabel1 VARCHAR(500),
GoogleShoppingCustomLabel2 VARCHAR(500),
GoogleShoppingCustomLabel3 VARCHAR(500), 
GoogleShoppingCustomLabel4 VARCHAR(500),
VariantImage VARCHAR(500),
VariantWeightUnit VARCHAR(50),
INDEX `index_name` (`Handle`));

-- DELETE FROM ProductVendor where ProductId < 10000;
-- DELETE FROM Vendor where Id < 10000;
-- DELETE FROM ProductCategory where ProductId < 10000;
-- DELETE FROM Product where Id < 10000;
   
# Create procedures for import
drop procedure if exists Insert_Product;
delimiter //
CREATE PROCEDURE Insert_Product(first_id INT, OUT next_id INT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN END;
  START TRANSACTION;
	SET @handle = (SELECT Handle from ImportProductData WHERE Id = first_id limit 1);
    -- SET @handle = 's14-onl-li-4184l-navy';
    DROP TEMPORARY TABLE IF EXISTS tempProd; 
    CREATE TEMPORARY TABLE tempProd 
    SELECT first_row.Handle AS ProductName,
       first_row.Title AS Description,
       first_row.Vendor AS Vendor,
       first_row.Type As Type,
       first_row.GoogleShoppingGoogleProductCategory AS Category,
       SUBSTR(child_row.Variantbarcode, 2) AS ProductCode,
       child_row.VariantInventoryQty AS Qty,
       child_row.VariantPrice AS Price,
       IF(UPPER(first_row.Option1Name) = 'SIZE', child_row.Option1Value, 
		IF(UPPER(first_row.Option2Name) = 'SIZE', child_row.Option2Value, 
		 IF(UPPER(first_row.Option3Name) = 'SIZE', child_row.Option3Value, ''))) AS Size,
       IF(UPPER(first_row.Option1Name) = 'COLOR', child_row.Option1Value, 
		IF(UPPER(first_row.Option2Name) = 'COLOR', child_row.Option2Value, 
		 IF(UPPER(first_row.Option3Name) = 'COLOR', child_row.Option3Value, ''))) AS Color,
       IF(UPPER(first_row.Option1Name) = 'MATERIAL', child_row.Option1Value, 
		IF(UPPER(first_row.Option2Name) = 'MATERIAL', child_row.Option2Value, 
		 IF(UPPER(first_row.Option3Name) = 'MATERIAL', child_row.Option3Value, ''))) AS Material
	FROM ImportProductData as first_row 
	INNER JOIN ImportProductData as child_row 
	ON first_row.Handle = @handle AND first_row.Handle = child_row.Handle 
    AND first_row.Option1Name <> '' AND child_row.VariantBarcode <> '';

    INSERT IGNORE INTO Product
	(ProductCode,Name,Description,ProductType,Season,Size,Specifications)
	SELECT t.ProductCode,t.ProductName,t.Description,t.Type,"На любой сезон", t.Size, 
    IF(t.Color <> '' OR t.Material <> '',
	   concat('{', IF(t.Color <> '', concat('"Color":"',t.Color, '"'),''),
                    IF(t.Color <> '' AND t.Material <> '', ', ', ''),
                    IF(t.Material <> '', concat('"Material":"',t.Material, '"'),''), '}'), 
	   NULL)
    FROM tempProd as t;

    INSERT IGNORE INTO ProductCategory
	(CategoryId, ProductId)
	SELECT c.Id, p.Id
    FROM Product as p INNER JOIN tempProd as t 
    ON p.ProductCode = t.ProductCode 
    INNER JOIN Category as c 
    ON t.Category = c.FullName;

	Set @vendor = (Select Vendor from tempProd where Vendor <> '' LIMIT 1);

    INSERT IGNORE INTO Vendor
	(Name, Address, Email, Phone)
    Values (@vendor, concat('address of ', @vendor), concat(@vendor,"@mail.ru"), "+79998887766");
    
    INSERT IGNORE INTO ProductVendor
	(VendorId, ProductId, UnitCost)
	SELECT v.Id, p.Id, t.Price 
	FROM Product as p INNER JOIN tempProd as t 
    ON p.ProductCode = t.ProductCode
    INNER JOIN Vendor as v ON v.Name = t.Vendor;
    
	SET @count = (SELECT Count(1) FROM ImportProductData WHERE Handle = @handle);
    SET next_id = first_id + @count;
    DROP TEMPORARY TABLE IF EXISTS tempProd ;

    DELETE FROM ImportProductData WHERE Handle = @handle;
 COMMIT;
END
//
delimiter ;

drop procedure if exists From_ImportProdutData_To_Product;
delimiter //
CREATE procedure From_ImportProdutData_To_Product()
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN END;
  START TRANSACTION;
	  SET @last_id = (SELECT Id from ImportProductData ORDER BY Id DESC limit 1);
	  SET @next_id = (SELECT Id from ImportProductData ORDER BY Id limit 1);
	  label1: LOOP
   	    SET @first_id = @next_id;
		CALL Insert_Product(@first_id, @next_id);
		IF (@next_id > @first_id AND @next_id <= @last_id) THEN
		  ITERATE label1;
		END IF;
		LEAVE label1;
	  END LOOP label1;
  COMMIT;
END
//
delimiter ;

# Import data from file to table ImportProductData
LOAD DATA INFILE '/var/lib/mysql/Fashion.csv'
	 INTO TABLE ImportProductData
     COLUMNS TERMINATED BY ','
     ENCLOSED BY '"'
     ESCAPED BY '\\'
 	 LINES TERMINATED BY '\r\n'
     IGNORE 1 LINES
	(Handle,Title,BodyHTML,Vendor,Type,Tags,Published,Option1Name,Option1Value,Option2Name,Option2Value,
	 Option3Name,Option3Value,VariantSKU,VariantGrams,VariantInventoryTracker,VariantInventoryQty,
	 VariantInventoryPolicy,VariantFulfillmentService,VariantPrice,VariantCompareAtPrice,
	 VariantRequiresShipping,VariantTaxable,VariantBarcode,ImageSrc,ImageAltText,GiftCard,
	 SEOTitle,SEODescription,GoogleShoppingGoogleProductCategory,GoogleShoppingGender,
	 GoogleShoppingAgeGroup,GoogleShoppingMPN,GoogleShoppingAdWordsGrouping,GoogleShoppingAdWordsLabels,
	 GoogleShoppingCondition,GoogleShoppingCustomProduct,GoogleShoppingCustomLabel0,
	 GoogleShoppingCustomLabel1,GoogleShoppingCustomLabel2,GoogleShoppingCustomLabel3,
     GoogleShoppingCustomLabel4,VariantImage,VariantWeightUnit);

# Import data from file to table Category
LOAD DATA INFILE '/var/lib/mysql/Category.csv'
	 INTO TABLE Category
     COLUMNS TERMINATED BY ','
     ENCLOSED BY '"'
     ESCAPED BY '\\'
 	 LINES TERMINATED BY '\r\n'
     IGNORE 1 LINES
	(FullName,Id,ParentId,Name);

# move imported data in real tables
CALL From_ImportProdutData_To_Product();

SELECT * FROM Product;
drop procedure if exists From_ImportProdutData_To_Product;
drop procedure if exists Insert_Product;
drop table if exists ImportProductData;

# Import data from file to table City
LOAD DATA INFILE '/var/lib/mysql/City.csv'
	 INTO TABLE City
     COLUMNS TERMINATED BY ','
     ENCLOSED BY '"'
     ESCAPED BY '\\'
 	 LINES TERMINATED BY '\r\n'
     IGNORE 1 LINES
	(Id,Name);

# import customers
drop table if exists ImportCustomerNames;
create table if not exists ImportCustomerNames 
(Id INT PRIMARY KEY AUTO_INCREMENT,
FullName VARCHAR(200));

LOAD DATA INFILE '/var/lib/mysql/Names.csv'
	 INTO TABLE ImportCustomerNames
     COLUMNS TERMINATED BY ','
     ENCLOSED BY '"'
     ESCAPED BY '\\'
 	 LINES TERMINATED BY '\r\n'
     IGNORE 1 LINES
	(FullName);

# создать записи в таблицe Customer
drop procedure if exists Create_Customer;
delimiter //
CREATE procedure  Create_Customer()
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN END;
  START TRANSACTION;
  SET @p1 = 0;
  -- for each city create 3 warehouses
  label1: LOOP
    SET @p1 = @p1 + 1;
    SET @customerName = (Select FullName FRom ImportCustomerNames where id = @p1 limit 1);
    IF @customerName Is NULL OR @customerName = '' THEN
      LEAVE label1;
    END IF;
    SET @ind = POSITION(' ' IN @customerName);
    SET @firstName = SUBSTR(@customerName,1, @ind-1);
    SET @lastName = SUBSTR(@customerName, @ind+1);
    SET @email = concat(@firstName, '_', @lastName, '@mail.ru');
    SET @phone = SUBSTR(CONCAT("+74951234", @p1, 00), 1, 12);

    INSERT INTO Customer (Id, FullName, FirstName, LastName, Phone, EMail)
       VALUES(@p1, @customerName,  @firstName, @lastName, @phone, @email); 

    INSERT INTO Warehouse (CityId, Name, Address, Phone, IsStore)
       VALUES(@p1, 'MyShop-2',  concat(@cityName, ", ул. Ленина, д.1"), "+79998887766", 1); 

    INSERT INTO Warehouse (CityId, Name, Address, Phone, IsStore)
       VALUES(@p1, 'MyShop-3',  concat(@cityName, ", ул. Пушкина, д.1"), "+79998887766", 0); 

    IF @p1 < 200 THEN
      ITERATE label1;
    END IF;
    LEAVE label1;
  END LOOP label1;

  COMMIT; 
END
//
delimiter ;

CALL Create_Customer();
SELECT * FROM Customer;
drop table if exists ImportCustomerNames;
drop procedure if exists Create_Warehouse;



#---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `debug_msg`;
delimiter //
CREATE PROCEDURE debug_msg(enabled INTEGER, msg VARCHAR(255))
BEGIN
  IF enabled THEN BEGIN
    select concat("** ", msg) AS '** DEBUG:';
  END; END IF;
END 
//
delimiter ;
