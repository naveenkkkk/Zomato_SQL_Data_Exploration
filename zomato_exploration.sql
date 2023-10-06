CREATE DATABASE zomato_practice;
USE zomato_practice;

CREATE TABLE goldusers_signup(userid integer,gold_signup_date VARCHAR(255)); 
INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'), (3,'04-21-2017');

CREATE TABLE users(userid integer,signup_date VARCHAR(255)); 
INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

CREATE TABLE sales(userid integer,created_date VARCHAR(255),product_id integer); 
INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

CREATE TABLE product(product_id integer,product_name text,price integer); 
INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

-- Total amount each customer spent 
SELECT a.userid, SUM(b.price) Total_Sum FROM sales a INNER JOIN product b on a.product_id=b.product_id GROUP BY a.userid;

-- Total number of days each user visited
SELECT userid, COUNT(DISTINCT created_date) No_of_days_loggedin FROM sales GROUP BY userid; 

-- Each customer's first purchase 
SELECT * FROM
	(SELECT *, rank() OVER (PARTITION BY userid ORDER BY created_date ASC ) rnk FROM sales) a WHERE rnk = 1;
    
-- Most purchased item and how many all customers bought the item
SELECT userid, COUNT(product_id) Total FROM sales WHERE product_id = 
	(SELECT product_id FROM sales GROUP BY product_id ORDER BY COUNT(product_id) DESC LIMIT 1)
	GROUP BY userid;
	 
-- Most popular item for each customer
SELECT * FROM 
	(SELECT *, RANK() OVER (PARTITION BY userid ORDER BY Total DESC) AS rnk FROM 
		(SELECT userid, product_id, COUNT(product_id) AS Total FROM sales GROUP BY userid, product_id) a)b
	WHERE rnk = 1;
    
-- First item purchased after becoming a member

SELECT * FROM
(SELECT c.*,rank() OVER (PARTITION BY userid ORDER BY created_date) rnk FROM
	(SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date FROM sales a
		INNER JOIN goldusers_signup b ON a.userid = b.userid AND created_date>=gold_signup_date) c) d WHERE rnk = 1;
        
-- Items Purchased before becoming a member
SELECT * FROM
(SELECT c.*,rank() OVER (PARTITION BY userid ORDER BY created_date DESC) rnk FROM
	(SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date FROM sales a
		INNER JOIN goldusers_signup b ON a.userid = b.userid AND created_date<=gold_signup_date) c) d WHERE rnk = 1;
        
-- total amount spent by each customer before becoming a member
SELECT c.*,d.price From 
(SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date FROM sales a
	INNER JOIN goldusers_signup b ON a.userid = b.userid AND created_date<=gold_signup_date)c 
		INNER JOIN product d ON c.product_id = d.product_id;
        
-- Calculating zomato points p1 5rs = 1 point, p2 10rs = 2 point, p3 5rs = 1 point
SELECT a.*, b.price from sales a INNER JOIN product b ON a.product_id = b.product_id;

SELECT userid, SUM(Zomato_points) Total_points FROM 
	(SELECT e.*, ROUND(amount/points) Zomato_points FROM
		(SELECT d.*, CASE WHEN product_id = 1 THEN 5 WHEN product_id = 2 THEN 2 WHEN product_id = 3 THEN 5 else 0 END AS points FROM
			(SELECT c.userid, c.product_id, SUM(price) amount FROM
				(SELECT a.*, b.price from sales a INNER JOIN product b ON a.product_id = b.product_id) c 
				GROUP BY userid, product_id ORDER BY product_id ASC) d) e) f GROUP BY userid;
     

