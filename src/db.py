"""DuckDB connection helper. The warehouse is a single .duckdb file."""

from pathlib import Path
import duckdb

PROJECT_ROOT = Path(__file__).resolve().parents[1]
WAREHOUSE_PATH = PROJECT_ROOT / "warehouse.duckdb"
SQL_DIR = PROJECT_ROOT / "sql"
DATA_DIR = PROJECT_ROOT / "data" / "raw"


def connect(read_only: bool = False) -> duckdb.DuckDBPyConnection:
    return duckdb.connect(str(WAREHOUSE_PATH), read_only=read_only)


def execute_sql_file(con: duckdb.DuckDBPyConnection, filename: str) -> None:
    """Run every statement in a .sql file. Supports multi-statement scripts."""
    path = SQL_DIR / filename
    sql = path.read_text(encoding="utf-8")
    con.execute(sql)


def query(filename: str) -> "pd.DataFrame":
    """Execute a single .sql file and return its result as a DataFrame."""
    import pandas as pd
    with connect(read_only=True) as con:
        return con.execute((SQL_DIR / filename).read_text()).df()
