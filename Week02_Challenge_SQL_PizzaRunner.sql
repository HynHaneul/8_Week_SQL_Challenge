USE MASTER
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
	"pizza_name" VARCHAR(40)
);
GO
CREATE TABlE pizza_toppings (
	"topping_id" INTEGER PRIMARY KEY ,
	"topping_name" VARCHAR(40)
);
GO
CREATE TABLE customer_orders(
	"order_id" INTEGER PRIMARY KEY,
	"customer_id" INTEGER,
	"pizza_id" INTEGER,
	"exclusions" VARCHAR(40),
	"extras" VARCHAR(40),
	"order_date" DATETIME,
	CONSTRAINT fk_customer_order_pizza_id FOREIGN KEY (pizza_id) REFERENCES pizza_names(pizza_id)
);
GO
CREATE TABLE runner_orders (
	"order_id" INTEGER,
	"runner_id" INTEGER,
	"pickup_time" VARCHAR(19),
	"distance"	DECIMAL, --số thập phân 
	"duration" INTEGER,
	"cancellation" VARCHAR(23),
	PRIMARY KEY (order_id,runner_id),
	CONSTRAINT FK_runner_orders_order_id FOREIGN KEY (order_id) REFERENCES customer_orders(order_id),
	CONSTRAINT FK_runner_orders_runner_id FOREIGN KEY (runner_id) REFERENCES runners(runner_id)
);
GO
CREATE TABLE pizza_recipes (
	"pizza_id" INTEGER PRIMARY KEY,
	"toppings" VARCHAR(40),
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
  (1, 101, 1, 'None', 'None', '2020-01-01 18:05:02'),
  (2, 101, 5, 'Onions', 'None', '2020-01-01 19:00:52'),
  (3, 102, 4, 'Onions', 'None', '2020-01-02 23:51:23'),
  (4, 102, 3, 'Pineapple', 'None', '2020-01-04 13:23:46'),
  (5, 103, 2, 'Onions','None' , '2020-01-08 21:00:29'),
  (6, 103, 2, 'Pineapple', 'Extra Cheese', '2020-01-08 21:03:13'),
  (7, 104, 2, 'Onions', 'Extra Cheese', '2020-01-08 21:20:29'),
  (8, 104, 4, 'Pineapple', 'Extra Cheese', '2020-01-09 23:54:33'),
  (9, 105, 5, 'Pineapple', '', '2020-01-10 11:22:59'),
  (10, 105, 5, 'Ham', 'None', '2020-01-11 18:34:49'),
  (11, 102, 5, 'Ham', 'Extra Cheese', '2020-01-11 18:34:49'),
  (12, 104, 5, 'Ham', 'None', '2020-01-11 18:34:49');
GO
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20','50', 'no'),
  (2, 1, '2020-01-01 19:10:54', '20','15', 'no'),
  (3, 1, '2020-01-02 00:12:37', '13.4','20', 'no'),
  (4, 2, '2020-01-04 13:53:03', '23.4','5', 'no'),
  (5, 3, '2020-01-08 21:10:57', '10','25', 'no'),
  (6, 3, NULL, NULL,'20', 'Customer Cancelled'),
  (7, 2, '2020-01-08 21:30:45', '25','40', 'yes'),
  (8, 2, '2020-01-10 00:15:02', '23.4','50', 'no'),
  (9, 1, '2020-01-11 18:50:20', '10','30', 'no'),
  (10, 1, '2020-01-11 19:10:54', '10','15', 'yes'),
  (11, 2, '2020-01-11 19:30:45', '25','35', 'no'),
  (12, 2, '2020-01-11 20:57:03', '25','20', 'no');
  
GO
INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 8'),
  (2, '4, 6, 7, 10'),
  (3, '8'),
  (4, '4, 10'),
  (5, '4, 9');
GO
SELECT * FROM customer_orders
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
WHERE cancellation <> 'yes' or cancellation  <>  'Customer Cancelled' 
GROUP BY runner_id

-- TASK 04: HOW MANY OF EACH TYPE OF PIZZA WAS DELIVERED?
SELECT pn.pizza_name,
	   ro.order_id, 
	   COUNT (co.pizza_id) AS pizza_delivered
FROM pizza_names pn join customer_orders co on pn.pizza_id = co.pizza_id 
				join runner_orders ro on co.order_id = ro.order_id
WHERE cancellation <> 'yes' or cancellation  <>  'Customer Cancelled'
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
	WHERE ro.cancellation <> 'yes' or ro.cancellation <> 'Customer Cancelled'
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
	WHERE ro.cancellation <> 'yes' OR ro.cancellation <> 'Customer Cancelled'
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
WHERE ro.cancellation <> 'yes' OR  ro.cancellation <> 'Customer Cancled'

--TASK 09: WHAT WAS THE TOTAL VOLUME OF PIZZAS ORDERED FOR EACH HOUR OF THE DAY?
SELECT DATEPART(HOUR, CAST([order_date] AS datetime)) AS hour_of_day,
		count (co.order_id) AS pizzas_total
FROM customer_orders co  
GROUP BY DATEPART(HOUR, CAST([order_date] AS datetime))

SELECT * FROM customer_orders

--TASK 10: WHAT WAS THE VOLUME OF ORDERS FOR EACH DAY OF THE WEEK?
SELECT co.order_id ,DATEPART (DAY, CAST([order_date] AS datetime)) AS day_of_week
FROM customer_orders co
--GROUP BY co.order_id ---task 10: chưa đúng 

--------------------------------------B. RUNNER AND CUSTOMER EXPERIENCE -------------------------------------
--TASK 01: HOW MANY RUNNERS SIGNED UP FOR EACH 1 WEEK PERIOD?
SELECT DATEPART(WEEK, CAST([registration_date] AS datetime)) AS registration_week , 
		count (runner_id) AS runner_signup
FROM runners 
GROUP BY DATEPART(WEEK, CAST([registration_date] AS datetime))
SELECT * FROM runners;

--TASK 02: WHAT WAS THE AVERAGE TIME IN MINUTES IT TOOK FOR EACH RUNNER TO ARRIVE AT THE PIZZA RUNNER HQ TO PICKUP THE ORDER?
WITH CTE AS (
	SELECT co.order_date, ro.pickup_time, ro.order_id, ro.runner_id,
		DATEDIFF(MINUTE,co.order_date, ro.pickup_time) AS pickup_minues
	FROM customer_orders co 
	JOIN runner_orders ro ON co.order_id = ro.order_id
	WHERE ro.cancellation <> 'yes' or ro.cancellation <> 'Customer Cancelled'
	GROUP BY co.order_date, ro.pickup_time, ro.order_id, ro.runner_id
)
SELECT AVG (pickup_minues) AS avg_pickup_time_minues
FROM CTE 
WHERE pickup_minues > 1;
SELECT * FROM runner_orders;
SELECT * FROM customer_orders;

--TASK 03: IS THERE ANY RELATIONSHIP BETWEEN THE NUMBER OF PIZZAS AND HOW LONG THE ORDER TAKES TO PREPARE?
WITH CTE_MINUES_ORDER AS (
	SELECT ro.pickup_time,co.order_id, COUNT (co.pizza_id) AS pizza_order, co.order_date AS order_time,
			DATEDIFF(MINUTE, ro.pickup_time, co.order_date) AS pre_time_minues 
	FROM customer_orders co join runner_orders ro on co.order_id = ro.order_id
	WHERE ro.cancellation <> 'yes' or ro.cancellation <> 'Customer Cancelled' 
	GROUP BY ro.pickup_time, co.order_id, co.order_date
)
SELECT COUNT (co.pizza_id) AS pizza_order
	 , AVG( pre_time_minues) AS avg_pre_time_minues
FROM CTE_MINUES_ORDER join customer_orders co on CTE_MINUES_ORDER.order_id = co.order_id 
WHERE pre_time_minues > 1
GROUP BY co.pizza_id ;

--TASK 04: WHAT WAS THE AVERAGE DISTANCE TRAVELLED FOR EACH CUSTOMER?
SELECT co.customer_id,ROUND( AVG(ro.distance),2) AS avg_distance 
FROM customer_orders co JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation <> 'yes' or ro.cancellation <> 'Customer Cancelled' 
GROUP BY co.customer_id;
SELECT * FROM customer_orders

--TASK 05: WHAT WAS THE DIFFERENCE BETWEEN THE LONGEST AND SHORTEST DELIVERY TIMES FOR ALL ORDERS?
SELECT MAX(CAST(duration AS DECIMAL(18, 2))) - MIN(CAST(duration AS DECIMAL(18, 2))) AS delivery_time_difference
FROM runner_orders2
WHERE duration NOT LIKE ' ';
--note: không có cách giải

--TASK 06: WHAT WAS THE AVERAGE SPEED FOR EACH RUNNER FOR EACH DELIVERY AND DO YOU NOTICE ANY TREND FOR THESE VALUES?
SELECT ro.runner_id, ro.order_id , AVG(ro.duration) AS runner_delivery 
FROM runner_orders ro 
GROUP BY runner_id, order_id;
--TASK 07: WHAT IS THE SUCCESSFUL DELIVERY PERCENTAGE FOR EACH RUNNER?
SELECT count (runner_orders.order_id) , 
FROM runner_orders ro
WHERE ro.cancellation <> 'yes' or cancellation <> 'Customer Cancelled' 
----------------------------SỬA BÀI TASK 07:---------------------------
SELECT ro.runner_id,ROUND(100, SUM(
	CASE 
		WHEN ro.distance <> '0' and ro.cancellation <> 'yes' THEN 1
		ELSE 0 END ) / COUNT(*),0)  AS delivery_successful

FROM runner_orders ro
GROUP BY ro.runner_id
