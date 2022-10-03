use otus;

# я не нашла вариант как импортить с нужным типом, 
# поэтому создаю буферную таблицу ImportProductData, имеющую стринговые поля,
# в которую загружаю данные из файла. А уже отдельной процедурой разношу 
# данные по таблицам.

# Create tables for imported data
drop table if exists ImportProductData;
create table if not exists ImportProductData 
(Id INT PRIMARY KEY AUTO_INCREMENT,
ProductCategory VARCHAR(100),
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

drop table if exists ExtProduct;
create table if not exists ExtProduct 
(Id INT PRIMARY KEY AUTO_INCREMENT,
ProductCategory VARCHAR(100),
Handle VARCHAR(100),
Title VARCHAR(100),
BodyHTML VARCHAR(3000),
Vendor VARCHAR(100),
Type  VARCHAR(100),
Tags  VARCHAR(500),
Published boolean);

drop table if exists ExtProductVariant;
create table if not exists ExtProductVariant 
(Id INT PRIMARY KEY AUTO_INCREMENT,
ExtProductId INT,
Option1Name VARCHAR(50),
Option1Value VARCHAR(50),
Option2Name VARCHAR(50),
Option2Value VARCHAR(50),
Option3Name VARCHAR(50),
Option3Value VARCHAR(50),
SKU VARCHAR(100),
Grams VARCHAR(100),
InventoryTracker VARCHAR(100),
InventoryQty INT,
InventoryPolicy VARCHAR(50),
FulfillmentService VARCHAR(50),
Price NUMERIC(13,2),
CompareAtPrice NUMERIC(13,2),
RequiresShipping BOOLEAN,
Taxable BOOLEAN,
Barcode VARCHAR(50),
ImageSrc VARCHAR(500),
ImageAltText VARCHAR(500),
GiftCard BOOLEAN,
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
Image VARCHAR(500),
WeightUnit VARCHAR(50));

# Create procedures for import
drop procedure if exists Insert_ExtProduct;
delimiter //
CREATE PROCEDURE Insert_ExtProduct(first_id INT, OUT next_id INT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN END;
  START TRANSACTION;
	SET @handle = (SELECT Handle from ImportProductData WHERE Id = first_id limit 1);

    DROP TEMPORARY TABLE IF EXISTS tempProd; 
    CREATE TEMPORARY TABLE tempProd 
    SELECT * FROM ImportProductData WHERE Handle = @handle;

    INSERT IGNORE INTO ExtProduct
	(ProductCategory,Handle,Title,BodyHTML,Vendor,Type,Tags,Published)
	SELECT t.ProductCategory, t.Handle,t.Title,t.BodyHTML,t.Vendor,t.Type,t.Tags,IF(t.Published = 'true', 1, 0)
    FROM tempProd as t where t.Id = first_id;

	SET @extProductId = (SELECT Id from ExtProduct WHERE Handle = @handle limit 1);
    SET @Option1Name = (SELECT Option1Name  FROM tempProd as t where t.Id = first_id);
    SET @Option2Name = (SELECT Option2Name  FROM tempProd as t where t.Id = first_id);
    SET @Option3Name = (SELECT Option3Name  FROM tempProd as t where t.Id = first_id);
    
    INSERT IGNORE INTO ExtProductVariant
    (ExtProductId, Option1Name, Option1Value, Option2Name, Option2Value,
	 Option3Name, Option3Value, SKU, Grams, InventoryTracker, InventoryQty,
	 InventoryPolicy, FulfillmentService, Price, CompareAtPrice,
	 RequiresShipping, Taxable, Barcode, ImageSrc, ImageAltText, GiftCard,
	 SEOTitle, SEODescription,GoogleShoppingGoogleProductCategory,GoogleShoppingGender,
	 GoogleShoppingAgeGroup,GoogleShoppingMPN,GoogleShoppingAdWordsGrouping,GoogleShoppingAdWordsLabels,
	 GoogleShoppingCondition,GoogleShoppingCustomProduct,GoogleShoppingCustomLabel0,
	 GoogleShoppingCustomLabel1,GoogleShoppingCustomLabel2,GoogleShoppingCustomLabel3,
     GoogleShoppingCustomLabel4, Image, WeightUnit)
    SELECT @extProductId, @Option1Name, t.Option1Value, @Option2Name, t.Option2Value,
	 t.Option3Name, @Option3Value,t.VariantSKU,t.VariantGrams,t.VariantInventoryTracker,
     IF(t.VariantInventoryQty <> '', t.VariantInventoryQty, 0),
	 t.VariantInventoryPolicy,t.VariantFulfillmentService,
     IF(t.VariantPrice <> '', t.VariantPrice, 0),
     IF(t.VariantCompareAtPrice  <> '', t.VariantCompareAtPrice, 0),
	 IF(t.VariantRequiresShipping = 'true', 1, 0),
     IF(t.VariantTaxable = 'true', 1, 0),
     t.VariantBarcode,t.ImageSrc,t.ImageAltText,
     IF(t.GiftCard = 'true', 1, 0),
	 t.SEOTitle,t.SEODescription,t.GoogleShoppingGoogleProductCategory,t.GoogleShoppingGender,
	 t.GoogleShoppingAgeGroup,t.GoogleShoppingMPN,t.GoogleShoppingAdWordsGrouping,
     t.GoogleShoppingAdWordsLabels,	t.GoogleShoppingCondition, t.GoogleShoppingCustomProduct,
     t.GoogleShoppingCustomLabel0,t.GoogleShoppingCustomLabel1,t.GoogleShoppingCustomLabel2,
     t.GoogleShoppingCustomLabel3,t.GoogleShoppingCustomLabel4,t.VariantImage,t.VariantWeightUnit
    FROM tempProd as t;

	SET @count = (SELECT Count(1) from tempProd);
    SET next_id = first_id + @count;
    DROP TEMPORARY TABLE IF EXISTS tempProd ;

    DELETE FROM ImportProductData WHERE Handle = @handle;
 COMMIT;
END
//
delimiter ;

drop procedure if exists From_ImportProdutData_To_ExtProduct;
delimiter //
CREATE procedure From_ImportProdutData_To_ExtProduct()
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN END;
  START TRANSACTION;
	  SET @last_id = (SELECT Id from ImportProductData ORDER BY Id DESC limit 1);
	  SET @next_id = (SELECT Id from ImportProductData ORDER BY Id limit 1);
	  label1: LOOP
   	    SET @first_id = @next_id;
		CALL Insert_ExtProduct(@first_id, @next_id);
		IF (@next_id > @first_id AND @next_id <= @last_id) THEN
		  ITERATE label1;
		END IF;
		LEAVE label1;
	  END LOOP label1;
  COMMIT;
END
//
delimiter ;

# clear data
truncate table ImportProductData;
truncate table ExtProduct;
truncate table ExtProductVariant;

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
     GoogleShoppingCustomLabel4,VariantImage,VariantWeightUnit)
  Set ProductCategory = 'Fashion';

-- mysqlimport billing --ignore-lines=1 --lines-terminated-by="r\n" --fields-terminated-by="," --fields-enclosed-by="\""  -c title,author,created_at "./articles.csv"

SELECT * FROM ImportProductData;

# move imported data in real tables
CALL From_ImportProdutData_To_ExtProduct();

SELECT * FROM ImportProductData;
SELECT * FROM ExtProduct;
SELECT * FROM ExtProductVariant;
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
