#!/usr/bin/env bash

set -euo pipefail

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

install_starship() {
  if [ ! -d /usr/local/bin ]; then
    sudo mkdir -p /usr/local/bin
  fi
  sh -c "$(curl -sS https://starship.rs/install.sh)" -y -f
}

install_mise() {
  if [ ! -d ${HOME}/.local/share/mise ]; then
    curl https://mise.run | sh
    eval "$(~/.local/bin/mise activate bash)"
    mise install -y
  fi
}

install_sheldon() {
  if [ "${machine}" = "Linux" ]; then
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
      | bash -s -- --repo rossmacarthur/sheldon --to ${HOME}/.local/bin
  elif [ "${machine}" = "macOS" ]; then
    brew install sheldon
  fi
}

install_neovim() {
  mkdir -p ${HOME}/bin ${HOME}/lib ${HOME}/share
  echo "Installing NeoVim..."
  if [ "${machine}" = "Linux" ]; then
    curl -fsSL https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz \
      | tar xz --strip-components=1 -C ${HOME}
  elif [ "${machine}" = "macOS" ]; then
    curl -fsSL https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-macos-arm64.tar.gz \
      | tar xz --strip-components=1 -C ${HOME}
  fi
  echo "NeoVim installed."
}

install_typos_lsp() {
  echo "Installing typos-lsp..."
  if [ "${machine}" = "Linux" ]; then
    curl -fsSL https://github.com/tekumara/typos-lsp/releases/download/v0.1.27/typos-lsp-v0.1.27-x86_64-unknown-linux-gnu.tar.gz \
      | tar xz -C ${HOME}/bin
  elif [ "${machine}" = "macOS" ]; then
    curl -fsSL https://github.com/tekumara/typos-lsp/releases/download/v0.1.27/typos-lsp-v0.1.27-aarch64-apple-darwin.tar.gz \
      | tar xz -C ${HOME}/bin
  fi
  echo "typos-lsp installed."
}

install_taplo_cli() {
  echo "Installing taplo-cli..."
  cargo install --features lsp --locked taplo-cli
  echo "taplo-cli installed."
}

install_gems() {
  echo "Installing RuboCop and Ruby LSP..."
  gem install rubocop ruby-lsp
  echo "RuboCop and ruby-lsp installed."
}

install_npm_packages() {
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
}

install_starship & pids+=($!)
install_mise & pids+=($!)
install_sheldon & pids+=($!)
install_neovim & pids+=($!)
install_typos_lsp & pids+=($!)

rv=0
for pid in "${pids[@]}"; do
  wait "$pid" || rv=1
done
if [ "$rv" -ne 0 ]; then
  echo "Error: Failed to install some dependencies."
  exit "$rv"
fi

eval "$(~/.local/bin/mise activate bash)"
export PATH="$HOME/.local/share/mise/shims:$PATH"
install_taplo_cli & pids+=($!)
install_gems & pids+=($!)
install_npm_packages & pids+=($!)

rv=0
for pid in "${pids[@]}"; do
  wait "$pid" || rv=1
done
if [ "$rv" -ne 0 ]; then
  echo "Error: Failed to install some dependencies."
  exit "$rv"
fi

mkdir -p ${HOME}/Pictures/codesnap
echo "codesnap directory created."

echo "Setup complete."
