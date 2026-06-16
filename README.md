# Olist SQL Warehouse and Dashboard

A star-schema analytical warehouse over the Olist Brazilian e-commerce dataset (~100K orders, 2016–2018), built in **DuckDB** with a **Streamlit** dashboard layer. Ten analytical SQL queries cover the full surface area of a data-science SQL interview: window functions, CTEs, ranking, cohort logic, conditional aggregation, hierarchical grouping, and date arithmetic.

## What this demonstrates

- **SQL fluency at the level required for product-DS interviews.** Each of the ten queries lives in `sql/qNN_*.sql` with a header comment documenting the business question and the SQL techniques it exercises.
- **Star-schema warehouse design.** Four conformed dimensions (`customer`, `product`, `seller`, `date`) and two facts (`fact_order_items` at line grain, `fact_orders` at order grain), built declaratively from nine raw CSVs via three SQL setup scripts.
- **Self-service analytics layer.** A Streamlit dashboard that surfaces revenue, growth, category performance, and delivery metrics, plus an interactive query inspector that lets viewers explore the underlying SQL alongside its results.

## Headline findings

| Finding | Value |
|---|---|
| Total revenue, 2016–2018 (delivered orders) | R$ 15.4M |
| Total orders | 96,478 |
| Repeat-purchase rate (Olist's known weakness) | ~3.4% across 2017 cohorts |
| Black Friday 2017 monthly revenue lift | +53.6% MoM |
| Top category by 2017 revenue | bed_bath_table |
| Worst-performing state for on-time delivery | Maranhão (MA), Brazilian northeast |

## Repository layout

```
olist-sql-warehouse/
├── data/raw/             # CSVs from Kaggle (gitignored)
├── sql/
│   ├── 01_raw_load.sql       # Load nine CSVs into staging
│   ├── 02_build_dims.sql     # Build customer/product/seller/date dims
│   ├── 03_build_facts.sql    # Build fact_order_items, fact_orders
│   └── q01_…_q10_*.sql       # Ten analytical queries
├── src/
│   ├── db.py             # DuckDB connection helper + query runner
│   └── runner.py         # One-shot warehouse build
├── dashboard/
│   └── app.py            # Streamlit dashboard (4 sections)
├── notebooks/
│   └── 01_warehouse_demo.ipynb   # Per-query demo notebook
├── pyproject.toml
└── README.md
```

## The ten analytical queries

| # | Question | SQL techniques |
|---|---|---|
| 01 | Monthly revenue and MoM growth | `LAG()` window, `DATE_TRUNC`, aggregation |
| 02 | Top categories with YoY change | `FILTER` clause, CTE, conditional aggregation |
| 03 | Delivery performance by state | `CASE` buckets, `HAVING`, percentage calculation |
| 04 | Review-score 30-day rolling average | `ROWS BETWEEN` window |
| 05 | Repeat-customer cohorts | self-join, `MIN()` per customer, date arithmetic |
| 06 | Seller revenue Pareto curve | cumulative `SUM` over window, ranking |
| 07 | Payment-method mix by order size | tiered `CASE`, multi-dimension `GROUP BY` |
| 08 | Top cities by revenue | `RANK() OVER (PARTITION BY …)`, `QUALIFY` |
| 09 | Basket-size distribution | per-order aggregation, distribution histogram |
| 10 | 2017 customer activation funnel (30/60/90/180 days) | cohort selection, correlated subquery, multi-window comparison |

## Data model

```
                    ┌─────────────┐
                    │  dim_date   │
                    └──────┬──────┘
                           │
   ┌──────────────┐    ┌───┴─────────────┐    ┌──────────────┐
   │ dim_customer │────│ fact_order_items│────│ dim_product  │
   └──────────────┘    │  - line_revenue │    └──────────────┘
                       │  - freight      │
                       │  - delivery_days│
                       └────────┬────────┘
                                │
                          ┌─────┴───────┐
                          │ dim_seller  │
                          └─────────────┘
```

`fact_orders` (order-grain) carries payment and review attributes that naturally aggregate at the order level rather than line level.

## Quickstart

```bash
git clone https://github.com/QuantumPouya19/olist-sql-warehouse.git
cd olist-sql-warehouse
python -m venv .venv
.venv\Scripts\activate                  # Windows
# source .venv/bin/activate              # Linux/Mac
pip install -e .
```

Then download the Olist dataset from Kaggle (`kaggle.com/datasets/olistbr/brazilian-ecommerce`) and place the nine CSVs in `data/raw/`. The dataset is ~30 MB compressed.

```bash
python -m src.runner                    # builds warehouse.duckdb (~15 sec)
streamlit run dashboard/app.py          # launches dashboard at localhost:8501
```

## Dashboard sections

1. **Revenue and order volume** — three top-line metrics, monthly revenue line chart, expandable growth-rate table.
2. **Top categories — 2017 → 2018** — horizontal bar chart of the top 10 categories, colored by year-over-year growth.
3. **Delivery performance by state** — stacked bar chart showing % early / on-time / late by state, ordered by lateness.
4. **Query inspector** — dropdown selector that displays any of the ten queries' source SQL and its result table side by side.

## Why DuckDB

DuckDB is an embedded analytical database (think SQLite for analytics) that reads CSVs and Parquet directly, runs columnar SQL at speeds competitive with cloud warehouses, and ships as a single Python package. The entire `warehouse.duckdb` file is ~80 MB; the full ELT runs in 15 seconds; analytical queries return in milliseconds. No server, no Docker, no orchestration — the simplest deployment surface that still produces real engineering signal.

## Limitations

- Olist data ends in late 2018; no recent activity.
- Customer geography is at ZIP-prefix granularity (first 3 digits), not full ZIP.
- Multiple reviews per order are aggregated to one via `MAX(review_score)`.
- The Streamlit dashboard reads from a local DuckDB file; a production setup would proxy through a service-account-authenticated connection.

## License

MIT — see `LICENSE`.

## Acknowledgements

Olist data is available on Kaggle under `olistbr/brazilian-ecommerce`. This project is educational and the analyses should not be cited as business intelligence for the underlying company.