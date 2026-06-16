-- Q05: Repeat-purchase rate by acquisition cohort
-- ===========================================
-- Question: For customers acquired in each month of 2017, what fraction
--           made a repeat purchase within 90 days, 180 days, ever?
-- Techniques: self-join logic, MIN() per customer, conditional aggregation,
--             date arithmetic.

WITH first_purchase AS (
    SELECT
        customer_key,
        MIN(order_date_key)                     AS first_order_date,
        DATE_TRUNC('month', MIN(order_date_key))::DATE AS cohort_month
    FROM dw.fact_orders
    WHERE order_status NOT IN ('canceled', 'unavailable')
    GROUP BY customer_key
),
repeat_purchases AS (
    SELECT
        fp.cohort_month,
        fp.customer_key,
        MIN(CASE WHEN fo.order_date_key > fp.first_order_date THEN fo.order_date_key END) AS second_purchase_date
    FROM first_purchase fp
    JOIN dw.fact_orders fo ON fp.customer_key = fo.customer_key
    WHERE fp.cohort_month BETWEEN DATE '2017-01-01' AND DATE '2017-12-01'
    GROUP BY fp.cohort_month, fp.customer_key, fp.first_order_date
)
SELECT
    cohort_month,
    COUNT(*) AS cohort_size,
    SUM(CASE WHEN second_purchase_date IS NOT NULL
             AND second_purchase_date <= cohort_month + INTERVAL 90 DAY
             THEN 1 ELSE 0 END)                                     AS repeat_in_90d,
    SUM(CASE WHEN second_purchase_date IS NOT NULL
             AND second_purchase_date <= cohort_month + INTERVAL 180 DAY
             THEN 1 ELSE 0 END)                                     AS repeat_in_180d,
    SUM(CASE WHEN second_purchase_date IS NOT NULL THEN 1 ELSE 0 END) AS repeat_ever,
    100.0 * SUM(CASE WHEN second_purchase_date IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) AS pct_repeat_ever
FROM repeat_purchases
GROUP BY cohort_month
ORDER BY cohort_month;