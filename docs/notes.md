# Notes

## What I did

### Act 1 - Setup

First I set up a project with devenv. Devenv is great for setting up small nix-based project environments without much hassle. I can put together a more familiar dockerfile for reviewers to use later.

```bash
$ devenv init
Creating devenv.nix
Creating devenv.yaml
Creating .envrc
Creating .gitignore
direnv: loading <project-location>/greybeam/.envrc
direnv: using devenv
```

Devenv has ready-made "options" (configurations) for ClickHouse and Postgres out of the box, so I went with those. For time reasons, I didn't want to put together my own integrations for DuckDB or SQLite, though it would have been straightforward to add them with some extra time.

```diff:devenv.nix
# devenv.nix
+ lanaguages.python.enable = true;
...
+ services.clickhouse.enable = true;
+ services.postgres.enable = true;
```

I've heard good things about `uv`, so let's try it:
```diff:devenv.nix
# devenv.nix
+ languages.python.uv.enable = true;
```

Then I let uv take care of creating the basic python project scaffolding:

```bash
$ uv init --package
```

### Act 2 - Server Scaffolding

I've also been seeing more references to FastAPI lately, so I decided to try that as well. This meant spending some time reading up on FastAPI, uvicorn, and pydantic.

As the requirements involve connecting to various databases already, it seemed easy enough to reusing the postgres connection to manage server activity. Additionally, I could throw events into clickhouse and do analysis.

For time reasons, I skipped over usual features like authnz, rate limitting, pagination, deployment concerns, etc.

### Act 3 - Transpilation with SQLGlot

Initially I thought I'd explore calcite, but my five minutes of browsing didn't surface any out of the box python integrations. I'm sure I could have found something or rolled my own integration with a bit more time.

SQLGlot it is.

SQLGlot has a handy `transpile()` function that takes a dialect as input, so most of the work is done. Rather than passing in whatever input, I constrained the possible set of dialects and enforced in.

### Act 4 - Seeding Databases

First, I started exploring the datasets with clickhouse-local.

I ran into issues with devenv's clickhouse integration and the way clickhouse-server "helpfully" prevents reading files from arbitrary locations. I settled on symlink-ing my assets folder containing the gaming dataset zip to get myself unblocked.

I decided to tracking seeding with a migrations tool like initial table creation. Devenv saves database state for clickhouse and postgres, so there's no need recreate tables or duplicate inserts.

### Act 4 - Query Execution

I added migrations creating tables and seed dbs with the unzipped dataset.

Then I made functions using psyopg2 and clickhouse-driver to query the target postgres and clickhouse databases, respectively.

### Act 5 - Metrics

I stuck to result row counts (length) and execution timings. Normally I'd use an OTel and/or native timing apis, but for time I decided to simply wrap the relevant invocations with timers.

### Act 6 - Final Touches

Last second scramble to get every process initiated with single `devenv up` command and have server ready for actions.

Then I did some docs.