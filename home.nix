{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nix/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  # Auto-generate from folders in the dotfiles directory
  configs = pkgs.lib.filterAttrs (name: type: type == "directory")
    (builtins.readDir dotfiles);

  # Helium extensions as pinned local .crx files.
  # Helium sinkholes Google's extension update service, so policy
  # force-install (ExtensionInstallForcelist) can never download
  # anything. Instead we fetch the store-signed .crx at build time
  # (nix has no trouble reaching clients2.google.com) and pre-install
  # via Chromium's "external extensions" mechanism, which installs
  # from a local file with no update check involved.
  # To bump an extension: update version below, then get the new hash with:
  #   nix store prefetch-file '<url>'
  # Vimium (keyboard navigation), v2.4.2
  vimiumCrx = pkgs.fetchurl {
    name = "vimium-2.4.2.crx";
    url = "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=153.0.8010.52&acceptformat=crx2,crx3&x=id%3Ddbepggeogbaibhgnhhndojpepiihcmeb%26installsource%3Dondemand%26uc";
    hash = "sha256-MZjCaqcZvkYt6lhQUPvtm4uAYo1X6oihE7q/UzTFUXw=";
  };
  # Rose Pine (base) theme, v2.0.0
  rosePineCrx = pkgs.fetchurl {
    name = "rose-pine-2.0.0.crx";
    url = "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=153.0.8010.52&acceptformat=crx2,crx3&x=id%3Dnoimedcjdohhokijigpfcbjcfcaaahej%26installsource%3Dondemand%26uc";
    hash = "sha256-+2gF/jQQnU8+BPzjUGCp6iB6jCtWlk3wMTzXZZL++Rs=";
  };
in

{
  home.username = "grae";
  home.homeDirectory = "/home/grae";
  programs.git = {
    enable = true;
    settings.credential."https://github.com".helper =
      "!f() { gh auth git-credential \"$@\"; }; f";
  };
  home.stateVersion = "25.05";

  home.file.".zshenv".text = "export ZDOTDIR=\"$HOME/.config/zsh\"";

  # Declarative Helium extensions: external-install JSONs pointing at
  # the pinned .crx files above. Helium picks these up on startup
  # (needs one browser restart after rebuild).
  home.file.".config/net.imput.helium/External Extensions/dbepggeogbaibhgnhhndojpepiihcmeb.json".text = builtins.toJSON {
    external_crx = "${vimiumCrx}";
    external_version = "2.4.2";
  };
  home.file.".config/net.imput.helium/External Extensions/noimedcjdohhokijigpfcbjcfcaaahej.json".text = builtins.toJSON {
    external_crx = "${rosePineCrx}";
    external_version = "2.0.0";
  };

  # gtk = {
  #   enable = true;
  #   colorScheme = "dark";
  #   theme = {
  #     name = "rose-pine";
  #     package = pkgs.rose-pine-gtk-theme;
  #   };
  #   iconTheme = {
  #     name = "rose-pine";
  #     package = pkgs.rose-pine-icon-theme;
  #   };
  #   cursorTheme = {
  #     name = "rose-pine-cursor";
  #     package = pkgs.rose-pine-cursor;
  #     size = 24;
  #   };
  #   gtk4.theme = config.gtk.theme;
  # };

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
    # Terminal (Wayland native)
    foot

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
