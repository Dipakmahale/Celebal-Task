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


INSERT INTO Sales (customer_id, order_date, product_id)
VALUES
('A', '2021-01-01', '1'),
('A', '2021-01-01', '2'),
('A', '2021-01-07', '2'),
('A', '2021-01-10', '3'),
('A', '2021-01-11', '3'),
('A', '2021-01-11', '3'),
('B', '2021-01-01', '2'),
('B', '2021-01-02', '2'),
('B', '2021-01-04', '1'),
('B', '2021-01-11', '1'),
('B', '2021-01-16', '3'),
('B', '2021-02-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-07', '3');

INSERT INTO Menu (product_id, product_name, price)
VALUES
('1', 'sushi', '10'),
('2', 'curry', '15'),
('3', 'ramen', '12');

INSERT INTO Members (customer_id, join_date)
VALUES
('A', '2021-01-07'),
('B', '2021-01-09');

select * from Members;

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
 customer_id,
 SUM(price) AS total_amount_spent
FROM
 Sales
JOIN
 Menu ON Sales.product_id = Menu.product_id
GROUP BY
 customer_id;

 -- 2. How many days has each customer visited the restaurant?
SELECT
 customer_id,
 COUNT(DISTINCT order_date) AS days_visited
FROM
 Sales
GROUP BY
 customer_id;


 -- 3. What was the first item from the menu purchased by each customer?
WITH FirstPurchase AS (
 SELECT
 customer_id,
 product_name,
 ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
 FROM
 Sales
 JOIN
 Menu ON Sales.product_id = Menu.product_id
)
SELECT
 customer_id,
 product_name AS first_item_purchased
FROM
 FirstPurchase
WHERE
 rn = 1;

 -- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1
 product_name,
 COUNT(*) AS purchase_count
FROM
 Sales
JOIN
 Menu ON Sales.product_id = Menu.product_id
GROUP BY
 product_name
ORDER BY
 purchase_count DESC;

 -- 5. Which item was the most popular for each customer?
WITH PopularItems AS (
 SELECT
 customer_id,
 product_name,
 COUNT(*) AS purchase_count,
 ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS
rn
 FROM
 Sales
 JOIN
 Menu ON Sales.product_id = Menu.product_id
 GROUP BY
 customer_id, product_name
)
SELECT
 customer_id,
 product_name AS most_popular_item
FROM
 PopularItems
WHERE
 rn = 1;

 -- 6. Which item was purchased first by the customer after they became a member?
WITH MemberFirstPurchase AS (
 SELECT
 s.customer_id,
 product_name,
 ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS
rn
 FROM
 Sales s
 JOIN
 Menu m ON s.product_id = m.product_id
 JOIN
 Members mem ON s.customer_id = mem.customer_id
 WHERE
 s.order_date >= mem.join_date
)
SELECT
 customer_id,
 product_name AS first_purchase_after_membership
FROM
 MemberFirstPurchase
WHERE
 rn = 1; -- 7. Which item was purchased just before the customer became a member?
WITH MemberLastPurchase AS (
 SELECT
 s.customer_id,
 product_name,
 ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date
DESC) AS rn
 FROM
 Sales s
 JOIN
 Menu m ON s.product_id = m.product_id
 JOIN
 Members mem ON s.customer_id = mem.customer_id
 WHERE
 s.order_date < mem.join_date
)
SELECT
 customer_id,
 product_name AS last_purchase_before_membership
FROM
 MemberLastPurchase
WHERE
 rn = 1;

 -- 8. What is the total items and amount spent for each member before they became a member?
SELECT
 mem.customer_id,
 COUNT(s.product_id) AS total_items_before_membership,
 SUM(Menu.price) AS total_amount_spent_before_membership
FROM
 Sales s
JOIN
 Menu ON s.product_id = Menu.product_id
LEFT JOIN
 Members mem ON s.customer_id = mem.customer_id
WHERE
 s.order_date < mem.join_date OR mem.join_date IS NULL
GROUP BY
 mem.customer_id; --9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
 customer_id,
 SUM(CASE WHEN product_name = 'sushi' THEN 2 * price * 10 ELSE price * 10
END) AS total_points
FROM
 Sales
JOIN
 Menu ON Sales.product_id = Menu.product_id
GROUP BY
 customer_id;

 -- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points 
 --     do customer A and B have at the end of January?
WITH Points AS (
 SELECT
 s.customer_id,
 SUM(CASE WHEN product_name = 'sushi' THEN 2 * price * 10 ELSE price *
10 END) AS total_points
 FROM
 Sales s
 JOIN
 Menu m ON s.product_id = m.product_id
 JOIN
 Members mem ON s.customer_id = mem.customer_id
 WHERE
 s.order_date >= mem.join_date
 AND s.order_date <= DATEADD(WEEK, 1, mem.join_date) -- within the first week after joining
 GROUP BY
 s.customer_id
)
SELECT
 customer_id,
 total_points
FROM
 Points
WHERE
 customer_id IN ('A', 'B');