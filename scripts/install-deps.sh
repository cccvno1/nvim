#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
INSTALL_AI=1
INSTALL_MASON=1
WITH_DEV_RUNTIMES=0

usage() {
  cat <<'USAGE'
Usage: scripts/install-deps.sh [options]

Options:
  --dry-run             Print commands without executing them.
  --no-ai-cli           Do not install Codex or OpenCode CLI.
  --no-mason            Do not run Mason tool installation.
  --with-dev-runtimes   Also install common language runtimes/toolchains.
  -h, --help            Show this help.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --no-ai-cli) INSTALL_AI=0 ;;
    --no-mason) INSTALL_MASON=0 ;;
    --with-dev-runtimes) WITH_DEV_RUNTIMES=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

log() {
  printf '\033[1;34m==>\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2
}

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '+ %q' "$1"
    shift
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n'
  else
    "$@"
  fi
}

has() {
  command -v "$1" >/dev/null 2>&1
}

sudo_cmd=()
if [ "$(id -u)" -ne 0 ]; then
  if has sudo; then
    sudo_cmd=(sudo)
  else
    warn "sudo is missing; system package installation may fail unless you run as root"
  fi
fi

detect_pm() {
  if has pacman; then echo pacman; return; fi
  if has apt-get; then echo apt; return; fi
  if has dnf; then echo dnf; return; fi
  if has brew; then echo brew; return; fi
  echo unknown
}

install_system_packages() {
  local pm="$1"

  case "$pm" in
    pacman)
      local packages=(git ripgrep fd fzf nodejs npm unzip tree-sitter-cli stylua shellcheck shfmt clang)
      if [ "$WITH_DEV_RUNTIMES" -eq 1 ]; then
        packages+=(python python-pip go gcc make cmake)
      fi
      log "Installing system packages with pacman"
      run "${sudo_cmd[@]}" pacman -S --needed "${packages[@]}"
      ;;
    apt)
      local packages=(git ripgrep fd-find fzf nodejs npm unzip shellcheck shfmt clang-format)
      if [ "$WITH_DEV_RUNTIMES" -eq 1 ]; then
        packages+=(python3 python3-pip golang gcc g++ make cmake)
      fi
      log "Installing system packages with apt"
      run "${sudo_cmd[@]}" apt-get update
      run "${sudo_cmd[@]}" apt-get install -y "${packages[@]}"
      if has fdfind && ! has fd; then
        local bin_dir="${HOME}/.local/bin"
        run mkdir -p "$bin_dir"
        run ln -sf "$(command -v fdfind)" "$bin_dir/fd"
        warn "Created fd shim at $bin_dir/fd. Ensure ~/.local/bin is in PATH."
      fi
      ;;
    dnf)
      local packages=(git ripgrep fd-find fzf nodejs npm unzip ShellCheck shfmt clang-tools-extra)
      if [ "$WITH_DEV_RUNTIMES" -eq 1 ]; then
        packages+=(python3 python3-pip golang gcc gcc-c++ make cmake)
      fi
      log "Installing system packages with dnf"
      run "${sudo_cmd[@]}" dnf install -y "${packages[@]}"
      ;;
    brew)
      local packages=(git ripgrep fd fzf node unzip tree-sitter stylua shellcheck shfmt clang-format)
      if [ "$WITH_DEV_RUNTIMES" -eq 1 ]; then
        packages+=(python go cmake)
      fi
      log "Installing system packages with brew"
      run brew install "${packages[@]}"
      ;;
    *)
      warn "No supported package manager found. Install git, rg, fd, fzf, node, npm, unzip, tree-sitter, stylua, shellcheck, shfmt, and clang-format manually."
      ;;
  esac
}

install_npm_tools() {
  if ! has npm; then
    warn "npm is missing; skipping npm-based tools"
    return
  fi

  if ! has tree-sitter; then
    log "Installing tree-sitter CLI with npm"
    run npm install -g tree-sitter-cli
  fi

  if [ "$INSTALL_AI" -eq 1 ]; then
    if ! has codex; then
      log "Installing Codex CLI with npm"
      run npm install -g @openai/codex
    fi

    if ! has opencode; then
      log "Installing OpenCode CLI with npm"
      run npm install -g opencode-ai
    fi
  fi
}

install_mason_tools() {
  if [ "$INSTALL_MASON" -eq 0 ]; then
    return
  fi

  if ! has nvim; then
    warn "nvim is missing; skipping Mason tool installation"
    return
  fi

  log "Syncing lazy.nvim plugins"
  run nvim --headless "+Lazy! sync" +qa

  log "Installing Mason tools declared by this config"
  run nvim --headless "+MasonToolsInstall" +qa
}

print_summary() {
  log "Tool status"
  local tools=(git rg fd fzf node npm unzip tree-sitter stylua shellcheck shfmt clang-format nvim codex opencode)
  for tool in "${tools[@]}"; do
    if has "$tool"; then
      printf '  ok      %s -> %s\n' "$tool" "$(command -v "$tool")"
    else
      printf '  missing %s\n' "$tool"
    fi
  done
}

main() {
  local pm
  pm="$(detect_pm)"
  log "Detected package manager: $pm"
  install_system_packages "$pm"
  install_npm_tools
  install_mason_tools
  print_summary

  log "Next checks"
  printf '  nvim --headless "+checkhealth ad" +qa\n'
  printf '  find lua -name '"'"'*.lua'"'"' -print0 | xargs -0 luac -p\n'
}

main "$@"
