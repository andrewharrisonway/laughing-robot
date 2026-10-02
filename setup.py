"""
Loads the raw CSVs in data/ into an in-memory DuckDB instance for ad-hoc
exploration outside of dbt (e.g. sanity-checking a raw file, or poking at
data quality issues before writing a staging model).

    python setup.py

drops you into an interactive DuckDB shell (via the `duckdb` CLI's Python
API) with three tables already loaded: raw_accounts, raw_subscriptions,
raw_events.

This is *not* how the dbt project itself reads the data -- dbt reads the
CSVs directly as external sources (see models/sources.yml), so
`dbt build` does not depend on this script or its output. This script only
exists for quick manual exploration.
"""
import duckdb

RAW_FILES = {
    "raw_accounts": "data/raw_accounts.csv",
    "raw_subscriptions": "data/raw_subscriptions.csv",
    "raw_events": "data/raw_events.csv",
}


def load() -> duckdb.DuckDBPyConnection:
    con = duckdb.connect(database=":memory:")
    for table_name, path in RAW_FILES.items():
        con.execute(
            f"CREATE OR REPLACE TABLE {table_name} AS SELECT * FROM read_csv_auto('{path}')"
        )
        count = con.execute(f"SELECT count(*) FROM {table_name}").fetchone()[0]
        print(f"Loaded {table_name} ({count} rows) from {path}")
    return con


if __name__ == "__main__":
    conn = load()
    print("\nTables ready: raw_accounts, raw_subscriptions, raw_events")
    print("Example: conn.sql('SELECT * FROM raw_accounts LIMIT 5').show()")
    import code

    code.interact(local={"conn": conn, "duckdb": duckdb})
