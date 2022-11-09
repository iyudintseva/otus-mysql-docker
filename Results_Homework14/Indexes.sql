use otus;

-- с уникальными полями индексы отрабатывают и на небольших данных
EXPLAIN SELECT Id, Name FROM City WHERE Name = 'Нижний Новгород';

-- Добавлены дополнительные индексы, по которым часто будет происходить поиск:
EXPLAIN SELECT Id FROM Product WHERE Name = 'leather-loafer-lime';
CREATE INDEX idx_Product_Name ON Product (Name);

EXPLAIN SELECT Id FROM Customer WHERE FullName = 'Светлана Светлова';
CREATE INDEX idx_Customer_FullName ON Customer (FullName);

EXPLAIN SELECT Id FROM SalesOrder WHERE OrderDate = '2022-10-25';
CREATE INDEX idx_SalesOrder_OrderDate ON SalesOrder (OrderDate);

-- Полнотекстовый поиск
EXPLAIN SELECT Id FROM Product WHERE (CAST(Specifications->>'$.Color' AS CHAR(30)) = 'Black');
-- Как я поняла, на отдельный параметр JSON поля Product.Specification нельзя создать индекс, 
-- так как нет гарантии, что все параметры заполнены. Но увидела предложение организовать 
-- полнотекстовый поиск по текстовому полю сгенерированному из JSON данных   
-- "Color", "Material", "Age", "Height", "Style", "ProductWeight"
ALTER TABLE Product ADD txtSpecifications VARCHAR(3000) AS
(CONCAT('Color ', 
        IF(Specifications->'$.Color' IS NOT NULL, Specifications->'$.Color', ''),
        IF(Specifications->'$.Material' IS NOT NULL, CONCAT('Material ', Specifications->'$.Material'), ' '),
        IF(Specifications->'$.Age' IS NOT NULL, CONCAT('Age ', Specifications->'$.Age'), ' '),
        IF(Specifications->'$.Height' IS NOT NULL, CONCAT('Height ', Specifications->'$.Height'), ' '),
        IF(Specifications->'$.Style' IS NOT NULL, CONCAT('Style ', Specifications->'$.Style'), ' '),
        IF(Specifications->'$.ProductWeight' IS NOT NULL, CONCAT('ProductWeight ', Specifications->'$.ProductWeight'), ' ')
))
STORED AFTER Specifications, 
ADD FULLTEXT (txtSpecifications);

EXPLAIN SELECT id, Name, txtSpecifications FROM Product
WHERE MATCH(txtSpecifications) AGAINST('*Silver*' IN BOOLEAN MODE);

-- Думаю нужно объединить эти данные с полем Description, тогда поиск будет более точным
ALTER TABLE Product 
ADD FULLTEXT idx_Product_Description (Description, txtSpecifications);

EXPLAIN SELECT id, Name, Description, txtSpecifications FROM Product
WHERE MATCH(Description, txtSpecifications) AGAINST('*Cotton*' IN BOOLEAN MODE);

-- проверить сколько весят таблицы
SELECT
table_name AS `Table`,
round(((data_length + index_length) / 1024), 2) `Size in KB`
FROM information_schema.TABLES
WHERE table_schema = "otus";

