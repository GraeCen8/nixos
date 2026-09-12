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

  xdg.configFile = builtins.mapAttrs
    (name: _: {
      source = create_symlink "${dotfiles}/${name}";
      recursive = true;
    })
    configs;

  home.packages = with pkgs; [
    (pkgs.st.overrideAttrs (old: {
      src = ./config/st;
      patches = [ ];
      preBuild = "make clean";
      buildInputs = old.buildInputs ++ [ pkgs.harfbuzz ];
    }))

    neovim
    helix
    ripgrep
    localsend
    nil
    taplo
    nixpkgs-fmt
    opencode
    lazygit
    nodejs
    rofi
    xwallpaper
    fzf
    zoxide
    eza
    github-cli
    clang
    clang-tools
  ];

}
