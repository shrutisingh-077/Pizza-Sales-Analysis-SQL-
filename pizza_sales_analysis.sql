create database pizza;

create table orders(
order_id int,
order_date date,
order_time time);

desc orders;
drop table orders;

desc order_details;

-- 1. Retrieve the total number of orders placed.

SELECT 
    COUNT(*) AS total_orders
FROM
    orders;


-- 2. Calculate the total revenue generated from pizza sales.

SELECT 
    SUM(p.price * od.quantity) AS total_revenue
FROM
    order_details AS od
        INNER JOIN
    pizzas AS p ON p.pizza_id = od.pizza_id;


-- 3 Identify the highest-priced pizza.

SELECT 
    *
FROM
    pizzas
ORDER BY price DESC
LIMIT 1;


-- 4. Identify the most commonly ordered pizza size.

SELECT 
    p.size, COUNT(*) AS commonly_orderd
FROM
    order_details AS od
        INNER JOIN
    pizzas AS p ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY commonly_orderd DESC
LIMIT 1;


-- 5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name AS pizza_type, SUM(od.quantity) AS total_quantity
FROM
    order_details AS od
        INNER JOIN
    pizzas AS p ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;


-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category AS pizza_type, SUM(od.quantity) AS total_quantity
FROM
    order_details AS od
        INNER JOIN
    pizzas AS p ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- 7. Determine the distribution of orders by hour of the day.

SELECT date_format(order_time,"%H") AS order_hour,
       COUNT(order_id) AS total_orders
       from orders
       group by order_hour
       order by order_hour;


-- 8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    pt.category, COUNT(p.pizza_id) AS total_pizzas
FROM
    pizzas AS p
        INNER JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;


-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT AVG(daily_total) AS avg_pizzas_per_day
FROM (
    SELECT o.order_date,
           SUM(od.quantity) AS daily_total
    FROM orders o
    INNER JOIN order_details od
      ON o.order_id = od.order_id
    GROUP BY o.order_date
) AS daily_orders;


 -- 10. Determine the top 3 most ordered pizza types based on revenue.
 
 SELECT pt.name AS pizza_type,
       SUM(p.price * od.quantity) AS total_revenue
FROM order_details od
INNER JOIN pizzas p
  ON od.pizza_id = p.pizza_id
INNER JOIN pizza_types pt
  ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT pt.name AS pizza_type,
       SUM(p.price * od.quantity) AS revenue,
       (SUM(p.price * od.quantity) /
        (SELECT SUM(p.price * od.quantity)
         FROM order_details od
         JOIN pizzas p ON od.pizza_id = p.pizza_id) * 100) AS percentage_contribution
FROM order_details od
JOIN pizzas p
  ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
  ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY percentage_contribution DESC;

-- 12. Analyze the cumulative revenue generated over time.

SELECT order_date,
       SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT o.order_date,
           SUM(p.price * od.quantity) AS daily_revenue
    FROM orders o
    JOIN order_details od
      ON o.order_id = od.order_id
    JOIN pizzas p
      ON od.pizza_id = p.pizza_id
    GROUP BY o.order_date
) AS daily_sales;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category, pizza_type, revenue
FROM (
    SELECT pt.category,
           pt.name AS pizza_type,
           SUM(p.price * od.quantity) AS revenue,
           RANK() OVER (PARTITION BY pt.category 
                        ORDER BY SUM(p.price * od.quantity) DESC) AS rank_num
    FROM order_details od
    JOIN pizzas p
      ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt
      ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) AS ranked_pizzas
WHERE rank_num <= 3;




 










