#!/bin/bash

curl -H 'Content-Type: application/json' \
     -X POST 'localhost:8000/run-query' \
     --data '{"query": "select distinct gameid, title from games where gameid < 3", "dialect": "clickhouse"}' | jq .