# dotfiles

Configs for **nvim** (NvChad), **tmux**, **alacritty** and **zsh** (oh-my-zsh). They are symlinked into place, so editing a file in `~/.config` edits this repo directly.

## Layout

| Repo path | Linked to |
|---|---|
| `config/nvim/` | `~/.config/nvim` |
| `config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` |
| `config/alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` |
| `zsh/zshrc` | `~/.zshrc` |
| `config/git/config` | `~/.config/git/config` (`~/.gitconfig` is moved aside, since it would override it) |
| `bin/` | on `PATH` via zshrc |

## Prerequisites

- `curl`
- `git`
- `tar`
- `sudo`, plus `pacman`, `apt-get` or `dnf` on Linux, or Homebrew on macOS

## Get started

```sh
git clone git@github.com:thanhdxuan/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh          # tools: zsh, tmux, alacritty, ripgrep, nvim, oh-my-zsh, fzf, font, TPM, alacritty themes
./link.sh --dry-run   # preview
./link.sh             # link configs (existing files go to ~/.dotfiles-backup/)
```

Then:

1. Open a new shell.
2. Start `nvim` so lazy.nvim installs the plugins, then run `:MasonInstallAll`.
3. In tmux, press `prefix + I` if the plugins are missing. The prefix is `C-a`.

To run only some install steps: `./install.sh nvim font`.

## Fonts

Drop font files into `fonts/`, then run `./install.sh font`. You can add `.zip` archives (their `.ttf`/`.otf` files are extracted) or loose `.ttf`/`.otf` files. Fonts install for your user only: `~/.local/share/fonts/` on Linux, `~/Library/Fonts/` on macOS. Alacritty uses **CaskaydiaMono Nerd Font** from `fonts/CascadiaMono.zip`.

## Private and machine-specific settings

These files are untracked. `link.sh` creates them empty:

- `~/.zshrc.local`: aliases with passwords, paths that only exist on this machine, `export THEME_TZ=...`.
- `~/.config/alacritty/local.toml`: e.g. `[env]` variables.

## Light/dark theme

`bin/theme-switch [auto|light|dark]` switches nvim and alacritty together. `auto` uses light from 08:00 to 18:00 in `THEME_TZ` (default `Asia/Ho_Chi_Minh`). zshrc runs `theme-switch auto` on every new shell, and it does nothing if the theme is already right. Override the hours and themes with the variables at the top of the script.

The current theme is stored in `~/.local/state/dotfiles/`, not in the repo, so switching never shows up in `git status`.

## Clean up

Backups made by `link.sh` collect in `~/.dotfiles-backup/<timestamp>/`. Delete the old ones when you no longer need them:

```sh
rm -rf ~/.dotfiles-backup
```

## Uninstall

```sh
./link.sh --unlink   # removes the links and restores the most recent backup
```

Installed tools are left in place.
