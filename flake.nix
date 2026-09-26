{
  description = "NixOS from Scratch";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    helium.url = "github:oxcl/nix-flake-helium-browser";
    helium.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, home-manager, helium, disko, ... }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Builds a NixOS system plus a matching standalone Home Manager config
      # (surfaced as `hm.<user>.activationPackage`, which the `hmr` alias uses).
      #
      # Per-machine facts (hostname, username, repo path) live in
      # configuration.nix and home.nix as plain constants rather than
      # specialArgs, so adding a machine means copying those two lines.
      mkHost =
        hostname: username: {
          inherit username;

          nixosSystem = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./configuration.nix
              ./disko.nix
              disko.nixosModules.default
              helium.nixosModules.default
              { nixpkgs.overlays = [ helium.overlays.default ]; }
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = import ./home.nix;
                home-manager.backupFileExtension = "backup";
              }
            ];
          };

          homeConfiguration = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ ./home.nix ];
          };
        };

      # The machines this repo targets. To add one, add a line and update the
      # hostname/username constants in configuration.nix and home.nix:
      #   other-host = mkHost "other-host" "someone";
      hosts = {
        nixos-btw = mkHost "nixos-btw" "grae";
      };

      # Throwaway minimal system, only used to bootstrap a fresh install from
      # the install ISO (which has no nixos-rebuild). Not a real host: no
      # hostname, no home-manager, no desktop. See README.md step 4.
      bootstrapSystem = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./bootstrap.nix
          ./disko.nix
          disko.nixosModules.default
        ];
      };
    in
    {
      nixosConfigurations = lib.mapAttrs (_: host: host.nixosSystem) hosts // {
        bootstrap = bootstrapSystem;
      };

      homeConfigurations = lib.mapAttrs (_: host: host.homeConfiguration) hosts;

      # Keyed by username (not hostname) so this matches the `hmr` alias:
      # nix run ~/nix#hm.grae.activationPackage
      hm = lib.mapAttrs' (
        _: host:
        lib.nameValuePair host.username {
          activationPackage = host.homeConfiguration.config.home.activationPackage;
        }
      ) hosts;

      packages.${system} = {
        # disko's CLI package is called `disko`; the binary inside is
        # `nixos-disks`. Exposed under a clearer name so the install step
        # works pinned to this repo's lock file:
        #   sudo nix run .#nixos-disks -- --mode destroy,format,mount --flake .#nixos-btw
        nixos-disks = disko.packages.${system}.disko;

        # `nix run ~/nix#rebuild` for the default host.
        rebuild = pkgs.writeShellApplication {
          name = "rebuild";
          runtimeInputs = [ pkgs.nix ];
          text = ''
            repo="''${DOTFILES_DIR:-$HOME/nix}"
            # `sudo env`, not a bare export: sudo scrubs the environment, and
            # home.nix reads DOTFILES_DIR via builtins.getEnv under --impure.
            exec sudo env "DOTFILES_DIR=$repo" nixos-rebuild switch --impure \
              --flake "$repo#${builtins.head (builtins.attrNames hosts)}" "$@"
          '';
        };
      };

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
