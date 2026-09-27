# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/Users/inuatsu/.zsh/completions" $fpath)
autoload -Uz compinit
compinit
# OPENSPEC:END

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=1000000
bindkey -e
# End of lines configured by zsh-newuser-install

fpath+=~/.zfunc

setopt inc_append_history
setopt share_history

setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt extended_history
setopt hist_expire_dups_first

zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

setopt auto_param_slash
setopt auto_param_keys
setopt mark_dirs
setopt auto_menu
setopt correct
setopt interactive_comments
setopt magic_equal_subst
setopt complete_in_word
setopt print_eight_bit
setopt auto_cd
setopt no_beep
setopt +o nomatch

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
bindkey "^R" history-search-multi-word

# Cache sheldon
cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
sheldon_cache="$cache_dir/sheldon.zsh"
sheldon_toml="$HOME/.config/sheldon/plugins.toml"
if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
  mkdir -p $cache_dir
  sheldon source > $sheldon_cache
fi
source "$sheldon_cache"
unset cache_dir sheldon_cache sheldon_toml

daily_dev_tools_update() {
  local lock_file="/tmp/daily-update-$(date +%Y%m%d)"
  [[ -f "$lock_file" ]] && return
  echo "📦 Today's dev tools update hasn't run yet."
  read -q "reply?   Run 'mise run update' now? [y/N] "
  echo
  if [[ "$reply" == "y" ]]; then
    touch "$lock_file"
    mise run update
    mise run doctor
  fi
}
daily_dev_tools_update

# aube global bin
export PATH="$HOME/.local/share/aube/bin:$PATH"

alias claude='command claude --settings ~/.claude/profiles/lean.json'
alias claude-aws='command claude --settings ~/.claude/profiles/aws.json'
alias claude-sf='command claude --settings ~/.claude/profiles/sf.json'
alias claude-full='command claude --settings ~/.claude/profiles/full.json'
