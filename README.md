# inuatsu’s dotfiles

[![Build on Ubuntu x86_64](https://github.com/inuatsu/dotfiles/actions/workflows/ubuntu_x86-64_build.yml/badge.svg)](https://github.com/inuatsu/dotfiles/actions/workflows/ubuntu_x86-64_build.yml)
[![Build on macOS](https://github.com/inuatsu/dotfiles/actions/workflows/macos_arm64_build.yml/badge.svg)](https://github.com/inuatsu/dotfiles/actions/workflows/macos_arm64_build.yml)

Dotfiles for Ubuntu (or Ubuntu-based distros) and macOS

## Installation

Clone this repository and execute install.sh.

```bash
git clone https://github.com/inuatsu/dotfiles.git
cd dotfiles
bash install.sh
```

> [!CAUTION]
>
> Install on your own risk!
> Please review the code and understand what it does before executing install.sh.

### Give it a try on Docker

You can give it a try on Docker container before installation.

```bash
git clone https://github.com/inuatsu/dotfiles.git
cd dotfiles
docker compose run --build --rm test /bin/zsh
```

After zsh is opened on the container,
hit the command below to start installation on the container.

```bash
cd dotfiles
bash install.sh
```

Get a cup of ☕ or 🍵 while waiting for setup completion. It takes about 5 minutes.

After setup finished, execute `zsh -l` and you can try it out.

> [!WARNING]
> On arm64 macOS, it may be necessary to use VM with [lima](https://github.com/lima-vm/lima) to successfully install everything on docker.
> Refer to the following steps to run docker on VM with lima.
>
> 1. Install lima with homebrew.
>
>    ```bash
>    brew install lima
>    ```
>
> 2. Create configuration file of VM.
>
>    ```bash
>    cat << 'EOF' > jammy-amd64.yaml
>    cpus: 4
>    memory: "10GiB"
>    disk: "50GiB"
>
>    arch: "x86_64"
>    images:
>    - location: "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
>      arch: "x86_64"
>    EOF
>    ```
>
> 3. Validate the format of created yaml file.
>
>    ```bash
>    limactl validate jammy-amd64.yaml
>    ```
>
> 4. Start VM (this command takes a few minutes to complete).
>
>    ```bash
>    limactl start --tty=false jammy-amd64.yaml
>    ```
>
> 5. Login to VM.
>
>    ```bash
>    limactl shell jammy-amd64
>    ```
>
> 6. Install docker and docker compose on VM.
>
>    ```bash
>    sudo apt-get update
>    sudo apt-get install ca-certificates curl
>    sudo install -m 0755 -d /etc/apt/keyrings
>    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
>    sudo chmod a+r /etc/apt/keyrings/docker.asc
>    echo \
>      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
>      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
>      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
>    sudo apt-get update
>    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
>    ```
>
> 7. Clone this repository.
>
>    ```bash
>    git clone https://github.com/inuatsu/dotfiles.git
>    ```
>
> 8. Start docker container.
>
>    ```bash
>    cd dotfiles
>    sudo docker compose run --build --rm test /bin/zsh
>    ```
>
> After finished using the VM, remove it with the following commands.
>
> ```bash
> limactl stop jammy-amd64
> limactl delete jammy-amd64
> ```

## Toolboxes

- [starship](https://starship.rs/) : Shell prompt
- [mise](https://mise.jdx.dev/) : Manage languages, language servers and more
- [sheldon](https://sheldon.cli.rs/) : Shell plugin manager
- [NeoVim](https://neovim.io/) : text editor
  - [NvChad](https://nvchad.com/) : Base configuration
  - [lazy.nvim](https://lazy.folke.io/) : Plugin manager
  - [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) : LSP configuration
  - [conform.nvim](https://github.com/stevearc/conform.nvim) : Formatter configuration
  - [nvim-lint](https://github.com/mfussenegger/nvim-lint) : Linter configuration
  - [fidget.nvim](https://github.com/j-hui/fidget.nvim) : LSP/formatter/linter progress notification
  - [nvim-dbee](https://github.com/kndndrj/nvim-dbee) : Database client
  - [codesnap.nvim](https://github.com/mistricky/codesnap.nvim) : Code snapshot

## Highlights

- In my setup I don't use Mason to install linters, formatters and language servers.
  Most of them are installed by mise or pnpm.
- When opening Python files, it searches appropriate project root
  and automatically activates the virtual environment of the project using
  [venv-selector.nvim](https://github.com/linux-cultist/venv-selector.nvim/tree/regexp)
  - LSP (pyright) uses the project's virtual environment
    to provide autocompletion and definition lookup
  - Linters (flake8/mypy/ruff) and formatters (black/isort/ruff)
    in the project's virtual environment are used if exists,
    otherwise global ones are used.
    If you don't install linters and formatters globally,
    only the ones installed in the virtual environment is used, that is,
    if you install black/flake8/isort/mypy in the virtual environment,
    only black/flake8/isort/mypy are used,
    and if you install mypy/ruff in the virtual environment,
    only mypy and ruff are used.
    - I customised in such a way,
      because in some project black/flake8/isort/mypy are used as linters/formatters,
      and in another project mypy/ruff are used.
    - Same strategy is applied to JavaScript/TypeScript linters/formatters (biome/eslint/prettier)

## Feedback/Suggestions

Feedback and suggestions are welcome!
Please feel free to open an issue or pull request.

## Preview

<https://github.com/user-attachments/assets/255dc733-f4bb-45bb-a2cd-c9f1ec794d76>

## License

[MIT License](LICENSE)
