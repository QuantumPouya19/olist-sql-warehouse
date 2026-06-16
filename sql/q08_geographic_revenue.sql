-- Q08: Top cities by revenue, with state-level ranking
-- ===========================================
-- Question: Which cities lead in revenue, and how do they rank within their state?
-- Techniques: GROUP BY two levels, RANK() PARTITION BY, HAVING.

WITH city_revenue AS (
    SELECT
        c.state,
        c.city,
        COUNT(DISTINCT f.order_id) AS n_orders,
        SUM(f.line_revenue)        AS revenue
    FROM dw.fact_order_items f
    JOIN dw.dim_customer c ON f.customer_key = c.customer_key
    WHERE f.order_status = 'delivered'
    GROUP BY c.state, c.city
    HAVING COUNT(DISTINCT f.order_id) >= 50      -- filter noise
)
SELECT
    state,
    city,
    n_orders,
    revenue,
    RANK() OVER (PARTITION BY state ORDER BY revenue DESC) AS rank_in_state,
    RANK() OVER (ORDER BY revenue DESC)                     AS rank_overall
FROM city_revenue
QUALIFY rank_overall <= 50
ORDER BY rank_overall;
