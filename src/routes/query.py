from fastapi import APIRouter, Body
from pydantic import BaseModel, Field
from typing import Enum

import core.db
import core.transpiler

router = APIRouter()


class SQLDialect(str, Enum):
    """Supported SQL dialects for query transpilation"""

    ATHENA = "athena"
    BIGQUERY = "bigquery"
    CLICKHOUSE = "clickhouse"
    DATABRICKS = "databricks"
    DORIS = "doris"
    DRILL = "drill"
    DRUID = "druid"
    DUCKDB = "duckdb"
    DUNE = "dune"
    HIVE = "hive"
    MATERIALIZE = "materialize"
    MYSQL = "mysql"
    ORACLE = "oracle"
    POSTGRES = "postgres"
    PRESTO = "presto"
    PRQL = "prql"
    REDSHIFT = "redshift"
    RISINGWAVE = "risingwave"
    SNOWFLAKE = "snowflake"
    SPARK = "spark"
    SPARK2 = "spark2"
    SQLITE = "sqlite"
    STARROCKS = "starrocks"
    TABLEAU = "tableau"
    TERADATA = "teradata"
    TRINO = "trino"
    TSQL = "tsql"


class QueryRequest(BaseModel):
    query: str = Field(..., description="SQL query to transpile and execute")
    dialect: SQLDialect = Field(..., description="Dialect of the input query")

    model_config = {
        "json_schema_extra": {
            "example": {
                "query": "SELECT platform, COUNT(*) FROM games GROUP BY platform",
                "dialect": "duckdb",
            }
        }
    }


@router.post("/run-query")
async def run_query(request: QueryRequest = Body(...)):
    # Target dialects to transpile to
    target_dialects = ["clickhouse", "postgres"]
    results = {}

    # TODO Generate "run_id" uuid for session, to be used as prefix for CH primary key with `time`

    # Process for each target dialect
    for target_dialect in target_dialects:
        target_queries: str = core.transpiler.transpile_query(
            input_sql=request.query,
            input_dialect=request.dialect,
            target_dialect=target_dialect,
        )
        query_results = core.db.execute_query(
            target_dialect=target_dialect, target_queries=target_queries
        )

        results.update(query_results)

    # TODO Record processed request event in clickhouse indexed by run_id / session id

    return results
