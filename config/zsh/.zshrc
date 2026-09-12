# source global shell alias & variables files
[ -f "$XDG_CONFIG_HOME/shell/alias" ] && source "$XDG_CONFIG_HOME/shell/alias"
[ -f "$XDG_CONFIG_HOME/shell/vars" ] && source "$XDG_CONFIG_HOME/shell/vars"

# load modules
zmodload zsh/complist
autoload -U compinit && compinit
autoload -U colors && colors
# autoload -U tetris # main attraction of zsh, obviously


# cmp opts
zstyle ':completion:*' menu select # tab opens cmp menu
zstyle ':completion:*' special-dirs true # force . and .. to show in cmp menu
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33 # colorize cmp menu
# zstyle ':completion:*' file-list true # more detailed list
zstyle ':completion:*' squeeze-slashes false # explicit disable to allow /*/ expansion

# main opts
setopt append_history inc_append_history share_history # better history
# on exit, history appends rather than overwrites; history is appended as soon as cmds executed; history shared across sessions
setopt auto_menu menu_complete # autocmp first menu match
setopt autocd # type a dir to cd
setopt auto_param_slash # when a dir is completed, add a / instead of a trailing space
setopt no_case_glob no_case_match # make cmp case insensitive
setopt globdots # include dotfiles
setopt extended_glob # match ~ # ^
setopt interactive_comments # allow comments in shell
unsetopt prompt_sp # don't autoclean blanklines
stty stop undef # disable accidental ctrl s

# history opts
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE="$XDG_CACHE_HOME/zsh_history" # move histfile to cache
HISTCONTROL=ignoreboth # consecutive duplicates & commands starting with space are not saved


# fzf setup
source <(fzf --zsh) # allow for fzf history widget


# binds
bindkey "^a" beginning-of-line
bindkey "^e" end-of-line
bindkey "^k" kill-line
bindkey "^j" backward-word
bindkey "^k" forward-word
bindkey "^H" backward-kill-word
# ctrl J & K for going up and down in prev commands
bindkey "^J" history-search-forward
bindkey "^K" history-search-backward
bindkey '^R' fzf-history-widget


# open fff file manager with ctrl f
# openfff() {
#  fff <$TTY
#  zle redisplay
#}
#zle -N openfff
#bindkey '^f' openfff


# set up prompt (Rosé Pine dark sections, no time, ends with space)
NEWLINE=$'\n'
PROMPT="${NEWLINE}%K{#26233a}%F{#ebbcba} %n %K{#1f1d2e}%F{#9ccfd8} %~ %f%k "
# PROMPT="${NEWLINE}%K{#2E3440}%F{#E5E9F0}$(date +%_I:%M%P) %K{#3b4252}%F{#ECEFF4} %n %K{#4c566a} %~ %f%k ❯ " # nord theme (old, had time + ❯)
# PROMPT="${NEWLINE}%K{#32302f}%F{#d5c4a1} $0 %K{#3c3836}%F{#d5c4a1} %n %K{#504945} %~ %f%k ❯ " # warmer theme
# PROMPT="${NEWLINE}%K{$COL0}%F{$COL1}$(date +%_I:%M%P) %K{$COL0}%F{$COL2} %n %K{$COL3} %~ %f%k ❯ " # pywal colors, from postrun script

# echo -e "${NEWLINE}\033[48;2;46;52;64;38;2;216;222;233m $0 \033[0m\033[48;2;59;66;82;38;2;216;222;233m $(uptime -p | cut -c 4-) \033[0m\033[48;2;76;86;106;38;2;216;222;233m $(uname -r) \033[0m" # nord theme
# echo -e "${NEWLINE}\x1b[38;5;137m\x1b[48;5;0m it's$(date +%_I:%M%P) \x1b[38;5;180m\x1b[48;5;0m $(uptime -p | cut -c 4-) \x1b[38;5;223m\x1b[48;5;0m $(uname -r) \033[0m" # warmer theme

# fish-like autocomplete toggle (1=on, 0=off)
FISH_AUTOSUGGEST=1
if (( FISH_AUTOSUGGEST )); then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6e6a86' # Rosé Pine muted
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  _autosuggest_src="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -f "$_autosuggest_src" ]] || _autosuggest_src="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -f "$_autosuggest_src" ]] || _autosuggest_src="/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  if [[ -f "$_autosuggest_src" ]]; then
    source "$_autosuggest_src"
    bindkey '^F' autosuggest-accept # ctrl-f accepts ghost text like fish
    bindkey '^ ' forward-word # ctrl-space accepts next word
  else
    echo "zsh-autosuggestions not found (FISH_AUTOSUGGEST=1 but no plugin file)" >&2
  fi
  unset _autosuggest_src
fi

# syntax highlighting (guarded: old hardcoded path doesn't exist on Arch)
for _hl_src in \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
; do
  if [[ -f "$_hl_src" ]]; then
    source "$_hl_src"
    break
  fi
done
unset _hl_src 2>/dev/null

# --- fish ports: zoxide + aliases (non-git) + helpers ---
: ${EDITOR:=nvim}; export EDITOR

# zoxide (replaces fish `zoxide init fish | source`)
eval "$(zoxide init zsh)"

# --- aliases (ported from fish conf.d/aliases.fish, git ones skipped) ---
# File system
alias ls='eza --group-directories-first --icons=auto'
alias l="ls -l"
alias la='eza -a --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias tree='eza --tree --level=2 --long --icons --git'
alias cat='bat --paging=never'
alias grep='rg'
alias find='fd'

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias c='opencode'
alias cx='printf "\033[2J\033[3J\033[H" && claude --permission-mode bypassPermissions'
alias d='docker'
alias r='rails'
alias vim='nvim'

# nix helpers
alias hmr='nix run ~/nix#hm.grae.activationPackage'

# --- helpers (ported from fish conf.d/functions-helpers.fish) ---

ff() {
  fzf --preview 'bat --style=numbers --color=always {}'
}

eff() {
  local editor="${EDITOR:-nvim}"
  local file
  file="$(ff)" || return
  [[ -n "$file" ]] && "$editor" "$file"
}



# --- system (ported from fish conf.d/functions-system.fish) ---
nrs() {
  local hostname="$1"
  [[ "$hostname" == :* ]] && hostname="#${hostname#:}"
  bash -c "sudo nixos-rebuild switch --flake /home/grae/nixos$hostname |& nom"
}

qmk-swap() {
  if [[ "$1" == --new ]]; then
    command -v qmk >/dev/null || { echo "qmk is not installed yet. Add it to dev-tools.nix and rebuild first."; return 1; }
    qmk c2json -kb silakka54 -km default > silakka54-keymap.json \
      && echo "Wrote silakka54-keymap.json from the stock keymap. Edit the 'layers' arrays, then run: qmk-swap silakka54-keymap.json" \
      || echo "Failed to generate the template. Is qmk_firmware set up? Run: qmk setup"
    return
  fi

  if (( $# != 1 )); then
    echo "Usage: qmk-swap <keymap.json>"
    echo "       qmk-swap --new   (generate a starter silakka54 keymap.json)"
    return 1
  fi

  local file="$1"
  [[ -f "$file" ]] || { echo "File not found: $file"; return 1; }
  command -v qmk >/dev/null || { echo "qmk is not installed yet. Add it to dev-tools.nix and run: sudo nixos-rebuild switch --flake /home/grae/nixos#<host>"; return 1; }

  local qmk_home
  qmk_home="$(qmk config user.qmk_home 2>/dev/null | sed 's/^user\.qmk_home=//')"
  [[ -z "$qmk_home" ]] && qmk_home="$HOME/qmk_firmware"
  if [[ ! -d "$qmk_home" ]]; then
    echo "qmk_firmware is not set up yet. Run: qmk setup"
    echo "(This clones qmk_firmware to $qmk_home and checks the build toolchain.)"
    return 1
  fi

  echo "Compiling $file..."
  qmk compile "$file" || { echo "Compile failed. Fix the errors above (or run: qmk doctor -n)."; return 1; }

  local uf2
  uf2="$(ls -t "$qmk_home"/.build/*.uf2 2>/dev/null | head -n 1)"
  if [[ -z "$uf2" ]]; then
    echo "No .uf2 firmware was produced in $qmk_home/.build — something went wrong."
    return 1
  fi
  echo "Built: $uf2"

  local side mount m i confirm
  for side in LEFT RIGHT; do
    mount=""
    echo ""
    echo "=== Flashing $side half ==="
    while [[ -z "$mount" ]]; do
      echo "1. Unplug the keyboard from USB."
      echo "2. On the $side half, HOLD the BOOT button on the RP2040 Zero."
      echo "3. Plug the USB cable into that half while holding BOOT, then release."
      echo "   It should show up as a 'RPI-RP2' USB drive."
      read "confirm?Press Enter when the drive is visible (or type abort): "
      if [[ "$confirm" == abort ]]; then
        echo "Aborted."
        return 1
      fi
      for i in $(seq 1 15); do
        m="$(lsblk -rno LABEL,MOUNTPOINT 2>/dev/null | grep -P -o '^RPI-RP2\s+\K.+')"
        if [[ -n "$m" && -d "$m" ]]; then
          mount="$m"
          break
        fi
        sleep 1
      done
      [[ -z "$mount" ]] && echo "Could not find the RPI-RP2 drive. Try again (hold BOOT while plugging in)."
    done
    echo "Found: $mount"
    echo "Copying firmware..."
    cp "$uf2" "$mount/"
    sync
    for i in $(seq 1 15); do
      [[ -d "$mount" ]] || break
      sleep 1
    done
    echo "$side half flashed."
  done

  echo ""
  echo "Done! Both halves should now run the new layout."
  echo "If keys are swapped/missing, check handedness: the half plugged into USB is the left side by default."
}

t() {
  local session
  session="$(basename "$PWD")"
  tmux attach -t "$session" 2>/dev/null || tmux new -s "$session"
}
