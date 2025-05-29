-- migrate:up

INSERT INTO raws.playstation_games 
SELECT
  toInt64(gameid) as gameid,
  title,
  platform,
  parseArrayString(developers) as developers,
  parseArrayString(publishers) as publishers,
  parseArrayString(genres) as genres,
  parseArrayString(supported_languages) as supported_languages,
  release_date
FROM file('./assets/extracted/playstation/games.csv');

-- migrate:down

