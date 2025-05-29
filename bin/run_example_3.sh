#!/bin/bash

curl -H 'Content-Type: application/json' \
     -X POST 'localhost:8000/run-query' \
     --data '{"query": "select g.gameid, ANY_VALUE(g.title), avg(p.usd) from prices p inner join (select distinct gameid, title from games where gameid <= 3) g on g.gameid = p.gameid group by g.gameid", "dialect": "duckdb"}' | jq .