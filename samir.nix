{ config, pkgs, ... }:

{
  xsession.windowManager.i3 = {
    enable = true;
    config = { modifier = "Mod4"; };
  };

  xsession.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
  };

  xresources.properties = { "Xft.dpi" = 227; };

  home.file.".emacs.d" = {
    recursive = true;
    source = fetchGit {
      url = "https://github.com/syl20bnr/spacemacs";
      ref = "develop";
      rev = "d366150139c2c3fa8b743f502efccd542e7a6f3a";
    };
  };

  home.packages = with pkgs; [ xsel ];

  home.keyboard = {
    layout = "gb";
    model = "pc105";
    variant = "mac";
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
      enable = true;

      modules = {
        ipv6.enable = false;
        "wireless _first_".enable = false;
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
      };

      signing = {
        key = "0xDECCA1848C330AFE";
        signByDefault = true;
      };
    };

    kitty = {
      enable = true;
      font = { name = "SauceCodePro Nerd Font Mono"; };
      settings = { hide_window_decorations = "yes"; };
    };
  };
}
