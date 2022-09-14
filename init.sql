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
  BIN VARCHAR(16) NOT NULL,
  CONSTRAINT fk_WarehouseBin_Warehouse FOREIGN KEY (WarehouseId) REFERENCES Warehouse (Id)
);

CREATE TABLE Product (
 Id INT PRIMARY KEY AUTO_INCREMENT,
 Name VARCHAR(500) NOT NULL,
 Description VARCHAR(1000), 
 Age TINYINT,
 Size VARCHAR(8)
);

CREATE TABLE Vendor(
  Id INT PRIMARY KEY AUTO_INCREMENT,
  Name VARCHAR(500) NOT NULL,
  Description VARCHAR(1000), 
  Address VARCHAR(1000) NOT NULL, 
  EMail VARCHAR(500) NOT NULL, 
  Phone VARCHAR(50) NOT NULL 
);

CREATE TABLE ProductVendor(
  VendorId  INT NOT NULL,
  ProductId INT NOT NULL,
  UnitCost  NUMERIC(18,2),
  PRIMARY KEY (VendorID, ProductID ),
  CONSTRAINT fk_ProductVendor_Vendor FOREIGN KEY (VendorID) REFERENCES Vendor (Id),
  CONSTRAINT fk_ProductVendor_Product FOREIGN KEY (ProductID) REFERENCES Product (Id)
);

CREATE TABLE ProductBin(
  ProductId INT NOT NULL,
  VendorId INT NOT NULL,
  BinId INT NOT NULL,
  Count INT,
  PRIMARY KEY (ProductID, VendorID, BinID),
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
  EMail VARCHAR(500) NOT NULL,
  Phone VARCHAR(50) NOT NULL
);

CREATE TABLE CustomerOrder(
  Id INT PRIMARY KEY AUTO_INCREMENT,
  OrderNumber VARCHAR(16) NOT NULL,
  CustomerId INT NOT NULL,
  NeedDelivery BOOLEAN,
  DeliveryDate DATE,  
  DeliveryTimeInterval VARCHAR(100),
  DeliveryCost NUMERIC(18,2),
  Price NUMERIC(18,2),
  Promocode VARCHAR(8),
  CONSTRAINT fk_CustomerOrder_Customer FOREIGN KEY (CustomerID) REFERENCES Customer (Id)
);

CREATE TABLE OrderDtl(
  CustomerOrderId   INT NOT NULL,
  OrderLine INT NOT NULL,
  ProductId INT NOT NULL,
  VendorId  INT NOT NULL,
  UnitCost  NUMERIC(18,2),
  Discount  NUMERIC(5,2), 
  Price     NUMERIC(18,2),
  CONSTRAINT pk_OrderDtl PRIMARY KEY (CustomerOrderId, OrderLine), 
  CONSTRAINT fk_OrderDtl_CustomerOrder FOREIGN KEY (CustomerOrderId) REFERENCES CustomerOrder (Id) ON DELETE CASCADE,
  CONSTRAINT fk_OrderDtl_Product FOREIGN KEY (ProductId) REFERENCES Product (Id),
  CONSTRAINT fk_OrderDtl_ProductVendor FOREIGN KEY (VendorId, ProductId) REFERENCES ProductVendor (VendorId, ProductId)
);

