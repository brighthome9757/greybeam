-- migrate:up

-- Create schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS raws;

-------------------------------------------------------------------------------
-- Playstation Games + Prices
-------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS raws.playstation_games (
  gameid               BIGINT PRIMARY KEY,
  title                TEXT NOT NULL,
  platform             TEXT NOT NULL,
  developers           TEXT[] NOT NULL,
  publishers           TEXT[] NOT NULL,
  genres               TEXT[] NOT NULL,
  supported_languages  TEXT[] NOT NULL,
  release_date         DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS raws.playstation_prices (
  gameid         BIGINT PRIMARY KEY REFERENCES raws.playstation_games(gameid),
  usd            NUMERIC,
  eur            NUMERIC,
  gbp            NUMERIC,
  jpy            NUMERIC,
  rub            NUMERIC,
  date_acquired  DATE
);

-------------------------------------------------------------------------------
-- Steam Games + Prices
-------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS raws.steam_games (
  gameid               BIGINT PRIMARY KEY,
  title                TEXT NOT NULL,
  platform             TEXT NOT NULL,
  developers           TEXT[] NOT NULL,
  publishers           TEXT[] NOT NULL,
  genres               TEXT[] NOT NULL,
  supported_languages  TEXT[] NOT NULL,
  release_date         DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS raws.steam_prices (
  gameid         BIGINT PRIMARY KEY REFERENCES raws.steam_games(gameid),
  usd            NUMERIC,
  eur            NUMERIC,
  gbp            NUMERIC,
  jpy            NUMERIC,
  rub            NUMERIC,
  date_acquired  DATE
);

-------------------------------------------------------------------------------
-- Xbox Games + Prices
-------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS raws.xbox_games (
  gameid               BIGINT PRIMARY KEY,
  title                TEXT NOT NULL,
  platform             TEXT NOT NULL,
  developers           TEXT[] NOT NULL,
  publishers           TEXT[] NOT NULL,
  genres               TEXT[] NOT NULL,
  supported_languages  TEXT[] NOT NULL,
  release_date         DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS raws.xbox_prices (
  gameid         BIGINT PRIMARY KEY REFERENCES raws.xbox_games(gameid),
  usd            NUMERIC,
  eur            NUMERIC,
  gbp            NUMERIC,
  jpy            NUMERIC,
  rub            NUMERIC,
  date_acquired  DATE
);

-------------------------------------------------------------------------------
-- Indexes
-------------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_playstation_games_title ON raws.playstation_games(title);
CREATE INDEX IF NOT EXISTS idx_steam_games_title ON raws.steam_games(title);
CREATE INDEX IF NOT EXISTS idx_xbox_games_title ON raws.xbox_games(title);

CREATE INDEX IF NOT EXISTS idx_playstation_prices_date ON raws.playstation_prices(date_acquired);
CREATE INDEX IF NOT EXISTS idx_steam_prices_date ON raws.steam_prices(date_acquired);
CREATE INDEX IF NOT EXISTS idx_xbox_prices_date ON raws.xbox_prices(date_acquired);

-- migrate:down
