CREATE database otus;
USE otus;

CREATE TABLE City (
 Id SMALLINT PRIMARY KEY AUTO_INCREMENT,
 Name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Warehouse(
  Id INT PRIMARY KEY AUTO_INCREMENT,
  CityId SMALLINT NOT NULL,
  Name VARCHAR(500) NOT NULL,
  IsStore BOOLEAN NOT NULL DEFAULT false, 
  Address VARCHAR(1000) NOT NULL, 
  Phone VARCHAR(50) NOT NULL, 
  CONSTRAINT fk_Warehouse_City FOREIGN KEY (CityId) REFERENCES City (Id)
);

CREATE TABLE WarehouseBin(
  Id INT PRIMARY KEY AUTO_INCREMENT,
  WarehouseId INT NOT NULL,
  Bin VARCHAR(16) NOT NULL,
  CONSTRAINT fk_WarehouseBin_Warehouse FOREIGN KEY (WarehouseId) REFERENCES Warehouse (Id)
);

CREATE TABLE Category(
  Id SMALLINT PRIMARY KEY AUTO_INCREMENT,
  ParentCategoryId SMALLINT,
  Name VARCHAR(50)   
);

CREATE TABLE Product (
  Id INT PRIMARY KEY AUTO_INCREMENT,
  ProductCode CHAR(9) UNIQUE NOT NULL,
  Name VARCHAR(500) NOT NULL,
  Description VARCHAR(1000), 
  ProductType VARCHAR(20),
  Season ENUM('На любой сезон','Зима','Демисезон','Весна','Лето','Осень'),
  Size VARCHAR(8),
  Specifications JSON 
);

CREATE TABLE ProcuctCategory(
  CategoryId SMALLINT NOT NULL,
  ProductId INT NOT NULL,
  PRIMARY KEY (CategoryId, ProductId ),
  CONSTRAINT fk_ProductCategory_Category FOREIGN KEY (CategoryId) REFERENCES Category (Id),
  CONSTRAINT fk_ProductCategory_Product FOREIGN KEY (ProductId) REFERENCES Product (Id)
);

CREATE TABLE Vendor(
  Id INT PRIMARY KEY AUTO_INCREMENT,
  Name VARCHAR(500) UNIQUE NOT NULL,
  Description VARCHAR(1000), 
  Address VARCHAR(1000) NOT NULL, 
  EMail VARCHAR(50) NOT NULL, 
  Phone VARCHAR(50) NOT NULL 
);

CREATE TABLE ProductVendor(
  VendorId  INT NOT NULL,
  ProductId INT NOT NULL,
  UnitCost  NUMERIC(18,2),
  PRIMARY KEY (VendorId, ProductId ),
  CONSTRAINT fk_ProductVendor_Vendor FOREIGN KEY (VendorId) REFERENCES Vendor (Id),
  CONSTRAINT fk_ProductVendor_Product FOREIGN KEY (ProductId) REFERENCES Product (Id)
);

CREATE TABLE ProductBin(
  ProductId INT NOT NULL,
  VendorId INT NOT NULL,
  BinId INT NOT NULL,
  ProductCount INT,
  PRIMARY KEY (ProductId, VendorId, BinId),
  CONSTRAINT fk_ProductBin_WarehouseBin FOREIGN KEY (BinId) REFERENCES WarehouseBin (Id),
  CONSTRAINT fk_ProductBin_Vendor FOREIGN KEY (VendorId) REFERENCES Vendor (Id),
  CONSTRAINT fk_ProductBin_Product FOREIGN KEY (ProductId) REFERENCES Product (Id)
);

CREATE TABLE Customer(
  Id INT PRIMARY KEY AUTO_INCREMENT,
  FullName VARCHAR(500) NOT NULL,
  FirstName VARCHAR(100) NOT NULL,
  LastName VARCHAR(400) NOT NULL,
  Address VARCHAR(1000),
  EMail VARCHAR(50) UNIQUE NOT NULL,
  Phone VARCHAR(50) NOT NULL
);

CREATE TABLE SalesOrder(
  Id INT PRIMARY KEY AUTO_INCREMENT,
  OrderNumber VARCHAR(16) UNIQUE NOT NULL,
  OrderDate DATETIME,
  OrderStatus ENUM('Новый','Подтвержден','Оплачен','Доставлен','Отменен') default 'Новый',
  CustomerId INT NOT NULL,
  NeedDelivery BOOLEAN,
  DeliveryDate DATE,  
  DeliveryTimeInterval ENUM ('10:00-14:00','14:00-18:00','18:00-22:00'),
  DeliveryCost NUMERIC(13,2),
  Price NUMERIC(15,2),
  Total NUMERIC(15,2),
  Promocode VARCHAR(8),
  CONSTRAINT fk_SalesOrder_Customer FOREIGN KEY (CustomerID) REFERENCES Customer (Id)
);

CREATE TABLE OrderDtl(
  SalesOrderId   INT NOT NULL,
  OrderLine INT NOT NULL,
  ProductId INT NOT NULL,
  VendorId  INT NOT NULL,
  UnitCost  NUMERIC(13,2),
  DiscountPercent FLOAT(4,2) UNSIGNED CHECK (Discount >= 0 AND Discount <= 100), 
  Price NUMERIC(13,2),
  CONSTRAINT pk_OrderDtl PRIMARY KEY (SalesOrderId, OrderLine), 
  CONSTRAINT fk_OrderDtl_SalesOrder FOREIGN KEY (SalesOrderId) REFERENCES SalesOrder (Id) ON DELETE CASCADE,
  CONSTRAINT fk_OrderDtl_Product FOREIGN KEY (ProductId) REFERENCES Product (Id),
  CONSTRAINT fk_OrderDtl_ProductVendor FOREIGN KEY (VendorId, ProductId) REFERENCES ProductVendor (VendorId, ProductId)
);

