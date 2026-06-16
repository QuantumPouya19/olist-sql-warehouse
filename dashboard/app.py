"""Olist warehouse dashboard. Run with: streamlit run dashboard/app.py"""

from pathlib import Path
import sys

import pandas as pd
import plotly.express as px
import streamlit as st

# Make src importable when running from project root
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from src.db import query  # noqa: E402

st.set_page_config(page_title="Olist Warehouse", layout="wide")
st.title("Olist E-Commerce — Warehouse Dashboard")
st.caption(
    "Built on Brazilian e-commerce data (2016–2018). All numbers derived from "
    "a DuckDB star-schema warehouse; see `sql/` for the underlying queries."
)

# -- Section 1: Revenue trend ------------------------------------------------
st.header("1. Revenue and order volume")

monthly = query("q01_monthly_revenue.sql")
col1, col2, col3 = st.columns(3)
col1.metric("Total revenue", f"R$ {monthly['revenue'].sum():,.0f}")
col2.metric("Total orders", f"{monthly['n_orders'].sum():,}")
col3.metric("Months covered", len(monthly))

fig = px.line(
    monthly, x="month", y="revenue",
    title="Monthly revenue (delivered orders)",
)
st.plotly_chart(fig, use_container_width=True)

with st.expander("Growth-rate table"):
    st.dataframe(
        monthly.assign(mom_growth_pct=monthly["mom_growth_pct"].round(1)),
        use_container_width=True,
    )

# -- Section 2: Top categories ----------------------------------------------
st.header("2. Top categories — 2017 → 2018")
cats = query("q02_top_categories.sql")
fig = px.bar(
    cats.head(10),
    x="revenue_2017", y="category",
    orientation="h",
    color="yoy_growth_pct",
    color_continuous_scale="RdYlGn",
    color_continuous_midpoint=0,
    title="Top 10 categories: 2017 revenue, colored by 2018 YoY growth",
)
fig.update_layout(yaxis={"categoryorder": "total ascending"})
st.plotly_chart(fig, use_container_width=True)

# -- Section 3: Delivery performance ----------------------------------------
st.header("3. Delivery performance by state")
delivery = query("q03_delivery_performance.sql")
fig = px.bar(
    delivery.head(15),
    x="state", y=["pct_early", "pct_on_time", "pct_late"],
    title="Delivery outcomes by state (top 15 by lateness)",
    barmode="stack",
    color_discrete_map={"pct_early": "#2ecc71", "pct_on_time": "#3498db", "pct_late": "#e74c3c"},
)
st.plotly_chart(fig, use_container_width=True)

# -- Section 4: Sample query inspector --------------------------------------
st.header("4. Query inspector")
st.caption("Pick any of the ten analytical queries to view its result.")

sql_files = sorted(Path("sql").glob("q*.sql"))
choice = st.selectbox("Query", [p.name for p in sql_files])
if choice:
    sql_path = Path("sql") / choice
    st.code(sql_path.read_text(), language="sql")
    df = query(choice)
    st.dataframe(df, use_container_width=True)