-- migrate:up

INSERT INTO raws.steam_prices 
SELECT * 
FROM file('./assets/extracted/steam/prices.csv');

-- migrate:down

