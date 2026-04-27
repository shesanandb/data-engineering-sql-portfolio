-- Project Title: Sales Data Processing & Validation using SQL

-- Objective:
-- Process, validate, and transform transactional sales data to ensure data quality
-- and prepare structured datasets for reporting (ETL-like workflow).

-- Dataset:
-- Table Name: sales
-- Description: Contains transactional sales data including date, product line, quantity sold, revenue, and customer details.

/* =====================================================
   DATA QUALITY CHECKS
   Ensuring dataset consistency before transformation
   ===================================================== */

/* =====================================================
   DATA VALIDATION
   ===================================================== */

-- Check for NULL values in critical columns
SELECT
   SUM(CASE WHEN invoice_id IS NULL THEN 1 ELSE 0 END) AS invoice_nulls,
   SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity_nulls,
   SUM(CASE WHEN total IS NULL THEN 1 ELSE 0 END) AS total_nulls
FROM sales;

-- Check for duplicate records
SELECT invoice_id, COUNT(*) AS cnt
FROM sales
GROUP BY invoice_id
HAVING COUNT(*) > 1;

-- Total row count validation
SELECT COUNT(*) AS total_records
FROM sales;

-- Check for negative or invalid values
SELECT *
FROM sales
WHERE quantity <= 0 OR total <= 0;

/* =====================================================
   FEATURE ENGINEERING
   ===================================================== */

/* Transforming raw dataset into enriched structured dataset */

-- Create an enriched view for analysis
CREATE VIEW enriched_sales AS
SELECT
    invoice_id,
    product_line,
    quantity,
    total,
    branch,
    city,
    date,
    time,
    CASE
        WHEN time BETWEEN '00:00:00' AND '05:59:59' THEN 'Night'
        WHEN time BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
        WHEN time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    DAYNAME(date) AS day_name,
    MONTH(date) AS month_num,
    MONTHNAME(date) AS month_name
FROM sales;

/* =====================================================
   DATA PROCESSING STEP 1
   ===================================================== */

-- What is the most selling product line based on quantity sold?
SELECT
    product_line,
    SUM(quantity) AS total_units_sold
FROM enriched_sales
GROUP BY product_line
ORDER BY total_units_sold DESC;

/* =====================================================
      DATA PROCESSING STEP 2
   ===================================================== */

-- Does the most selling product line (by quantity) also generate the highest revenue?
SELECT
    product_line,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(total), 2) AS total_revenue
FROM enriched_sales
GROUP BY product_line
ORDER BY total_units_sold DESC;

/* =====================================================
   DATA PROCESSING STEP 3
   ===================================================== */

-- What is the total revenue trend by month?
SELECT
    month_name,
    month_num,
    ROUND(SUM(total), 2) AS total_revenue
FROM enriched_sales
GROUP BY month_name, month_num
ORDER BY month_num;

/* =====================================================
   DATA PROCESSING STEP 4
   ===================================================== */

-- What is the Month-over-Month (MoM) revenue growth?
WITH monthly_sales AS (
    SELECT
        month_num,
        month_name,
        ROUND(SUM(total), 2) AS revenue
    FROM enriched_sales
    GROUP BY month_num, month_name
)
SELECT
    month_name,
    revenue,
    LAG(revenue) OVER (ORDER BY month_num) AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month_num)) /
        NULLIF(LAG(revenue) OVER (ORDER BY month_num), 0) * 100,
        2
    ) AS mom_growth_pct
FROM monthly_sales
ORDER BY month_num;

/* =====================================================
   DATA PROCESSING STEP 5
   ===================================================== */

-- Which branches generate revenue higher than the average branch revenue?
WITH branch_revenue AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM enriched_sales
    GROUP BY branch
)
SELECT
    branch,
    revenue
FROM branch_revenue
WHERE revenue > (SELECT AVG(revenue) FROM branch_revenue)
ORDER BY revenue DESC;

/* =====================================================
   DATA PROCESSING STEP 6
   ===================================================== */

-- What is the running total of revenue over time?
SELECT
    date,
    SUM(total) AS daily_revenue,
    SUM(SUM(total)) OVER (ORDER BY date) AS running_total_revenue
FROM enriched_sales
GROUP BY date
ORDER BY date;

/* =====================================================
   DATA PROCESSING STEP 7
   ===================================================== */

-- What is the top-performing product line in each city?
SELECT
    city,
    product_line,
    revenue
FROM (
    SELECT
        city,
        product_line,
        SUM(total) AS revenue,
        RANK() OVER (PARTITION BY city ORDER BY SUM(total) DESC) AS rnk
    FROM enriched_sales
    GROUP BY city, product_line
) t
WHERE rnk = 1;

/* =====================================================
   DATA PROCESSING STEP 8
   ===================================================== */

-- Classify product lines as Good or Bad based on average quantity sold
SELECT
    product_line,
    CASE
        WHEN AVG(quantity) > (SELECT AVG(quantity) FROM enriched_sales)
        THEN 'Good'
        ELSE 'Bad'
    END AS performance_category
FROM enriched_sales
GROUP BY product_line;

/* =====================================================
   FINAL OUTPUT
   Data is validated, transformed, and ready for reporting
   ===================================================== */
