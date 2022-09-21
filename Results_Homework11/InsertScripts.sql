use otus;
-- Product --
INSERT INTO Product
(ProductCode, Name, Description, ProductType, Season, Size, Specifications)
VALUES
('112233441','Комбинезон Дети рядом', 'Современный полукомбинезон для девочек, выполнен из материала кулирка (100/% хлопок), очень легкий и комфортный,',
 'Комбинизон',  'На любой сезон', '116',
 '{ "Color":"тай дай", "Material":"Кулирная гладь, Хлопок, Трикотаж",
    "Height":"110-116", "Style":"Повседневный, Домашний, Пляжный, Спортивный" }'),
('112233442','Жилет', 'Удачная форма с заниженной линией спинки, продуманные детали, оригинальное и модное оформление, делают жилет идеальным вариантом для городских прогулок, путешествий и активного отдыха.',
 'Жилет', 'Демисезон',  '132',
 '{ "Color":"Темно-синий", "Height":"128-134"}'),
('112233443','Брюки синие', 'Комфортные стильные брюки для девочки', 'Брюки', 'Лето', '92', 
  '{ "Color":"Синий", "Material":"100/% Хлопок", "Age":"2", "Height":"92-98"}'),
('112233444','Брюки зеленые', 'Комфортные стильные брюки для девочки', 'Брюки', 'Лето', '98', 
  '{ "Color":"Зеленый", "Material":"Хлопок 80/% Эластан20/%", "Age":"3", "Height":"98-104", "Style":"На каждый день"}'),
('112233445','Платье желтое', '', 'Платье', 'На любой сезон', '104', 
  '{"Color":"Желтый", "Material":"Хлопок 95/% Эластан5/%", "Age":"4", "Height":"104"}' ),
('112233446','Ветровка SherySheff', 'Детская МЕМБРАННАЯ куртка SHERYSHEFF', 'Куртка', 'Демисезон', '98',
  '{"Color":"Цикламен", "Material":"полиэстер 95/%, спандекс 5/%", "Age":"2", "Height":"92-98", "Style":"Повседневный"}');

-- Vendor -- 
INSERT INTO Vendor
(Name, Description, Address, Email, Phone)
VALUES 
('ООО Трикотаж Профи', 'Трикотаж Профи - это производство трикотажных изделий, на рынке 17 лет.','601900, Владимирская область, Ковров, ул.Либерецкая, 2, 14', 'nosovakatya44@mail.ru', '8-982-383-02-30'),
('ООО Баттон Блю','Button Blue — это классная детская одежда с творческим характером!', '107023, г. Москва, Медовый переулок, д. 5, стр. 1, этаж 2, помещение 15Д', 'durakova@button-blue.ru', '+7 (495) 995-11-23 / 24, доб. 523'),
('ООО МОНЭКС ТРЕЙДИНГ', 'ООО МОНЭКС ТРЕЙДИНГ – российская компания, работающая по системе франчайзинга известной торговой мароки: Mothercare.', '125124, Г.Москва, Москва, Правды, 26, XXIX, ком. 1', 'Marketing.Rus@alshaya.com', '+74956489580');

-- ProductVendor --  
INSERT INTO ProductVendor 
SELECT upd.VendorId, upd.ProductId, 1200 as UnitCost 
FROM (Select v.Id as VendorId, p.Id as ProductId  
    FROM Product as p, Vendor as v
    WHERE p.ProductCode = '112233445' and
          v.Name = 'ООО Трикотаж Профи') as upd;

INSERT INTO ProductVendor  
SELECT upd.VendorId, upd.ProductId, 1100 as UnitCost 
FROM (Select v.Id as VendorId, p.Id as ProductId  
    FROM Product as p, Vendor as v
    WHERE (p.ProductCode = '112233443' or p.ProductCode = '112233444') and
           v.Name = 'ООО Баттон Блю') as upd;

INSERT INTO ProductVendor 
SELECT upd.VendorId, upd.ProductId, 7200 as UnitCost  
FROM (Select v.Id as VendorId, p.Id as ProductId  
    FROM Product as p, Vendor as v
    WHERE p.ProductCode = '112233446' and
          v.name = 'ООО МОНЭКС ТРЕЙДИНГ') as upd;
    
-- Customer --
INSERT INTO Customer(FullName, FirstName, LastName, Address, Email, Phone)
VALUES 
('Василий Иванов', 'Василий', 'Иванов', 'Москва, ул. Вятская, д.27', 'vasya@mail.ru', '+74957788999'),
('Николай Петров', 'Николай', 'Петров', 'Москва, ул. Зой Космедемьянской, д.11, кв.55', 'petya@mail.ru', '+74953334442'),
('Светлана Светлова', 'Светлана', 'Светлова', 'Москва, ул. Kоролева, д.11, кв.54', 'sveta@mail.ru', '+74951111111');

-- SalesOrder --
INSERT INTO SalesOrder
(OrderNumber, OrderDate, CustomerId, NeedDelivery, 
 DeliveryDate, DeliveryTimeInterval, DeliveryCost, Price, Total, Promocode)
VALUES 
('12347BV', SUBDATE(NOW(),1),  2, true, '2022-07-08', '14:00-18:00', 249, 7200, 7449, ''),
('12345A', CURDATE() , 3, true, '2022-07-07', '14:00-18:00', 149, 2700, 2849, '');

-- OrderDtl --

INSERT INTO OrderDtl(
SalesOrderId, OrderLine, ProductId, VendorId, UnitCost, DiscountPercent, price)
VALUES 
((SELECT o.Id FROM SalesOrder AS o WHERE o.OrderNumber = '12345A' limit 1), 
 1, (SELECT p.Id FROM Product AS p WHERE p.ProductCode = '112233443' limit 1), 
 (SELECT v.Id FROM Vendor AS v WHERE v.Name = 'ООО Баттон Блю' limit 1), 900, 0, 900),
((SELECT o.Id FROM SalesOrder AS o WHERE o.OrderNumber = '12345A' limit 1), 
 2, (SELECT p.Id FROM Product AS p WHERE p.ProductCode = '112233444' limit 1), 
 (SELECT v.Id FROM Vendor AS v WHERE v.Name = 'ООО Баттон Блю' limit 1), 1400, 0, 1400),
((SELECT o.Id FROM SalesOrder AS o WHERE o.OrderNumber = '12347BV' limit 1), 
 1, (SELECT p.Id FROM Product AS p WHERE p.ProductCode = '112233446' limit 1), 
 (SELECT v.Id FROM Vendor AS v WHERE v.Name = 'ООО МОНЭКС ТРЕЙДИНГ' limit 1), 7200, 0, 7200),
((SELECT o.Id FROM SalesOrder AS o WHERE o.OrderNumber = '12347BV' limit 1), 
 2, (SELECT p.Id FROM Product AS p WHERE p.ProductCode = '112233445' limit 1), 
 (SELECT v.Id FROM Vendor AS v WHERE v.Name = 'ООО Трикотаж Профи' limit 1), 700, 0, 700); 
 
-- City
INSERT INTO City (Name)
VALUES ('Москва'),
       ('Ярославль');

-- Warehouse --
INSERT INTO Warehouse (Name, CityID, IsStore, Address, Phone)
VALUES 
('N1', 1, TRUE, 'Москва, Ярославское шоссе, д.1', '+74958887766');

-- WarehouseBin --
INSERT INTO WarehouseBin (WarehouseId, Bin)
VALUES 
(1, 'AA00001'),
(1, 'AA00002'),
(1, 'AA00003');

-- ProductBin --  
INSERT INTO ProductBin (ProductId, VendorId, BinId, ProductCount)
VALUES
((SELECT Id FROM Product WHERE ProductCode = '112233445'),
 (SELECT pv.VendorId From ProductVendor as pv 
      WHERE ProductId IN (SELECT p.Id FROM Product as p WHERE p.ProductCode = '112233445')),
 (SELECT Id From WarehouseBin where WarehouseId = 1 and Bin = 'AA00001'), 1);
 
INSERT INTO ProductBin (ProductId, VendorId, BinId, ProductCount)
VALUES
((SELECT Id FROM Product WHERE ProductCode = '112233443'),
 (SELECT pv.VendorId From ProductVendor as pv 
      WHERE ProductId IN (SELECT p.Id FROM Product as p WHERE p.ProductCode = '112233443')),
 (SELECT Id From WarehouseBin where WarehouseId = 1 and Bin = 'AA00002'), 20);
 
INSERT INTO ProductBin (ProductId, VendorId, BinId, ProductCount)
VALUES
((SELECT Id FROM Product WHERE ProductCode = '112233444'),
 (SELECT pv.VendorId From ProductVendor as pv 
       WHERE ProductId IN (SELECT p.Id FROM Product as p WHERE p.ProductCode = '112233444')),
 (SELECT Id From WarehouseBin where WarehouseId = 1 and Bin = 'AA00003'), 15);


