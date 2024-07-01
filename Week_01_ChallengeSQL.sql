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

