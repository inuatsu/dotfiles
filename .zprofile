export PATH="$HOME/.local/share/mise/shims:$PATH"

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ "$(uname -s)" = "Darwin" ]; then
  ARCH="$(uname -m)"
  if [ "$ARCH" = "arm64" ]; then
    if [ -e /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  elif [ "$ARCH" = "x86_64" ]; then
    if [ -e /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
fi
