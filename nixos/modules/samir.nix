{ config, pkgs, ... }:
{
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

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3GapsSupport = true;
      alsaSupport = true;
      iwSupport = true;
    };
    script = "polybar bar &";
    extraConfig = ''
      [bar/bar]
      width = 100%
      height = 18pt
      radius = 6

      line-size = 3pt

      border-size = 4pt
      border-color = #00000000

      padding-left = 0
      padding-right = 1

      module-margin = 1

      separator = |

      font-0 = monospace;2

      modules-left = xworkspaces xwindow
      modules-right = filesystem pulseaudio memory cpu wlan date

      cursor-click = pointer
      cursor-scroll = ns-resize

      enable-ipc = true

      tray-position = right

      wm-restack = i3

      [module/xworkspaces]
      type = internal/xworkspaces

      label-active = %name%
      label-active-background = #373B41
      label-active-padding = 1

      label-occupied = %name%
      label-occupied-padding = 1

      label-urgent = %name%
      label-urgent-padding = 1

      label-empty = %name%
      label-empty-padding = 1

      [module/xwindow]
      type = internal/xwindow
      label = %title:0:60:...%

      [module/filesystem]
      type = internal/fs
      interval = 25

      mount-0 = /

      label-mounted = %{F#F0C674}%mountpoint%%{F-} %percentage_used%%

      label-unmounted = %mountpoint% not mounted

      [module/pulseaudio]
      type = internal/pulseaudio

      format-volume-prefix = "VOL "
      format-volume = <label-volume>

      label-volume = %percentage%%

      label-muted = muted

      [module/memory]
      type = internal/memory
      interval = 2
      format-prefix = "RAM "
      label = %percentage_used:2%%

      [module/cpu]
      type = internal/cpu
      interval = 2
      format-prefix = "CPU "
      label = %percentage:2%%

      [network-base]
      type = internal/network
      interval = 5
      format-connected = <label-connected>
      format-disconnected = <label-disconnected>
      label-disconnected = %{F#F0C674}%ifname%%{F#707880} disconnected

      [module/wlan]
      inherit = network-base
      interface-type = wireless
      label-connected = %{F#F0C674}%ifname%%{F-} %essid% %local_ip%

      [module/date]
      type = internal/date
      interval = 1

      date = %H:%M
      date-alt = %Y-%m-%d %H:%M:%S

      label = %date%

      [settings]
      screenchange-reload = true
      pseudo-transparency = false
    '';
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

      plugins = [
        {
          name = "zsh-fast-syntax-highlighting";
          src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
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
          src = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
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
      settings = { hide_window_decorations = "yes"; };
    };
  };
}
