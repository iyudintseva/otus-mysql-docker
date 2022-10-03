use otus;

# Create tables for imported data
drop table if exists Fashion;
create table if not exists Fashion 
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
VariantWeightUnit VARCHAR(50));

-- mysqlimport otus --ignore-lines=1 --lines-terminated-by="\r\n" --fields-terminated-by="," --fields-enclosed-by="\"" --fields-escaped-by "\\\\" -c Handle,Title,BodyHTML,Vendor,Type,Tags,Published,Option1Name,Option1Value,Option2Name,Option2Value,Option3Name,Option3Value,VariantSKU,VariantGrams,VariantInventoryTracker,VariantInventoryQty,VariantInventoryPolicy,VariantFulfillmentService,VariantPrice,VariantCompareAtPrice,VariantRequiresShipping,VariantTaxable,VariantBarcode,ImageSrc,ImageAltText,GiftCard,SEOTitle,SEODescription,GoogleShoppingGoogleProductCategory,GoogleShoppingGender,GoogleShoppingAgeGroup,GoogleShoppingMPN,GoogleShoppingAdWordsGrouping,GoogleShoppingAdWordsLabels,GoogleShoppingCondition,GoogleShoppingCustomProduct,GoogleShoppingCustomLabel0,GoogleShoppingCustomLabel1,GoogleShoppingCustomLabel2,GoogleShoppingCustomLabel3,GoogleShoppingCustomLabel4,VariantImage,VariantWeightUnit "./Fashion.csv" -p

SELECT * FROM Fashion;
truncate Fashion;

