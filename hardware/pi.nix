{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  hardware.enableRedistributableFirmware = true;

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = false;

      raspberryPi = {
        enable = true;
        version = 4;
      };
    };

    kernel.sysctl."net.ipv4.ip_forward" = 1;
    kernelPackages = pkgs.linuxPackages_rpi4;
    kernelParams =
      [ "8250.nr_uarts=1" "console=ttyAMA0,115200" "console=tty1" ];

    initrd.availableKernelModules = [ "usb_storage" "usbhid" ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      neededForBoot = true;
      fsType = "vfat";
    };

    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      neededForBoot = true;
      fsType = "ext4";
    };

    "/mnt/media" = {
      fsType = "ext4";
      device = "/dev/disk/by-label/media";
      neededForBoot = true;
      noCheck = true;
    };
  };

  swapDevices = [{ device = "/dev/disk/by-label/SWAP"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
