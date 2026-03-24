USE brazilian_ecommerce;

SET GLOBAL local_infile = 1;
SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA LOCAL INFILE 'C:/Users/dalia/Downloads/olist/olist_customers_dataset.csv'
INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/dalia/Downloads/olist/olist_products_dataset.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/dalia/Downloads/olist/olist_geolocation_dataset.csv'
INTO TABLE geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/dalia/Downloads/olist/olist_orders_dataset.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/dalia/Downloads/olist/olist_order_items_dataset.csv'
INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/dalia/Downloads/olist/olist_order_payments_dataset.csv'
INTO TABLE payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET FOREIGN_KEY_CHECKS = 1;


SELECT * FROM customers LIMIT 10;

SELECT * FROM products LIMIT 10;

SELECT * FROM geolocation LIMIT 10;

SELECT * FROM orders LIMIT 10;

SELECT * FROM order_items LIMIT 10;

SELECT * FROM payments LIMIT 10; 
