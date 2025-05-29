-- migrate:up

INSERT INTO pg.prices
SELECT * 
FROM default.prices;

-- migrate:down

