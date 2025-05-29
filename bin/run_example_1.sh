#!/bin/bash

curl -H 'Content-Type: application/json' \
     -X POST 'localhost:8000/run-query' \
     --data '{"query": "SELECT platform, COUNT(*) FROM games GROUP BY platform", "dialect": "duckdb"}' | jq .