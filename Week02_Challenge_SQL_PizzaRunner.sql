﻿USE MASTER
GO
CREATE DATABASE PIZZA_RUNNER;
GO
USE PIZZA_RUNNER;
GO
CREATE TABLE runners (
	"runner_id" INTEGER PRIMARY KEY,
	"registration_date" DATE
);
GO
CREATE TABLE pizza_names (
	"pizza_id" INTEGER PRIMARY KEY,
	"pizza_name" TEXT
);
GO
CREATE TABlE pizza_toppings (
	"topping_id" INTEGER PRIMARY KEY ,
	"topping_name" TEXT
);
GO
CREATE TABLE customer_orders(
	"order_id" INTEGER PRIMARY KEY,
	"customer_id" INTEGER,
	"pizza_id" INTEGER,
	"exclusions" VARCHAR(4),
	"extras" VARCHAR(4),
	"order_date" DATE,
	CONSTRAINT fk_customer_order_pizza_id FOREIGN KEY (pizza_id) REFERENCES pizza_names(pizza_id)
);
GO
CREATE TABLE runner_orders (
	"order_id" INTEGER,
	"runner_id" INTEGER,
	"pickup_time" VARCHAR(19),
	"distance"	VARCHAR(10),
	"cancellation" VARCHAR(23),
	PRIMARY KEY (order_id,runner_id),
	CONSTRAINT FK_runner_orders_order_id FOREIGN KEY (order_id) REFERENCES customer_orders(order_id),
	CONSTRAINT FK_runner_orders_runner_id FOREIGN KEY (runner_id) REFERENCES runners(runner_id)
);
GO
CREATE TABLE pizza_recipes (
	"pizza_id" INTEGER PRIMARY KEY,
	"toppings" TEXT,
	CONSTRAINT FK_pizza_recipes_pizza_id FOREIGN KEY (pizza_id) REFERENCES pizza_names (pizza_id)
);
GO
INSERT INTO runners (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
GO
INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian'),
  (3, 'Pepperoni'),
  (4, 'Margherita'),
  (5, 'Hawaiian');
GO
INSERT INTO pizza_toppings (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Chicken'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Pineapple'),
  (10, 'Tomatoes');
GO
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_date)
VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (4, 102, 3, '', '', '2020-01-04 13:23:46'),
  (5, 103, 2, '', NULL, '2020-01-08 21:00:29'),
  (6, 103, 2, '', '', '2020-01-08 21:03:13'),
  (7, 104, 2, '', NULL, '2020-01-08 21:20:29'),
  (8, 104, 1, '', '', '2020-01-09 23:54:33'),
  (9, 105, 3, '', '', '2020-01-10 11:22:59'),
  (10, 105, 2, '', '', '2020-01-11 18:34:49'),
  (11, 102, 1, '4', '', '2020-01-11 18:34:49'),
  (12, 104, 2, NULL, '1', '2020-01-11 18:34:49');
GO
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', ''),
  (3, 1, '2020-01-02 00:12:37', '13.4km', ''),
  (4, 2, '2020-01-04 13:53:03', '23.4km', ''),
  (5, 3, '2020-01-08 21:10:57', '10km', ''),
  (6, 3, NULL, NULL, 'Customer Cancelled'),
  (7, 2, '2020-01-08 21:30:45', '25km', 'null'),
  (8, 2, '2020-01-10 00:15:02', '23.4km', 'null'),
  (9, 1, '2020-01-11 18:50:20', '10km', 'null'),
  (10, 1, '2020-01-11 19:10:54', '10km', 'null'),
  (11, 2, '2020-01-11 19:30:45', '25km', 'null'),
  (12, 2, '2020-01-11 20:57:03', '25km', 'null');
GO
INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 8'),
  (2, '4, 6, 7, 10'),
  (3, '8'),
  (4, '4, 10'),
  (5, '4, 9');

--------------------------------------A. PIZZA METRICS-------------------------------------
--TASK 01: HOW MANY PIZZAS WERE ORDERED?
SELECT COUNT(order_id) AS PIZZA_ORDER_COUNT
FROM customer_orders co

--TASK 02: HOW MANY UNIQUE CUSTOMER ORDERS WERE MADE?
SELECT COUNT (DISTINCT order_id)  AS unique_customer_order 
FROM customer_orders co

--TASK 03: HOW MANY SUCCESSFULL ORDERS WERE DELIVERED BY EACH RUNNER ?
SELECT runner_id, 
		COUNT (ro.order_id) AS order_successfull
FROM runner_orders ro
WHERE cancellation != 'null' and cancellation  !=  'Customer Cancelled' 
GROUP BY runner_id

-- TASK 04: HOW MANY OF EACH TYPE OF PIZZA WAS DELIVERED?
SELECT pn.pizza_name,
	   ro.order_id, 
	   COUNT (co.pizza_id) AS pizza_delivered
FROM pizza_names pn join customer_orders co on pn.pizza_id = co.pizza_id 
				join runner_orders ro on co.order_id = ro.order_id
WHERE cancellation != 'null' and cancellation  !=  'Customer Cancelled'
GROUP BY ro.order_id, pn.pizza_name

--TASK 05: HOW MANY VEGETARIAN AND MEATLOVERS WERE ORDERED BY EACH CUSTOMER ? 
--(count name của vegetarian and meatlovers)
SELECT co.order_id, co.customer_id,pn.pizza_name,
		COUNT(pn.pizza_name) AS order_by_customer
FROM pizza_names pn inner join customer_orders co on pn.pizza_id = co.pizza_id
WHERE pn.pizza_name IN ('Meatlovers' , 'Vegetarian')
GROUP BY co.order_id, co.customer_id,pn.pizza_name

--TASK 06: WHAT WAS THE MAXIMUM NUMBER OF PIZZAS DELIVERED IN A SNGLE ORDER?
SELECT MAX(pizza_count) AS max_pizza_order
FROM (
	SELECT COUNT (co.pizza_id) AS pizza_count, co.order_id
	FROM customer_orders co INNER JOIN runner_orders ro ON co.order_id = ro.order_id
	WHERE ro.cancellation != 'null' and ro.cancellation != 'Customer Cancelled'
	GROUP BY co.order_id
) AS a

--TASK 07: FOR EACH CUSTOMER, HOW MANY DELIVERED PIZZAS HAD AT LEATS 1 CHANGE AND HOW  MANY HAD NO CHANGES?
--SELECT customer_orders.customer_id, COUNT (customer_orders.pizza_id) AS pizza_count, runner_orders.order_id
--FROM customer_orders inner join  runner_orders ON customer_orders.order_id = runner_orders.order_id
--GROUP BY customer_orders.customer_id, runner_orders.order_id
-------------SỬA TASK 07: --------------
WITH cte AS(
	SELECT
		co.customer_id,
		CASE 
			WHEN co.exclusions IS NOT NULL or co.extras IS NOT NULL THEN 1 
			ELSE 0
		END AS has_change
	FROM customer_orders co inner join runner_orders ro ON co.order_id = ro.order_id
	WHERE ro.cancellation IS NULL OR ro.cancellation <> 'Customer Cancelled'
	-- có sự thay dổi đặt điều kiện case when chỉ lấy những đơn hàng đã được giao
)
SELECT customer_id,
		SUM( 
		CASE 
			WHEN has_change = 1 THEN 1 
			ELSE 0
		END ) AS delivered_pizzas_with_change,
		SUM(
		CASE
			WHEN has_change = 0 THEN 1
			ELSE 0
		END  ) AS deliveried_pizzas_without_change
		--- SAU KHI CHIA TÍNH TÔNG HAS_CHANGE AND NOT HAS_CHANGE
FROM cte 
GROUP BY CTE.customer_id

--TASK 08: HOW MANY PIZZAS WERE DELIVERED THAT HAD BOTH EXCLUSIONS AND EXTRAS? 
SELECT 
	SUM(
	CASE
		WHEN co.exclusions IS NOT NULL AND co.extras IS NOT NULL THEN 1
		ELSE 0
	END )AS pizzas_count_exclusion_extras
FROM customer_orders co INNER JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL OR  ro.cancellation <> 'Customer Cancled'

--TASK 09: WHAT WAS THE TOTAL VOLUME OF PIZZAS ORDERED FOR EACH HOUR OF THE DAY?
SELECT DATEPART(HOUR, CAST([order_date] AS datetime)) AS hour_of_day,
		SUM (co.pizza_id) AS pizzas_total
FROM customer_orders co  
GROUP BY DATEPART(HOUR, CAST([order_date] AS datetime))
ORDER BY hour_of_day

--TASK 10: WHAT WAS THE VOLUME OF ORDERS FOR EACH DAY OF THE WEEK?
