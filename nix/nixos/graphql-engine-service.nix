{ lib, pkgs, config, ... }:
let
  cfg = config.services.graphql-engine;

in {
  options = {
    services.graphql-engine = {
      enable = lib.mkEnableOption "graphql engine service";

      host = lib.mkOption {
        type = lib.types.str;
        default = "/var/run/postgresql";
      };

      dbUser = lib.mkOption {
        type = lib.types.str;
        default = "cexplorer";
      };

      password = lib.mkOption {
        type = lib.types.str;
        default = ''""'';
      };

      db = lib.mkOption {
        type = lib.types.str;
        default = "cexplorer";
      };

      dbPort = lib.mkOption {
        type = lib.types.int;
        default = 5432;
      };

      enginePort = lib.mkOption {
        type = lib.types.int;
        default = 9999;
      };
    };
  };
  config = let
    graphqlEngine = (import ../pkgs.nix {}).packages.graphql-engine;
    hasuraSchemas = pkgs.writeScript "hasuraSchemas.sql" ''
      CREATE SCHEMA IF NOT EXISTS hdb_catalog;
      CREATE SCHEMA IF NOT EXISTS hdb_views;
    '';
    postgresqlIp = if ((__head (pkgs.lib.stringToCharacters cfg.host)) == "/")
                   then "127.0.0.1"
                   else cfg.host;
  in lib.mkIf cfg.enable {
    systemd.services.graphql-engine = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "postgresql.service" ];
      path = with pkgs; [ curl netcat postgresql sudo ];
      preStart = ''
        for x in {1..10}; do
          nc -z ${postgresqlIp} ${toString cfg.dbPort} && break
          echo loop $x: waiting for postgresql 2 sec...
          sleep 2
        done
        psql ${cfg.db} < ${hasuraSchemas}
      '';
      script = ''
        ${graphqlEngine}/bin/graphql-engine \
          --host ${cfg.host} \
          -u ${cfg.dbUser} \
          --password ${cfg.password} \
          -d ${cfg.db} \
          --port ${toString cfg.dbPort} \
          serve \
          --server-port ${toString cfg.enginePort} \
          --enable-telemetry=false \
          --disable-cors
      '';
    };
  };
}
