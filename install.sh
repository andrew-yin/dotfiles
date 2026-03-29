#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd
)
Brewfile_PATH="$SCRIPT_DIR/Brewfile"

fail() {
  echo "Error: $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux) echo "linux" ;;
    *) fail "Unsupported operating system: $(uname -s)" ;;
  esac
}

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  echo "Installing Homebrew..."
  need_cmd curl
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  command -v brew >/dev/null 2>&1 || fail "Homebrew installation completed, but brew is not on PATH"
}

extract_cross_platform_brews() {
  awk '
    BEGIN {
      macos_depth = 0
    }
    /^[[:space:]]*$/ || /^[[:space:]]*#/ {
      next
    }
    /^[[:space:]]*if[[:space:]]+OS\.mac\?[[:space:]]*$/ {
      macos_depth++
      next
    }
    /^[[:space:]]*end[[:space:]]*$/ {
      if (macos_depth == 0) {
        print "Unsupported Brewfile structure: unexpected end" > "/dev/stderr"
        exit 1
      }
      macos_depth--
      next
    }
    macos_depth > 0 {
      next
    }
    /^[[:space:]]*brew[[:space:]]+"[^"]+"([[:space:]]*,.*)?[[:space:]]*$/ {
      line = $0
      sub(/^[[:space:]]*brew[[:space:]]+"/, "", line)
      sub(/".*$/, "", line)
      print line
      next
    }
    /^[[:space:]]*(cask|mas)[[:space:]]+/ {
      next
    }
    {
      print "Unsupported Brewfile structure for Linux install: " $0 > "/dev/stderr"
      exit 1
    }
  ' "$Brewfile_PATH"
}

map_brew_to_apt() {
  case "$1" in
    fd) echo "fd-find" ;;
    delta) echo "git-delta" ;;
    *) echo "$1" ;;
  esac
}

sudo_cmd() {
  if [[ $(id -u) -eq 0 ]]; then
    "$@"
    return
  fi

  command -v sudo >/dev/null 2>&1 || fail "This Linux install requires root or sudo"
  sudo "$@"
}

install_linux_packages() {
  [[ -f /etc/debian_version ]] || fail "Linux package install currently supports apt on Debian/Ubuntu only"
  need_cmd awk
  need_cmd apt-get

  local brew_pkg
  local apt_pkg
  local -a apt_packages=()

  while IFS= read -r brew_pkg; do
    [[ -n "$brew_pkg" ]] || continue
    if ! apt_pkg=$(map_brew_to_apt "$brew_pkg"); then
      fail "No apt mapping defined for Brewfile formula: $brew_pkg"
    fi
    apt_packages+=("$apt_pkg")
  done < <(extract_cross_platform_brews)

  ((${#apt_packages[@]} > 0)) || fail "No cross-platform Brewfile packages found to install"

  echo "Updating apt package index..."
  sudo_cmd apt-get update

  echo "Installing cross-platform packages with apt..."
  sudo_cmd apt-get install -y "${apt_packages[@]}"
}

main() {
  [[ -f "$Brewfile_PATH" ]] || fail "Brewfile not found at $Brewfile_PATH"

  case "$(detect_os)" in
    macos)
      ensure_brew
      brew bundle --file="$Brewfile_PATH" --no-lock
      ;;
    linux)
      install_linux_packages
      ;;
  esac
}

main "$@"
