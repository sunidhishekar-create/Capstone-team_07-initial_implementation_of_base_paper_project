"""Sanity check for the project environment (Windows / Linux / macOS).
Run: python check_env.py
"""
import importlib
import platform
import sys

REQUIRED = ["torch", "torchvision", "numpy", "scipy", "pandas",
            "matplotlib", "tqdm", "yaml", "sklearn", "cleanlab", "pytest"]


def main() -> int:
    ok = True
    print(f"OS          : {platform.system()} {platform.release()} ({platform.machine()})")
    print(f"Python      : {sys.version.split()[0]}")
    if not (3, 10) <= sys.version_info[:2] <= (3, 12):
        print("  [WARN] Python 3.10-3.12 recommended (3.11 ideal).")

    for name in REQUIRED:
        try:
            mod = importlib.import_module(name)
            print(f"{name:<12}: {getattr(mod, '__version__', 'ok')}")
        except ImportError:
            print(f"{name:<12}: MISSING")
            ok = False

    if not ok:
        print("\nENVIRONMENT INCOMPLETE")
        return 1

    import torch
    cuda = torch.cuda.is_available()
    mps = getattr(torch.backends, "mps", None) is not None and torch.backends.mps.is_available()
    print(f"CUDA avail  : {cuda}")
    print(f"MPS avail   : {mps}")

    if cuda:
        print(f"Device      : cuda -> {torch.cuda.get_device_name(0)}")
        x = torch.randn(1000, 1000, device="cuda")
        print(f"GPU matmul  : {'OK' if torch.isfinite(x @ x).all() else 'FAILED'}")
    elif mps:
        print("Device      : mps (Apple Silicon GPU)")
        x = torch.randn(1000, 1000, device="mps")
        print(f"GPU matmul  : {'OK' if torch.isfinite(x @ x).all() else 'FAILED'}")
    else:
        print("Device      : cpu")
        print("  [INFO] No GPU backend detected. Fine for development and smoke tests, "
              "but full-length runs will be very slow.")

    print("\nENVIRONMENT OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())