-- migrate:up

INSERT INTO default.games

SELECT *
FROM raws.playstation_games

UNION ALL

SELECT *
FROM raws.steam_games

UNION ALL

SELECT *
FROM raws.xbox_games;

-- migrate:down

