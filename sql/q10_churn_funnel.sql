-- Q10: Customer activation funnel
-- ===========================================
-- Question: Of all customers acquired in H1 2017, what fraction returned
--           within 30, 60, 90, 180 days? This is a survival/funnel analysis.
-- Techniques: cohort selection, LATERAL JOIN logic via correlated subquery,
--             multi-window comparison.

WITH h1_2017_cohort AS (
    SELECT
        customer_key,
        MIN(order_date_key) AS first_order_date
    FROM dw.fact_orders
    WHERE order_status NOT IN ('canceled', 'unavailable')
    GROUP BY customer_key
    HAVING MIN(order_date_key) BETWEEN DATE '2017-01-01' AND DATE '2017-06-30'
),
followups AS (
    SELECT
        c.customer_key,
        c.first_order_date,
        MIN(fo.order_date_key) AS next_order_date
    FROM h1_2017_cohort c
    LEFT JOIN dw.fact_orders fo
        ON c.customer_key = fo.customer_key
       AND fo.order_date_key > c.first_order_date
    GROUP BY c.customer_key, c.first_order_date
)
SELECT
    COUNT(*) AS cohort_size,
    SUM(CASE WHEN next_order_date IS NOT NULL
             AND next_order_date <= first_order_date + INTERVAL 30 DAY THEN 1 ELSE 0 END) AS returned_30d,
    SUM(CASE WHEN next_order_date IS NOT NULL
             AND next_order_date <= first_order_date + INTERVAL 60 DAY THEN 1 ELSE 0 END) AS returned_60d,
    SUM(CASE WHEN next_order_date IS NOT NULL
             AND next_order_date <= first_order_date + INTERVAL 90 DAY THEN 1 ELSE 0 END) AS returned_90d,
    SUM(CASE WHEN next_order_date IS NOT NULL
             AND next_order_date <= first_order_date + INTERVAL 180 DAY THEN 1 ELSE 0 END) AS returned_180d,
    SUM(CASE WHEN next_order_date IS NOT NULL THEN 1 ELSE 0 END) AS returned_ever,
    100.0 * SUM(CASE WHEN next_order_date IS NOT NULL
                     AND next_order_date <= first_order_date + INTERVAL 30 DAY THEN 1 ELSE 0 END) / COUNT(*) AS pct_30d,
    100.0 * SUM(CASE WHEN next_order_date IS NOT NULL
                     AND next_order_date <= first_order_date + INTERVAL 90 DAY THEN 1 ELSE 0 END) / COUNT(*) AS pct_90d,
    100.0 * SUM(CASE WHEN next_order_date IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) AS pct_ever
FROM followups;
