-- migrate:up

INSERT INTO pg.games
SELECT * 
FROM default.games;

-- migrate:down

