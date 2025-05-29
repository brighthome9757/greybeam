-- migrate:up

CREATE TABLE pg.games (
  `gameid`               Int64,
  `title`                String,
  `platform`             String,
  `developers`           Array(String),
  `publishers`           Array(String),
  `genres`               Array(String),
  `supported_languages`  Array(String),
  `release_date`         Date
) 
ENGINE = PostgreSQL(
  'localhost:5432', 
  'greybeam', 
  'games', 
  'postgres', 
  'password',
  'public'
);

-- migrate:down

