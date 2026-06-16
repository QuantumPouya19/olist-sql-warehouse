DROP SCHEMA IF EXISTS dw CASCADE;
CREATE SCHEMA dw;

-- Customer dimension. The Olist dataset distinguishes customer_id (per-order)
-- from customer_unique_id (the actual person across multiple orders).
-- We use customer_unique_id as the surrogate key for true customer-level analysis.
CREATE TABLE dw.dim_customer AS
SELECT
    customer_unique_id            AS customer_key,
    MIN(customer_city)            AS city,
    MIN(customer_state)           AS state,
    MIN(customer_zip_code_prefix) AS zip_prefix,
    COUNT(DISTINCT customer_id)   AS n_order_ids
FROM raw.stg_customers
GROUP BY customer_unique_id;

-- Product dimension, joined with English category translation.
CREATE TABLE dw.dim_product AS
SELECT
    p.product_id              AS product_key,
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    p.product_weight_g        AS weight_g,
    p.product_length_cm       AS length_cm,
    p.product_height_cm       AS height_cm,
    p.product_width_cm        AS width_cm,
    p.product_photos_qty      AS photos_qty
FROM raw.stg_products p
LEFT JOIN raw.stg_category_translation t
    ON p.product_category_name = t.product_category_name;

-- Seller dimension.
CREATE TABLE dw.dim_seller AS
SELECT
    seller_id            AS seller_key,
    seller_city          AS city,
    seller_state         AS state,
    seller_zip_code_prefix AS zip_prefix
FROM raw.stg_sellers;

-- Date dimension. We synthesize one from the orders table's date range.
CREATE TABLE dw.dim_date AS
WITH date_range AS (
    SELECT MIN(CAST(order_purchase_timestamp AS DATE)) AS min_d,
           MAX(CAST(order_purchase_timestamp AS DATE)) AS max_d
    FROM raw.stg_orders
),
days AS (
    SELECT min_d + INTERVAL (gs) DAY AS d
    FROM date_range,
         generate_series(0, CAST(max_d - min_d AS INTEGER)) AS t(gs)
)
SELECT
    d                          AS date_key,
    EXTRACT(YEAR FROM d)       AS year,
    EXTRACT(MONTH FROM d)      AS month,
    EXTRACT(DAY FROM d)        AS day,
    EXTRACT(DOW FROM d)        AS dow,
    DATE_TRUNC('month', d)::DATE AS month_start,
    DATE_TRUNC('quarter', d)::DATE AS quarter_start
FROM days;
