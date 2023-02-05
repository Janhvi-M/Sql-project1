/*What is the total amount each customer spent at the restaurant?*/
SELECT
s.customer_id,
SUM(price) AS total_sales
FROM
dbo.sales AS s
JOIN dbo.menu AS m
ON s.product_id = m.product_id
GROUP BY customer_id; 

/*How many days has each customer visited the restaurant?*/
SELECT
customer_id,
 COUNT(DISTINCT(order_date)) AS visit_count
FROM
dbo.sales
GROUP BY customer_id;

/*What was the first item from the menu purchased by each customer?*/
WITH ordered_sales_cte AS
(
 SELECT customer_id, order_date, product_name,
 DENSE_RANK() OVER(PARTITION BY s.customer_id
 ORDER BY s.order_date) AS ranking
 FROM dbo.sales AS s
 JOIN dbo.menu AS m
 ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM ordered_sales_cte
WHERE ranking = 1
GROUP BY customer_id, product_name;

/*What is the most purchased item on the menu and how many times was it purchased by all customers?*/
SELECT (COUNT(s.product_id)) AS most_purchased, product_name
FROM dbo.sales AS s
JOIN dbo.menu AS m
 ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY most_purchased DESC
LIMIT 1;

/*Which item was the most popular one for each customer?*/
WITH fav_item_cte AS
(
 SELECT s.customer_id, m.product_name,
 COUNT(m.product_id) AS order_count,
 DENSE_RANK() OVER(PARTITION BY s.customer_id
 ORDER BY COUNT(m.product_id) DESC) AS ranking
FROM dbo.menu AS m
JOIN dbo.sales AS s
 ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, order_count
FROM fav_item_cte
WHERE ranking = 1;

/*Which item was purchased first by the customer after they became a member?*/
WITH member_sales_cte AS
(
 SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
 DENSE_RANK() OVER(PARTITION BY s.customer_id
 ORDER BY s.order_date) AS ranking
 FROM dbo.sales AS s
 JOIN dbo.members AS m
 ON s.customer_id = m.customer_id
 WHERE s.order_date = m.join_date
)
SELECT s.customer_id, s.order_date, m2.product_name
FROM member_sales_cte AS s
JOIN dbo.menu AS m2
 ON s.product_id = m2.product_id;
 
 /*What is the total number of items and amount spent for each member before they became a member?*/
 SELECT
s.customer_id,
 COUNT(DISTINCT s.product_id) AS unique_menu_item,
 SUM(mm.price) AS total_sales
FROM
dbo.sales AS s
JOIN
dbo.members AS m
 ON s.customer_id = m.customer_id
JOIN
dbo.menu AS mm
 ON s.product_id = mm.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;

/*If each customers’ $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer
have?*/
WITH price_points AS
 (
 SELECT *,
 CASE
 WHEN product_id = 1 THEN price * 20
 ELSE price * 10
 END AS points
 FROM
 dbo.menu
 )
 SELECT
s.customer_id,
 SUM(p.points) AS total_points
FROM
price_points AS p
JOIN
dbo.sales AS s
ON p.product_id = s.product_id
GROUP BY
s.customer_id
ORDER BY
customer_id;