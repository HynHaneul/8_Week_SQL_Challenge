CREATE DATABASE dannys_diner_more;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

ALTER TABLE sales ADD CONSTRAINT fk_sales_members_customer_id FOREIGN KEY (customer_id) REFERENCES members(customer_id);
ALTER TABLE sales ADD CONSTRAINT fk_sales_menu_product_id FOREIGN KEY (product_id) REFERENCES menu(product_id);

INSERT INTO sales ("customer_id", "order_date", "product_id")
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
 

CREATE TABLE menu(
  "product_id" INTEGER PRIMARY KEY,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members(
  "customer_id" VARCHAR(1) PRIMARY KEY,
  "join_date" DATE
);

INSERT INTO members ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09'),
  ('C', '2021-01-01');

select * from members
select * from menu 
select * from sales 

---task 1: what is the total amount each customer spent at the restaurat ?
select sales.customer_id, SUM(menu.price) as Total_sales
from sales inner join menu on sales.product_id = menu.product_id
group by sales.customer_id
order by sales.customer_id ASC;

----Task 2: how many days has each customer visited the restaurant?
select sales.customer_id,COUNT(DISTINCT order_date) as visit_count 
from sales
group by sales.customer_id ;

----task 3: what was the first item from the menu purchased by each customer?
	--DENSE_RANK : KHÔNG bỏ qua các số hạng khi gặp giá trị trùng lặp
	--PARTITION BY: (TÙY CHỌN) Chia tập kết quả thành các nhóm mà hàm "dense_rank" được áp dụng độc lập trên mỗi nhóm 
	--ORDER BY: sắp xếp các hàng trong mỗi nhóm.
 WITH ordered_sales
	 AS ( select sales.customer_id,sales.order_date, menu.product_name, 
DENSE_RANK() OVER (PARTITION BY sales.customer_id order by sales.order_date) as rank
from sales inner join menu on sales.product_id = menu.product_id )

SELECT customer_id, product_name
from ordered_sales
where rank = 1
group by customer_id , product_name;
----Task 4: What is the most purchased item on the menu and how many times was it purchased by all customers?
select menu.product_name,COUNT(sales.product_id)  as most_purchased_item
from menu inner join sales on sales.product_id = menu.product_id
group by menu.product_name 
order by most_purchased_item DESC
---Task 5: Which item was the most popular for each customer?
WITH MOST_POPULAR AS (
	SELECT 
	sales.customer_id, menu.product_name, COUNT (menu.product_id) AS order_count,
	DENSE_RANK () OVER (
		PARTITION BY sales.customer_id 
		Order BY COUNT (sales.customer_id) DESC )  AS rank 
		from sales join menu on menu.product_id = sales.product_id
		group by sales.customer_id, menu.product_name
)
select customer_id,product_name, order_count 
from MOST_POPULAR
WHERE rank = 1;
----Task 6: Sửa bài: Which item was purchased first by the customer after the became a member?
WITH JOINED_AS_MEMBER AS(
	SELECT 
		members.customer_id, sales.product_id,
		ROW_NUMBER() OVER (
			PARTITION BY members.customer_id
			ORDER BY sales.order_date) AS row_num
		FROM members inner join sales on members.customer_id = sales.customer_id 
							and sales.order_date > members.join_date
)
	SELECT customer_id , product_name 
	FROM JOINED_AS_MEMBER  INNER JOIN menu on JOINED_AS_MEMBER.product_id = menu.product_id
	WHERE row_num = 1
	ORDER BY customer_id ASC 
-----Task 7: Which item was purchased just before the customer became a member?
WITH the_purchased_before as (
	SELECT  sales.product_id,
			members.customer_id,
			ROW_NUMBER () OVER(
				PARTITION BY members.customer_id 
				ORDER BY sales.order_date DESC) as rank
	FROM sales inner join members on sales.customer_id = members.customer_id
					and sales.order_date < members.join_date
)
select p_member.customer_id , menu.product_name
FROM the_purchased_before as p_member INNER JOIN menu on p_member.product_id = menu.product_id
WHERE rank = 1
order by customer_id ASC;
-----Task 8: What is the total items amount spent for each member before they became a member?
WITH Total_item as (
	select members.customer_id, SUM(sales.product_id) AS total_product,
			 DENSE_RANK() OVER(
			 PARTITION BY members.customer_id 
			 ORDER BY  sales.order_date DESC) as rank 
	from members inner join sales on members.customer_id = sales.customer_id
					and sales.order_date < members.join_date
)
select total_product, customer_id
from Total_item  
where rank = 1
order by customer_id ASC;
-----Task 8: Sửa bài:sum của doanh số-> sum(menu.price) as total_sales, 
--count(sales.product) as total_items
SELECT sales.customer_id,
		SUM(menu.price) as total_sales, 
		COUNT(sales.product_id) as total_items
FROM members inner join sales on members.customer_id = sales.customer_id 
		and members.join_date > sales.order_date
		inner join menu on sales.product_id = menu.product_id 
GROUP BY sales.customer_id
ORDER BY sales.customer_id;
---Task 9: if each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points_cte AS (
	SELECT 
		menu.product_id, 
		CASE 
			WHEN product_id = 1 THEN price * 20
			ELSE price * 10 END AS points
	FROM menu
)
SELECT 
	sales.customer_id,
	SUM( points_cte.points) AS total_points
FROM sales	inner join points_cte on sales.product_id = points_cte.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;
--Task 10: in the first week after a customer joins the program(including their join date) 
--they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of january?
WITH dates_cte AS (
	SELECT 
		EOMONTH(DATEADD(month, 1, '2021-01-31')) AS last_date, 
		members.customer_id, 
		members.join_date, 
		DATEADD(day, 6, members.join_date) AS valid_date 
	FROM members
)
SELECT 
	sales.customer_id,
		SUM(
		CASE
			WHEN menu.product_name = 'sushi' THEN 2 * 10 * menu.price
			WHEN sales.order_date BETWEEN dates.join_date and dates.valid_date THEN 2 * 10 * menu.price
			ELSE 10 * menu.price 
		END 
	) AS points
FROM sales inner join dates_cte AS dates on sales.customer_id = dates.customer_id
			AND dates.join_date <= sales.order_date
			AND sales.order_date <= dates.last_date
			inner join menu on sales.product_id = menu.product_id
			GROUP BY sales.customer_id;
