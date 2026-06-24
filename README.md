# ComfyUI Linux Install Script

A beginner-friendly installer for [ComfyUI](https://github.com/comfyanonymous/ComfyUI) — an AI image generation tool. **Designed for dual-GPU systems with a discrete AMD GPU.** Not tested with NVIDIA GPUs. NVIDIA users are welcome to adapt the script — see [Contributing](#contributing).

## What you need

- A Linux computer (Arch, Ubuntu, Debian, Fedora, or similar)
- An internet connection
- A GPU (NVIDIA or AMD) — optional, CPU-only also works

## Installation

### 1. Open a terminal

Press `Ctrl + Alt + T` or search for "Terminal" in your apps menu.

### 2. Install git (if not already installed)

**Ubuntu / Debian:**
```bash
sudo apt update && sudo apt install git -y
```

**Arch / CachyOS / Manjaro:**
```bash
sudo pacman -Syu git --noconfirm
```

**Fedora:**
```bash
sudo dnf install git -y
```

### 3. Download this script

```bash
git clone https://github.com/bageraz88/comfyui-cachyos-install-script.git
cd comfyui-cachyos-install-script
```

### 4. (Optional) Preview what the script will do

```bash
bash install-comfyui.sh --dry-run
```

This shows every step without making any changes to your system.

### 5. Run the installer

```bash
bash install-comfyui.sh
```

The script will:
- Detect your Linux distribution
- Detect your GPU (NVIDIA or AMD)
- Install any missing system packages (asks for your password via sudo)
- Create a Python virtual environment
- Download ComfyUI
- Install all Python dependencies (ROCm PyTorch for AMD GPUs)
- Install ComfyUI-Manager (custom node manager)
- Install ComfyUI CLI (`comfy` command)
- Create a desktop shortcut (so you can find ComfyUI in your app menu)

> It will prompt you for your **sudo password** to install system packages, and ask **y/n** questions throughout. To skip all prompts, add `--yes`.

### 6. Run ComfyUI

After installation completes, launch ComfyUI:

**From the terminal (launcher):**
```bash
~/comfyui/run-comfyui.sh
```

**From the terminal (CLI):**
```bash
~/comfyui/venv/bin/comfy launch
```

**From your app menu:** Search for "ComfyUI" — a shortcut was added automatically.

ComfyUI starts a web server. Open your browser and go to **http://127.0.0.1:8188** to use it.

## First-time user guide

1. **Run the launcher** — either from terminal or app menu
2. **Open your browser** — go to `http://127.0.0.1:8188`
3. **Load an example** — click "Load Default" on the node graph
4. **Generate an image** — click "Queue Prompt" on the right panel

> If the page doesn't load, wait a few seconds and refresh. ComfyUI downloads models on first run which can take a moment.

### Dual GPU Browser Acceleration

For smoother image generation in the browser, enable GPU acceleration in your Chromium-based browser:

```bash
cp Chromium-based-Browser-flags.conf ~/.config/
```

Replace `Chromium-based-Browser` with your actual browser name (e.g., `chrome`, `brave`, `ungoogled-chromium`, `microsoft-edge`).

**Reference:** [CachyOS wiki — Enabling hardware acceleration in Google Chrome](https://wiki.cachyos.org/configuration/enabling_hardware_acceleration_in_google_chrome/)

## Want to customize the install?

| I want to... | Command |
|-------------|---------|
| Install to a different folder | `bash install-comfyui.sh --install-dir /path/to/folder` |
| Select a specific GPU | `bash install-comfyui.sh --gpu 0` |
| Force AMD (ROCm) mode | `bash install-comfyui.sh --gpu-type amd` |
| CPU-only (no GPU) | `bash install-comfyui.sh --gpu-type none` |
| Skip prompts (auto mode) | `bash install-comfyui.sh --yes` |
| Skip desktop shortcut | `bash install-comfyui.sh --no-shortcut` |
| Only preview (no changes) | `bash install-comfyui.sh --dry-run` |
| Use ComfyUI CLI | `~/comfyui/venv/bin/comfy --help` |
| Install more custom nodes | `~/comfyui/venv/bin/comfy node install <node-name>` |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `sudo: a password is required` | The script needs sudo to install packages. Run in a normal terminal (not in a script). |
| `Command not found: git` | Install git first (see step 2 above). |
| "No GPU detected" | Check your GPU with `lspci \| grep -E "VGA\|3D"`. If you have an AMD GPU, try `--gpu-type amd`. |
| Install fails mid-way | Run `bash install-comfyui.sh --reset` to clean up, then try again. |
| ComfyUI page doesn't load | Wait a moment (first run downloads models). Check the terminal for error messages. |
| Out of memory | ComfyUI needs significant RAM. Close other applications before running. |

## Reset / reinstall

To remove everything and start fresh:

```bash
bash install-comfyui.sh --reset
```

This deletes the ComfyUI folder, the launcher, and the desktop shortcut.

## All options reference

| Option | Description |
|--------|-------------|
| `--install` | Install or update ComfyUI (default action) |
| `--reset` | Remove everything (install folder, shortcut, icon) |
| `--yes` | Answer yes to all prompts (non-interactive mode) |
| `--dry-run` | Show what would happen without making changes |
| `--gpu <id\|auto>` | Select a GPU index or use auto-detect |
| `--gpu-type <type>` | Force GPU type: `nvidia`, `amd`, or `none` |
| `--install-dir <path>` | Install to a custom folder (default: `~/comfyui`) |
| `--repo-url <url>` | Use a different ComfyUI repository URL |
| `--no-shortcut` | Don't create a desktop menu shortcut |
| `-h, --help` | Show this help message |

### Environment variables

| Variable | Default | What it does |
|----------|---------|-------------|
| `INSTALL_DIR` | `~/comfyui` | Where ComfyUI gets installed |
| `REPO_URL` | ComfyUI GitHub | Where to download ComfyUI from |
| `LOG_FILE` | `~/comfyui-install.log` | Where install logs are saved |
| `ROCM_VERSION` | auto-detected | AMD ROCm version for PyTorch (override with `export ROCM_VERSION=6.3`) |

## Supported Linux distributions

- **Arch Linux, CachyOS, Manjaro** — uses `pacman`
- **Ubuntu, Debian, Pop!_OS, Linux Mint** — uses `apt`
- **Fedora, RHEL, CentOS, Rocky Linux** — uses `dnf`

## How it works

The script:

1. Detects your OS and GPU
2. Installs missing system packages (git, Python, ffmpeg, etc.)
3. Creates an isolated Python environment (venv)
4. Downloads ComfyUI from GitHub
5. Installs Python libraries (PyTorch, etc.) — uses the ROCm version if AMD GPU is detected
6. Installs ComfyUI-Manager and its dependencies
7. Installs ComfyUI CLI (`comfy-cli`)
8. Creates a launcher script and desktop shortcut

## Contributing

Contributions are welcome! Here's how you can help:

### Report issues

If you find a bug or have a feature request, [open an issue](https://github.com/bageraz88/comfyui-cachyos-install-script/issues). Include:
- Your Linux distribution and version
- Your GPU model (NVIDIA/AMD)
- The terminal output from the script (with `--dry-run` if possible)

### Submit changes

1. Fork the repository
2. Create a branch: `git checkout -b my-feature`
3. Make your changes
4. Test with `bash -n install-comfyui.sh` to verify syntax
5. Commit and push to your fork
6. Open a pull request

### Development tips

- Run `bash install-comfyui.sh --help` to see all options
- Use `--dry-run --yes` to test logic without sudo prompts or file changes
- The script follows POSIX-friendly bash — avoid bashisms where possible
- Keep the script self-contained (no external dependencies beyond standard Linux tools)

## License

This project is licensed under the **MIT License**.

The `comfyui.svg` icon is derived from the ComfyUI logo and is the property of [Comfyanonymous](https://github.com/comfyanonymous/ComfyUI). All rights to the original logo belong to its respective owner.
