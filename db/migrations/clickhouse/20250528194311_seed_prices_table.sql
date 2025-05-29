-- migrate:up

INSERT INTO default.games
  (
    gameid,
    title,
    platform,
    developers,
    publishers,
    genres,
    supported_languages,
    release_date
  )
SELECT 
  gameid,
  title,
  platform,
  developers,
  publishers,
  genres,
  supported_languages,
  release_date
FROM raws.playstation_games

UNION ALL

SELECT 
  gameid,
  title,
  'Steam' as platform,
  developers,
  publishers,
  genres,
  supported_languages,
  release_date
FROM raws.steam_games

UNION ALL

SELECT 
  gameid,
  title,
  'Xbox' as platform,
  developers,
  publishers,
  genres,
  supported_languages,
  release_date
FROM raws.xbox_games;

-- migrate:down

