# Todo

## Project goals
- Create a Linux installer script for ComfyUI.
- Support installing missing dependencies automatically.
- Allow GPU selection when a system has multiple GPUs.
- Add a reset/reinstall cleanup option.

## Implementation checklist
- [ ] Inspect workspace files and confirm install location.
- [ ] Define supported Linux distros and package managers.
- [ ] Create the main installer script skeleton.
- [ ] Implement dependency detection and installation.
- [ ] Implement GPU detection and selection logic.
- [ ] Add a reset function for reinstall cleanup.
- [ ] Set up ComfyUI clone/update and Python virtual environment.
- [ ] Install Python packages and runtime dependencies.
- [ ] Add logging, prompts, and error handling.
- [ ] Test the script in a safe environment.
- [ ] Document usage and troubleshooting.

## Notes
- Prioritize a simple, reliable script for CachyOS/Arch and Ubuntu/Debian-style systems.
- Keep the script interactive by default, but make automation possible later.
