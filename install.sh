#!bin/sh
#Author
#

function is_installed {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0;  }
  # return
  echo "$return_"
}

function install_archlinux {
  if [[ $OSTYPE != darwin* ]]; then
    return
  fi


  if [[ ! -d ~/.oh-my-zsh ]]; then
    echo "Installing oh-my-zsh"
    unset ZSH
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  fi

  if [ ! -d "$ZSH/custom/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions"
    git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH/custom/plugins/zsh-autosuggestions
  fi

  #if [ "$(is_installed ag)" == "0" ]; then
  #  echo "Installing The silver searcher"
  #  brew install the_silver_searcher
  #fi

#  if [ "$(is_installed fzf)" == "0" ]; then
    # echo "Installing fzf"
    # brew install fzf
    # /opt/homebrew/opt/fzf/install
  #fi

  if [ "$(is_installed tmux)" == "0" ]; then
    echo "Installing tmux"
    sudo pacman -S tmux
    #echo "Installing reattach-to-user-namespace"
    #brew install reattach-to-user-namespace
    #echo "Installing tmux-plugin-manager"
    #git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi

  if [ "$(is_installed git)" == "0" ]; then
    echo "Installing Git"
    sudo pacman -S git
  fi

  if [ "$(is_installed gh)" == "0" ]; then
    echo "Installing Github CLI"
    sudo pacman -S github-cli
  fi

  if [ "$(is_installed nvim)" == "0" ]; then
    echo "Install neovim"
    sudo pacman -S neovim
    if [ "$(is_installed pip3)" == "1" ]; then
      pip3 install neovim --upgrade
    fi

    #curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
}

function backup {
  echo "Backing up dotfiles"
  local current_date=$(date +%s)
  local backup_dir=dotfiles_$current_date

  mkdir ~/$backup_dir

  mv ~/.zshrc ~/$backup_dir/.zshrc
  mv ~/.tmux.conf ~/$backup_dir/.tmux.conf
  mv ~/.vim ~/$backup_dir/.vim
  mv ~/.vimrc ~/$backup_dir/.vimrc
  #mv ~/.vimrc.bundles ~/$backup_dir/.vimrc.bundles
}

function link_dotfiles {
  echo "Linking dotfiles"

  ln -s $(pwd)/.zshrc ~/.zshrc
  ln -s $(pwd)/tmux.conf ~/.config/tmux/tmux.conf
  ln -s $(pwd)/vim ~/.vim
  ln -s $(pwd)/vimrc ~/.vimrc
  ln -s $(pwd)/vimrc.bundles ~/.vimrc.bundles

  rm -rf $HOME/.config/nvim/init.vim
  rm -rf $HOME/.config/nvim
  rm -rf $HOME/.vim/bundle/*

  mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}

  ln -s $(pwd)/vim $XDG_CONFIG_HOME/nvim
  ln -s $(pwd)/vimrc $XDG_CONFIG_HOME/nvim/init.vim
  ln -s $(pwd)/schemes/dracula.zsh-theme $HOME/.oh-my-zsh/themes/dracula.zsh-theme

  if [[ ! -f ~/.zshrc.local ]]; then
    echo "Creating .zshrc.local"
    touch ~/.zshrc.local
  fi
}

while test $# -gt 0; 
do 
  case "$1" in
    --help)
      echo "Help"
      exit
      ;;
    --macos)
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
      exit
      ;;
  esac

  shift
done
