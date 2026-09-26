# nixos

Single-host NixOS config: niri + noctalia-shell on Wayland, Helium browser,
rosé-pine theme throughout. Partitioning is declarative via
[disko](https://github.com/nix-community/disko); dotfiles are symlinked into
`~/.config` by Home Manager, so editing them takes effect immediately with no
rebuild.

## Fresh install

Assumes a *wiped* machine. Boot the NixOS installer ISO and open a terminal.

The order matters: the disk layout and the system config are both defined in
this repo, so clone it before partitioning.

### 1. Clone this repo

Clone to `~/nix`. This is the path of least resistance — `home.nix` defaults to
it, and `config/noctalia/settings.json` references `~/nix/walls` by absolute
path.

```
git clone https://github.com/GraeCen8/nixos.git ~/nix
cd ~/nix
git config --global user.name "..."
git config --global user.email "..."
```

Other locations work if you `export DOTFILES_DIR=/path/to/repo` for every
rebuild, but you will also need to fix the wallpaper path in
`config/noctalia/settings.json`.

### 2. Check the disk

`disko.nix` names the target disk, and `nixos-disks` has no flag to override
it — that line is the single source of truth. If your disk is not `/dev/sda`,
edit it now.

```
grep -n 'device =' disko.nix
```

### 3. Wipe, format and mount

```
lsblk                                    # sanity check the target

sudo nix run .#nixos-disks -- --mode destroy,format,mount --flake .#nixos-btw
```

The layout comes from `disko.nix`: a 700M vfat `/boot` labelled `nixos-boot`
and an ext4 `/` labelled `nixos` filling the rest, GPT-partitioned. This also
mounts everything under `/mnt`, so the next step needs no manual mounting.

**This erases the whole device.** Point `disko.nix` at the wrong disk and you
lose it. Omit `--mode destroy` if you only want to format and mount.

### 4. Install a minimal system

The installer image has no `nixos-rebuild`, so install a stock single-user
config first. This deliberately does *not* use this repo yet.

```
sudo nixos-enter --root /mnt   # or: nixos-install
```

Inside the chroot:

```
mkdir -p /etc/nixos

# Pick up the real disk UUIDs of the partitions that were just created.
nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix

cat > /etc/nixos/configuration.nix <<'EOF'
{ ... }: {
  imports = [
    <nixpkgs/nixos/modules/profiles/minimal.nix>
    ./hardware-configuration.nix
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "grae" ];
  users.users.grae = {
    isNormalUser = true;
    initialPassword = "change-me";
    extraGroups = [ "wheel" ];
  };
  system.stateVersion = "25.05";
}
EOF

nixos-install --flake /etc/nixos#default
```

Reboot. You now have a working text-mode NixOS with `nixos-rebuild`.

### 5. Apply this config

```
cd ~/nix
sudo nixos-rebuild switch --impure --flake ~/nix#nixos-btw
```

`users.users.grae.initialPassword` in `configuration.nix` is the login password
for the `ly` screen and for `sudo`. It is committed in plaintext, so change it
(there is a `TODO` on it) before pushing anywhere public.

Reboot again to land in the graphical session (ly → niri → noctalia-shell).

### 6. First-boot checklist

- [ ] `gh auth login` — `programs.git` delegates GitHub auth to the `gh` CLI,
      so `git push` fails until this is done.
- [ ] Change `initialPassword` in `configuration.nix`, then `nrs`.
- [ ] Fix the display block in `config/niri/config.kdl` if the output is not
      `eDP-1` at `1920x1080@120.030` scale 2. Wrong values here mean no
      picture or a misplaced workspace.
- [ ] Paste `config/vimium/rose-pine.css` into Vimium's options page by hand
      (Appearance → Custom CSS). The file is symlinked, but Vimium reads it
      from its own profile, not from disk.
- [ ] `nix run ~/nix#hm.grae.activationPackage` (alias `hmr`) to apply Home
      Manager changes without a full system rebuild.

## Day-to-day

```
nrs              # sudo nixos-rebuild switch --impure --flake ~/nix#nixos-btw
nrs --flake .    # extra args pass through, e.g. nrs --rebuild
nrs :other-host  # target another machine
hmr              # home-manager only
```

`nrs` finds the repo by resolving its own symlinked path, so it keeps working
if you ever move the checkout.

To format the Nix files: `nix fmt`.

## Layout

| Path | Purpose |
|---|---|
| `flake.nix` | Entry point. `hosts` maps machine name to its NixOS system. |
| `configuration.nix` | System config: boot, bluetooth, niri/ly, Helium, users, packages. |
| `disko.nix` | Declarative partition layout, and the target disk. |
| `home.nix` | Home Manager: symlinks `config/*` into `~/.config/`, plus user packages. |
| `config/` | The dotfile tree. One subdirectory per `~/.config` entry. |
| `walls/` | Wallpapers. Not Nix-managed; referenced by absolute path. |

## Adding a machine

1. Add an entry to `hosts` in `flake.nix`:
   `other-host = mkHost "other-host" "someone";`
2. Update the `username` and `networking.hostName` constants in
   `configuration.nix` and `home.nix` to match.
3. Rebuild with `nrs :other-host`.

The per-machine constants live in the module files rather than in
`specialArgs` to keep the flake simple; that duplication is the main thing to
watch when adding a host.

## Known gaps

- `x86_64-linux` only.
- `config/dunst/` is orphaned — dunst was dropped in favour of noctalia-shell's
  own notifications.
- The GTK theme block in `home.nix` is commented out, so GTK apps use the
  default theme rather than rosé-pine.
- `config/nvim/lazy-lock.json` is gitignored, so plugin versions are unpinned.
- Several `config/nvim/plugin/lsp.lua` servers (`lua-language-server`,
  `intelephense`, and others) are not in `home.packages`; those LSPs will not
  start until they are added.
- `zsh-syntax-highlighting` is probed for at `/usr/share/zsh-syntax-highlighting/`
  in `.zshrc`, which does not exist on NixOS, so it never loads.
