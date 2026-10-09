# One-command project setup for Windows (PowerShell).
# Usage (from the repo root):   .\setup.ps1
# If scripts are blocked, run once:  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "== 1/5 Locating Python 3.10-3.12 ==" -ForegroundColor Cyan
$py = $null
foreach ($v in @("3.11", "3.12", "3.10")) {
    try {
        & py "-$v" --version *> $null
        if ($LASTEXITCODE -eq 0) { $py = @("py", "-$v"); break }
    } catch { }
}
if (-not $py) {
    try {
        $ver = (& python --version) 2>&1
        if ($ver -match "Python 3\.(10|11|12)\.") { $py = @("python") }
    } catch { }
}
if (-not $py) {
    Write-Host "Python 3.10-3.12 not found. Install Python 3.11 from python.org (tick 'Add to PATH')." -ForegroundColor Red
    exit 1
}
Write-Host "Using: $($py -join ' ')"

Write-Host "== 2/5 Creating virtual environment (.venv) ==" -ForegroundColor Cyan
if (-not (Test-Path ".venv")) {
    & $py[0] $py[1..($py.Length - 1)] -m venv .venv
}
$venvPy = ".\.venv\Scripts\python.exe"

Write-Host "== 3/5 Installing dependencies (PyTorch is ~2.5 GB, be patient) ==" -ForegroundColor Cyan
& $venvPy -m pip install --upgrade pip
& $venvPy -m pip install -r requirements.txt

Write-Host "== 4/5 Creating project folders ==" -ForegroundColor Cyan
$dirs = @("configs", "scripts", "results", "tests",
          "src\data", "src\models", "src\fl", "src\algorithms", "src\attacks", "src\utils")
foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
$pkgs = @("src", "src\data", "src\models", "src\fl", "src\algorithms", "src\attacks", "src\utils")
foreach ($p in $pkgs) {
    $f = Join-Path $p "__init__.py"
    if (-not (Test-Path $f)) { New-Item -ItemType File -Path $f | Out-Null }
}

Write-Host "== 5/5 Verifying environment ==" -ForegroundColor Cyan
& $venvPy check_env.py

Write-Host "`nDone. Activate the environment with:  .venv\Scripts\Activate.ps1" -ForegroundColor Green
Write-Host "In VS Code: Ctrl+Shift+P -> 'Python: Select Interpreter' -> pick the .venv one."