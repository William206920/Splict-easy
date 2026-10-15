param([switch]$Smoke)
$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') { throw 'This script requires Windows.' }
Set-Location (Split-Path $PSScriptRoot -Parent)

# Enter the installed MSVC environment, without requiring a globally modified PATH.
if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path $vswhere)) { throw 'Install Visual Studio Build Tools: C++ desktop workload and Windows SDK.' }
    $vsPath = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if (-not $vsPath) { throw 'MSVC C++ tools not found.' }
    & (Join-Path $vsPath 'Common7\Tools\Launch-VsDevShell.ps1') -Arch amd64 -HostArch amd64 -SkipAutomaticLocation
}

$env:MOONBIT_NEW_NATIVE = '0'
$env:_CL_ = "$env:_CL_ /MT"
& moon version --all
if ($LASTEXITCODE -ne 0) { throw 'MoonBit is not ready.' }
& moon check --target native
if ($LASTEXITCODE -ne 0) { throw 'Native check failed.' }
& moon test --target native
if ($LASTEXITCODE -ne 0) { throw 'Native tests failed.' }
& moon build --target native --release
if ($LASTEXITCODE -ne 0) { throw 'Native build failed.' }
if ($Smoke) {
    & moon run cmd/smoke --target native --release
    if ($LASTEXITCODE -ne 0) { throw 'Win32 integration smoke failed.' }
}
New-Item -ItemType Directory -Force dist | Out-Null
Copy-Item '_build/native/release/build/cmd/desktop/desktop.exe' 'dist/SplitEasy.exe' -Force
Copy-Item '_build/native/release/build/cmd/cli/cli.exe' 'dist/spliteasy-cli.exe' -Force
& dumpbin /DEPENDENTS dist/SplitEasy.exe | Set-Content dist/dependencies.txt
& python scripts/verify_cli.py dist/spliteasy-cli.exe
if ($LASTEXITCODE -ne 0) { throw 'CLI process integration failed.' }
Write-Host 'Built native GUI + CLI; Windows integration complete'
