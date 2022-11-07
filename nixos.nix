{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  networking = {
    hostName = "nixos";
    networkmanager = { enable = true; };
  };

  services.blueman.enable = true;

  services.xserver = {
    videoDrivers = [ "intel" ];
    deviceSection = ''
      Option "DRI" "2"
      Option "TearFree" "true"
    '';

    desktopManager = {
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    displayManager = { defaultSession = "xfce+i3"; };
  };

  environment.systemPackages = with pkgs; [ wally-cli firefox zoom-us ];
}
