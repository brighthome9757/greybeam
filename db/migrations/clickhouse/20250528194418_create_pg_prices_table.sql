-- migrate:up

CREATE TABLE pg.prices (
  `gameid`         Int64,
  `usd`            Nullable(Float64),
  `eur`            Nullable(Float64),
  `gbp`            Nullable(Float64),
  `jpy`            Nullable(Float64),
  `rub`            Nullable(Float64),
  `date_acquired`  Nullable(Date),
  `platform`       String
) 
ENGINE = PostgreSQL(
  'localhost:5432', 
  'greybeam', 
  'prices', 
  'postgres', 
  'password',
  'public'
);

-- migrate:down

