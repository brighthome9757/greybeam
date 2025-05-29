-- migrate:up

INSERT INTO raws.playstation_prices 
SELECT * 
FROM file('./assets/extracted/playstation/prices.csv');

-- migrate:down

