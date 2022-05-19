{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.lazylibrarian;
  pythonWithDeps = pkgs.python3.withPackages (ps: with ps; [urllib3 requests charset-normalizer]);
  lazylibrarian = pkgs.stdenv.mkDerivation rec {
     pname = "lazylibrarian";
      version = "1.7.2";
      src = pkgs.fetchgit { 
        url = "https://gitlab.com/LazyLibrarian/LazyLibrarian";
        sha256 = "Od18RClmLw2QDL6vO29Tu4AYjdXWtLwRVXFq2bD/QP4=";
      };
     installPhase = ''
       cp -r . $out/
     '';
  };  
in
{
  options = {
    services.lazylibrarian = {
      enable = mkEnableOption "LazyLibrarian";

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/lazylibrarian";
        description = "The directory where LazyLibrarian stores its data files.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for the LazyLibrarian web interface.";
      };

      user = mkOption {
        type = types.str;
        default = "lazylibrarian";
        description = "User account under which LazyLibrarian runs.";
      };

      group = mkOption {
        type = types.str;
        default = "lazylibrarian";
        description = "Group under which LazyLibrarian runs.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.lazylibrarian = {
      description = "LazyLibrarian";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "${lazylibrarian}";
        ExecStart = "${pythonWithDeps}/bin/python3 LazyLibrarian.py --datadir='${cfg.dataDir}' --debug";
        Restart = "on-failure";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 5299 ];
    };

    users.users = mkIf (cfg.user == "lazylibrarian") {
      lazylibrarian = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "lazylibrarian") {
      lazylibrarian.gid = config.ids.gids.lazylibrarian;
    };
  };
}
