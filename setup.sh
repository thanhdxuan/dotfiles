USER_CONFIG_DIR="~/.config"
NVIM_CONFIG_DIR="$USER_CONFIG_DIR/nvim"
ALACRITTY_CONFIG_DIR="$USER_CONFIG_DIR/alacritty"

mkdir -p $ALACRITTY_CONFIG_DIR
cp -r ./alacritty/* $ALACRITTY_CONFIG_DIR

# Setup alacritty themes
mkdir -p ~/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes

# Setup tmux
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux source ~/.tmux.conf

# RC files

cat ./.zshrc >> ~/.zshrc
cat ./auto_change_term_themes.sh >> ~/.zshrc
