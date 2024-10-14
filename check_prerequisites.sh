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

apt_packages=(
  "autoconf"
  "build-essential"
  "ca-certificates"
  "curl"
  "git"
  "libc6"
  "libcrypt1"
  "libdb-dev"
  "libffi-dev"
  "libgdbm-dev"
  "libgdbm6"
  "libgmp-dev"
  "libncurses5-dev"
  "libreadline6-dev"
  "libssl-dev"
  "libyaml-dev"
  "make"
  "patch"
  "rustc"
  "unzip"
  "uuid-dev"
  "zlib1g-dev"
  "zsh"
)

brew_packages=(
  "gmp"
  "libyaml"
  "openssl@3"
  "pinentry-mac"
  "readline"
  "zlib"
)

check_xcode_cli_tools() {
  if xcode-select -p &> /dev/null; then
    echo "Xcode Command Line Tools are installed"
  else
    echo "Xcode Command Line Tools are NOT installed. Installing..."
    xcode-select --install
    echo "Finished installing Xcode Command Line Tools."
  fi
}

# Function to check and install missing packages on Ubuntu
check_apt_packages() {
  echo "Checking prerequisite apt packages..."
  sudo apt-get update -y

  missing_packages=()
  for package in "${apt_packages[@]}"; do
    if ! dpkg -l | grep -w "${package}" | awk "/${package}/ {print \$2}" | grep -w "^${package}$"; then
      missing_packages+=("${package}")
    fi
  done

  if [ ${#missing_packages[@]} -gt 0 ]; then
    echo "Installing missing packages: ${missing_packages[*]}"
    sudo apt-get install -y --no-install-recommends "${missing_packages[@]}"
    echo "Finished installing missing packages."
  else
    echo "All packages are already installed."
  fi
}

check_brew_packages() {
  echo "Checking brew packages..."

  check_xcode_cli_tools

  if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew upgrade

  missing_packages=()
  for package in "${brew_packages[@]}"; do
    if ! brew list | grep -w "${package}"; then
      missing_packages+=("${package}")
    fi
  done

  if [ ${#missing_packages[@]} -gt 0 ]; then
    echo "Installing missing packages: ${missing_packages[*]}"
    brew install "${missing_packages[@]}"
    echo "Finished installing missing packages."
  else
    echo "All packages are already installed."
  fi
}

if [[ "${machine}" == "Linux" ]]; then
    check_apt_packages
elif [[ "${machine}" == "macOS" ]]; then
    check_brew_packages
fi
