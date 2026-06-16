-- Fact table: one row per item per order. Joinable to every dimension.
CREATE TABLE dw.fact_order_items AS
SELECT
    oi.order_id                                        AS order_id,
    oi.order_item_id                                   AS line_number,
    o.customer_id                                      AS customer_id_per_order,
    c.customer_unique_id                               AS customer_key,
    oi.product_id                                      AS product_key,
    oi.seller_id                                       AS seller_key,
    CAST(o.order_purchase_timestamp AS DATE)           AS order_date_key,
    CAST(o.order_delivered_customer_date AS DATE)      AS delivered_date_key,
    CAST(o.order_estimated_delivery_date AS DATE)      AS estimated_delivery_date_key,
    o.order_status                                     AS order_status,
    oi.price                                           AS item_price,
    oi.freight_value                                   AS freight_value,
    oi.price + oi.freight_value                        AS line_revenue,
    -- Delivery performance in days. Negative means late.
    CASE WHEN o.order_delivered_customer_date IS NOT NULL
         THEN CAST(o.order_estimated_delivery_date AS DATE) - CAST(o.order_delivered_customer_date AS DATE)
         ELSE NULL
    END                                                AS delivery_days_vs_estimate,
    CASE WHEN o.order_delivered_customer_date IS NOT NULL
         THEN CAST(o.order_delivered_customer_date AS DATE) - CAST(o.order_purchase_timestamp AS DATE)
         ELSE NULL
    END                                                AS delivery_days_actual
FROM raw.stg_order_items oi
JOIN raw.stg_orders o ON oi.order_id = o.order_id
JOIN raw.stg_customers c ON o.customer_id = c.customer_id;

-- A second fact for order-level metrics (payments, reviews are at order grain, not line grain).
CREATE TABLE dw.fact_orders AS
SELECT
    o.order_id                                          AS order_id,
    c.customer_unique_id                                AS customer_key,
    CAST(o.order_purchase_timestamp AS DATE)            AS order_date_key,
    o.order_status                                      AS order_status,
    SUM(p.payment_value)                                AS order_total,
    MAX(r.review_score)                                 AS review_score,
    -- Most common payment method per order (orders can have multiple)
    MODE(p.payment_type)                                AS payment_type
FROM raw.stg_orders o
JOIN raw.stg_customers c ON o.customer_id = c.customer_id
LEFT JOIN raw.stg_order_payments p ON o.order_id = p.order_id
LEFT JOIN raw.stg_order_reviews r ON o.order_id = r.order_id
GROUP BY o.order_id, c.customer_unique_id, o.order_purchase_timestamp, o.order_status;
