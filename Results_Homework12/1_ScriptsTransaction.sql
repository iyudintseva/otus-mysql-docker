use otus;

# Для изменения цены продукта продавцом надо изменить цену в таблице ProductVendor
# и в заказах имеющих статус 'Новый'. Общая цена такого заказа должна быть тоже пересчитана. 
# В дальнейшем эта логика должна быть перенесена в триггер

-- prepare data for test
INSERT INTO ProductVendor (VendorId, ProductId, UnitCost)
VALUES (1,1, 1000);

INSERT INTO SalesOrder
(OrderNumber, OrderDate, OrderStatus, CustomerId, NeedDelivery, 
 DeliveryDate, DeliveryTimeInterval, DeliveryCost, Price, Total, Promocode)
VALUES 
('12345B', CURDATE() , 'Новый', 3, true, '2022-10-01', '14:00-18:00', 100, 1000, 1100, ''),
('12345С', CURDATE() , 'Оплачен', 3, true, '2022-09-27', '14:00-18:00', 100, 1000, 1100, '');

INSERT INTO OrderDtl
(SalesOrderId, OrderLine, ProductId, VendorId, UnitCost, DiscountPercent, price)
VALUES 
((SELECT o.Id FROM SalesOrder AS o WHERE o.OrderNumber = '12345B'),  1, 1, 1, 1000, 0, 1000), 
((SELECT o.Id FROM SalesOrder AS o WHERE o.OrderNumber = '12345С'),  1, 1, 1, 1000, 0, 1000);

-- create procedure
use otus;
drop procedure if exists UpdateUnitCost_ProductVendor;
delimiter //
CREATE procedure  UpdateUnitCost_ProductVendor(prodId INT, vendId INT, productUnitCost NUMERIC(13,2))
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN END;
  START TRANSACTION;
	  UPDATE ProductVendor 
	  SET UnitCost = productUnitCost
	  WHERE VendorId = vendId and ProductId = prodId;
	  
	  UPDATE OrderDtl
	  SET UnitCost = productUnitCost
	  WHERE VendorId = vendId and ProductId = prodId and 
			SalesOrderId IN 
			( SELECT Id FROM SalesOrder WHERE OrderStatus = 'Новый');
      
  COMMIT;
END
// delimiter ;

CALL UpdateUnitCost_ProductVendor(1, 1, 1200);

SELECT p.Id as ProductId,
       p.Name as Product,
       ord.OrderNumber,
       ord.OrderStatus,
       dtl.OrderLine,
       dtl.UnitCost as OrderDtl_Price,
       pv.UnitCost as ProductVendor_UnitCost
       FROM ProductVendor as pv 
       INNER JOIN Product as p ON pv.VendorId = 1 and pv.ProductId = 1 and p.Id = pv.ProductId
       INNER JOIN Vendor as v ON pv.VendorId = v.Id
       INNER JOIN OrderDtl as dtl ON dtl.VendorId = pv.VendorId and dtl.ProductId = pv.VendorID
       INNER JOIN SalesOrder as ord ON dtl.SalesOrderId = ord.Id;


