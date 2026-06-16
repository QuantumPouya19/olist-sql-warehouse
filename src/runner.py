"""One-shot warehouse build: run the three setup SQL files in order."""

from pathlib import Path
import sys

from src.db import connect, execute_sql_file


def build_warehouse() -> None:
    setup_files = ["01_raw_load.sql", "02_build_dims.sql", "03_build_facts.sql"]
    with connect() as con:
        for f in setup_files:
            print(f"Running {f}...")
            execute_sql_file(con, f)
        # Sanity check
        row_counts = con.execute("""
            SELECT 'fact_order_items' AS table_name, COUNT(*) AS n FROM dw.fact_order_items
            UNION ALL SELECT 'fact_orders',           COUNT(*) FROM dw.fact_orders
            UNION ALL SELECT 'dim_customer',          COUNT(*) FROM dw.dim_customer
            UNION ALL SELECT 'dim_product',           COUNT(*) FROM dw.dim_product
            UNION ALL SELECT 'dim_seller',            COUNT(*) FROM dw.dim_seller
            UNION ALL SELECT 'dim_date',              COUNT(*) FROM dw.dim_date
        """).df()
        print(row_counts.to_string(index=False))


if __name__ == "__main__":
    build_warehouse()
