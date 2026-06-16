-- Q07: Payment method breakdown by order value tier
-- ===========================================
-- Question: How does payment method preference vary by order size?
--           Do larger orders skew more toward installment-style payments?
-- Techniques: NTILE for tiering, GROUP BY two dimensions, conditional counts.

WITH tiered AS (
    SELECT
        order_id,
        payment_type,
        order_total,
        CASE
            WHEN order_total < 50  THEN '01_under_50'
            WHEN order_total < 100 THEN '02_50_to_100'
            WHEN order_total < 250 THEN '03_100_to_250'
            WHEN order_total < 500 THEN '04_250_to_500'
            ELSE                        '05_500_plus'
        END AS order_size_tier
    FROM dw.fact_orders
    WHERE payment_type IS NOT NULL
      AND order_status = 'delivered'
)
SELECT
    order_size_tier,
    COUNT(*)                                                            AS n_orders,
    SUM(CASE WHEN payment_type = 'credit_card' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS pct_credit_card,
    SUM(CASE WHEN payment_type = 'boleto'      THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS pct_boleto,
    SUM(CASE WHEN payment_type = 'voucher'     THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS pct_voucher,
    SUM(CASE WHEN payment_type = 'debit_card'  THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS pct_debit_card,
    AVG(order_total)                                                    AS avg_order_value
FROM tiered
GROUP BY order_size_tier
ORDER BY order_size_tier;
