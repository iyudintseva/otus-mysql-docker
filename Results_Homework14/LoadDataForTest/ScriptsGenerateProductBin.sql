use otus;

# сгенерировать записи в таблицe Warehouse
drop procedure if exists Create_Warehouse;
delimiter //
CREATE procedure  Create_Warehouse()
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN END;
  START TRANSACTION;
  SET @p1 = 0;
  -- for each city create 3 warehouses
  label1: LOOP
    SET @p1 = @p1 + 1;
    SET @cityName = (Select Name FRom City where id = @p1 limit 1);

    INSERT INTO Warehouse (CityId, Name, Address, Phone, IsStore)
       VALUES(@p1, 'MyShop-1',  concat(@cityName, ", ул. Мира, д.1"), "+79998887766", 1); 

    INSERT INTO Warehouse (CityId, Name, Address, Phone, IsStore)
       VALUES(@p1, 'MyShop-2',  concat(@cityName, ", ул. Ленина, д.1"), "+79998887766", 1); 

    INSERT INTO Warehouse (CityId, Name, Address, Phone, IsStore)
       VALUES(@p1, 'MyShop-3',  concat(@cityName, ", ул. Пушкина, д.1"), "+79998887766", 0); 

    IF @p1 < 50 THEN
      ITERATE label1;
    END IF;
    LEAVE label1;
  END LOOP label1;
  COMMIT; 
END
//
delimiter ;

CALL Create_Warehouse();
SELECT * FROM Warehouse;
drop procedure if exists Create_Warehouse;

# сгенерировать записи в таблицe WarehouseBin
drop procedure if exists Create_WarehouseBin;
delimiter //
CREATE procedure  Create_WarehouseBin()
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN END;
  START TRANSACTION;
  SET @p1 = 0;
  -- for each warehouses create 1000 bins
  label1: LOOP
    SET @p1 = @p1 + 1;

    SET @p2 = 0; 
    label2: Loop
		SET @p2 = @p2 + 1;

		INSERT INTO WarehouseBin (WarehouseId, Bin)
        VALUES (@p1, SUBSTR(concat("A", @p1, @p2),1,8)); 
		IF @p2 < 100 THEN
		  ITERATE label2;
		END IF;
		LEAVE label2;
	END LOOP label2;

    IF @p1 < 151 THEN
      ITERATE label1;
    END IF;
    LEAVE label1;
  END LOOP label1;
  COMMIT; 
END
//
delimiter ;

CALL Create_WarehouseBin();
SELECT * FROM WarehouseBin;
drop procedure if exists Create_WarehouseBin;

# сгенерировать записи в таблицe ProductBin
drop procedure if exists Create_ProductBin;
delimiter //
CREATE procedure  Create_ProductBin()
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN END;
  SET @p1 = 1; 
  SET @lastWarehouseId = (SELECT Id FROM Warehouse ORDER BY Id DESC LIMIT 1);
  SET @num_warehouses = FLOOR(RAND()*(100)) + 1;
  
  label1: LOOP
    SET @p1 = @p1 + 1000;
    START TRANSACTION;
		INSERT IGNORE INTO ProductBin (ProductId, VendorId, BinId, ProductCount) 
		SELECT pv.ProductId, pv.VendorId, w_bin.BinId, FLOOR(RAND()*(100)) + 1
		FROM ProductVendor as pv CROSS JOIN     
		(SELECT w.Id AS WarehouseId, wb.Id As BinId FROM 
		Warehouse as w INNER JOIN WarehouseBin as wb
		ON wb.WarehouseId = w.Id 
		WHERE w.Id = FLOOR(RAND()*(@lastWarehouseId))
        LIMIT 10) AS w_bin;
	COMMIT; 
    IF @p1 < 4000 THEN
      ITERATE label1;
    END IF;
    LEAVE label1;
  END LOOP label1;
END
//
delimiter ;
CALL Create_ProductBin();
select count(1) from ProductBin;
drop procedure if exists Create_ProductBin;

