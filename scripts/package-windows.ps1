$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$version = [regex]::Match((Get-Content moon.mod -Raw), '(?m)^version = "([^"]+)"').Groups[1].Value
if (-not $version) { throw 'Missing module version.' }
New-Item -ItemType Directory -Force dist/package | Out-Null
Copy-Item LICENSE dist/LICENSE -Force
$compiler = Get-Command ISCC.exe -ErrorAction SilentlyContinue
if ($compiler) { $compiler = $compiler.Source } else { $compiler = 'C:\Program Files (x86)\Inno Setup 6\ISCC.exe' }
if (-not (Test-Path $compiler)) { throw 'Install Inno Setup 6.7+ before packaging.' }
& $compiler "/DAppVersion=$version" packaging/spliteasy.iss
if ($LASTEXITCODE -ne 0) { throw 'Installer build failed.' }
Compress-Archive -Path dist/SplitEasy.exe,dist/spliteasy-cli.exe,dist/LICENSE,third_party -DestinationPath "dist/package/SplitEasy-$version-Windows-x64-Portable.zip" -Force
$lines = Get-ChildItem dist/package -File | Where-Object { $_.Name -like "SplitEasy-$version-*" } | ForEach-Object {
    "$((Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant())  $($_.Name)"
}
$lines | Set-Content dist/package/SHA256SUMS.txt -Encoding ascii
Write-Host "PASS: installer + portable ZIP + SHA256 ($version)"
