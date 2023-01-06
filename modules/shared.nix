{ pkgs, home-manager, ... }: {
  imports = [
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.samir = { pkgs, ... }: {
        xsession.windowManager.i3 = {
          package = pkgs.i3-gaps;
          enable = true;
          config = {
            modifier = "Mod4";
            bars = [ ];

            gaps = {
              inner = 10;
              outer = 0;
              smartGaps = true;
            };
          };
          extraConfig = ''
            for_window [class="^.*"] border pixel 0
          '';
        };

        home = {
          stateVersion = "22.05";
          pointerCursor.x11.enable = true;
          pointerCursor = {
            name = "Vanilla-DMZ";
            package = pkgs.vanilla-dmz;
          };

          file.".emacs.d" = {
            recursive = true;
            source = fetchGit {
              url = "https://github.com/syl20bnr/spacemacs";
              ref = "develop";
              rev = "acab040c72b918aef390f538d6725b29eaa3b17c";
            };
          };

          packages = with pkgs; [ xsel ];

          keyboard = { layout = "gb"; };
        };

        services.gpg-agent = {
          enable = true;
          defaultCacheTtl = 1800;
          enableSshSupport = true;
        };

        programs = {
          direnv = {
            enable = true;
            enableZshIntegration = true;
            nix-direnv.enable = true;
          };

          tmux = {
            enable = true;

            terminal = "screen-256color";

            keyMode = "vi";
            newSession = true;

            plugins = with pkgs; [
              tmuxPlugins.yank
              tmuxPlugins.copycat
              tmuxPlugins.sensible
              tmuxPlugins.logging
              tmuxPlugins.fingers
              tmuxPlugins.resurrect
              tmuxPlugins.vim-tmux-navigator
              tmuxPlugins.pain-control
              tmuxPlugins.sidebar
              {
                plugin = tmuxPlugins.continuum;
                extraConfig = ''
                  set -g @continuum-restore 'on'
                  set -g @continuum-save-interval '1' # minutes
                '';
              }
            ];

            extraConfig = ''
              bind -T copy-mode-vi y send -X copy-selection-and-cancel
              bind -T copy-mode-vi v send -X begin-selection

              set -g status-style bg=black,fg=green

              set -g window-status-current-style bg=green,fg=black
              set -g window-status-current-format "#I #W#{?window_flags,#{window_flags}, }"

              set -g window-status-style bg=black,fg=green
              set -g window-status-format "#I #W#{?window_flags,#{window_flags}, }"

              set -g window-status-activity-style fg=red
              set -g window-status-bell-style fg=yellow
            '';
          };

          fzf = {
            enable = true;
            enableZshIntegration = true;
          };

          zsh = {
            enable = true;

            shellAliases = { em = ''emacsclient -a "" -t''; };

            sessionVariables = {
              EDITOR = ''emacsclient -a "" -t'';
              VISUAL = ''emacsclient -a "" -t'';
              ZSH_TMUX_AUTOSTART = true;
            };

            enableAutosuggestions = true;
            enableCompletion = true;

            initExtra = ''
              source /home/samir/.config/op/plugins.sh
            '';

            plugins = [
              {
                name = "zsh-fast-syntax-highlighting";
                src =
                  "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
              }
              {
                name = "zsh-history-substring-search";
                src =
                  "${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search";
              }
              {
                name = "zsh-nix-shell";
                src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
              }
              {
                name = "zsh-you-should-use";
                src =
                  "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
              }
            ];

            oh-my-zsh = {
              enable = true;

              plugins = [ "git" "aws" "fzf" "tmux" "kubectl" ];

              theme = "amuse";
            };
          };

          i3status = {
            enable = false;

            modules = {
              ipv6.enable = false;
              "wireless _first_".enable = false;
              "ethernet _first_".enable = false;
              "battery all".enable = false;
            };
          };

          git = {
            enable = true;
            userName = "Samir Hafez";
            userEmail = "me@samirhafez.com";

            extraConfig = {
              magithub = {
                online = true;
                includesStatusHeader = true;
                includesPullRequestsSection = true;
                includesIssuesSection = true;
              };

              gitlab = { user = "SamirHafez"; };

              url."ssh://git@github.com/".insteadOf = "https://github.com/";

              safe.directory = [ "/etc/nixos" ];
            };

            signing = {
              key = "0xDECCA1848C330AFE";
              signByDefault = true;
            };
          };

          kitty = {
            enable = true;
            font = {
              name = "SauceCodePro Nerd Font Mono";
              size = 18;
            };
            settings = {
              hide_window_decorations = "yes";
              macos_option_as_alt = "no";
            };
          };
        };
      };
    }
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Europe/London";

  virtualisation = { docker.enable = true; };

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  services = {
    xserver = {
      enable = true;
      layout = "gb";

      desktopManager = {
        xterm.enable = false;
        wallpaper.mode = "fill";
      };

      displayManager = { lightdm.enable = true; };

      windowManager.i3.enable = true;
      windowManager.i3.package = pkgs.i3-gaps;
    };
  };

  programs.zsh.enable = true;

  users = {
    mutableUsers = false;
    users.samir = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "docker" ];
      hashedPassword =
        "$6$4JAiwSPiW.yHIJUd$ZuTx6mPPkx3/Yl9uB.fel7D1A23JJ48wEDeLMNgX2yWdqmrILY7d1YYfHH3tUeM0TPEyAI4hn3mAlXzp21Ji4.";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCenwvQ4fQAH6MC4FCDsRHwE83gl+vS7cv1FD8DgpqTEL4ob9gU5KLwdp5hhf4fauVgToNjft0T4GeC5iHFw6efJ3TVE8XhXin3FRvJFNV1Rl6gAqynpAWfXxzCMDIg0TYXXI3e4+ePYk2GcJAxfbTDUycydpYWFvqiqPcyyt5/7POOV39fOvoMDBc1r9vtyTJQVCb/DP+a6SqlRosSZMU/KhnQyfOE/Bmk6OwQlbn02CAFNWHw1VEaNs2b0YBcCXAhdZBHbbcjIXSO1mh2Xs4w4vRTTZhmsZyUSKXV38es+TzioqUrKEjsWJi/DQuAkhxWjWKx9YaY/6sxIirtThXz cardno:000606352946"
      ];
      shell = pkgs.zsh;
    };
  };

  environment = {

    systemPackages = with pkgs; [
      vim
      (emacs.override { toolkit = "lucid"; })
      pinentry
      pinentry-emacs
      git
      gnupg

      nixfmt

      ripgrep

      gtkmm3
      xclip

      gcc

      go
      gopls
      gopkgs
      gotests
      libcap

      python3
      pyright

      terraform
      terraform-ls

      kubectl
      kubectx
      kube3d

      jq
      openssl
    ];

    sessionVariables.TERMINAL = [ "kitty" ];
  };

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
}
