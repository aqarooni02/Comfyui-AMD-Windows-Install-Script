

# ComfyUI AMD Setup Script

This PowerShell script helps set up **ComfyUI** on Windows for AMD RDNA GPUs (RDNA 3 / 3.5 / 4) using ROCm. It automates the installation of Python dependencies, ComfyUI, ROCm PyTorch, and `torchsde`, while allowing users to configure the `HIP_VISIBLE_DEVICES` environment variable for GPU selection.

---

## Features

- Checks if Python 3.12 (64-bit) is installed.
- Clones ComfyUI if not already present.
- Creates and activates a Python virtual environment.
- Upgrades pip, wheel, and setuptools.
- Installs ROCm-compatible PyTorch, ComfyUI dependencies, and `torchsde`.
- Displays and allows modification of `HIP_VISIBLE_DEVICES` before launching ComfyUI.
- Sets `HSA_OVERRIDE_GFX_VERSION` automatically based on GPU generation.

---

## Requirements

- Windows 10 / 11  
- Python 3.12 (64-bit)  
- Git (for cloning ComfyUI)  
- AMD RDNA 3 / 3.5 / 4 GPU  
- ROCm-compatible drivers installed

---

## Usage

1. **Clone this repository:**

```powershell
git clone [https://github.com/yourusername/comfyui-amd-setup.git](https://github.com/aqarooni02/Comfyui-AMD-Windows-Install-Script)
cd comfyui-amd-setup
````

2. **Run the setup script in PowerShell Admin:**

```powershell
.\setup-comfyui-amd-selection.ps1
```

3. **Follow the prompts:**

   * If ComfyUI is not installed, select your AMD GPU generation:

     ```
     1. RDNA 3   (RX 7000 series)
     2. RDNA 3.5 (Ryzen AI / Strix Halo / 365)
     3. RDNA 4   (RX 9000 series)
     ```

   * The script will install Python dependencies and set up the environment.

   * It will display the current `HIP_VISIBLE_DEVICES` value and ask if you want to change it.
     Example:

     ```powershell
     Current HIP_VISIBLE_DEVICES value: (not set)
     Do you want to change HIP_VISIBLE_DEVICES? (y/n) y
     Enter the new HIP_VISIBLE_DEVICES value (e.g., 0 for first GPU): 0
     HIP_VISIBLE_DEVICES updated to 0
     ```

4. **ComfyUI will launch automatically** after setup.

---

## Notes

* The script **does not automatically detect GPUs**. Users must manually set `HIP_VISIBLE_DEVICES` if multiple GPUs are present.
* Ensure `HIP_VISIBLE_DEVICES` matches the GPU you want to use before launching ComfyUI.
* `HSA_OVERRIDE_GFX_VERSION` is set automatically based on the selected GPU generation.

---

## License

MIT License
