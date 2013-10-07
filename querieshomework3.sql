--1. Get the cities of agents booking an order for customer c002. Use a subquery.
SELECT agents.city
FROM public.agents
WHERE agents.aid in --connects orders and agents
          (
          SELECT distinct aid
          FROM public.orders
          WHERE orders.cid = 'c002' --makes sure the customer id is c002
          );
          
--2.Get the cities of agents booking an order from customer c002. This time with joins.
SELECT agents.city
FROM public.agents
INNER JOIN orders --joins orders and agents
ON agents.aid = orders.aid --joins on the aids
WHERE orders.cid = 'c002'; --looks for specific cust

--3. Get the pids of products ordered through any agent who makes at least one order for a cust in Kyoto.
SELECT distinct orders.pid
FROM orders
WHERE aid in --linking orders to agents
        (
        SELECT distinct aid
        FROM agents
        WHERE aid in -- linking agents back to orders
                (
                SELECT distinct aid
                FROM orders
                WHERE cid in --linking agents to customers as to allow the comparison between the customers and agents
                      (
                      SELECT distinct cid
                      FROM customers
                      WHERE customers.city = 'Kyoto'
                      )
               )
        )
;

--4.Get the pids of products ordered through any agents who makes at least one order for a cust in kyoto. Use joins this time
select distinct b.pid
from orders a full outer join orders b on a.aid=b.aid, customers c --joined orders to orders as Alan stated in lab
where c.cid = a.cid and c.city = 'Kyoto'
order by b.pid

--5. Get the names of the customers who have never placed an order. Use a subquery
SELECT c.name
FROM customers c
WHERE cid not in --not in allows everything that is not in the subquery below
        (
        SELECT distinct cid
        FROM orders o
        WHERE c.cid = o.cid
        )
;
        
--6. Get the names of customers who have never placed an order. Use an outer join.
SELECT customers.name
FROM customers 
FULL OUTER JOIN orders --Joins all possible values of orders and custs
ON customers.cid = orders.cid --where an id is shared
WHERE orders.cid is null; --if the cust never placed an order, this space will be null so looking for the null value will return the right answer

--7. Get the names of customers who placed at least one order through an agent in their city, along with those agent(s) names.
SELECT distinct c.name, a.name
FROM customers c, agents a, orders o
WHERE c.cid = o.cid --join customers and orders
AND 
a.aid = o.aid --join agents and orders. These allow to see if the cust had an order with the agent
AND
c.city = a.city; --sees if they share cities

                
--8.Get the names of customers and agents in the same city, along with the name of the city, regardless of whether or not the cust has ever placed an order with that agents.
SELECT distinct customers.name, agents.name, customers.city
FROM customers , agents, orders
WHERE customers.city = agents.city; --just looks to see if the customer and agents share a city

--9. Get the name and city of customers who live in a city where the least number of products are made.
DROP VIEW IF EXISTS leastproducts;--recreate the view table each time, allows it to run the create view each time
CREATE VIEW leastproducts AS
	(
	SELECT products.city, count(city) as Num --the count is an aggregate function to count the number of time a city is used in the table. Also renames column to num and allows it to be called as num later on in Query
	FROM products
	group by products.city --to allow the city to be seen, must group by the city.
	)
;
--connects cust city to product city to get the answer
SELECT c.name, c.city
FROM customers c
WHERE c.city in
	(
	--This subquery is used to get the name of the least used city by comparing it to the products table
	SELECT products.city 
	FROM products
	Group by products.city
	HAVING count(city) in 
		(
		SELECT MIN(num) from leastproducts --returns the numerical value of the lowest number of city use. Also calls the num as renamed earlier
		)
	)
;

--10. Get the name and city of customers who live in any city where the most number of products are made.
DROP VIEW IF EXISTS leastproducts;--allows the view table to recreate each time it is run
CREATE VIEW leastproducts AS
	(
	SELECT products.city, count(city) as Num --the count is an aggregate function to count the number of time a city is used in the table. Also renames column to num and allows it to be called as num later on in Query
	FROM products
	group by products.city --to allow the city to be seen, must group by the city.
	)
;
--connects cust city to product city to get the answer
SELECT c.name, c.city
FROM customers c
WHERE c.city in
	(
	--This subquery is used to get the name of the least used city by comparing it to the products table
	SELECT products.city
	FROM products
	Group by products.city
	HAVING count(city) in 
		(
		SELECT MAX(num) from leastproducts --returns the numerical value of the max number of cities used. Also calls the num as renamed earlier
		)
	)
;

--11. Get the name and city of customers who live in any city where the most number of products are made.
DROP VIEW IF EXISTS leastproducts;--allows the view table to recreate each time it is run
CREATE VIEW leastproducts AS
	(
	SELECT products.city, count(city) as Num --the count is an aggregate function to count the number of time a city is used in the table. Also renames column to num and allows it to be called as num later on in Query
	FROM products
	group by products.city--to allow the city to be seen, must group by the city.
	)
;
--connects cust city to product city to get the answer
SELECT c.name, c.city
FROM customers c
WHERE c.city in
	(
	--This subquery is used to get the name of the least used city by comparing it to the products table
	SELECT products.city
	FROM products
	Group by products.city
	HAVING count(city) in (SELECT MAX(num) from leastproducts)  --returns the numerical value of the max number of cities used. Also calls the num as renamed earlier
	LIMIT 1 --this allows only on value to be returned from the above Aggregate function
	)
;

--12.List the products whose priceUSD is above the average priceUSD.
SELECT products.name
FROM products
WHERE products.priceUSD > --compares to see if the price is above the average price
	(
	--Returns the average of the the price
	SELECT avg(priceUSD) as averageprice
	FROM products
	)
	
--13.Show the customer name, pid ordered, and the dollars for all customer orders, sorted by dollars from high to low
SELECT customers.name, orders.pid, orders.dollars
FROM orders, customers
WHERE orders.cid = customers.cid
Order BY dollars Desc --orders by dollars from high to low

--14.Show all customer names(in order) and their total ordered, and nothing more. Use coalesce to avoid showing NULLs.
SELECT c.name, COALESCE (   SUM(dollars) , 0  )as Total --gets the sum of all orders in the orders table and makes sure all null values appear as 0.
FROM customers c
FULL OUTER JOIN orders o
on c.cid = o.cid
group by c.cid
order by total desc --sorts dollars from high to low

--15.Show the names of all customers who bought from agents based in New york along with the names of the product they ordered, and the names of the agents who sold it to them
SELECT c.name, p.name, a.name
FROM customers c, orders o, agents a, products p
WHERE c.cid = o.cid --joins customers and orders
AND
o.pid = p.pid --joins orders and products
AND
o.aid = a.aid --joins agents and orders
AND 
a.city = 'New York' --for all places where the agents city is NY
;

--16.Write a query to check the accuracy of the dollars column in the Orders table, This means calculating Orders.dollars from other data in other tables and then comparing those values in Orders.dollars.
DROP VIEW IF EXISTS accuracy;--allows the view table to recreate each time it is run
CREATE VIEW accuracy AS
  (
  SELECT o.ordno, (p.priceUSD * o.qty ) - ((p.priceUSD * o.qty )* (c.discount / 100)) as ACC --returns the actual value of the orders
  FROM orders o, products p, customers c
  WHERE o.cid = c.cid --joins orders and customers
  AND 
  o.pid = p.pid--joins orders and products
  group by o.ordno, ACC --necessary to allow query to run
  ORDER BY o.ordno asc --sorts in accending order
  )
;

SELECT o.ordno, o.dollars, a.ACC
FROM accuracy a, orders o --calls the table created above, accuracy as a
WHERE o.ordno = a.ordno --makes sure that the order numbers of both values match
;

--17.Create an error in the dollars column of the Orders table so that you can verify your accuracy checking query
--Updates the database to make orderno 1011 incorrect
UPDATE orders
SET dollars = '300'
WHERE ordno = '1011'
;

DROP VIEW IF EXISTS accuracy;--allows the view table to recreate each time it is run
CREATE VIEW accuracy AS
  (
  SELECT o.ordno, (p.priceUSD * o.qty ) - ((p.priceUSD * o.qty )* (c.discount / 100)) as ACC --returns the actual value of the orders
  FROM orders o, products p, customers c
  WHERE o.cid = c.cid --joins orders and customers
  AND 
  o.pid = p.pid--joins orders and products
  group by o.ordno, ACC --necessary to allow query to run
  ORDER BY o.ordno asc --sorts in accending order
  )
;

SELECT o.ordno, o.dollars, a.ACC
FROM accuracy a, orders o --calls the table created above, accuracy as a
WHERE o.ordno = a.ordno --makes sure that the order numbers of both values match
AND
a.ACC != o.dollars --compares the view table to the order table to see if there are any discrepencies and returns the value
;