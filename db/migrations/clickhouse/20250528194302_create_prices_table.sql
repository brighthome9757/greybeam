-- migrate:up

CREATE TABLE IF NOT EXISTS default.prices (
  `gameid`         Int64    DEFAULT 0,
  `usd`            Nullable(Float64),
  `eur`            Nullable(Float64),
  `gbp`            Nullable(Float64),
  `jpy`            Nullable(Float64),
  `rub`            Nullable(Float64),
  `date_acquired`  Nullable(Date),
  `platform`       String   DEFAULT ''  -- new
)
ENGINE = MergeTree()
ORDER BY (gameid, platform);

-- migrate:down

