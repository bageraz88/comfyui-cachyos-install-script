#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
INSTALL_DIR="${INSTALL_DIR:-$HOME/comfyui}"
REPO_URL="${REPO_URL:-https://github.com/comfyanonymous/ComfyUI.git}"
LOG_FILE="${LOG_FILE:-$HOME/comfyui-install.log}"
GPU_SELECTION="${GPU_SELECTION:-auto}"
DRY_RUN=0
RESET=0

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [options]

Options:
  --install             Install or update ComfyUI (default action)
  --reset               Remove the ComfyUI installation directory and virtualenv
  --dry-run             Print actions without executing them
  --gpu <id|auto>       Select a GPU index for CUDA_VISIBLE_DEVICES or use auto
  --install-dir <path>  Override the installation directory
  --repo-url <url>      Override the ComfyUI repository URL
  -h, --help            Show this help message

Examples:
  $SCRIPT_NAME --install
  $SCRIPT_NAME --install --gpu 0
  $SCRIPT_NAME --reset
EOF
}

log() {
  printf '[%s] %s\n' "$(date '+%F %T')" "$*" | tee -a "$LOG_FILE"
}

run_cmd() {
  if (( DRY_RUN )); then
    log "[dry-run] $*"
  else
    log "+ $*"
    "$@"
  fi
}

ensure_dir() {
  if (( DRY_RUN )); then
    log "[dry-run] mkdir -p $1"
  else
    mkdir -p "$1"
  fi
}

prompt_yes_no() {
  local prompt="$1"
  local answer
  if [ -t 0 ]; then
    read -r -p "$prompt [y/N] " answer
  else
    answer="n"
  fi
  [[ "$answer" =~ ^[Yy]$ ]]
}

detect_os() {
  if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
  fi

  case "${ID:-}" in
    ubuntu|debian|pop|linuxmint)
      PKG_MGR="apt"
      ;;
    arch|cachyos|manjaro)
      PKG_MGR="pacman"
      ;;
    fedora|rhel|centos|rocky)
      PKG_MGR="dnf"
      ;;
    *)
      echo "Unsupported distribution: ${ID:-unknown}" >&2
      exit 1
      ;;
  esac
}

check_root() {
  if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
  else
    SUDO="sudo"
  fi
}

run_pkg_cmd() {
  if [ -n "$SUDO" ]; then
    run_cmd "$SUDO" "$@"
  else
    run_cmd "$@"
  fi
}

ensure_dependencies() {
  local missing=()

  case "$PKG_MGR" in
    apt)
      local packages=(git python3 python3-venv python3-pip build-essential ffmpeg curl wget pkg-config libgl1 libglib2.0-0 libsm6 libxrender1)
      for pkg in "${packages[@]}"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
          missing+=("$pkg")
        fi
      done
      if [ "${#missing[@]}" -gt 0 ]; then
        log "Installing missing packages: ${missing[*]}"
        run_pkg_cmd apt-get update
        run_pkg_cmd apt-get install -y "${missing[@]}"
      else
        log "Required APT packages already installed"
      fi
      ;;
    pacman)
      local packages=(git python python-pip python-virtualenv base-devel ffmpeg curl wget pkgconf libglvnd mesa libx11)
      for pkg in "${packages[@]}"; do
        if ! pacman -Q "$pkg" >/dev/null 2>&1; then
          missing+=("$pkg")
        fi
      done
      if [ "${#missing[@]}" -gt 0 ]; then
        log "Installing missing packages: ${missing[*]}"
        run_pkg_cmd pacman -Syu --noconfirm "${missing[@]}"
      else
        log "Required pacman packages already installed"
      fi
      ;;
    dnf)
      local packages=(git python3 python3-pip python3-virtualenv gcc gcc-c++ make ffmpeg curl wget pkgconfig libglvnd mesa-libGL libSM libXrender)
      for pkg in "${packages[@]}"; do
        if ! rpm -q "$pkg" >/dev/null 2>&1; then
          missing+=("$pkg")
        fi
      done
      if [ "${#missing[@]}" -gt 0 ]; then
        log "Installing missing packages: ${missing[*]}"
        run_pkg_cmd dnf install -y "${missing[@]}"
      else
        log "Required DNF packages already installed"
      fi
      ;;
  esac
}

choose_gpu() {
  if command -v nvidia-smi >/dev/null 2>&1; then
    mapfile -t gpus < <(nvidia-smi --query-gpu=index,name --format=csv,noheader 2>/dev/null || true)
    if [ "${#gpus[@]}" -gt 1 ] && [ "$GPU_SELECTION" = "auto" ]; then
      log "Multiple GPUs detected:"
      printf '  %s\n' "${gpus[@]}"
      if [ -t 0 ]; then
        read -r -p "Select GPU index (0,1,...), or press Enter for auto: " selected
        if [[ "$selected" =~ ^[0-9]+$ ]]; then
          GPU_SELECTION="$selected"
        else
          GPU_SELECTION="auto"
        fi
      fi
    fi
  fi
}

reset_install() {
  if [ -d "$INSTALL_DIR" ]; then
    if prompt_yes_no "Remove $INSTALL_DIR and all generated files?"; then
      run_cmd rm -rf "$INSTALL_DIR"
      log "Reset complete"
    else
      log "Reset cancelled"
    fi
  else
    log "$INSTALL_DIR does not exist; nothing to reset"
  fi
}

prepare_install_dir() {
  ensure_dir "$INSTALL_DIR"
}

clone_or_update_repo() {
  local repo_dir="$INSTALL_DIR/ComfyUI"
  if [ -d "$repo_dir/.git" ]; then
    log "Updating existing ComfyUI checkout"
    run_cmd git -C "$repo_dir" pull --ff-only
  else
    log "Cloning ComfyUI into $repo_dir"
    run_cmd git clone "$REPO_URL" "$repo_dir"
  fi
}

setup_virtualenv() {
  local venv_dir="$INSTALL_DIR/venv"
  local python_bin=""

  if command -v python3 >/dev/null 2>&1; then
    python_bin="$(command -v python3)"
  elif command -v python >/dev/null 2>&1; then
    python_bin="$(command -v python)"
  else
    echo "Python is not available after dependency setup" >&2
    exit 1
  fi

  run_cmd "$python_bin" -m venv "$venv_dir"
}

install_python_requirements() {
  local venv_python="$INSTALL_DIR/venv/bin/python"
  local repo_dir="$INSTALL_DIR/ComfyUI"

  run_cmd "$venv_python" -m pip install --upgrade pip setuptools wheel
  run_cmd "$venv_python" -m pip install -r "$repo_dir/requirements.txt"
}

create_launcher() {
  local launcher="$INSTALL_DIR/run-comfyui.sh"
  if (( DRY_RUN )); then
    log "[dry-run] create launcher: $launcher"
    return
  fi

  cat > "$launcher" <<EOF_LAUNCHER
#!/usr/bin/env bash
set -euo pipefail
cd "$INSTALL_DIR/ComfyUI"
export CUDA_VISIBLE_DEVICES="$GPU_SELECTION"
exec "$INSTALL_DIR/venv/bin/python" main.py
EOF_LAUNCHER
  chmod +x "$launcher"
  log "Created launcher: $launcher"
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --install)
        ACTION="install"
        ;;
      --reset)
        RESET=1
        ;;
      --dry-run)
        DRY_RUN=1
        ;;
      --gpu)
        shift
        GPU_SELECTION="${1:-auto}"
        ;;
      --install-dir)
        shift
        INSTALL_DIR="${1:-$HOME/comfyui}"
        ;;
      --repo-url)
        shift
        REPO_URL="${1:-https://github.com/comfyanonymous/ComfyUI.git}"
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown argument: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
    shift
  done

  if [ -z "${ACTION:-}" ]; then
    ACTION="install"
  fi
}

main() {
  parse_args "$@"
  if (( RESET )); then
    detect_os
    check_root
    log "Reset mode selected"
    reset_install
    exit 0
  fi

  detect_os
  check_root
  ensure_dir "$(dirname "$LOG_FILE")"
  log "Starting ComfyUI installer"
  log "Install directory: $INSTALL_DIR"
  log "GPU selection: $GPU_SELECTION"
  choose_gpu
  ensure_dependencies
  prepare_install_dir
  clone_or_update_repo
  setup_virtualenv
  install_python_requirements
  create_launcher
  log "Installation complete"
  log "Run: $INSTALL_DIR/run-comfyui.sh"
}

main "$@"
