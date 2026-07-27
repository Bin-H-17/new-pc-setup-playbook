# Hardware Compatibility Notes

> Key hardware compatibility for new PC setup, especially GPU vs CUDA / PyTorch versions. Wrong GPU config is the most common and stealthiest pitfall in AI research—this note is for lookup.

---

## I. RTX 5060 Blackwell Compatibility

### Core Parameters

| Item | Value |
|------|-------|
| GPU model | RTX 5060 |
| Architecture | Blackwell |
| Compute Capability | **sm_120** |
| Minimum CUDA version | **12.8** |
| Minimum PyTorch version | **2.9** |
| Recommended driver | NVIDIA Studio Driver |

### Key Notes

**1. Why CUDA 12.4 Does Not Work**

PyTorch official wheels for CUDA 12.4 **do not include kernels compiled for sm_120**. Blackwell sm_120 support first appears in **CUDA 12.8** PyTorch wheels. Wrong version yields "false success":
- `torch.cuda.is_available()` returns `True` (driver sees GPU)
- `torch.cuda.get_device_name(0)` returns `RTX 5060` (driver info correct)
- But `torch.compile` or fused kernels fail: `no kernel image is available for execution on the device`

**2. Why Not `conda install pytorch`**

conda-channel PyTorch **lags PyPI by 1–2 months**, and conda dependency resolution may pull cu121 / cu118 builds. New architectures like Blackwell need PyPI official **cu128** wheels with sm_120 kernels built in.

### Correct Install Commands

```powershell
# 1. Confirm miniconda3 is installed and on PATH
conda --version

# 2. Create env (med example)
conda create -n med python=3.12 -y
conda activate med

# 3. Install PyTorch (Blackwell must use cu128)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

# 4. Validate (6-step script below)
```

---

## II. GPU Validation: 6-Step Script

After PyTorch install, **run all 6 steps in order**. GPU setup is done only if all pass.

### Step 1: nvidia-smi
```powershell
nvidia-smi
```
**Expected**:
- GPU name `RTX 5060` (or NVIDIA Graphics Driver line)
- VRAM ~8GB
- Driver Version ≥ 570.x (latest Studio)
- CUDA Version ≥ 12.8 (max CUDA supported by driver, not installed toolkit version)

**If wrong**:
- `Microsoft Basic Render Driver`: driver not installed—reinstall Studio Driver.
- 0MB VRAM: hardware fault or driver too old.

### Step 2: torch.cuda.is_available()
```powershell
python -c "import torch; print(torch.cuda.is_available())"
```
**Expected**: `True`

**If wrong**:
- `False`: likely CPU-only PyTorch—`pip uninstall torch`, reinstall cu128 build.

### Step 3: torch.cuda.get_device_name()
```powershell
python -c "import torch; print(torch.cuda.get_device_name(0))"
```
**Expected**: `NVIDIA GeForce RTX 5060`

**If wrong**:
- Other GPU name: multi-GPU system—use `CUDA_VISIBLE_DEVICES`.

### Step 4: torch.cuda.get_device_capability() (Critical)
```powershell
python -c "import torch; print(torch.cuda.get_device_capability())"
```
**Expected**: `(12, 0)` (sm_120)

**If wrong**:
- `(8, 6)` or `(8, 9)`: wheel lacks sm_120 kernels—reinstall cu128.
- Steps 1–3 pass but old capability here = wrong install.

### Step 5: torch.__version__
```powershell
python -c "import torch; print(torch.__version__)"
```
**Expected**: `2.9.x` or higher (with `+cu128` suffix)

**If wrong**:
- Version < 2.9: incomplete Blackwell support—upgrade PyTorch.

### Step 6: torch.compile Actually Runs
```powershell
python -c "import torch; @torch.compile\ndef f(x): return x * 2 + 1\nprint(f(torch.randn(100, device='cuda')))"
```
**Expected**: 100-dim tensor, no error.

**If wrong**:
- `no kernel image is available`: typical missing sm_120 kernel—recheck Step 4, reinstall cu128 wheel.
- `CUDA error: no kernel image`: same.
- Other (e.g. `Compiler failed`): check `triton`—`pip install triton` (Windows: `pip install triton-windows`, or use WSL2).

---

## III. Other GPUs (Reference)

If your GPU is not RTX 5060, use this table:

| GPU series | Architecture | Compute Capability | Min CUDA | Min PyTorch | Install command |
|------------|--------------|-------------------|----------|-------------|-----------------|
| RTX 50 (5060/5070/5080/5090) | Blackwell | sm_120 | 12.8 | 2.9 | `--index-url https://download.pytorch.org/whl/cu128` |
| RTX 40 (4060/4070/4080/4090) | Ada Lovelace | sm_89 | 12.1 | 2.1 | `--index-url https://download.pytorch.org/whl/cu121` |
| RTX 30 (3060/3070/3080/3090) | Ampere | sm_86 | 11.8 | 2.0 | `--index-url https://download.pytorch.org/whl/cu118` |
| RTX 20 (2060/2070/2080) | Turing | sm_75 | 11.7 | 1.13 | `--index-url https://download.pytorch.org/whl/cu117` |
| GTX 10 (1060/1070/1080) | Pascal | sm_61 | 11.3 | 1.10 | `--index-url https://download.pytorch.org/whl/cu113` |

**Note**: Table shows **minimum** compatible versions, not the only options. RTX 40 can run cu128 but need not start that new. RTX 50 **must** start with cu128.

### Compute Capability Lookup

- Official page: https://developer.nvidia.com/cuda-gpus
- Command: `python -c "import torch; print(torch.cuda.get_device_capability())"`

---

## IV. NVIDIA Driver Choice

NVIDIA offers two driver lines for AI research:

### Studio Driver (Recommended for AI Research)

- **Pros**: Stability-first; monthly release; tested with pro apps (Blender / Premiere / DaVinci).
- **Cons**: Game optimizations lag.
- **Research value**: Better CUDA / cuDNN compatibility testing; lower crash rate on long training runs.
- **Download**: https://www.nvidia.com/Download/index.aspx?lang=cn (select "Studio Driver")

### Game Ready Driver (Not Recommended for AI Research)

- **Pros**: Day-one game updates.
- **Cons**: Frequent updates, stability swings, occasional CUDA crashes.
- **Use when**: Gaming only, or very short AI jobs (< 1 hour).

### Driver Install Order (Important)

```
1. OEM support tools (e.g. HP Support Assistant / Lenovo Vantage / Dell SupportAssist) → BIOS / chipset / NIC firmware
2. NVIDIA site → download and install Studio Driver
3. Windows Update → in Advanced options → Optional updates, uncheck NVIDIA driver
4. nvidia-smi → confirm driver not rolled back
```

Wrong order (Windows Update before site driver): old WHQL driver claims signature slot; site install fails or rolls back.

---

## V. Do You Need CUDA Toolkit Separately?

**Conclusion: For typical AI research, usually no separate CUDA Toolkit.**

### When You Do Not Need It

If you only run PyTorch / TensorFlow / JAX, **pip PyTorch wheels bundle the CUDA runtime you need** (not full Toolkit, but sufficient). No `nvcc`, `nvprof`, etc. required.

### When You Do Need It

Install CUDA Toolkit separately if:
1. **Custom CUDA kernels** (`.cu` files).
2. **Build PyTorch from source** (rare).
3. **`nvprof` / Nsight Compute** kernel profiling.
4. **Libraries needing nvcc** (`cupy`, `numba.cuda`, etc.).

If needed: https://developer.nvidia.com/cuda-downloads
- CUDA Toolkit 12.8 or newer (match PyTorch cu128 wheel).
- Default path `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8`—do not relocate.
- Add `bin` and `libnvvp` to PATH.

---

## VI. Reference Links (Verifiable)

### PyTorch Official

- **Install page (CUDA version selector)**: https://pytorch.org/get-pytorch/
- **CUDA compatibility / previous versions**: https://pytorch.org/get-started/previous-versions/
- **PyTorch GitHub Releases**: https://github.com/pytorch/pytorch/releases

### NVIDIA Official

- **Driver download**: https://www.nvidia.com/Download/index.aspx?lang=cn
- **CUDA Toolkit download**: https://developer.nvidia.com/cuda-downloads
- **CUDA GPU Compute Capability**: https://developer.nvidia.com/cuda-gpus
- **CUDA Toolkit Release Notes** (sm_120 support versions): https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/

### Blackwell Architecture

- **NVIDIA Blackwell architecture white paper**: https://resources.nvidia.com/en-us-blackwell-architecture
- **PyTorch Blackwell sm_120 support PRs**: search PyTorch GitHub for `sm_120` or `Blackwell`

### Driver vs CUDA Version Mapping

- **CUDA Toolkit vs minimum driver versions**: https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html#cuda-major-component-versions

---

## VII. Quick Diagnostic Checklist

After GPU setup on a new PC, confirm each item:

- [ ] `nvidia-smi` shows RTX 5060, ~8GB VRAM
- [ ] `nvidia-smi` Driver Version ≥ 570.x
- [ ] `nvidia-smi` CUDA Version ≥ 12.8
- [ ] `python -c "import torch; print(torch.cuda.is_available())"` → `True`
- [ ] `python -c "import torch; print(torch.cuda.get_device_name(0))"` → `NVIDIA GeForce RTX 5060`
- [ ] `python -c "import torch; print(torch.cuda.get_device_capability())"` → `(12, 0)`
- [ ] `python -c "import torch; print(torch.__version__)"` ≥ 2.9
- [ ] `torch.compile` decorator runs (Step 6 script passes)
- [ ] One real training job (e.g. MNIST) shows GPU utilization

All ✓ before serious research work. If any of the first 7 fail, fix before proceeding.
