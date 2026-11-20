#!/usr/bin/env bash
# Symlink the configs in this repo into $HOME. Anything already at a target
# path is moved into ~/.dotfiles-backup/<timestamp>/ first, never deleted.
#
#   ./link.sh             create links
#   ./link.sh --dry-run   show what would happen
#   ./link.sh --unlink    remove the links and restore the latest backup
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_ROOT="$HOME/.dotfiles-backup"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"

# "<path in repo>|<link location>"
LINKS=(
  "config/nvim|$CONFIG_HOME/nvim"
  "config/tmux/tmux.conf|$CONFIG_HOME/tmux/tmux.conf"
  "config/alacritty/alacritty.toml|$CONFIG_HOME/alacritty/alacritty.toml"
  "zsh/zshrc|$HOME/.zshrc"
  "config/git/config|$CONFIG_HOME/git/config"
)
# Paths that would silently override a link above; moved to the backup too.
SHADOWS=(
  "$HOME/.tmux.conf" # tmux reads this before ~/.config/tmux/tmux.conf
  "$HOME/.gitconfig" # git reads this after ~/.config/git/config, so it would win
)

DRY_RUN=0
log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
run() {
  if ((DRY_RUN)); then
    printf '    [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

pretty() { printf '%s' "${1/#"$HOME"/\~}"; }

# backup <path>: move it under $BACKUP_DIR at its full absolute path, so it
# can be restored exactly, wherever it lived (e.g. a custom XDG_CONFIG_HOME).
backup() {
  local dest="$BACKUP_DIR$1"
  log "backup  $(pretty "$1") -> $(pretty "$dest")"
  run mkdir -p "$(dirname "$dest")"
  run mv "$1" "$dest"
}

do_link() {
  local entry src dst
  for entry in "${LINKS[@]}"; do
    src="$DOTFILES/${entry%%|*}"
    dst="${entry#*|}"
    if [[ -L $dst && "$(readlink "$dst")" == "$src" ]]; then
      printf '    ok      %s\n' "$(pretty "$dst")"
      continue
    fi
    if [[ -e $dst || -L $dst ]]; then
      backup "$dst"
    fi
    log "link    $(pretty "$dst") -> $src"
    run mkdir -p "$(dirname "$dst")"
    run ln -s "$src" "$dst"
  done

  for dst in "${SHADOWS[@]}"; do
    if [[ -e $dst || -L $dst ]]; then
      backup "$dst"
    fi
  done

  post_link
}

# Files the configs import/source, which must exist but are not tracked.
post_link() {
  local local_toml="$CONFIG_HOME/alacritty/local.toml"
  if [[ ! -e $local_toml ]]; then
    log "create  $(pretty "$local_toml") (private alacritty settings, untracked)"
    run touch "$local_toml"
  fi
  if [[ ! -e $HOME/.zshrc.local ]]; then
    log "create  ~/.zshrc.local (private zsh settings, untracked)"
    run touch "$HOME/.zshrc.local"
  fi

  log "theme-switch (writes ~/.local/state/dotfiles/)"
  run "$DOTFILES/bin/theme-switch" auto

  local tpm="$CONFIG_HOME/tmux/plugins/tpm"
  if [[ -x $tpm/bin/install_plugins ]]; then
    log "tmux plugins"
    run "$tpm/bin/install_plugins" || true
  else
    log "tmux plugins skipped: TPM not found (./install.sh tpm)"
  fi

  log "Done. Open a new shell; first nvim start installs its plugins."
}

do_unlink() {
  local entry src dst latest=""
  if [[ -d $BACKUP_ROOT ]]; then
    latest="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d | sort | tail -1)"
  fi

  for entry in "${LINKS[@]}"; do
    src="$DOTFILES/${entry%%|*}"
    dst="${entry#*|}"
    if [[ -L $dst && "$(readlink "$dst")" == "$src" ]]; then
      log "unlink  $(pretty "$dst")"
      run rm "$dst"
    fi
  done

  if [[ -z $latest ]]; then
    log "No backup to restore."
    return
  fi
  log "restore from $(pretty "$latest")"
  local targets=() item
  for entry in "${LINKS[@]}"; do targets+=("${entry#*|}"); done
  targets+=("${SHADOWS[@]}")
  for dst in "${targets[@]}"; do
    item="$latest$dst"
    [[ -e $item || -L $item ]] || continue
    if [[ -e $dst || -L $dst ]]; then
      printf '    keep    %s (already exists)\n' "$(pretty "$dst")"
      continue
    fi
    run mkdir -p "$(dirname "$dst")"
    run mv "$item" "$dst"
    printf '    restore %s\n' "$(pretty "$dst")"
  done
}

case "${1:-}" in
  "") do_link ;;
  --dry-run)
    DRY_RUN=1
    do_link
    ;;
  --unlink) do_unlink ;;
  -h | --help) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//' ;;
  *)
    echo "unknown option: $1 (see --help)" >&2
    exit 2
    ;;
esac
