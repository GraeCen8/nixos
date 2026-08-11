# nixos conf

this is my _personal_ nixos config and should be fine to work on intel machine
but is portable enough to work on almost any hardware

## features

the main config uses:

- ly as a display manager
- niri as a windowmanager.
- fish is used as the shell of choice.
- nautilus for file manager.
- librewolf browser.
- fuzzel for apps

the rest of the config is almost entirely swappable. for example:

- for editor you can you nvim or helix
- for top bar: waybar, quickshell, noctalia

there is also a power menu on laptops with the command:

```fish
power-menu
```

opencode is used for agents. and there is a AGENTS.md file in the config

read niri keybinds that show at startup for niri keybindings

there are  multiple nvim  configs  which you can swap between in configuration.nix per host 

## themes

there are many themes you can use like:

- 'minimal'
- 'rose-pine'
- 'catpuccin-mocha'
- 'tokyo-night'
- 'nord'

the themes affect the look of the following apps after a rebuild

- nvim
- helix
- alacritty
- waybar
- noctalia
- mako
- niri
- ly (some)
- btop
- nautilus
- librewolf
- fuzzel
- probably more :)

all themes also have there own backrounds with can be swappable with a Ctrl+N
and you can choose which opens at startup in ./themes-data.nix

## looks

good

![desktop-minimal](desktop-minimalist.png)

## other

issues: <gceney7@gmail.com>
have fun!
