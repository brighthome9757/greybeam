{ pkgs, lib, config, inputs, ... }:

{
  ##################################################################################################
  # https://devenv.sh/basics/
  ##################################################################################################

  env = {
    PG_URL = "postgresql://postgres:password@localhost:5432/greybeam";
    CH_URL = "clickhouse://localhost:9000";
  };

  ##################################################################################################
  # https://devenv.sh/packages/
  ##################################################################################################

  packages = with pkgs; [
    # Python
    mypy # typechecker (ty not working yet)

    # Database
    dbmate # migrations tool
    tbls # db documentation

    # Formatting
    nixpkgs-fmt
    ruff
  ];

  ##################################################################################################
  # https://devenv.sh/languages/
  ##################################################################################################

  languages.python.enable = true;
  languages.python = {
    uv.enable = true;
    # uv.sync.enable = true;

    venv.enable = true;
    venv.requirements = ''
      fastapi
      uvicorn
      sqlglot
      psycopg2-binary
      clickhouse-driver
    '';
  };

  ##################################################################################################
  # https://devenv.sh/processes/
  ##################################################################################################

  processes = {
    extract_gaming_dataset = {
      # exec = "bash -c '[ ! -f assets/archive.zip ] || unzip -q -o assets/archive.zip -d assets'";
      exec = ''
        # Create the extraction directory if it doesn't exist
        mkdir -p assets/extracted
        
        # Extract the gaming dataset if needed
        if [ -f assets/archive.zip ]; then
          echo "Extracting gaming dataset from archive.zip to assets/extracted..."
          unzip -q -o assets/archive.zip -d assets/extracted
        fi
        
        # Create the user_files directory if it doesn't exist
        mkdir -p .devenv/state/clickhouse/user_files
        
        # Remove any existing symlinks to avoid issues
        rm -f .devenv/state/clickhouse/user_files/*
        
        # Create a symlink for the entire assets directory
        echo "Creating symlink for assets directory..."
        ln -sf "$(pwd)/assets" .devenv/state/clickhouse/user_files/assets
        
        echo "All files in assets/ are now accessible to ClickHouse at assets/"
      '';
    };

    wipe-clickhouse = {
      exec = ''
        echo "Dropping all created tables and users in ClickHouse cluster..."
        clickhouse client \
          "''${CH_URL}" \
          --query "DROP DATABASE IF EXISTS raws"

        clickhouse client \
          "''${CH_URL}" \
          --query "DROP DATABASE IF EXISTS pg"

        clickhouse client \
          "''${CH_URL}" \
          --query "DROP TABLE IF EXISTS default.gaming"
        
        clickhouse client \
          "''${CH_URL}" \
          --query "DROP TABLE IF EXISTS default.prices"
      '';
      process-compose = {
        depends_on = {
          clickhouse-server.condition = "process_healthy";
        };
      };
    };

    wipe-postgres = {
      exec = ''
        echo "Dropping all created tables and users in PostgreSQL..."
        psql "''${PG_URL}" -c "
          DROP SCHEMA IF EXISTS raws CASCADE;

          DROP SCHEMA IF EXISTS public CASCADE;
          CREATE SCHEMA public;

          GRANT ALL ON SCHEMA public TO postgres;
          GRANT ALL ON SCHEMA public TO public;
        "
      '';
      process-compose = {
        depends_on = {
          postgres.condition = "process_healthy";
        };
      };
    };

    migrate-postgres = {
      exec = ''
        dbmate \
          --url "postgres://postgres:password@localhost:5432/greybeam?sslmode=disable" \
          --migrations-dir ./db/migrations/postgres \
          --no-dump-schema \
          up
      '';
      process-compose = {
        depends_on = {
          postgres.condition = "process_healthy";
          wipe-postgres.condition = "process_completed_successfully";
        };
      };
    };

    migrate-clickhouse = {
      exec = ''
        dbmate \
          --url "''${CH_URL}" \
          --migrations-dir ./db/migrations/clickhouse \
          --no-dump-schema \
          up
      '';
      process-compose = {
        depends_on = {
          clickhouse-server.condition = "process_started";
          postgres.condition = "process_healthy";
          wipe-clickhouse.condition = "process_completed_successfully";
          # Waits for postgres tables to be created before seeding with clickhouse ones
          migrate-postgres.condition = "process_completed_successfully";
          # Waits for unzipped csvs before using to seed dbs
          extract_gaming_dataset.condition = "process_completed_successfully";
        };
      };
    };

    server = {
      exec = "./bin/start_server.sh";
      process-compose = {
        depends_on = {
          clickhouse-server.condition = "process_healthy";
          postgres.condition = "process_healthy";
          migrate-postgres.condition = "process_completed_successfully";
          migrate-clickhouse.condition = "process_completed_successfully";
        };
      };
    };
  };

  ##################################################################################################
  # https://devenv.sh/services/
  ##################################################################################################

  services.postgres.enable = true;
  services.postgres = {
    package = pkgs.postgresql_17;
    initialDatabases = [{ name = "greybeam"; }];
    # Enable TCP/IP connections
    listen_addresses = "127.0.0.1";
    port = 5432;
    # Create greybeam database and set permissions
    initialScript = ''
      CREATE DATABASE greybeam;
      
      CREATE USER postgres WITH PASSWORD 'password';
      GRANT ALL PRIVILEGES ON DATABASE greybeam TO postgres;
      ALTER USER postgres WITH SUPERUSER;
    '';
  };

  # CH server (as opposed to CH local) requires files to be at user_files_path
  # Devenv hardcodes this and a few other configurations and doesn't allow overriding
  # So I hacked together quick and dirty symlinks within user_files_path to assets/
  services.clickhouse.enable = true;

  # TODO Maybe - Set up manually with process-compose
  # services.influxdb.enable = true;
  # services.duckdb.enable = true;  

  ##################################################################################################
  ##################################################################################################
  ##################################################################################################

  enterShell = ''
    echo -e ""
    echo "PG_URL is set to: $PG_URL"
    echo "CH_URL is set to: $CH_URL"

    echo -e ""
    echo "Run 'devenv up' to launch server and target databases"
    echo -e ""
  '';

  ##################################################################################################
  # https://devenv.sh/scripts
  ##################################################################################################

  scripts.clean-dbs.exec = ''
    echo "Cleaning up database state directories..."
    rm -rf .devenv/state/clickhouse/
    rm -rf .devenv/state/postgres/
    echo "Database state directories cleaned. Fresh databases will be initialized."
  '';


  ##################################################################################################
  # https://devenv.sh/reference/options/#git-hookshooks
  ##################################################################################################

  git-hooks.hooks.nixpkgs-fmt.enable = true; # nix formatter
  git-hooks.hooks.ruff.enable = true; # python formatter

  # See full reference at https://devenv.sh/reference/options/
}
