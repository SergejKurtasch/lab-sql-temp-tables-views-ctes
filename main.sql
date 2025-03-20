-- Creating a Customer Summary Report

-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
CREATE VIEW rental_info AS
select 
	customer_id
    ,first_name
    ,last_name
    ,email
    ,count(r.rental_id) as rental_count
from customer c
join rental r
using (customer_id)
group by (customer_id);

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE customer_rental_sum
select 
	ri.customer_id
    , sum(p.amount) as total_amount
from payment p
join rental_info ri
using (customer_id)
group by customer_id;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.

WITH customer_summary_cte AS (
    SELECT 
        ri.first_name,
        ri.last_name,
        ri.email,
        ri.rental_count,
        crs.total_amount
    FROM rental_info ri
    JOIN customer_rental_sum crs
    USING (customer_id)
)
SELECT *
FROM customer_summary_cte;

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH customer_summary_cte AS (
    SELECT 
        ri.first_name,
        ri.last_name,
        ri.email,
        ri.rental_count,
        crs.total_amount
    FROM rental_info ri
    JOIN customer_rental_sum crs
    USING (customer_id)
)
SELECT * , round(total_amount / rental_count, 2) as average_payment_per_rental
FROM customer_summary_cte;
