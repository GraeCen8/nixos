{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nix/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  # Auto-generate from folders in the dotfiles directory
  configs = pkgs.lib.filterAttrs (name: type: type == "directory")
    (builtins.readDir dotfiles);
in

{
  home.username = "grae";
  home.homeDirectory = "/home/grae";
  programs.git = {
    enable = true;
    extraConfig.credential."https://github.com".helper =
      "!f() { gh auth git-credential \"$@\"; }; f";
  };
  home.stateVersion = "25.05";

  home.file.".zshenv".text = "export ZDOTDIR=\"$HOME/.config/zsh\"";

  gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      name = "rose-pine";
      package = pkgs.rose-pine-gtk-theme;
    };
    iconTheme = {
      name = "rose-pine";
      package = pkgs.rose-pine-icon-theme;
    };
    cursorTheme = {
      name = "rose-pine-cursor";
      package = pkgs.rose-pine-cursor;
      size = 24;
    };
    gtk4.theme = config.gtk.theme;
  };

  xdg.configFile = builtins.mapAttrs
    (name: _: {
      source = create_symlink "${dotfiles}/${name}";
      recursive = true;
    })
    configs;

  home.packages = with pkgs; [
    # Core utilities
    bat
    eza
    fzf
    ripgrep
    zoxide
    zathura
    yazi
    # Development tools
    clang
    clang-tools
    nil
    nodejs
    nixpkgs-fmt
    opencode
    pi-coding-agent
    taplo
    neovim
    helix
    lazygit
    github-cli
    # Apps
    rofi
    imv
    mpv
    cliamp
    localsend
    # Terminal
    (pkgs.st.overrideAttrs (old: {
      src = ./config/st;
      patches = [ ];
      preBuild = "make clean";
      buildInputs = old.buildInputs ++ [
        pkgs.harfbuzz
      ];
    }))

    alacritty
    # Wayland apps
    niri
    noctalia-shell
    grim
    slurp
    wl-clipboard
    xwayland-satellite
    # Notification daemon
    # (dunst removed: noctalia-shell already provides notifications,
    # and the dunst user service was inactive)
    # Brightness/screen control
    brightnessctl
    # Video processing etc
    ffmpeg
    # Audio volume tools (pipewire service is system-wide;
    # the standalone pulseaudio package is redundant)
    pipewire
    pamixer
  ];

}
