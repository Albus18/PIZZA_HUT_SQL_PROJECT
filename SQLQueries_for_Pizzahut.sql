-- PIZZA SQL QUERIES

-- ### Part 1: Basic Analysis ###
-- 1. Retrieve the total number of orders placed.
SELECT count(order_id) AS total_orders FROM orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS Total_Revenue
FROM order_details
LEFT JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id;

-- 3. Identify the highest-priced pizza.
SELECT pizza_types2.name, pizzas.price
FROM pizza_types2
LEFT JOIN pizzas ON pizza_types2.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered.
SELECT pizzas.size, COUNT(order_details.order_details_id) AS order_count
FROM pizzas
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

---
-- ### Part 2: Deeper Insights ###
-- 1. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types2.category, SUM(order_details.quantity) AS quantity
FROM pizzas
LEFT JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
LEFT JOIN pizza_types2 ON pizzas.pizza_type_id = pizza_types2.pizza_type_id
GROUP BY pizza_types2.category
ORDER BY quantity DESC;

-- 2. Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time);

-- 3. Find the category-wise distribution of pizzas.
SELECT pizza_types2.category, count(name) as Total FROM pizza_types2
GROUP BY pizza_types2.category;

-- 4. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity), 0) AS AVG
FROM (
    SELECT orders.order_date, SUM(order_details.quantity) AS quantity
    FROM orders
    LEFT JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS order_Quantity;

-- 5. Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types2.name, SUM(order_details.quantity * pizzas.price) AS Revenue
FROM pizzas
LEFT JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
LEFT JOIN pizza_types2 ON pizzas.pizza_type_id = pizza_types2.pizza_type_id
GROUP BY pizza_types2.name
ORDER BY Revenue DESC
LIMIT 3;

---
-- ### Part 3: Advanced Analytics ###
-- 1. Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types2.category, ROUND((SUM(order_details.quantity * pizzas.price) /
(SELECT SUM(order_details.quantity * pizzas.price) AS Total_sales
FROM order_details
LEFT JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100, 2) AS Revenue
FROM order_details
LEFT JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
LEFT JOIN pizza_types2 ON pizzas.pizza_type_id = pizza_types2.pizza_type_id
GROUP BY pizza_types2.category
ORDER BY Revenue DESC;

-- 2. Analyze the cumulative revenue generated over time.
SELECT order_date, SUM(revenue) OVER(ORDER BY order_date) AS cum_revenue
FROM (
    SELECT orders.order_date, SUM(order_details.quantity * pizzas.price) AS Revenue
    FROM order_details
    LEFT JOIN orders ON order_details.order_id = orders.order_id
    LEFT JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY orders.order_date
) AS sales;

-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category, name, revenue, rank() OVER(PARTITION BY category ORDER BY revenue DESC) AS Rn
FROM (
    SELECT pizza_types2.category, pizza_types2.name, SUM(order_details.quantity * pizzas.price) AS Revenue
    FROM pizza_types2
    JOIN pizzas ON pizza_types2.pizza_type_id = pizzas.pizza_type_id
    LEFT JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types2.category, pizza_types2.name
) AS sales;
