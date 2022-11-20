USE otus;
Drop user if exists 'otus_manager'@'localhost';
Drop user if exists 'otus_client'@'localhost';

-- create user and grant privileges to manager
CREATE USER 'otus_manager'@'localhost' IDENTIFIED BY 'Mngr12345';
GRANT SELECT, INSERT, UPDATE, DELETE ON otus.* TO 'otus_manager'@'localhost';
GRANT EXECUTE ON procedure Get_Orders TO 'otus_manager'@'localhost';
flush privileges;

-- create user and grant privileges to client
CREATE USER 'otus_client'@'localhost' IDENTIFIED BY 'Clnt12345';
GRANT SELECT ON otus.* TO 'otus_client'@'localhost';
GRANT INSERT, UPDATE, DELETE ON otus.Customer TO 'otus_client'@'localhost';
GRANT INSERT, UPDATE, DELETE ON otus.SalesOrder TO 'otus_client'@'localhost';
GRANT INSERT, UPDATE, DELETE ON otus.OrderDtl TO 'otus_client'@'localhost';
GRANT EXECUTE ON procedure Get_ProductsByFilters TO 'otus_client'@'localhost';
GRANT EXECUTE ON function CreateCategoryCteStatement TO 'otus_client'@'localhost';
GRANT EXECUTE ON function CreateGroupByStatement TO 'otus_client'@'localhost';
GRANT EXECUTE ON function CreateSelectStatement TO 'otus_client'@'localhost';
GRANT EXECUTE ON function CreateLimitStatement TO 'otus_client'@'localhost';
GRANT EXECUTE ON function CreateWhereStatement TO 'otus_client'@'localhost';

flush privileges;

