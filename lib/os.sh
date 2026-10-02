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

sort_by_basename() {
  awk -F/ '{print $NF"\t"$0}' | sort -k1,1 -s | cut -f2-
}

# find_scripts <folder>...: executable files, sorted by basename within each folder
find_scripts() {
  if is_macos; then
    find "$@" -mindepth 1 -maxdepth 1 -type f ! -name '.*' -perm +111 | sort_by_basename
  else
    find "$@" -mindepth 1 -maxdepth 1 -type f ! -name '.*' -executable | sort_by_basename
  fi
}

# find_non_scripts <folder>...: files that are not executable, sorted by basename within each folder
find_non_scripts() {
 if is_macos; then
   find "$@" -mindepth 1 -maxdepth 1 -type f ! -name '.*' ! -perm +111
 else
   find "$@" -mindepth 1 -maxdepth 1 -type f ! -name '.*' ! -executable
 fi
}

pkg_install() {
  if is_macos; then
    brew install -y "$@"
  elif is_wsl; then
    sudo apt-get install -y "$@"
  else
    echo "pkg_install: unsupported OS" >&2
    return 1
  fi
}

# make the helpers available in the scripts run by ./run (bash children)
export -f is_macos is_wsl pkg_install
