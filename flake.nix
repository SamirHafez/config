{
  description = "NixOS Configuration";

  inputs = {
    #nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/bacbfd713b4781a4a82c1f390f8fe21ae3b8b95b";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, fenix }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./hardware-configuration.nix
        ./modules/vmware-guest.nix
        home-manager.nixosModule
        ({ pkgs, ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.samir = import ./samir.nix;

          nixpkgs.overlays = [ fenix.overlay ];

          nix = {
            package = pkgs.nixFlakes;
            extraOptions = ''
              experimental-features = nix-command flakes
            '';
          };

          disabledModules = [ "virtualisation/vmware-guest.nix" ];

          hardware.video.hidpi.enable = true;

          boot.kernelPackages = pkgs.linuxPackages_5_15;
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          networking.useDHCP = false;
          networking.interfaces.ens160.useDHCP = true;
          networking.hostName = "nixos";
          networking.wireless.enable = false;

          time.timeZone = "Europe/London";

          virtualisation.docker.enable = true;
          virtualisation.vmware.guest.enable = true;

          i18n.defaultLocale = "en_US.UTF-8";
          console = {
            font = "Lat2-Terminus16";
            keyMap = "us";
          };

          services.xserver = {
            enable = true;

            layout = "gb";
            xkbModel = "pc105";
            xkbVariant = "mac";

            resolutions = [{
              x = 2560;
              y = 1600;
            }];
            dpi = 227;
            #dpi = 82;

            desktopManager = {
              xterm.enable = false;
              wallpaper.mode = "scale";
            };

            displayManager = {
              defaultSession = "none+i3";
              lightdm.enable = true;
            };

            windowManager.i3.enable = true;
          };

          programs.zsh.enable = true;

          users= {
            mutableUsers = false;
            users.samir = {
              isNormalUser = true;
              extraGroups = [ "wheel" "networkmanager" ];
              hashedPassword = "$6$4JAiwSPiW.yHIJUd$ZuTx6mPPkx3/Yl9uB.fel7D1A23JJ48wEDeLMNgX2yWdqmrILY7d1YYfHH3tUeM0TPEyAI4hn3mAlXzp21Ji4.";
              shell = pkgs.zsh;
            };
          };

          environment.systemPackages = let
            my-cookies = pkgs.python3.pkgs.buildPythonApplication rec {
              pname = "my_cookies";
              version = "0.1.2";

              src = pkgs.python3.pkgs.fetchPypi {
                inherit pname version;
                sha256 = "sha256-RvDt/FCLzBF9uT51jupyzOM/fz2KltBg8v0J0Fw8O4M=";
              };

              propagatedBuildInputs = with pkgs.python3.pkgs; [
                browser-cookie3
              ];
            };
          in with pkgs; [
            vim
            emacs
            pinentry
            pinentry-emacs
            git
            gnupg

            nixfmt
            ripgrep

            gtkmm3
            xclip

            gcc

            (fenix.packages.${system}.complete.withComponents [
              "cargo"
              "clippy"
              "rust-src"
              "rustc"
              "rustfmt"
            ])
            rust-analyzer-nightly

            go
            gopls
            libcap

            python3 pyright my-cookies
          ];

          environment.sessionVariables.TERMINAL = [ "kitty" ];

          fileSystems."/host" = {
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

          fonts.fonts = with pkgs;
            [ (nerdfonts.override { fonts = [ "SourceCodePro" ]; }) ];

          system.stateVersion = "22.05";
        })
      ];
    };
  };
}
