# Todo

## Project goals
- Create a Linux installer script for ComfyUI.
- Support installing missing dependencies automatically.
- Allow GPU selection when a system has multiple GPUs.
- Add a reset/reinstall cleanup option.
- Support NVIDIA and AMD (ROCm) GPUs.

## Implementation

### Done
- [x] Inspect workspace files and confirm install location.
- [x] Define supported Linux distros and package managers.
- [x] Create the main installer script skeleton.
- [x] Implement dependency detection and installation.
- [x] Implement GPU detection and selection logic.
- [x] Add a reset function for reinstall cleanup.
- [x] Set up ComfyUI clone/update and Python virtual environment.
- [x] Install Python packages and runtime dependencies.
- [x] Add logging, prompts, and error handling.
- [x] Document usage in README.
- [x] Test the script in a safe environment (dry-run, then real run).
- [x] Add `--yes` flag for non-interactive/automation mode.
- [x] Remove unnecessary `python-virtualenv` from Arch deps.
- [x] Fix unnecessary `ensure_dir` on `$HOME`.

### AMD/ROCm support
- [x] Detect AMD GPU via `rocm-smi` or `lspci`.
- [x] Add `--gpu-type` flag to override auto-detection.
- [x] Install `rocm-hip-sdk` on Arch/CachyOS for AMD GPUs.
- [x] Install ROCm PyTorch from `download.pytorch.org/whl/rocm*`.
- [x] Use `HIP_VISIBLE_DEVICES` in launcher for AMD; no GPU var for CPU mode.
- [x] Handle apt/dnf ROCm deps with fallback instructions.

### Desktop shortcut
- [x] Create `comfyui.desktop` in `~/.local/share/applications/` after install.
- [x] Add `--no-shortcut` flag to opt out.
- [x] Copy `comfyui.svg` icon to `~/.local/share/icons/`.
- [x] Clean up shortcut + icon on `--reset`.

## Notes
- Prioritize a simple, reliable script for CachyOS/Arch and Ubuntu/Debian-style systems.
- Keep the script interactive by default, but make automation possible with `--yes`.
- ROCm version defaults to 6.3; override with `export ROCM_VERSION=6.2`.
