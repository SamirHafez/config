{ pkgs, system, ... }:
let
  ffmpeg_with_aac = pkgs.ffmpeg-full.override {
    nonfreeLicensing = true;
    fdkaacExtlib = true;
  };
  pined-calibre = import (builtins.fetchTarball {
    name = "nixos-unstable";
    url =
      "https://github.com/nixos/nixpkgs/archive/bc4b9eef3ce3d5a90d8693e8367c9cbfc9fc1e13.tar.gz";
    sha256 = "0mrpsl0554fzk04asz0nmyxf6ny1syd9qzrh37vz85bpq8wi21dx";
  }) { inherit system; };
  pined-plex = import (builtins.fetchTarball {
    name = "nixos-unstable";
    url =
      "https://github.com/nixos/nixpkgs/archive/ef4f066697d1fabca282ef88526bb41ff291bafb.tar.gz";
    sha256 = "0q93a941rx6637xz4cjpcacb1j9hch2xnacyhmqcrh78azkd9xmd";
  }) {
    inherit system;
    config.allowUnfree = true;
  };
in {
  imports = [ ];

  disabledModules = [ "services/misc/calibre-server.nix" ];

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs = {
    overlays = [
      (self: super: {
        calibre = pined-calibre.calibre;
        calibre-web = pined-calibre.calibre-web;
        plex = pined-plex.plex;
      })
    ];
    config.allowUnfree = true;
  };

  systemd.services.sshd.wantedBy =
    pkgs.lib.mkOverride 40 [ "multi-user.target" ];

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  networking = {
    hostName = "pi";
    wireless.enable = false;
    wireless.networks.VM6037920.pskRaw =
      "f77d5cb1598fc09da3b4d0fdd9575e336b473a1283b753b19b1dd84cb71610df";
    networkmanager = {
      enable = true;
      unmanaged = [ "wlan0" ];
    };
    nat.enable = true;
    nat.externalInterface = "eth0";
    nat.internalInterfaces = [ "wg0" ];
    firewall.enable = true;
    firewall.allowedTCPPorts = [
      8080 # calibre-server
      53 # adguardhome-DNS
      6789 # nzbget
      9000 # grafana
      9090 # prometheus
      8384 # syncthing
    ];
    firewall.allowedUDPPorts = [
      53 # adguardhome-DNS
      51820 # wireguard
      5351 # nat
    ];
    wg-quick.interfaces = {
      wg0 = {
        address = [ "10.2.0.2/32" ];
        dns = [ "10.2.0.1" ];
        privateKeyFile = "/home/nixos/wireguard_key_o0F4H";

        postUp = ''
          /run/current-system/sw/bin/iptables -A FORWARD -i eth0 -j ACCEPT
          /run/current-system/sw/bin/iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
        '';

        postDown = ''
          /run/current-system/sw/bin/iptables -D FORWARD -i eth0 -j ACCEPT
          /run/current-system/sw/bin/iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE
        '';

        peers = [{
          publicKey = "o0F4H+q6+dxKknCQES2+8Upz/VFTivxqqDC3UnEhNFo=";

          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "89.238.150.170:51820";
          persistentKeepalive = 25;
        }];
      };
    };
  };

  services = {
    sshd.enable = true;

    journald.extraConfig = ''
      SystemMaxUse=100M
      MaxLevelStore=notice
      MaxLevelSyslog=notice
    '';

    homebridge = {
      enable = true;
      openFirewall = true;
      workDir = "/home/nixos/.homebridge";
    };

    adguardhome = {
      enable = true;
      openFirewall = true;
    };

    plex = {
      enable = true;
      openFirewall = true;
      group = "media";
      dataDir = "/mnt/media/plex";
    };

    nzbget = {
      enable = true;
      group = "media";
    };

    sonarr = {
      enable = true;
      openFirewall = true;
      group = "media";
    };

    radarr = {
      enable = true;
      openFirewall = true;
      group = "media";
    };

    lazylibrarian = {
      enable = true;
      openFirewall = true;
      group = "media";
    };

    lidarr = {
      enable = true;
      openFirewall = true;
      group = "media";
    };

    calibre-server = {
      enable = true;
      user = "lazylibrarian";
      group = "media";
      libraries = [ "/mnt/media/calibre-library" ];
    };

    calibre-web = {
      enable = true;
      user = "lazylibrarian";
      listen.ip = "0.0.0.0";
      openFirewall = true;
      options = { calibreLibrary = "/mnt/media/calibre-library"; };
      group = "media";
    };
  };

  users = {
    mutableUsers = false;
    users.nixos = {
      hashedPassword =
        "$6$dQjkI37gYxoDZei$v30Z34Sf3Hx5STxamN2mi0k0Q2vPS.cCezuqt6yvCJdbdXbxJeV6LllkOGGW8XWVJz7UpHrPOH364620mY5EH/";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCenwvQ4fQAH6MC4FCDsRHwE83gl+vS7cv1FD8DgpqTEL4ob9gU5KLwdp5hhf4fauVgToNjft0T4GeC5iHFw6efJ3TVE8XhXin3FRvJFNV1Rl6gAqynpAWfXxzCMDIg0TYXXI3e4+ePYk2GcJAxfbTDUycydpYWFvqiqPcyyt5/7POOV39fOvoMDBc1r9vtyTJQVCb/DP+a6SqlRosSZMU/KhnQyfOE/Bmk6OwQlbn02CAFNWHw1VEaNs2b0YBcCXAhdZBHbbcjIXSO1mh2Xs4w4vRTTZhmsZyUSKXV38es+TzioqUrKEjsWJi/DQuAkhxWjWKx9YaY/6sxIirtThXz cardno:000606352946"
      ];
      isNormalUser = true;
      home = "/home/nixos";
      shell = pkgs.bashInteractive;
      extraGroups = [ "wheel" "networkmanager" ];
    };
    groups.media = { };
  };

  environment.systemPackages = with pkgs; [ p7zip vim ffmpeg_with_aac git ];

  system.stateVersion = "21.11";
}
