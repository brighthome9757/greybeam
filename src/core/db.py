import psycopg2
from psycopg2.extras import RealDictCursor
import time
import math
from clickhouse_driver import Client

from core.types import SQLDialect


def execute_query(target_dialect: SQLDialect, target_queries: dict) -> dict:
    match target_dialect:
        case SQLDialect.POSTGRES:
            target_queries["postgres"] = execute_pg_query(
                pg_query=target_queries["postgres"]
            )
        case SQLDialect.CLICKHOUSE:
            target_queries["clickhouse"] = execute_ch_query(
                ch_query=target_queries["clickhouse"]
            )
        case _:
            print(f"{target_dialect} is an invalid target database.")

            target_queries[target_dialect]["error"] = (
                f"{target_dialect} is an invalid target database."
            )

    return target_queries


def execute_pg_query(pg_query: dict) -> dict:
    results = []

    conn_params = {
        "dbname": "greybeam",
        "user": "postgres",
        "password": "password",
        "host": "localhost",
        "port": "5432",
    }

    try:
        with psycopg2.connect(**conn_params) as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                exec_start_time = time.time()
                cursor.execute(pg_query["transpiled_sql"], None)
                exec_time_ms = (time.time() - exec_start_time) * 1000

                fetch_start_time = None

                # Proceed if it's a SELECT query
                if cursor.description:
                    fetch_start_time = time.time()
                    results = cursor.fetchall()
                    fetch_time_ms = (time.time() - fetch_start_time) * 1000
                # Ignore non-SELECT queries
                else:
                    print(
                        f"Only SELECT queries are allowed. Your transpiled query: {pg_query}"
                    )

                conn.commit()

                pg_query["execution_time_ms"] = math.ceil(exec_time_ms)
                if fetch_time_ms is not None:
                    pg_query["fetch_time_ms"] = math.ceil(fetch_time_ms)
                pg_query["row_count"] = len(results)
                pg_query["results_sample"] = [dict(row) for row in results]

    except Exception as e:
        print(f"Database error: {e}")

        pg_query["error"] = f"Error executing against postgres: {str(e)}"
        pg_query["execution_time_ms"] = 0
        pg_query["row_count"] = 0
        pg_query["results_sample"] = []

    return pg_query


def execute_ch_query(ch_query: dict) -> dict:
    # ClickHouse connection parameters - replace with your actual credentials
    conn_params = {
        "host": "localhost",
        "port": 9000,
        "user": "default",
        "password": "",
        "database": "default",
    }

    try:
        client = Client(**conn_params)

        start_time = time.time()
        results = client.execute(ch_query["transpiled_sql"], with_column_types=True)
        exec_time_ms = (time.time() - start_time) * 1000

        data, columns = results

        # Convert to list of dictionaries
        column_names = [col[0] for col in columns]
        results_dicts = []
        for row in data:
            row_dict = {column_names[i]: value for i, value in enumerate(row)}
            results_dicts.append(row_dict)

        ch_query["execution_time_ms"] = math.ceil(exec_time_ms)
        ch_query["row_count"] = len(results_dicts)
        ch_query["results_sample"] = results_dicts

    except Exception as e:
        print(f"ClickHouse error: {e}")

        ch_query["error"] = f"Error executing against clickhouse: {str(e)}"
        ch_query["execution_time_ms"] = 0.0
        ch_query["row_count"] = 0.0
        ch_query["results_sample"] = []

    return ch_query
