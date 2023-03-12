
function link_dotfiles {
  echo "Linking dotfiles"

  ln -s $(pwd)/.zshrc ~/.zshrc
  ln -s $(pwd)/tmux.conf ~/.config/tmux/tmux.conf
  # ln -s $(pwd)/vim ~/.vim
  # ln -s $(pwd)/vimrc ~/.vimrc
  # ln -s $(pwd)/vimrc.bundles ~/.vimrc.bundles
  #
  # rm -rf $HOME/.config/nvim/init.vim
  # rm -rf $HOME/.config/nvim
  # rm -rf $HOME/.vim/bundle/*
  #
  # mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
  #
  # ln -s $(pwd)/vim $XDG_CONFIG_HOME/nvim
  # ln -s $(pwd)/vimrc $XDG_CONFIG_HOME/nvim/init.vim
  # ln -s $(pwd)/schemes/dracula.zsh-theme $HOME/.oh-my-zsh/themes/dracula.zsh-theme
  #
  # if [[ ! -f ~/.zshrc.local ]]; then
  #   echo "Creating .zshrc.local"
  #   touch ~/.zshrc.local
  # fi
}

while test $# -gt 0; 
do 
  case "$1" in
    --help)
      echo "Help"
      exit
      ;;
    --archlinux)
      install_archlinux
      backup
      link_dotfiles
      zsh
      source ~/.zshrc
      exit
      ;;
    --backup)
      backup
      exit
      ;;
    --dotfiles)
      link_dotfiles
      source ~/.zshrc
      exit
      ;;
  esac

  shift
done
