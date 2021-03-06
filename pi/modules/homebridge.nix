{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.homebridge;
in
{
  options = {
    services.homebridge = {
      enable = mkEnableOption "Homebridge Server";

      workDir = mkOption {
        type = types.str;
        default = "/var/lib/homebridge";
        description = ''
          The directory where Homebridge stores its data files.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Open ports in the firewall for the server.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.homebridge = {
      description = "Homebridge Service";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.nodejs pkgs.bash ];

      serviceConfig = {
        Type = "simple";
        User = "nixos";
        Group = "users";

        WorkingDirectory = "/home/nixos/node_modules";
        ExecStart = "${pkgs.bash}/bin/bash -c 'npx homebridge'";
        StandardOutput = "append:${cfg.workDir}/logs.log";
        StandardError = "append:${cfg.workDir}/logs.log";

        KillSignal = "SIGQUIT";
        Restart = "on-failure";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 8581 51373 ];
      allowedUDPPorts = [ 8581 ];
    };
  };
}
