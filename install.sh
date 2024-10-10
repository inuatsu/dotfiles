#!/usr/bin/env bash

set -e
set -o pipefail

IGNORE_PATTERN="^\.(git|travis)"

echo "Creating dotfile links..."
for dotfile in .??*; do
    [[ $dotfile =~ $IGNORE_PATTERN ]] && continue
    ln -snfv "$(pwd)/$dotfile" "$HOME/$dotfile"
done
echo "Dotfile links created."

curl https://mise.run | sh
eval "$(~/.local/bin/mise activate bash)"
export PATH="$HOME/.local/share/mise/shims:$PATH"
mise install -y

echo "Installing NeoVim..."
curl -LO https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm -f nvim-linux64.tar.gz
echo "NeoVim installed."

echo "Installing typos-lsp..."
curl -fsSL https://github.com/tekumara/typos-lsp/releases/download/v0.1.27/typos-lsp-v0.1.27-x86_64-unknown-linux-gnu.tar.gz \
  | sudo tar xz -C /usr/local/bin
rm -f typos-lsp-v0.1.27-x86_64-unknown-linux-gnu.tar.gz
echo "typos-lsp installed."

echo "Installing taplo-cli..."
cargo install --features lsp --locked taplo-cli
echo "taplo-cli installed."

echo "Installing RuboCop and Ruby LSP..."
gem install rubocop ruby-lsp
echo "RuboCop and ruby-lsp installed."

echo "Installing npm packages..."
corepack pnpm add -g \
  @fsouza/prettierd \
  @microsoft/compose-language-service \
  @vue/language-server \
  @vue/typescript-plugin \
  dockerfile-language-server-nodejs \
  eslint_d \
  markdown-toc \
  markdownlint-cli2 \
  pyright \
  stylelint \
  stylelint-config-recommended-scss \
  stylelint-config-standard \
  stylelint-order \
  stylelint-scss \
  typescript \
  typescript-language-server \
  vscode-langservers-extracted \
  yaml-language-server
echo "npm packages installed."

echo "Setup complete."
