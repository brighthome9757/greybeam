-- migrate:up

INSERT INTO raws.steam_games 
SELECT
  toInt64(gameid) as gameid,
  title,
  'Steam' as platform,
  parseArrayString(developers) as developers,
  parseArrayString(publishers) as publishers,
  parseArrayString(genres) as genres,
  parseArrayString(supported_languages) as supported_languages,
  release_date
FROM file('./assets/extracted/steam/games.csv');

-- migrate:down

