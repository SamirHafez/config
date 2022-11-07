{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      availableKernelModules =
        [ "xhci_pci" "ahci" "usb_storage" "uas" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  hardware = {
    enableRedistributableFirmware = true;

    cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;
    bluetooth = {
      enable = true;
      settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };
    };

    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraConfig = "\n      load-module module-switch-on-connect\n    ";
    };

    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
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
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
