-- migrate:up

-- Create schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS public;

CREATE TABLE IF NOT EXISTS games (
  id                   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  gameid               BIGINT NOT NULL,
  title                TEXT NOT NULL,
  platform             TEXT NOT NULL,
  developers           TEXT[] NOT NULL,
  publishers           TEXT[] NOT NULL,
  genres               TEXT[] NOT NULL,
  supported_languages  TEXT[] NOT NULL,
  release_date         DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS prices (
  id                   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  gameid               BIGINT NOT NULL,
  usd                  NUMERIC,
  eur                  NUMERIC,
  gbp                  NUMERIC,
  jpy                  NUMERIC,
  rub                  NUMERIC,
  date_acquired        DATE,
  platform             TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_games_gameid_platform ON games(gameid, platform);
CREATE INDEX IF NOT EXISTS idx_prices_gameid_platform ON prices(gameid, platform);

CREATE INDEX IF NOT EXISTS idx_games_title ON games(title);
CREATE INDEX IF NOT EXISTS idx_games_platform ON games(platform);
CREATE INDEX IF NOT EXISTS idx_prices_date ON prices(date_acquired);
CREATE INDEX IF NOT EXISTS idx_prices_usd ON prices(usd);

-- migrate:down

