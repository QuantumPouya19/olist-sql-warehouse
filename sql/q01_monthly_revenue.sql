-- Q01: Monthly revenue and order volume
-- ===========================================
-- Question: Month-over-month revenue, order count, and growth rate.
-- Techniques: window functions (LAG), DATE_TRUNC, aggregation.

WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_date_key)::DATE AS month,
        COUNT(DISTINCT order_id)                  AS n_orders,
        SUM(line_revenue)                         AS revenue
    FROM dw.fact_order_items
    WHERE order_status = 'delivered'
    GROUP BY 1
)
SELECT
    month,
    n_orders,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
          / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) AS mom_growth_pct
FROM monthly
ORDER BY month;
