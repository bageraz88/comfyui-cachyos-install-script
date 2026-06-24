# ComfyUI Linux Install Script

This project is a work-in-progress installer for setting up ComfyUI on Linux systems.

## Purpose
The goal is to provide a simple terminal-based installer that can:
- detect and install missing system dependencies;
- support GPU selection on systems with multiple GPUs;
- set up a Python virtual environment;
- clone or update the ComfyUI repository;
- offer a reset option for reinstall cleanup.

## Planned features
- Automatic dependency detection for common Linux distributions.
- GPU detection and selection for dual-GPU setups.
- Safe reset/reinstall support.
- Logging and clear error handling.
- Basic documentation for usage and troubleshooting.

## Current status
A first implementation of the installer script is now available in [install-comfyui.sh](install-comfyui.sh).

## Usage
Run the installer with:

```bash
bash install-comfyui.sh --install
```

Useful options:
- `--dry-run` to preview actions without changing the system.
- `--gpu 0` or `--gpu 1` to select a specific GPU.
- `--reset` to remove the generated installation directory.

## Next steps
1. Test the script on a supported Linux environment.
2. Refine package lists for additional distributions.
3. Add more robust error handling and optional automation flags.
