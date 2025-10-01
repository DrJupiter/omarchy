# Ensure we have gum available
ensure_gum_available() {
  if command -v gum &>/dev/null; then
    return 0
  fi

  if is_arch_based; then
    sudo pacman -S --needed --noconfirm gum || return 1
    return 0
  fi

  local gum_version="0.14.3"
  local arch="$(uname -m)"
  local gum_arch=""

  case "$arch" in
    x86_64) gum_arch="x86_64" ;;
    aarch64|arm64) gum_arch="arm64" ;;
    *)
      echo "Unsupported architecture ($arch) for automatic gum installation" >&2
      return 1
      ;;
  esac

  local tmp_dir
  tmp_dir=$(mktemp -d)
  local tarball="gum_${gum_version}_Linux_${gum_arch}.tar.gz"
  local url="https://github.com/charmbracelet/gum/releases/download/v${gum_version}/${tarball}"

  if command -v curl &>/dev/null; then
    curl -fsSL "$url" -o "$tmp_dir/$tarball" || { rm -rf "$tmp_dir"; return 1; }
  elif command -v wget &>/dev/null; then
    wget -q "$url" -O "$tmp_dir/$tarball" || { rm -rf "$tmp_dir"; return 1; }
  else
    echo "Neither curl nor wget is available to download gum" >&2
    rm -rf "$tmp_dir"
    return 1
  fi

  if tar -xzf "$tmp_dir/$tarball" -C "$tmp_dir"; then
    sudo install -m 755 "$tmp_dir/gum" /usr/local/bin/gum || { rm -rf "$tmp_dir"; return 1; }
  else
    rm -rf "$tmp_dir"
    return 1
  fi

  rm -rf "$tmp_dir"
}

ensure_gum_available || true

if command -v gum &>/dev/null; then
  export OMARCHY_HAS_GUM=1
else
  export OMARCHY_HAS_GUM=0

  gum() {
    local subcommand="$1"
    shift || true

    case "$subcommand" in
      style)
        local text=""
        while [[ $# -gt 0 ]]; do
          case "$1" in
            --*)
              shift
              if [[ $# -gt 0 && $1 != --* ]]; then
                shift
              fi
              ;;
            -*)
              shift
              ;;
            *)
              if [[ -z "$text" ]]; then
                text="$1"
              else
                text+=" $1"
              fi
              shift
              ;;
          esac
        done

        printf '%b\n' "$text"
        ;;
      log)
        local level="INFO"
        while [[ $# -gt 0 ]]; do
          case "$1" in
            --level)
              level="${2:-INFO}"
              shift 2
              ;;
            --)
              shift
              break
              ;;
            *)
              break
              ;;
          esac
        done
        # shellcheck disable=SC2145
        echo "[$level] $@"
        ;;
      confirm)
        local prompt="Proceed?"
        local default_choice=""
        while [[ $# -gt 0 ]]; do
          case "$1" in
            --affirmative)
              shift 2
              ;;
            --negative)
              shift 3
              ;;
            --default)
              default_choice="y"
              shift
              ;;
            --*)
              shift
              ;;
            *)
              prompt="$1"
              shift
              ;;
          esac
        done

        local response
        if [[ "${default_choice:-}" == "y" ]]; then
          read -rp "$prompt [Y/n] " response
          response=${response:-Y}
        else
          read -rp "$prompt [y/N] " response
        fi

        [[ "$response" =~ ^[Yy]$ ]]
        ;;
      spin)
        while [[ $# -gt 0 ]]; do
          case "$1" in
            --)
              shift
              break
              ;;
            *)
              shift
              ;;
          esac
        done
        "$@"
        ;;
      *)
        echo "gum $subcommand not available without gum binary" >&2
        return 1
        ;;
    esac
  }
fi

# Get terminal size from /dev/tty (works in all scenarios: direct, sourced, or piped)
if [ -e /dev/tty ]; then
  TERM_SIZE=$(stty size 2>/dev/null </dev/tty)

  if [ -n "$TERM_SIZE" ]; then
    export TERM_HEIGHT=$(echo "$TERM_SIZE" | cut -d' ' -f1)
    export TERM_WIDTH=$(echo "$TERM_SIZE" | cut -d' ' -f2)
  else
    # Fallback to reasonable defaults if stty fails
    export TERM_WIDTH=80
    export TERM_HEIGHT=24
  fi
else
  # No terminal available (e.g., non-interactive environment)
  export TERM_WIDTH=80
  export TERM_HEIGHT=24
fi

export LOGO_PATH="$OMARCHY_PATH/logo.txt"
export LOGO_WIDTH=$(awk '{ if (length > max) max = length } END { print max+0 }' "$LOGO_PATH" 2>/dev/null || echo 0)
export LOGO_HEIGHT=$(wc -l <"$LOGO_PATH" 2>/dev/null || echo 0)

export PADDING_LEFT=$((($TERM_WIDTH - $LOGO_WIDTH) / 2))
export PADDING_LEFT_SPACES=$(printf "%*s" $PADDING_LEFT "")

# Tokyo Night theme for gum confirm
export GUM_CONFIRM_PROMPT_FOREGROUND="6"     # Cyan for prompt
export GUM_CONFIRM_SELECTED_FOREGROUND="0"   # Black text on selected
export GUM_CONFIRM_SELECTED_BACKGROUND="2"   # Green background for selected
export GUM_CONFIRM_UNSELECTED_FOREGROUND="7" # White for unselected
export GUM_CONFIRM_UNSELECTED_BACKGROUND="0" # Black background for unselected
export PADDING="0 0 0 $PADDING_LEFT"         # Gum Style
export GUM_CHOOSE_PADDING="$PADDING"
export GUM_FILTER_PADDING="$PADDING"
export GUM_INPUT_PADDING="$PADDING"
export GUM_SPIN_PADDING="$PADDING"
export GUM_TABLE_PADDING="$PADDING"
export GUM_CONFIRM_PADDING="$PADDING"

clear_logo() {
  printf "\033[H\033[2J" # Clear screen and move cursor to top-left
  gum style --foreground 2 --padding "1 0 0 $PADDING_LEFT" "$(<"$LOGO_PATH")"
}
