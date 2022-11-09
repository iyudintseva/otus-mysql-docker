use otus;

drop procedure if exists Generate_SalesOrders;
delimiter //
CREATE procedure  Generate_SalesOrders()
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN END;
  SET @p1 = -100; 

  label1: LOOP
    SET @p1 = @p1 + 100;
    START TRANSACTION;
		  SET @p2 = 0; 
		  label2: LOOP
			SET @p2 = @p2 + 1;

            SET @orderDate = '2022-12-05';
            SET @order_id = @p1 + @p2;
            IF @p2 < 25 THEN
              SET @orderDate = '2022-11-05';
            ELSEIF @p2 < 50 THEN   
              SET @orderDate = '2022-12-18';
            ELSEIF @p2 < 70 THEN   
              SET @orderDate = '2023-01-12';
            END IF;
            
			CALL Create_SalesOrder(@order_id, @orderDate);
			IF @p2 < 100 THEN
			  ITERATE label2;
			END IF;
			LEAVE label2;
		  END LOOP label2;
	COMMIT; 
    
    IF @p1 < 10000 THEN
      ITERATE label1;
    END IF;
    LEAVE label1;
  END LOOP label1;
END
//
delimiter ;

drop procedure if exists Create_SalesOrder;
delimiter //
CREATE procedure  Create_SalesOrder(order_id INT, order_date DATE)
BEGIN

  SET @orderNumber = CONCAT('AASSDDFFGG', order_id);
  IF LENGTH(@orderNumber) > 16 THEN
	SET @orderNumber = substr(@orderNumber, 1, 16);
  END IF;  
 
  SET @orderStatus = 'Подтвержден';
  IF MONTH(order_date) = 11 THEN
	SET @orderStatus = 'Доставлен';
  ELSEIF  MONTH(order_date) = 12 THEN 	
	SET @orderStatus = 'Оплачен';
  END IF;  
  
  SET @lastCustomerId = (Select Id From Customer ORDER By Id DESC LIMIT 1);
  SET @customerId = (Select Id From Customer where Id >= FLOOR(RAND()*(50)) + 1 ORDER BY Id LIMIT 1);
  SET @orderDate = order_date;
  SET @deliveryDate = DATE_ADD(order_date, INTERVAL 2 DAY);

  INSERT IGNORE INTO SalesOrder 
  (Id, OrderNumber, OrderDate, OrderStatus, CustomerId, NeedDelivery,
    DeliveryDate, DeliveryTimeInterval, DeliveryCost, Price, Total, Promocode) 
  VALUES (@order_id, @orderNumber, @orderDate, @orderStatus, @customerId, true,
  @deliveryDate, '14:00-18:00', 199, 0, 199, '');  
  
  SET @price = 0;
  SET @pricedtl = 0;
  
  # add 5 order lines
  SET @order_line = 0; 
  label1: LOOP
    SET @order_line = @order_line + 1;
    CALL Create_OrderDtl(order_id, @order_line, @pricedtl);
    SET @price = @price + @pricedtl;
    IF @order_line < 5 THEN
      ITERATE label1;
    END IF;
    LEAVE label1;
  END LOOP label1;
  
  UPDATE SalesOrder
  SET Price = @price, Total = Total + Price
  WHERE Id = order_id;
END
//
delimiter ;

drop procedure if exists Create_OrderDtl;
delimiter //
CREATE procedure  Create_OrderDtl(order_id INT, order_line INT, OUT price NUMERIC(15,2))
BEGIN
	SET @lastProductId = (SELECT ProductId FROM ProductVendor ORDER BY ProductId DESC LIMIT 1);
    
	SET @productId = (SELECT ProductId From ProductVendor 
                      WHERE ProductId > FLOOR(RAND()*(@lastProductId)) ORDER BY ProductId LIMIT 1); 
	
    SET @vendorId = (SELECT VendorId FROM ProductVendor 
					WHERE ProductId = @productId 
					LIMIT 1);
    
    SET price = (SELECT UnitCost FROM ProductVendor 
                   WHERE VendorId = @vendorId and ProductId = @productId 
                   LIMIT 1);                 

	INSERT IGNORE INTO OrderDtl 
		(SalesOrderId, OrderLine, VendorId, ProductId, UnitCost, DiscountPercent, Price) 
	VALUES (order_id, order_line, @vendorId, @productId, price, 0, price);  
END
//
delimiter ;

CALL Generate_SalesOrders();
drop procedure if exists Create_OrderDtl;
drop procedure if exists Create_SalesOrder;
drop procedure if exists Generate_SalesOrders;

