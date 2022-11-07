{ pkgs, ... }: {
  disabledModules = [ "virtualisation/vmware-guest.nix" ];

  networking = {
    hostName = "vm";
    wireless.enable = false;
  };

  virtualisation = {
    vmware.guest.enable = true;
  };

  services.xserver = {
    resolutions = [{
      x = 1920;
      y = 1440;
    }];

    displayManager = {
      defaultSession = "none+i3";
    };
  };
}
