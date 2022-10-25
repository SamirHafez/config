{ nixpkgs, home-manager, fenix }:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./thinkpad-t470-hardware.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.samir = import ./modules/samir.nix;
    }
    ({ pkgs, ... }: {
      nixpkgs.overlays = [ fenix.overlay ];
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.packageOverrides = pkgs: {
        vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
      };

      nix = {
        package = pkgs.nixFlakes;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };

      boot = {
        kernelPackages = pkgs.linuxPackages_latest;
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
      };

      networking = {
        hostName = "nixos";
        networkmanager = { enable = true; };
      };

      time.timeZone = "Europe/London";

      virtualisation = { docker.enable = true; };

      i18n.defaultLocale = "en_US.UTF-8";
      console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
      };

      services.xserver.videoDrivers = [ "intel" ];
      services.xserver.deviceSection = ''
        Option "DRI" "2"
        Option "TearFree" "true"
      '';

      services.blueman.enable = true;

      services.xserver = {
        enable = true;
        dpi = 111;

        layout = "gb";

        desktopManager = {
          xterm.enable = false;
          wallpaper.mode = "scale";
          xfce = {
            enable = true;
            noDesktop = true;
            enableXfwm = false;
          };
        };

        displayManager = {
          defaultSession = "xfce+i3";
          lightdm.enable = true;
        };

        windowManager.i3.enable = true;
        windowManager.i3.package = pkgs.i3-gaps;
      };

      programs.zsh.enable = true;

      users = {
        mutableUsers = false;
        users.samir = {
          isNormalUser = true;
          extraGroups = [ "wheel" "networkmanager" "docker" ];
          hashedPassword =
            "$6$4JAiwSPiW.yHIJUd$ZuTx6mPPkx3/Yl9uB.fel7D1A23JJ48wEDeLMNgX2yWdqmrILY7d1YYfHH3tUeM0TPEyAI4hn3mAlXzp21Ji4.";
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

          propagatedBuildInputs = with pkgs.python3.pkgs; [ browser-cookie3 ];
        };
      in with pkgs; [
        vim
        (emacs.override { toolkit = "lucid"; })
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
        gopkgs
        gotests
        libcap

        python3
        pyright
        my-cookies
        firefox
        zoom-us
        terraform
        terraform-ls
        kubectl
        kubectx
        kube3d
        dnsutils
        wally-cli
      ];

      environment.sessionVariables.TERMINAL = [ "kitty" ];

      fonts = {
        enableDefaultFonts = true;
        fonts = with pkgs;
          [ (nerdfonts.override { fonts = [ "SourceCodePro" ]; }) ];
        fontconfig = {
          defaultFonts = {
            serif = [ "DejaVu" ];
            sansSerif = [ "DejaVu" ];
            monospace = [ "SourceCodePro" ];
          };
        };
      };

      system.stateVersion = "22.05";
    })
  ];
}
