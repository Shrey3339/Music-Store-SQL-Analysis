--1)What are the total sales and
--the total number of invoices for each customer?
Select
  C.customer_id,
  C.first_name || ' ' || C.last_name as Customer_name,
  Sum(I.total),
  count(distinct I.invoice_id )
from 
  customer as C
join 
  invoice as I
on C.customer_id=I.customer_id
Group by 1,2
Order by 3  desc

--2)Which customer has the highest total purchase amount?
Select
  C.customer_id,
  C.first_name || ' ' || C.last_name as Customer_name,
  Sum(I.total) as MVP_customer
from 
  customer as C
join 
  invoice as I
on C.customer_id=I.customer_id
Group by 1,2
Order by 3  desc
Limit 1

--3)segment customers based on their purchasing behavior 
--(e.g., high spenders, frequent buyers)?
WITH customer_summary AS (
SELECT
 c.customer_id,
 c.first_name,
 c.last_name,
 AVG(i.total) AS avg_spent
FROM Customer c
JOIN Invoice i ON c.customer_id = i.customer_id
GROUP BY 1,2,3
)
SELECT
customer_id,
first_name,
last_name,
avg_spent,
 CASE
        WHEN avg_spent >= (SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY avg_spent) FROM customer_summary) THEN 'High Spender'
        WHEN avg_spent >= (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_spent) FROM customer_summary) THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS spending_segment
FROM
    customer_summary
ORDER BY 4 DESC;

--How does the revenue vary across different customer segments?	
WITH customer_summary AS (
SELECT i.customer_id,
   SUM(il.unit_price * il.quantity) AS total_spent
FROM invoice_line il
INNER JOIN invoice i ON il.invoice_id = i.invoice_id
GROUP BY 1),
customer_segments AS (
SELECT
cs.customer_id,
cs.total_spent,
CASE
WHEN cs.total_spent > (SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY total_spent) FROM customer_summary) THEN 'High Spender'
ELSE 'Regular Spender'
END AS spending_behavior
FROM customer_summary cs
)
SELECT spending_behavior,
SUM(total_spent) AS total_revenue
FROM customer_segments
GROUP BY spending_behavior;


--Product Analysis
--4)Which products are the best-sellers in terms of revenue?
Select 
  T.track_id,
  T.name as product_name,
  Sum(I.unit_price * I.quantity) as Revenue
From track as T
join invoice_line as I
on T.track_id=I.track_id
Group by 1
Order by 3 desc

--5)Are there any products
--that are consistently high-performing or underperforming?
WITH product_sales AS (
SELECT
  t.track_id,
  t.name AS product_name,
  SUM(il.unit_price * il.quantity) AS total_revenue
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY 1,2
),
avg_product_sales AS (
SELECT
  AVG(total_revenue) AS avg_sales
  FROM product_sales
)
SELECT
  ps.product_name,
  ps.total_revenue,
    CASE
        WHEN ps.total_revenue >= aps.avg_sales THEN 'High-performing'
        ELSE 'Underperforming'
    END AS performance_category
FROM
    product_sales ps, avg_product_sales aps
ORDER BY
    ps.total_revenue DESC;
	
--Top-Selling Genres
Select 
  genre.name,
  Sum (invoice_line.quantity)
From genre
join track on genre.genre_id = track.genre_id
join invoice_line on invoice_line.track_id = track.track_id
Group by 1
order by 2 desc 

--Top selling artist 
Select artist.name,
  Sum (invoice_line.quantity)
From artist
Join album on album.artist_id = artist.artist_id
Join track on track.album_id = album.album_id
join invoice_line on invoice_line.track_id = track.track_id
Group by 1
order by 2 desc 

--which is the top selling artisct for each genre
Select artist.name,
   genre.name,
   track.name,
  Sum (invoice_line.quantity)
From artist
Join album on album.artist_id = artist.artist_id
Join track on track.album_id = album.album_id
join genre on genre.genre_id = track.genre_id
join invoice_line on invoice_line.track_id = track.track_id
Group by 1
order by 4 desc 

--Geographical Analysis:
--How does sales revenue vary across different regions or countries?
Select * from customer
select * from inoice

SELECT
billing_country AS country,
SUM(unit_price * quantity) AS total_sales
FROM invoice as I
JOIN invoice_line as Il ON Il.invoice_id = I.invoice_id
GROUP BY 1
ORDER BY 2 desc

--How many customers have made purchases in each country 
SELECT count (distinct I.customer_id)as NO_of_cust,
       C.country
From invoice as I
join customer as C on C.customer_id = I.customer_id
group by 2
order by 1 desc


--Employee analysis
Select * from employee
Select * From customer
-- Query to find the senior-most employee based on job title
SELECT
    employee_id,
    first_name ||' '||last_name as Emploee_name,
	hire_date,
	title
FROM employee
WHERE hire_date = (SELECT MIN(hire_date) FROM employee );

--Each employee attended to how many customer ?
-- Query to find the employee with the highest total number of customers assigned
SELECT COUNT(c.customer_id) AS total_customers,
        c.support_rep_id
From customer as c 
Group by 2
order by 1 desc



