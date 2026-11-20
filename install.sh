#!/usr/bin/env bash
# Install the tools these dotfiles configure. Safe to re-run: every step skips
# whatever is already installed. Run ./link.sh afterwards to link the configs.
#
#   ./install.sh                 all steps
#   ./install.sh nvim font       only the given steps
#
# Steps: packages nvim omz fzf font tpm alacritty-themes
set -euo pipefail

NVIM_VERSION="${NVIM_VERSION:-v0.12.5}"
NVIM_MIN="0.11.0" # NvChad v2.5 needs >= 0.11
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
skip() { printf '    %s\n' "$*"; }
die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}
has() { command -v "$1" >/dev/null 2>&1; }

detect_platform() {
  case "$(uname -s)" in
    Linux*) OS=linux ;;
    Darwin*) OS=macos ;;
    *) die "unsupported OS: $(uname -s)" ;;
  esac
  case "$(uname -m)" in
    x86_64 | amd64) ARCH=x86_64 ;;
    arm64 | aarch64) ARCH=arm64 ;;
    *) die "unsupported architecture: $(uname -m)" ;;
  esac
}

# clone_once <url> <dir>
clone_once() {
  if [[ -d $2/.git ]]; then
    skip "$2 already exists"
  else
    git clone --depth 1 "$1" "$2"
  fi
}

install_packages() {
  log "System packages (zsh, tmux, alacritty, ripgrep, ...)"
  case $OS in
    macos)
      has brew || die "Homebrew is missing: https://brew.sh"
      brew install zsh tmux ripgrep
      # brew install --cask alacritty
      ;;
    linux)
      if has pacman; then
        sudo pacman -S --needed --noconfirm zsh tmux alacritty ripgrep git curl tar unzip fontconfig
      elif has apt-get; then
        sudo apt-get update
        sudo apt-get install -y zsh tmux alacritty ripgrep git curl tar unzip fontconfig
      elif has dnf; then
        sudo dnf install -y zsh tmux alacritty ripgrep git curl tar unzip fontconfig
      else
        die "unsupported package manager; install zsh tmux alacritty ripgrep manually"
      fi
      ;;
  esac
}

# Prebuilt release tarball -> ~/.local/opt/nvim-<ver>, with ~/.local/bin/nvim
# linked to it. The whole tree is kept: the binary needs share/nvim/runtime.
install_nvim() {
  log "Neovim $NVIM_VERSION"
  if has nvim; then
    local current
    current="$(nvim --version | head -1 | sed -E 's/^NVIM v([0-9.]+).*/\1/')"
    if [[ "$(printf '%s\n' "$NVIM_MIN" "$current" | sort -V | head -1)" == "$NVIM_MIN" ]]; then
      skip "nvim $current already installed (>= $NVIM_MIN)"
      return
    fi
    skip "nvim $current is older than $NVIM_MIN, installing $NVIM_VERSION to ~/.local"
  fi

  local name="nvim-$OS-$ARCH"
  local dest="$HOME/.local/opt/nvim-$NVIM_VERSION"
  local tmp
  tmp="$(mktemp -d)"

  curl -fsSL -o "$tmp/$name.tar.gz" \
    "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/$name.tar.gz"
  tar -xzf "$tmp/$name.tar.gz" -C "$tmp"
  [[ $OS == macos ]] && xattr -cr "$tmp/$name" # avoid Gatekeeper "unknown developer"

  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")" "$HOME/.local/bin"
  mv "$tmp/$name" "$dest"
  ln -sfn "$dest/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$tmp"
  skip "installed to $dest (make sure ~/.local/bin is on PATH; zshrc does this)"
}

install_omz() {
  log "oh-my-zsh"
  if [[ -d $HOME/.oh-my-zsh ]]; then
    skip "already installed"
    return
  fi
  # RUNZSH=no: don't drop into a new shell mid-script.
  # KEEP_ZSHRC=yes: don't replace ~/.zshrc (link.sh manages it).
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  if [[ "$(basename "${SHELL:-}")" != zsh ]]; then
    skip "make zsh your login shell with: chsh -s \"\$(command -v zsh)\""
  fi
}

install_fzf() {
  log "fzf"
  clone_once https://github.com/junegunn/fzf.git "$HOME/.fzf"
  # --no-update-rc: zshrc already sources ~/.fzf.zsh
  "$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
}

# Installs every font in the repo's fonts/ folder, for the current user only:
#   fonts/<Name>.zip       -> its .ttf/.otf files go to <font dir>/<Name>/
#   fonts/*.ttf, *.otf     -> copied to <font dir>/dotfiles/
# Re-running only replaces files that changed.
install_font() {
  log "Fonts from fonts/"
  local src="$DOTFILES/fonts" dest
  case $OS in
    linux) dest="${XDG_DATA_HOME:-$HOME/.local/share}/fonts" ;;
    macos) dest="$HOME/Library/Fonts" ;;
  esac

  shopt -s nullglob nocaseglob
  local zips=("$src"/*.zip) loose=("$src"/*.ttf "$src"/*.otf)
  shopt -u nullglob nocaseglob
  if ((${#zips[@]} + ${#loose[@]} == 0)); then
    skip "no fonts in $src"
    return
  fi
  has unzip || die "unzip is required (./install.sh packages)"

  local zip name
  for zip in "${zips[@]}"; do
    name="$(basename "${zip%.*}")"
    mkdir -p "$dest/$name"
    # -j: flatten folders, -u: only extract new/changed files, -qq: quiet
    unzip -j -u -qq "$zip" '*.ttf' '*.otf' '*.TTF' '*.OTF' -d "$dest/$name" 2>/dev/null ||
      [[ $? -eq 11 ]] # 11 = some patterns matched nothing (e.g. no .otf), which is fine
    skip "$(basename "$zip") -> $dest/$name"
  done
  if ((${#loose[@]})); then
    mkdir -p "$dest/dotfiles"
    cp -p "${loose[@]}" "$dest/dotfiles/"
    skip "${#loose[@]} loose font file(s) -> $dest/dotfiles"
  fi

  # Linux needs the font cache refreshed; macOS picks fonts up by itself.
  if [[ $OS == linux ]]; then
    has fc-cache || die "fc-cache is required (fontconfig; ./install.sh packages)"
    fc-cache -f "$dest" >/dev/null
  fi
}

install_tpm() {
  log "tmux plugin manager"
  clone_once https://github.com/tmux-plugins/tpm "$CONFIG_HOME/tmux/plugins/tpm"
}

install_alacritty_themes() {
  log "alacritty themes"
  clone_once https://github.com/alacritty/alacritty-theme "$CONFIG_HOME/alacritty/themes"
}

main() {
  detect_platform
  local steps=("$@")
  ((${#steps[@]})) || steps=(packages nvim omz fzf font tpm alacritty-themes)

  for step in "${steps[@]}"; do
    case $step in
      packages) install_packages ;;
      nvim) install_nvim ;;
      omz) install_omz ;;
      fzf) install_fzf ;;
      font) install_font ;;
      tpm) install_tpm ;;
      alacritty-themes) install_alacritty_themes ;;
      *) die "unknown step: $step" ;;
    esac
  done

  log "Done. Next: ./link.sh"
}

main "$@"
