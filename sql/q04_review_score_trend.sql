-- Q04: Review score trend with 30-day rolling average
-- ===========================================
-- Question: How has the daily average review score evolved over time,
--           with a 30-day moving average to smooth out noise?
-- Techniques: ROWS BETWEEN window, AVG over rolling window, date join.

WITH daily_reviews AS (
    SELECT
        order_date_key AS day,
        AVG(review_score) AS avg_score,
        COUNT(*)           AS n_reviews
    FROM dw.fact_orders
    WHERE review_score IS NOT NULL
    GROUP BY order_date_key
)
SELECT
    day,
    n_reviews,
    avg_score,
    AVG(avg_score) OVER (
        ORDER BY day
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS rolling_30d_avg
FROM daily_reviews
ORDER BY day;
