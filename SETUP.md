# Team Setup (Windows / Linux / macOS)

Reproduction of **DRAG / BR-DRAG** (arXiv 2601.06903) for our capstone.

## 1. Prerequisites (one time per machine)

| | Windows | macOS | Linux (Ubuntu/Debian) |
|---|---|---|---|
| Git | https://git-scm.com/download/win | `xcode-select --install` or `brew install git` | `sudo apt install git` |
| Python 3.10-3.12 (3.11 best) | python.org installer (tick *Add to PATH*) | `brew install python@3.11` | `sudo apt install python3.11 python3.11-venv` |
| GPU (optional) | NVIDIA driver; `nvidia-smi` must work | Apple Silicon uses the built-in GPU (MPS) | NVIDIA driver; `nvidia-smi` must work |

No separate CUDA Toolkit is needed on any system: the PyTorch wheel bundles what it needs.

Also install **VS Code** with the *Python*, *Pylance* and *Jupyter* extensions.

**Compatibility notes**
- PyTorch 2.5.1 (the paper's version) has no wheels for **Intel Macs**. Intel Mac users should use Colab/Kaggle or a teammate's machine for runs, or ask the team to relax the torch pin.
- Apple Silicon works on CPU or MPS. Some operations may fall back to CPU, so expect it to be slower than an NVIDIA GPU.
- Machines without a GPU can develop and run smoke tests, but full 3000-4000 round experiments need a GPU.

## 2. Clone

Use a short path with no spaces, outside cloud-synced folders (OneDrive, iCloud Drive, Dropbox).

**Windows (PowerShell)**
```powershell
git config --global core.autocrlf true
cd C:\dev
git clone <team-repo-url>
cd Capstone-team_07
code .
```

**macOS / Linux**
```bash
git config --global core.autocrlf input
mkdir -p ~/dev && cd ~/dev
git clone <team-repo-url>
cd Capstone-team_07
code .
```

## 3. One-command setup

Run from the repo root (the VS Code terminal opens there if you opened the repo folder).

**Windows**
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned   # only if scripts are blocked
.\setup.ps1
```

**macOS / Linux**
```bash
bash setup.sh
```

Each script creates `.venv`, installs `requirements.txt`, creates the project folders, and runs `check_env.py`.

Then in VS Code: `Ctrl/Cmd+Shift+P` -> **Python: Select Interpreter** -> choose the one inside `.venv`.

## 4. Everyday use

| | Windows | macOS / Linux |
|---|---|---|
| Activate env (every new terminal) | `.venv\Scripts\Activate.ps1` | `source .venv/bin/activate` |
| Check environment | `python check_env.py` | `python check_env.py` |
| Run tests | `pytest` | `pytest` |

## 5. Manual setup (if the script fails)

**Windows**
```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
python check_env.py
```

**macOS / Linux**
```bash
python3.11 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt
python check_env.py
```

## 6. Troubleshooting

- **`ensurepip` / venv error on Ubuntu**: `sudo apt install python3.11-venv`.
- **`setup.sh: Permission denied`**: run it as `bash setup.sh` (no need for chmod).
- **PowerShell blocks `.ps1`**: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.
- **`check_env.py` shows CPU only on an NVIDIA machine**: run `nvidia-smi`; if it fails, update the NVIDIA driver, then re-run `pip install -r requirements.txt`.
- **Slow or failed torch download**: the package is several GB. Retry on a stable connection.
- **Corporate/university network blocks pip**: use a hotspot or ask IT about the proxy.

## 7. Team Git workflow

- `main` only holds working code.
- Work on a branch: `git checkout -b feat/<short-name>`, push it, open a Pull Request.
- Run `git pull` before starting work.
- Never commit `.venv/`, `data/`, or checkpoints (already in `.gitignore`).
- If you add a package, pin it in `requirements.txt` and tell the team to re-run `pip install -r requirements.txt`.

## 8. Notes for the code we write

- Select the compute device once, in a single helper (`cuda` -> `mps` -> `cpu`), so the same code runs on every teammate's machine.
- Use `num_workers=0` in data loaders (or keep datasets as tensors on the device) to avoid multiprocessing differences between Windows, macOS and Linux.
- Datasets (EMNIST, CIFAR-10, CIFAR-100) download automatically into `data/` on first use.