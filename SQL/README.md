# Sales Data Processing & Validation using SQL

## 📌 Project Overview
This project focuses on processing and validating transactional sales data using SQL.

The workflow simulates ETL-like operations:
- Extract: Raw transactional data from the sales table
- Transform: Feature engineering and data enrichment using SQL views
- Validate: Data quality checks including NULL validation and consistency verification

The objective is to ensure data accuracy and prepare structured datasets for reliable business reporting.

---

## 🗂 Dataset Information
Table Name: sales

Transaction-level dataset containing:
- Invoice ID
- Product line
- Quantity and revenue
- Branch and city
- Date and time attributes

Used for data validation, transformation, and reporting.

---

## 🛠 Key Work Performed
- Performed data validation using NULL checks on critical columns (invoice_id, quantity, revenue)
- Transformed raw data using SQL views and derived columns
- Created structured dataset with time-based and date-based features
- Applied aggregations to compute revenue and performance metrics
- Used CTEs and subqueries for structured data processing
- Implemented window functions for trend and growth calculations
- Ensured data consistency and reliability for downstream reporting

---

## Data Processing & Validation Steps
1. Data Validation:
   - Checked NULL values in key columns
   - Verified dataset completeness and consistency

2. Data Transformation:
   - Created derived columns (time_of_day, month, day_name)
   - Built enriched dataset using SQL views

3. Data Aggregation:
   - Calculated revenue and quantity metrics
   - Grouped data by product, branch, and time dimensions

4. Data Processing for Reporting:
   - Computed Month-over-Month growth using window functions
   - Generated running totals and rankings
   - Identified anomalies and performance variations


---

## 📁 Files Included
- `sales-analysis.sql` — Complete SQL analysis with queries and business logic
- `README.md` — Project documentation
---
