from fastapi import APIRouter, HTTPException, Body
from pydantic import BaseModel, Field
from typing import Dict, Any, Optional
import sqlglot

import core.db
import core.transpiler

router = APIRouter()

class QueryRequest(BaseModel):
    query: str = Field(..., description="SQL query to transpile and execute")
    dialect: str = Field(..., description="Dialect of the input query")
    
    model_config = {
        "json_schema_extra": {
            "example": {
                "query": "SELECT platform, COUNT(*) FROM games GROUP BY platform",
                "dialect": "duckdb"
            }
        }
    }

"""
curl -H 'Content-Type: application/json' -X POST 'localhost:8000/run-query' --data '{"query": "SELECT platform, COUNT(*) FROM games GROUP BY platform", "dialect": "duckdb"}' | jq .
"""

@router.post("/run-query")
async def run_query(request: QueryRequest = Body(...)):
    # Validate input dialect is supported by sqlglot
    supported_dialects = list(sqlglot.dialects.__all__)
    if request.dialect.lower() not in [d.lower() for d in supported_dialects]:
        return {"error": f"Unsupported dialect: {request.dialect}. Supported dialects: {supported_dialects}"}
    
    # Target dialects to transpile to
    target_dialects = ["clickhouse", "postgres"]
    results = {}

    # TODO Generate "run_id" uuid for session, to be used as prefix for CH primary key with `time`
    
    # Process for each target dialect
    for target_dialect in target_dialects:
        target_queries: str = core.transpiler.transpile_query(
            input_sql=request.query,
            input_dialect=request.dialect,
            target_dialect=target_dialect
        )
        query_results = core.db.execute_query(
            target_dialect=target_dialect,
            target_queries=target_queries
        )

        results.update(query_results)

    # TODO Record processed request event in clickhouse indexed by run_id / session id

    return results
