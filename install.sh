#!/usr/bin/env bash

set -e
set -o pipefail

case "$(uname -s)" in
  Linux*)
    machine=Linux
    ;;
  Darwin*)
    machine=macOS
    ;;
  *)
    echo "Error: Unsupported platform: $(uname -s)"
    exit 1
    ;;
esac

sh -c "$(curl -sS https://starship.rs/install.sh)" -y -f

curl https://mise.run | sh
eval "$(~/.local/bin/mise activate bash)"
export PATH="$HOME/.local/share/mise/shims:$PATH"
mise install -y

IGNORE_PATTERN="^\.(git|travis)"

echo "Creating dotfile links..."
for dotfile in .??*; do
  [[ $dotfile =~ $IGNORE_PATTERN ]] && continue
  ln -snfv "$(pwd)/$dotfile" "$HOME/$dotfile"
done
echo "Dotfile links created."

echo "Installing NeoVim..."
if [ "${machine}" = "Linux" ]; then
  curl -fsSL https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz \
    | sudo tar xz --strip-components=1 -C /usr/local
elif [ "${machine}" = "macOS" ]; then
  curl -fsSL https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz \
    | sudo tar xz --strip-components=1 -C /usr/local
fi
echo "NeoVim installed."

echo "Installing typos-lsp..."
if [ "${machine}" = "Linux" ]; then
  curl -fsSL https://github.com/tekumara/typos-lsp/releases/download/v0.1.27/typos-lsp-v0.1.27-x86_64-unknown-linux-gnu.tar.gz \
    | sudo tar xz -C /usr/local/bin
elif [ "${machine}" = "macOS" ]; then
  curl -fsSL https://github.com/tekumara/typos-lsp/releases/download/v0.1.27/typos-lsp-v0.1.27-aarch64-apple-darwin.tar.gz \
    | sudo tar xz -C /usr/local/bin
fi
echo "typos-lsp installed."

echo "Installing taplo-cli..."
cargo install --features lsp --locked taplo-cli
echo "taplo-cli installed."

echo "Installing RuboCop and Ruby LSP..."
gem install rubocop ruby-lsp
echo "RuboCop and ruby-lsp installed."

echo "Installing npm packages..."
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
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
