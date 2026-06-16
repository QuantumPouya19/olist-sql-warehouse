-- Stage 1: load raw CSVs as-is into staging tables.
-- DuckDB infers types automatically. We rename to consistent snake_case
-- and prefix all staging tables with `stg_`.

DROP SCHEMA IF EXISTS raw CASCADE;
CREATE SCHEMA raw;

CREATE TABLE raw.stg_orders AS
SELECT * FROM read_csv_auto('data/raw/olist_orders_dataset.csv');

CREATE TABLE raw.stg_order_items AS
SELECT * FROM read_csv_auto('data/raw/olist_order_items_dataset.csv');

CREATE TABLE raw.stg_order_payments AS
SELECT * FROM read_csv_auto('data/raw/olist_order_payments_dataset.csv');

CREATE TABLE raw.stg_order_reviews AS
SELECT * FROM read_csv_auto('data/raw/olist_order_reviews_dataset.csv');

CREATE TABLE raw.stg_products AS
SELECT * FROM read_csv_auto('data/raw/olist_products_dataset.csv');

CREATE TABLE raw.stg_sellers AS
SELECT * FROM read_csv_auto('data/raw/olist_sellers_dataset.csv');

CREATE TABLE raw.stg_customers AS
SELECT * FROM read_csv_auto('data/raw/olist_customers_dataset.csv');

CREATE TABLE raw.stg_geolocation AS
SELECT * FROM read_csv_auto('data/raw/olist_geolocation_dataset.csv');

CREATE TABLE raw.stg_category_translation AS
SELECT * FROM read_csv_auto('data/raw/product_category_name_translation.csv');
