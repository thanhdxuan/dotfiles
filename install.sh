echo "Start installing tools ..."

detect_os_arch() {
    # Detect Operating System
    case "$(uname -s)" in
        Linux*)  os="linux" ;;
        Darwin*) os="macos" ;;
        *)       os="unknown" ;;
    esac

    # Detect Architecture
    case "$(uname -m)" in
        x86_64|amd64) arch="x86_64" ;;
        arm64|aarch64) arch="arm64" ;;
        *)             arch="unknown" ;;
    esac
    echo "${os}-${arch}"
}

install_nvim() {
  echo "> Installing Neovim ..."
  local local_target="$1"
  local nvim_archive="nvim-$(detect_os_arch).tar.gz"
  local url="https://github.com/neovim/neovim/releases/download/v0.12.3/$nvim_archive"
  curl -sSLf -o $local_target $url
  tar -xf $local_target/$nvim_archive -C $local_target
  cp "$local_target/nvim-$(detect_os_arch)/bin/nvim" ~/.local/bin/
  
}


install_nvchad() {
  echo "> Installing NvChad ..."
  git clone https://github.com/NvChad/starter ~/.config/nvim
  echo "\t ==>> Run :MasonInstallAll and :TSInstallAll command after lazy.nvim finishes downloading plugins."
}

install_omz() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_ripgrep() {

}

install_necessary_tools() {
  echo "> Installing ZSH, ripgrep ..."
      # Detect the operating system
  case "$(uname)" in
      "Darwin")
          echo "Operating system: macOS"
          # Note: macOS Catalina and later include zsh by default
          if command -v brew &> /dev/null; then
              brew install zsh alacritty ripgrep
          else
              echo "Homebrew is missing. Please install Homebrew or install zsh manually."
              exit 1
          fi
          ;;
          
      "Linux")
          echo "Operating system: Linux"
          if command -v apt-get &> /dev/null; then
              sudo apt-get update && sudo apt-get install -y zsh alacritty ripgrep
          elif command -v dnf &> /dev/null; then
              sudo dnf install -y zsh alacritty ripgrep
          elif command -v pacman &> /dev/null; then
              sudo pacman -S --noconfirm zsh alacritty ripgrep
          else
              echo "Unsupported package manager. Please install package manually."
              exit 1
          fi
          ;;
          
      *)
          echo "Unknown Operating System."
          exit 1
          ;;
  esac
}

install_fzf() {
  echo "> Installing fzf ..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
}



