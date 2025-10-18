# ==============================================
# ComfyUI Setup Script for AMD RDNA (3 / 3.5 / 4)
# Author: ChatGPT
# Date: 2025-10-18
# ==============================================

Write-Host "`n=== ComfyUI Setup for AMD RDNA GPUs (Windows) ===" -ForegroundColor Cyan

# --- Step 1: Check Python installation ---
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python not found. Please install Python 3.12 (64-bit) and rerun this script." -ForegroundColor Red
    exit 1
}

# --- Step 2: Set working directory ---
$scriptPath = $PSScriptRoot
if (-not $scriptPath) { $scriptPath = (Get-Location).Path }
Set-Location $scriptPath
Write-Host "Using working directory: $scriptPath" -ForegroundColor Yellow

# --- Step 3: Ask user for AMD GPU generation (only if ComfyUI missing) ---
if (-not (Test-Path "$scriptPath\ComfyUI")) {
    Write-Host "`nSelect your AMD GPU generation:" -ForegroundColor Cyan
    Write-Host "1. RDNA 3   (RX 7000 series)"
    Write-Host "2. RDNA 3.5 (Ryzen AI / Strix Halo / 365)"
    Write-Host "3. RDNA 4   (RX 9000 series)"

    $gpuChoice = Read-Host "Enter 1, 2, or 3"

    switch ($gpuChoice) {
        '1' { $torchIndexUrl="https://rocm.nightlies.amd.com/v2/gfx110X-dgpu/"; $gfxVersion="11.0.0"; $gpuName="RDNA 3 (RX 7000 series)" }
        '2' { $torchIndexUrl="https://rocm.nightlies.amd.com/v2/gfx1151/"; $gfxVersion="11.5.1"; $gpuName="RDNA 3.5 (Strix Halo / Ryzen AI)" }
        '3' { $torchIndexUrl="https://rocm.nightlies.amd.com/v2/gfx120X-all/"; $gfxVersion="12.0.0"; $gpuName="RDNA 4 (RX 9000 series)" }
        default { Write-Host "Invalid choice."; exit 1 }
    }

    Write-Host "`nSelected GPU generation: $gpuName" -ForegroundColor Green
    Write-Host "Using ROCm PyTorch index: $torchIndexUrl`n" -ForegroundColor Yellow
}

# --- Step 4: Clone ComfyUI if missing ---
if (-not (Test-Path "$scriptPath\ComfyUI")) {
    Write-Host "Cloning ComfyUI repository..."
    git clone https://github.com/comfyanonymous/ComfyUI.git
}
Set-Location "$scriptPath\ComfyUI"

# --- Step 5: Create/activate virtual environment ---
if (-not (Test-Path "$scriptPath\ComfyUI\venv")) {
    Write-Host "`nCreating Python virtual environment..."
    python -m venv venv
}
$venvActivate = "$scriptPath\ComfyUI\venv\Scripts\Activate.ps1"
& $venvActivate
Write-Host "Virtual environment activated.`n"

# --- Step 6: Upgrade pip ---
pip install --upgrade pip wheel setuptools

# --- Step 7: Install ROCm PyTorch if missing ---
$torchInstalled = & python -c "import torch; print(torch.__version__)" 2>$null
if (-not $torchInstalled) {
    Write-Host "`nInstalling ROCm PyTorch..."
    pip install --pre torch torchvision torchaudio --index-url $torchIndexUrl
} else { Write-Host "PyTorch already installed: $torchInstalled" }

# --- Step 8: Install ComfyUI dependencies ---
$depsInstalled = & python -c "import comfy" 2>$null
if (-not $depsInstalled) {
    Write-Host "`nInstalling ComfyUI dependencies..."
    (Get-Content requirements.txt) | Where-Object {$_ -notmatch "torch"} | Set-Content requirements_filtered.txt
    pip install -r requirements_filtered.txt
} else { Write-Host "ComfyUI dependencies already installed." }

# --- Step 9: Install torchsde ---
$torchsdeInstalled = & python -c "import torchsde" 2>$null
if (-not $torchsdeInstalled) {
    Write-Host "`nInstalling torchsde..."
    pip install torchsde
} else { Write-Host "torchsde already installed." }

# --- Step 10: Show HIP_VISIBLE_DEVICES and ask user ---
$currentHip = $env:HIP_VISIBLE_DEVICES
if (-not $currentHip) { $currentHip = "(not set)" }
Write-Host "`nCurrent HIP_VISIBLE_DEVICES value: $currentHip"

$changeHip = Read-Host "Do you want to change HIP_VISIBLE_DEVICES? (y/n)"
if ($changeHip -eq "y" -or $changeHip -eq "Y") {
    $newHip = Read-Host "Enter the new HIP_VISIBLE_DEVICES value (e.g., 0 for first GPU)"
    $env:HIP_VISIBLE_DEVICES = $newHip
    Write-Host "HIP_VISIBLE_DEVICES updated to $newHip"
} else {
    Write-Host "Using existing HIP_VISIBLE_DEVICES value: $currentHip"
}

Write-Host "`nMake sure this matches the GPU you want to use before ComfyUI launches.`n"

# --- Step 11: Launch ComfyUI ---
Write-Host "`nLaunching ComfyUI..."
$env:HSA_OVERRIDE_GFX_VERSION = $gfxVersion

python main.py

Write-Host "`n============================================"
Write-Host "ComfyUI has exited. You can rerun this script anytime to start again."
Write-Host "============================================"
pause
