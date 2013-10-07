--1. Get the cities of agents booking an order for customer c0002. Use a subquery.
SELECT agents.city
FROM public.agents
WHERE agents.aid in
          (
          SELECT distinct aid
          FROM public.orders
          WHERE orders.cid = 'c002'
          );
          
--2.Get the cities of agents booking an order from customer c002. This time with joins.
SELECT agents.city
FROM public.agents
INNER JOIN orders
ON agents.aid = orders.aid
WHERE orders.cid = 'c002';

--3. Get the pids of products ordered through any agent who makes at least one order for a cust in Kyoto.
SELECT distinct orders.pid
FROM orders
WHERE aid in
        (
        SELECT distinct aid
        FROM agents
        WHERE aid in
                (
                SELECT distinct aid
                FROM orders
                WHERE cid in
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
from orders a full outer join orders b on a.aid=b.aid, customers c
where c.cid = a.cid and c.city = 'Kyoto'
order by b.pid

--5. Get the names of the customers who have never placed an order. Use a subquery
SELECT c.name
FROM customers c
WHERE cid not in 
        (
        SELECT distinct cid
        FROM orders o
        WHERE c.cid = o.cid
        );
        
--6. Get the names of customers who have never placed an order. Use an outer join.
SELECT customers.name
FROM customers 
FULL OUTER JOIN orders
ON customers.cid = orders.cid
WHERE orders.cid is null;

--7. Get the names of customers who placed at least one order through an agent in their city, along with those agent(s) names.
SELECT distinct c.name, a.name
FROM customers c, agents a, orders o
WHERE c.cid = o.cid
AND 
a.aid = o.aid
AND
c.city = a.city;

                
--8.Get the names of customers and agents in the same city, along with the name of the city, regardless of whether or not the cust has ever placed an order with that agents.
SELECT distinct customers.name, agents.name, customers.city
FROM customers , agents, orders
WHERE customers.city = agents.city;

--9. Get the name and city of customers who live in a city where the least number of products are made.
DROP VIEW IF EXISTS leastproducts;
CREATE VIEW leastproducts AS
	(
	SELECT products.city, count(city) as Num
	FROM products
	group by products.city
	)
;

SELECT c.name, c.city
FROM customers c
WHERE c.city in
	(
	SELECT products.city
	FROM products
	Group by products.city
	HAVING count(city) in 
		(
		SELECT MIN(num) from leastproducts
		)
	)
;

--10. Get the name and city of customers who live in any city where the most number of products are made.
DROP VIEW IF EXISTS leastproducts;
CREATE VIEW leastproducts AS
	(
	SELECT products.city, count(city) as Num
	FROM products
	group by products.city
	)
;

SELECT c.name, c.city
FROM customers c
WHERE c.city in
	(
	SELECT products.city
	FROM products
	Group by products.city
	HAVING count(city) in 
		(
		SELECT MAX(num) from leastproducts
		)
	)
;

--11. Get the name and city of customers who live in any city where the most number of products are made.
DROP VIEW IF EXISTS leastproducts;
CREATE VIEW leastproducts AS
	(
	SELECT products.city, count(city) as Num
	FROM products
	group by products.city
	)
;

SELECT c.name, c.city
FROM customers c
WHERE c.city in
	(
	SELECT products.city
	FROM products
	Group by products.city
	HAVING count(city) in (SELECT MAX(num) from leastproducts)
	LIMIT 1
	)
;

--12.List the products whose priceUSD is above the average priceUSD.
SELECT products.name
FROM products
WHERE products.priceUSD >
	(
	SELECT avg(priceUSD) as averageprice
	FROM products
	)
	
--13.Show the customer name, pid ordered, and the dollars for all customer orders, sorted by dollars from high to low
SELECT customers.name, orders.pid, orders.dollars
FROM orders, customers
WHERE orders.cid = customers.cid
Order BY dollars Desc