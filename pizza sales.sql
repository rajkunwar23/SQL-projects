CREATE DATABASE project_db;
USE project_db;
CREATE TABLE orders(order_id int PRIMARY KEY,date date NOT NULL,time time NOT NULL);
CREATE TABLE order_details(order_details_id int PRIMARY KEY,order_id int NOT NULL,pizza_id VARCHAR(50) NOT NULL,quantity int NOT NULL,FOREIGN KEY(order_id) REFERENCES orders(order_id));
SELECT * FROM order_details;
SELECT * FROM orders;

 -- (FOR PATH) SHOW VARIABLES LIKE 'secure_file_priv';
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_details.csv'
-- INTO TABLE order_details
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS total_orders FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(p.price*o.quantity),2) AS total_revenue 
FROM pizzas p RIGHT JOIN order_details o
ON p.pizza_id=o.pizza_id;

-- Identify the highest-priced pizza.
SELECT p2.name,p1.price
FROM pizzas p1 JOIN pizza_types p2
ON p1.pizza_type_id=p2.pizza_type_id
ORDER BY p1.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT size,COUNT(order_id) AS cnt
FROM pizzas p JOIN order_details o
ON p.pizza_id=o.pizza_id
GROUP BY size
ORDER BY cnt DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT p2.name,SUM(o.quantity) AS quantities
FROM pizzas p1 JOIN pizza_types p2
ON p1.pizza_type_id=p2.pizza_type_id JOIN order_details o
ON p1.pizza_id=o.pizza_id
GROUP BY name
ORDER BY quantities DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT p1.category,SUM(o.quantity) AS total_quantity
FROM pizza_types p1 JOIN pizzas p2
ON p1.pizza_type_id=p2.pizza_type_id JOIN order_details o
ON p2.pizza_id=o.pizza_id
GROUP BY category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT HOUR(time) AS hour_of_the_day,COUNT(order_id) AS no_of_orders
FROM orders
GROUP BY hour_of_the_day
ORDER BY no_of_orders DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category,COUNT(name) AS pizza_distribution
FROM pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
WITH cte AS (
SELECT o1.date,SUM(o2.quantity) AS sum_quantity
FROM orders o1 JOIN order_details o2
ON o1.order_id=o2.order_id
GROUP BY o1.date)
SELECT ROUND(AVG(sum_quantity),2) AS avg_orders_per_day
FROM cte;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT p2.name,SUM(o.quantity*p1.price) AS revenue
FROM pizzas p1 JOIN pizza_types p2
ON p1.pizza_type_id=p2.pizza_type_id JOIN order_details o
ON p1.pizza_id=o.pizza_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
WITH revenue_by_type AS (
    SELECT 
        pt.category,
        SUM(p.price * od.quantity) AS type_revenue
    FROM 
        order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category
)
SELECT 
    category,
    CONCAT(ROUND(type_revenue * 100.0 / SUM(type_revenue) OVER (), 2),"%") AS percentage_contribution
FROM 
    revenue_by_type
ORDER BY 
    percentage_contribution DESC;

-- Analyze the cumulative revenue generated over time.
WITH cte AS (
SELECT o.date,ROUND(SUM(p.price * od.quantity),2) AS revenue
FROM orders o JOIN order_details od
ON o.order_id=od.order_id
JOIN pizzas p ON p.pizza_id=od.pizza_id
GROUP BY o.date )

SELECT date,ROUND(SUM(revenue) OVER(ORDER BY date),2) AS cumulative_revenue
FROM cte;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH cte1 AS(
SELECT pt.category,pt.name,ROUND(SUM(od.quantity*p.price),2) AS revenue
FROM pizzas p JOIN pizza_types pt
ON p.pizza_type_id=pt.pizza_type_id JOIN order_details od
ON p.pizza_id=od.pizza_id
GROUP BY pt.category,pt.name)
,
cte2 AS(
SELECT category,name,revenue,ROW_NUMBER() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
FROM cte1)

SELECT category,name,revenue
FROM cte2
WHERE rn<=3;