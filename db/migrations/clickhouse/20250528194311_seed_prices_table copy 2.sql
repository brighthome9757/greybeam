-- migrate:up

INSERT INTO default.prices
SELECT 
  *, 
  'Playstation' as platform
FROM raws.playstation_prices

UNION ALL

SELECT 
  *,
  'Steam' as platform
FROM raws.steam_prices

UNION ALL

SELECT 
  *,
  'Xbox' as platform
FROM raws.xbox_prices;

-- migrate:down

