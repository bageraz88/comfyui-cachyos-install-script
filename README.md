# ComfyUI Linux Install Script

A Linux installer script for [ComfyUI](https://github.com/comfyanonymous/ComfyUI) with automatic dependency handling and GPU detection. Supports NVIDIA (CUDA) and AMD (ROCm) GPUs.

## Features

- **Auto-detection** of Linux distribution and package manager (apt, pacman, dnf)
- **GPU detection** — NVIDIA (nvidia-smi) and AMD (rocm-smi / lspci)
- **ROCm support** — installs `rocm-hip-sdk` and ROCm PyTorch on AMD systems
- **Dependency installation** — missing system packages installed automatically
- **Python virtual environment** — isolated venv for ComfyUI and its dependencies
- **Multi-GPU selection** — prompts to pick a GPU when multiple are detected
- **Reset/reinstall** — `--reset` removes the install directory cleanly
- **Dry-run mode** — `--dry-run` previews actions without making changes
- **Non-interactive mode** — `--yes` skips prompts for automation/CI
- **Desktop shortcut** — creates `~/.local/share/applications/comfyui.desktop` with SVG icon

## Usage

```bash
bash install-comfyui.sh --install
```

### Options

| Option | Description |
|--------|-------------|
| `--install` | Install or update ComfyUI (default action) |
| `--reset` | Remove the installation directory and virtualenv |
| `--yes` | Answer yes to all prompts (non-interactive mode) |
| `--dry-run` | Print actions without executing them |
| `--gpu <id\|auto>` | Select a GPU index or auto-detect |
| `--gpu-type <type>` | Override GPU auto-detection (nvidia, amd, none) |
| `--install-dir <path>` | Override the installation directory (default: `~/comfyui`) |
| `--repo-url <url>` | Override the ComfyUI repository URL |
| `--no-shortcut` | Skip creating a desktop menu shortcut |
| `-h, --help` | Show help message |

### Examples

```bash
# Install with defaults
bash install-comfyui.sh

# Install to a custom location
bash install-comfyui.sh --install-dir /opt/comfyui

# Select a specific GPU
bash install-comfyui.sh --gpu 0

# Force AMD (ROCm) mode
bash install-comfyui.sh --gpu-type amd

# CPU-only mode (no GPU acceleration)
bash install-comfyui.sh --gpu-type none

# Preview what the script would do
bash install-comfyui.sh --dry-run

# Automated non-interactive install
bash install-comfyui.sh --yes

# Install without desktop shortcut
bash install-comfyui.sh --no-shortcut

# Reset / reinstall
bash install-comfyui.sh --reset
```

### Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `INSTALL_DIR` | `~/comfyui` | Installation directory |
| `REPO_URL` | ComfyUI GitHub | ComfyUI repository URL |
| `LOG_FILE` | `~/comfyui-install.log` | Log file path |
| `ROCM_VERSION` | `6.2` | ROCm version for PyTorch index URL |

## Supported distributions

- **Arch Linux / CachyOS / Manjaro** (pacman)
- **Ubuntu / Debian / Pop!_OS / Linux Mint** (apt)
- **Fedora / RHEL / CentOS / Rocky Linux** (dnf)

## Launcher

After installation, a `run-comfyui.sh` launcher script is created in the install directory. It sets the correct GPU visibility variable (`CUDA_VISIBLE_DEVICES` for NVIDIA, `HIP_VISIBLE_DEVICES` for AMD) and starts ComfyUI.

## Desktop shortcut

A `.desktop` entry is created automatically at `~/.local/share/applications/comfyui.desktop` and an icon is copied from `comfyui.svg` to `~/.local/share/icons/comfyui.svg`. Use `--no-shortcut` to skip. Both are removed on `--reset`.
