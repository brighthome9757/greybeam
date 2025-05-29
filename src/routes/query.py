from fastapi import APIRouter, Body
from pydantic import BaseModel, Field
import uuid

import core.db
import core.transpiler
from core.types import SQLDialect

router = APIRouter()


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
    # Generate a unique request ID for this session
    request_id = str(uuid.uuid4())

    # Target dialects to transpile to
    target_dialects = [SQLDialect.CLICKHOUSE, SQLDialect.POSTGRES]
    results = {}

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

        # Get the results for this dialect
        dialect_key = target_dialect.value.lower()
        dialect_result = query_results.get(dialect_key, {})

        # Calculate total processing time for this dialect
        total_time_ms = (
            (dialect_result.get("transpile_time_ms", 0) or 0)
            + (dialect_result.get("execution_time_ms", 0) or 0)
            + (dialect_result.get("fetch_time_ms", 0) or 0)
        )

        # Log the query execution for this dialect in CH
        await core.db.log_query_event(
            request_id=request_id,
            original_query=request.query,
            source_dialect=request.dialect,
            transpiled_query=dialect_result.get("transpiled_sql", ""),
            target_dialect=target_dialect,
            transpilation_time_ms=dialect_result.get("execution_time_ms", 0) or 0,
            execution_time_ms=dialect_result.get("execution_time_ms", 0) or 0,
            fetch_time_ms=dialect_result.get("fetch_time_ms", 0) or 0,
            total_processing_time_ms=total_time_ms,
            row_count=dialect_result.get("row_count", 0) or 0,
            is_error="error" in dialect_result,
            error=dialect_result.get("error", ""),
        )

        results.update(query_results)

    return results
