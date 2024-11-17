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
  if ! command -v starship &> /dev/null; then
    if [ ! -d /usr/local/bin ]; then
      sudo mkdir -p /usr/local/bin
    fi
    sh -c "$(curl -sS https://starship.rs/install.sh)" -y -f
  else
    echo "starship already installed."
  fi
}

install_wezterm() {
  if ! command -v wezterm &> /dev/null; then
    echo "Installing WezTerm..."
    if [ "${machine}" = "Linux" ]; then
      curl -LO https://github.com/wez/wezterm/releases/download/20240203-110809-5046fc22/WezTerm-20240203-110809-5046fc22-Ubuntu20.04.AppImage
      chmod +x WezTerm-20240203-110809-5046fc22-Ubuntu20.04.AppImage
      if [ ! -d /usr/local/bin ]; then
        sudo mkdir -p /usr/local/bin
      fi
      sudo mv ./WezTerm-20240203-110809-5046fc22-Ubuntu20.04.AppImage /usr/local/bin/wezterm
    elif [ "${machine}" = "macOS"]; then
      curl -LO https://github.com/wez/wezterm/releases/download/20240203-110809-5046fc22/WezTerm-macos-20240203-110809-5046fc22.zip
      unzip WezTerm-macos-20240203-110809-5046fc22.zip
      cp WezTerm-macos-20240203-110809-5046fc22/WezTerm.app /Applications/WezTerm.app
      rm WezTerm-macos-20240203-110809-5046fc22.zip
      rm -r WezTerm-macos-20240203-110809-5046fc22
    fi
    echo "WezTerm installed."
  else
    echo "WezTerm already installed."
  fi
}

install_mise() {
  if [ ! -d ${HOME}/.local/share/mise ]; then
    curl https://mise.run | sh
    eval "$(~/.local/bin/mise activate bash)"
    mise install -y
  fi
}

install_sheldon() {
  if ! command -v sheldon &> /dev/null; then
    if [ "${machine}" = "Linux" ]; then
      curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
        | bash -s -- --repo rossmacarthur/sheldon --to ${HOME}/.local/bin
    elif [ "${machine}" = "macOS" ]; then
      brew install sheldon
    fi
  else
    echo "sheldon already installed."
  fi
}

update_docker_config() {
  DOCKER_CONFIG="${HOME}/.docker/config.json"
  PLUGIN_KEY="cliPluginsExtraDirs"
  PLUGIN_VALUE="/opt/homebrew/lib/docker/cli-plugins"

  if [[ ! -f "${DOCKER_CONFIG}" ]]; then
    mkdir -p ${HOME}/.docker
    echo "{}" > "${DOCKER_CONFIG}"
  fi

  if ! jq -e ".${PLUGIN_KEY}" "${DOCKER_CONFIG}" > /dev/null; then
    jq --arg key "${PLUGIN_KEY}" --arg value "${PLUGIN_VALUE}" '. + {($key): [$value]}' "${DOCKER_CONFIG}" > "${DOCKER_CONFIG}.tmp" && \
      mv "${DOCKER_CONFIG}.tmp" "${DOCKER_CONFIG}"
    echo "Added ${PLUGIN_KEY} to ${DOCKER_CONFIG}."
  else
    echo "${PLUGIN_KEY} already exists in ${DOCKER_CONFIG}."
  fi
}

install_docker() {
  if [ "${machine}" = "Linux" ]; then
    if ! command -v docker &> /dev/null; then
      echo "Installing docker..."
      curl -fsSL https://get.docker.com -o get-docker.sh
      sudo bash get-docker.sh
      rm get-docker.sh
      sudo groupadd -f docker
      sudo usermod -aG docker $USER
      newgrp docker
      sudo systemctl enable docker.service
      sudo systemctl enable containerd.service
      echo "docker installed."
    fi
    echo "Installing docker compose..."
    DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
    mkdir -p $DOCKER_CONFIG/cli-plugins
    curl -SL https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-$(uname -m) -o $DOCKER_CONFIG/cli-plugins/docker-compose
    chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
    echo "docker compose installed."
  elif [ "${machine}" = "macOS" ]; then
    if ! command -v docker &> /dev/null; then
      echo "Installing docker and docker compose..."
      brew install docker docker-compose docker-credential-helper colima
    else
      echo "Installing docker compose..."
      brew install docker-compose docker-credential-helper colima
    fi
    update_docker_config
    brew services start colima
    echo "docker and docker compose installed."
  fi
}

install_typos_lsp() {
  if ! command -v typos-lsp &> /dev/null; then
    echo "Installing typos-lsp..."
    mkdir -p ${HOME}/bin
    if [ "${machine}" = "Linux" ]; then
      curl -fsSL https://github.com/tekumara/typos-lsp/releases/download/v0.1.27/typos-lsp-v0.1.27-x86_64-unknown-linux-gnu.tar.gz \
        | tar xz -C ${HOME}/bin
    elif [ "${machine}" = "macOS" ]; then
      curl -fsSL https://github.com/tekumara/typos-lsp/releases/download/v0.1.27/typos-lsp-v0.1.27-aarch64-apple-darwin.tar.gz \
        | tar xz -C ${HOME}/bin
    fi
    echo "typos-lsp installed."
  else
    echo "typos-lsp already installed."
  fi
}

# awscli cannot be installed without Rosetta 2 on macOS with mise
install_awscli() {
  if ! command -v aws &> /dev/null; then
    echo "Installing awscli..."
    if [ "${machine}" = "Linux" ]; then
      curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip"
      unzip -u awscliv2.zip
      rm awscliv2.zip
      sudo ./aws/install
      rm -r ./aws
    elif [ "${machine}" = "macOS" ]; then
      brew install awscli
    fi
    echo "awscli installed."
  else
    echo "awscli already installed."
  fi
}

install_taplo_cli() {
  if ! command -v taplo &> /dev/null; then
    echo "Installing taplo-cli..."
    cargo install --features lsp --locked taplo-cli
    echo "taplo-cli installed."
  else
    echo "taplo already installed."
  fi
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
install_wezterm & pids+=($!)
install_mise & pids+=($!)
install_sheldon & pids+=($!)
install_docker & pids+=($!)
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
install_awscli & pids+=($!)
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
