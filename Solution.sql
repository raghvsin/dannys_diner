-- QUERY 1 :
SELECT
  	customer_id , SUM(price) As price
FROM dannys_diner.sales AS s 
LEFT JOIN dannys_diner.menu AS m ON s.product_id=m.product_id
GROUP BY customer_id 
ORDER BY customer_id

-- QUERY 2:
SELECT 
s.customer_id , COUNT(DISTINCT order_date) AS days
FROM dannys_diner.sales AS s
GROUP BY s.customer_id
ORDER BY s.customer_id

--QUERY 3:
SELECT
customer_id, product_name AS first_product_purchased
FROM(
SELECT 
s.customer_id , m.product_name, ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m ON s.product_id=m.product_id) AS temp
WHERE rank = 1

--QUERY 4:
SELECT
m.product_name, COUNT(*) AS total_count
FROM dannys_diner.sales AS s 
LEFT JOIN dannys_diner.menu AS m ON s.product_id=m.product_id
GROUP BY m.product_name
ORDER BY total_count DESC
LIMIT 1

--QUERY 5
SELECT customer_id, product_name, total_count
FROM (SELECT
s.customer_id, m.product_name, COUNT(*) AS total_count, RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rn
FROM dannys_diner.sales AS s 
LEFT JOIN dannys_diner.menu AS m ON s.product_id=m.product_id
GROUP BY s.customer_id, m.product_name) as ranked
WHERE rn=1

--QUERY 6:
SELECT customer_id, product_name AS first_order_member
FROM (SELECT s.customer_id, me.product_name, s.order_date, m.join_date, Row_number() OVER(partition by s.customer_id ORDER BY s.order_date) AS row_num
FROM dannys_diner.sales As s
LEFT JOIN dannys_diner.members AS m ON s.customer_id=m.customer_id
LEFT JOIN dannys_diner.menu AS me ON s.product_id=me.product_id
WHERE s.order_date >= m.join_date) As ranks
WHERE row_num=1

--Query 7:
SELECT customer_id, product_name AS last_order_before_member
FROM (SELECT s.customer_id, me.product_name, s.order_date, m.join_date, Row_number() OVER(partition by s.customer_id ORDER BY s.order_date DESC) AS row_num
FROM dannys_diner.sales As s
LEFT JOIN dannys_diner.members AS m ON s.customer_id=m.customer_id
LEFT JOIN dannys_diner.menu AS me ON s.product_id=me.product_id
WHERE s.order_date < m.join_date) AS rn
WHERE row_num = 1

--QUERY 8:
SELECT s.customer_id, COUNT(me.product_name) as num_order, SUM(me.price) as total_price
FROM dannys_diner.sales As s
LEFT JOIN dannys_diner.members AS m ON s.customer_id=m.customer_id
LEFT JOIN dannys_diner.menu AS me ON s.product_id=me.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id

--QUERY 9:
SELECT s.customer_id, SUM (
    CASE
      WHEN m.product_name = 'sushi' THEN m.price * 20  -- 2x points multiplier for sushi
      ELSE m.price * 10  -- Regular points for other products
    END
  ) AS points
FROM dannys_diner.sales As s
LEFT JOIN dannys_diner.menu As m ON s.product_id=m.product_id
GROUP BY s.customer_id

--QUERY 10:
SELECT s.customer_id, SUM (
    CASE
      WHEN s.order_date >= m.join_date AND s.order_date < m.join_date + INTERVAL '7 days' THEN me.price * 20  
      ELSE me.price * 10 
    END
  ) AS points
FROM dannys_diner.sales As s
LEFT JOIN dannys_diner.members AS m ON s.customer_id=m.customer_id
LEFT JOIN dannys_diner.menu AS me ON s.product_id=me.product_id
WHERE s.order_date >= m.join_date AND s.order_date < '2021-01-31'
GROUP BY s.customer_id
ORDER BY s.customer_id
