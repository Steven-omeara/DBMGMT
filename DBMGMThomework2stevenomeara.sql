-- 1)Get the cities of agents booking an order for customer c002.
SELECT agents.city
FROM public.agents
WHERE agents.aid in 
  (SELECT distinct aid
   FROM public.orders
   WHERE cid = 'c0002');
   
   
-- 2)Get the pids of products ordered through any agent	who makes at least one	order for a customer in	Kyoto.(This is not the same as asking for pids of products ordered by a customer in Kyoto.)
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
);

-- 3)Find the cids and names of customers who never placed an order through agent a03
SELECT distinct cid, name
FROM customers
WHERE cid NOT IN
      (SELECT distinct cid
       FROM public.orders
       WHERE orders.aid = 'a03')
       
-- 4)Get the cids and names of customers who ordered both product p01 and p07
SELECT distinct cid, name
FROM customers
WHERE cid in
(
SELECT distinct cid
FROM public.orders
WHERE orders.pid = 'p07' AND orders.cid in
	(
	SELECT distinct cid
	FROM public.orders
	WHERE orders.pid = 'p01'
	)
);
  
--- 5)Get the pids of products ordered by any customers	who ever placed an order through agent a03.
SELECT distinct orders.pid
FROM public.orders
WHERE cid in 
    (SELECT distinct cid
    FROM public.orders
    WHERE aid = 'a03');
    
-- 6)Get the names and discounts of all customers who place orders through agents in Dallas or	Duluth.
SELECT distinct name, discount
FROM customers
WHERE cid in 
(
SELECT distinct cid
  FROM orders
  WHERE aid in
  (
  SELECT distinct aid
  FROM agents
  WHERE agents.city = 'Dallas'
  OR
  agents.city = 'Duluth'
  )
);

-- 7)Find all customers who have the same discount as that of any customers in Dallas or Kyoto.
SELECT name
FROM customers
WHERE discount in 
		(
		SELECT distinct discount
		FROM customers
		WHERE city = 'Dallas' OR city = 'Kyoto'
		)
		 	
		AND
		
		customers.city in
		(
		SELECT distinct city
		FROM customers
		WHERE city != 'Dallas' AND city != 'Kyoto');
