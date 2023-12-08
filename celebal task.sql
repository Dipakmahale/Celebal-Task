CREATE TABLE Sales (
 customer_id VARCHAR(20),
 order_date DATE,
 product_id INT
);

CREATE TABLE Menu (
 product_id INT,
 product_name VARCHAR(255),
 price DECIMAL(10, 2)
);

CREATE TABLE Members (
 customer_id VARCHAR(20),
 join_date DATE
);


--to view table
select name
from sys.tables;

