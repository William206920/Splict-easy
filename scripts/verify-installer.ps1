$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$setup = Get-ChildItem dist/package/*-Setup.exe | Select-Object -First 1
if (-not $setup) { throw 'Installer missing.' }
$destination = Join-Path $env:TEMP ('SplitEasy-install-' + [guid]::NewGuid().ToString('N'))
$dataDir = Join-Path $env:LOCALAPPDATA 'SplitEasy'
New-Item -ItemType Directory -Force $dataDir | Out-Null
$marker = Join-Path $dataDir ('installer-test-' + [guid]::NewGuid().ToString('N') + '.txt')
Set-Content $marker 'preserve-user-data'
try {
    for ($i = 0; $i -lt 2; $i++) {
        $p = Start-Process -FilePath $setup.FullName -ArgumentList '/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART',"/DIR=`"$destination`"" -Wait -PassThru
        if ($p.ExitCode -ne 0) { throw 'Install/upgrade failed.' }
        if (-not (Test-Path (Join-Path $destination 'SplitEasy.exe'))) { throw 'Installed GUI missing.' }
        & (Join-Path $destination 'spliteasy-cli.exe') --help
        if ($LASTEXITCODE -ne 0) { throw 'Installed CLI failed.' }
        if (-not (Test-Path $marker)) { throw 'User data lost on install.' }
    }
    $p = Start-Process -FilePath (Join-Path $destination 'unins000.exe') -ArgumentList '/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART' -Wait -PassThru
    if ($p.ExitCode -ne 0) { throw 'Uninstall failed.' }
    for ($i = 0; $i -lt 40 -and (Test-Path (Join-Path $destination 'SplitEasy.exe')); $i++) { Start-Sleep -Milliseconds 500 }
    if (Test-Path (Join-Path $destination 'SplitEasy.exe')) { throw 'Uninstall left the executable.' }
    if (-not (Test-Path $marker)) { throw 'Uninstall deleted user data.' }
    Write-Host 'PASS: silent install + reinstall + installed CLI + uninstall + user data retention'
} finally {
    if (Test-Path $marker) { Remove-Item $marker -Force }
}
