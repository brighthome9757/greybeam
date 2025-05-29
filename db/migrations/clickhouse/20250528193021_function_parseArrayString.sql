-- migrate:up

CREATE FUNCTION parseArrayString AS (arrString) -> 
  if(
      arrString is null, [], 
      arrayMap(
        elem -> trimBoth(elem),
        splitByChar(
          ',',
          replaceAll(
            replaceAll(
              replaceAll(
                replaceAll(
                  replaceAll(
                    replaceAll(assumeNotNull(arrString), '[', ''),
                      ']', ''
                    ),
                  '\'', ''
                ),
                '"', ''  -- to deal with ""Shoot 'em up"", "Travellers Tales", etc
              ),
              '{', ''  -- to deal with {uni}
            ),
            '}', ''  -- to deal with {uni}
          )
        )
      )
    )::Array(String);

-- migrate:down

