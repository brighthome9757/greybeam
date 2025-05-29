-- migrate:up

CREATE TABLE IF NOT EXISTS default.games (
  `gameid`               Int64   DEFAULT 0, 
  `title`                String  DEFAULT '',  
  `platform`             String  DEFAULT '',
  `developers`           Array(String)  DEFAULT [],
  `publishers`           Array(String)  DEFAULT [],
  `genres`               Array(String)  DEFAULT [],
  `supported_languages`  Array(String)  DEFAULT [],
  `release_date`         Date    DEFAULT '1970-01-01'
)
ENGINE = MergeTree()
ORDER BY (gameid, platform);

-- migrate:down

