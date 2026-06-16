-- Q02: Top product categories with year-over-year change
-- ===========================================
-- Question: Top 15 product categories by 2017 revenue, with their 2018 growth.
--           Excludes categories with under 100 orders to filter noise.
-- Techniques: PIVOT-like filtering with FILTER clause, CTE, ratio comparison.

WITH category_year AS (
    SELECT
        p.category,
        EXTRACT(YEAR FROM f.order_date_key)::INT AS year,
        SUM(f.line_revenue) AS revenue,
        COUNT(DISTINCT f.order_id) AS n_orders
    FROM dw.fact_order_items f
    JOIN dw.dim_product p ON f.product_key = p.product_key
    WHERE f.order_status = 'delivered'
      AND EXTRACT(YEAR FROM f.order_date_key) IN (2017, 2018)
    GROUP BY p.category, EXTRACT(YEAR FROM f.order_date_key)
),
pivoted AS (
    SELECT
        category,
        SUM(revenue) FILTER (WHERE year = 2017) AS revenue_2017,
        SUM(revenue) FILTER (WHERE year = 2018) AS revenue_2018,
        SUM(n_orders) FILTER (WHERE year = 2017) AS orders_2017
    FROM category_year
    GROUP BY category
)
SELECT
    category,
    revenue_2017,
    revenue_2018,
    100.0 * (revenue_2018 - revenue_2017) / NULLIF(revenue_2017, 0) AS yoy_growth_pct
FROM pivoted
WHERE orders_2017 >= 100
ORDER BY revenue_2017 DESC
LIMIT 15;
