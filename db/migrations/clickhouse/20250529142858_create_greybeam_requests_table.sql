-- migrate:up

CREATE TABLE query_logs (
    -- Request metadata
    request_id UUID,                                  -- Unique identifier for each session
    timestamp DateTime                DEFAULT now(),  -- When the request was received

    -- Request details
    original_query String,                  -- The original SQL query
    source_dialect LowCardinality(String),  -- Source dialect (e.g., 'duckdb')

    -- Transpilation details
    transpiled_query String,                -- The original SQL query
    target_dialect LowCardinality(String),  -- Target dialect for execution (e.g., 'duckdb')

    -- Processing details
    transpilation_time_ms UInt32      DEFAULT 0,
    execution_time_ms UInt32          DEFAULT 0,
    fetch_time_ms UInt32              DEFAULT 0,
    total_processing_time_ms UInt32   DEFAULT 0,
    
    -- Summary metrics
    row_count UInt32                  DEFAULT 0,
    is_error Bool                     DEFAULT False,
    error String                      DEFAULT ''  -- Error message if any
)
ENGINE = MergeTree()
ORDER BY (toHour(timestamp), target_dialect, request_id);

-- migrate:down

