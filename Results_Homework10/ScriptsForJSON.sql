use otus;

# insert JSON with all values
INSERT INTO Product
(Name, Description, ProductType, Season, Size, Specifications)
VALUES
('Комбинезон Дети рядом', 
 'Современный полукомбинезон для девочек, выполнен из материала кулирка (100\% хлопок), очень легкий и комфортный,',
 'Комбинизон',
 'На любой сезон',
 '116',
 '{ "Color":"тай дай" ,
    "Material":"Кулирная гладь, Хлопок, Трикотаж",
    "Age":"",
    "Height":"110-116",
    "Style":"Повседневный, Домашний, Пляжный, Спортивный",
    "ProductWeight":"" 
 }');

# insert JSON with only not empty values
INSERT INTO Product
(Name, Description, ProductType, Season, Size, Specifications)
VALUES
('Жилет', 
 'Удачная форма с заниженной линией спинки, продуманные детали, оригинальное и модное оформление, делают жилет идеальным вариантом для городских прогулок, путешествий и активного отдыха.',
 'Жилет',
 'Демисезон',
 '132',
 '{ "Color":"Темно-синий" ,
    "Height":"128-134"
  }');
  
#select all after inserts
select Id, Name, Specifications from Product;  

# select with search in JSON values
SELECT p.Id, p.Name, p.Specifications->>'$.Color' as Color 
FROM Product AS p
WHERE p.Specifications->>'$.Color' = 'Темно-синий';

# select JSON values, where one of them is not set
SELECT Specifications->>'$.Height' AS Height,
       Specifications->>'$.Style' AS Style
FROM Product;

# select with JSON_EXTRACT 
SELECT p.Id, p.Name, JSON_EXTRACT(p.Specifications, '$.Color') as Color FROM Product AS p;

