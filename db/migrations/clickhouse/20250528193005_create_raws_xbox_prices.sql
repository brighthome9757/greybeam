-- migrate:up

CREATE TABLE IF NOT EXISTS raws.xbox_prices (
  `gameid`         Int64    DEFAULT 0,
  `usd`            Nullable(Float64),
  `eur`            Nullable(Float64),
  `gbp`            Nullable(Float64),
  `jpy`            Nullable(Float64),
  `rub`            Nullable(Float64),
  `date_acquired`  Nullable(Date)
)
ENGINE = MergeTree()
ORDER BY gameid;

-- migrate:down

