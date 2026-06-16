-- Q03: Delivery performance distribution
-- ===========================================
-- Question: What fraction of orders arrived on time vs late vs early?
--           Broken out by state.
-- Techniques: CASE buckets, GROUP BY, percentage calculation, HAVING.

WITH delivery_buckets AS (
    SELECT
        c.state,
        COUNT(*) AS n_orders,
        SUM(CASE WHEN f.delivery_days_vs_estimate > 0 THEN 1 ELSE 0 END) AS n_early,
        SUM(CASE WHEN f.delivery_days_vs_estimate = 0 THEN 1 ELSE 0 END) AS n_on_time,
        SUM(CASE WHEN f.delivery_days_vs_estimate < 0 THEN 1 ELSE 0 END) AS n_late,
        AVG(f.delivery_days_actual)                                       AS avg_days_to_deliver
    FROM dw.fact_order_items f
    JOIN dw.dim_customer c ON f.customer_key = c.customer_key
    WHERE f.delivery_days_vs_estimate IS NOT NULL
    GROUP BY c.state
)
SELECT
    state,
    n_orders,
    100.0 * n_early   / n_orders AS pct_early,
    100.0 * n_on_time / n_orders AS pct_on_time,
    100.0 * n_late    / n_orders AS pct_late,
    avg_days_to_deliver
FROM delivery_buckets
WHERE n_orders >= 500     -- filter low-volume states
ORDER BY pct_late DESC;
