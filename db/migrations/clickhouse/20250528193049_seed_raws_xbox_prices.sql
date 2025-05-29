-- migrate:up

INSERT INTO raws.xbox_prices 
SELECT * 
FROM file('./assets/extracted/xbox/prices.csv');

-- migrate:down

