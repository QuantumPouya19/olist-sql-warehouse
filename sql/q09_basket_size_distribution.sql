-- Q09: Order basket size distribution and revenue contribution
-- ===========================================
-- Question: How does revenue distribute across basket sizes?
--           Do multi-item orders contribute disproportionately?
-- Techniques: COUNT per order, distribution histogram, revenue weighting.

WITH baskets AS (
    SELECT
        order_id,
        COUNT(*)        AS items_in_order,
        SUM(line_revenue) AS order_revenue
    FROM dw.fact_order_items
    WHERE order_status = 'delivered'
    GROUP BY order_id
),
bucketed AS (
    SELECT
        CASE
            WHEN items_in_order = 1 THEN '1 item'
            WHEN items_in_order = 2 THEN '2 items'
            WHEN items_in_order = 3 THEN '3 items'
            WHEN items_in_order BETWEEN 4 AND 5 THEN '4-5 items'
            ELSE '6+ items'
        END AS basket_bucket,
        items_in_order,
        order_revenue
    FROM baskets
)
SELECT
    basket_bucket,
    COUNT(*)                                       AS n_orders,
    100.0 * COUNT(*)        / SUM(COUNT(*))   OVER ()  AS pct_orders,
    SUM(order_revenue)                             AS total_revenue,
    100.0 * SUM(order_revenue) / SUM(SUM(order_revenue)) OVER () AS pct_revenue,
    AVG(order_revenue)                             AS avg_order_value
FROM bucketed
GROUP BY basket_bucket
ORDER BY basket_bucket;
