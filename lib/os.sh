#!/usr/bin/env bash
# Shared helpers, meant to be sourced. Sets $OS to "macos" or "wsl".

detect_os() {
  if [[ -n "${OS_OVERRIDE:-}" ]]; then
    echo "$OS_OVERRIDE"
    return
  fi

  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
      else
        echo "unsupported"
      fi
      ;;
    *) echo "unsupported" ;;
  esac
}

OS=$(detect_os)
export OS

is_macos() { [[ $OS == "macos" ]]; }
is_wsl() { [[ $OS == "wsl" ]]; }

# find_scripts <folder>...: executable files, sorted
find_scripts() {
  if is_macos; then
    find "$@" -mindepth 1 -maxdepth 1 -type f ! -name '.*' -perm +111 | sort
  else
    find "$@" -mindepth 1 -maxdepth 1 -type f ! -name '.*' -executable | sort
  fi
}

# find_non_scripts <folder>...: files that are not executable
find_non_scripts() {
  if is_macos; then
    find "$@" -mindepth 1 -maxdepth 1 -type f ! -name '.*' ! -perm +111 | sort
  else
    find "$@" -mindepth 1 -maxdepth 1 -type f ! -name '.*' ! -executable | sort
  fi
}

pkg_install() {
  if is_macos; then
    brew install "$@"
  elif is_wsl; then
    sudo apt-get install -y "$@"
  else
    echo "pkg_install: unsupported OS" >&2
    return 1
  fi
}

# make the helpers available in the scripts run by ./run (bash children)
export -f is_macos is_wsl pkg_install
