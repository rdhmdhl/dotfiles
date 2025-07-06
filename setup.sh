#!/bin/bash
echo "Setting up your dev environment..."

echo "Installing Xcode Command Line Tools..."
xcode-select --install 2>/dev/null || echo "Xcode Command Line Tools already installed."

if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --- Install CLI tools ---
echo "Installing CLI tools..."
brew install tmux zsh zsh-autosuggestions zsh-syntax-highlighting jq neovim git ripgrep tree-sitter lua-language-server koekeishiya/formulae/skhd

# -- Install Yabai
echo "Installing Yabai..."
curl -L https://raw.githubusercontent.com/koekeishiya/yabai/master/scripts/install.sh | sh /dev/stdin

# -- Install ghostty terminal
echo "Installing Ghostty..."
brew install --cask ghostty

# --- Install oh-my-zsh ---
echo "Installing oh-my-zsh (you may need to run 'source ~/.zshrc' or open a new terminal after this)"
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# --- Install MesloLGS Nerd Font ---
echo "Installing Nerd Font (MesloLGS)..."
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font

# --- Create symlinks to dotfiles ---
echo "Linking dotfiles..."
ln -sfn "$PWD/.zshrc" ~/.zshrc
ln -sfn "$PWD/.p10k.zsh" ~/.p10k.zsh
ln -sfn "$PWD/.tmux.conf" ~/.tmux.conf
ln -sfn "$PWD/.gitconfig" ~/.gitconfig
mkdir -p ~/.config
ln -sfv "$PWD/.nvim/" ~/.config/nvim/
mkdir -p ~/.config/yabai
ln -sfn "$PWD/.yabai/yabairc" ~/.config/yabai/yabairc 
mkdir -p ~/.config/skhd
ln -sfn "$PWD/.skhd/skhdrc" ~/.config/skhd/skhdrc

# --- Start yabai and skhd ---
echo "Reminder: Grant Yabai and SKHD permissions in System Settings > Privacy & Security > Accessibility and Screen Recording"
brew services start yabai
brew services start skhd

# --- Reload tmux config (if inside tmux) ---
if [ -n "$TMUX" ]; then
  echo "Reloading tmux config..."
  tmux source-file ~/.tmux.conf
fi

echo "Done! Open a new terminal or run: source ~/.zshrc"

