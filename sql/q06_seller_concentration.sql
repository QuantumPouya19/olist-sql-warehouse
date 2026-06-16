-- Q06: Pareto curve of seller revenue concentration
-- ===========================================
-- Question: What fraction of revenue do the top-N sellers account for?
--           Does the 80/20 rule hold?
-- Techniques: ranking, cumulative sum, percent_rank, window with ORDER BY.

WITH seller_revenue AS (
    SELECT
        seller_key,
        SUM(line_revenue) AS revenue
    FROM dw.fact_order_items
    GROUP BY seller_key
),
ranked AS (
    SELECT
        seller_key,
        revenue,
        ROW_NUMBER() OVER (ORDER BY revenue DESC)                  AS rank,
        SUM(revenue) OVER (ORDER BY revenue DESC)                  AS cumulative_revenue,
        SUM(revenue) OVER ()                                       AS total_revenue,
        COUNT(*) OVER ()                                           AS total_sellers
    FROM seller_revenue
)
SELECT
    rank,
    100.0 * rank / total_sellers       AS pct_sellers,
    revenue                            AS seller_revenue,
    100.0 * cumulative_revenue / total_revenue AS pct_cumulative_revenue
FROM ranked
WHERE rank IN (1, 5, 10, 25, 50, 100, 250, 500, 1000, 2000, 3095)
   OR rank % 100 = 0
ORDER BY rank;
