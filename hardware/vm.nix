{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ ];

  boot = {
    initrd = {
      availableKernelModules =
        [ "uhci_hcd" "xhci_pci" "ahci" "nvme" "usbhid" "sr_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];

    kernelPackages = pkgs.linuxPackages_5_15;
  };

  hardware = {
    enableRedistributableFirmware = true;
    video.hidpi.enable = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

    "/host" = {
      fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
      device = ".host:/";
      options = [
        "umask=22"
        "uid=1000"
        "gid=1000"
        "allow_other"
        "auto_unmount"
        "defaults"
      ];
    };
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];
}
