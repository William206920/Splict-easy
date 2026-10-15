$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class SplitEasyCapture {
 [StructLayout(LayoutKind.Sequential)] public struct RECT { public int left,top,right,bottom; }
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr window,out RECT rect);
 [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr window,IntPtr dc,uint flags);
}
'@
foreach ($screen in @(
    @{ Name='preview'; Argument='--demo' },
    @{ Name='preview-editor'; Argument='--demo-editor' },
    @{ Name='preview-ai'; Argument='--demo-ai' },
    @{ Name='preview-import'; Argument='--demo-import' }
)) {
$process = Start-Process -FilePath (Resolve-Path dist/SplitEasy.exe) -ArgumentList $screen.Argument -WindowStyle Hidden -PassThru
try {
    if (-not $process.WaitForInputIdle(15000)) { throw 'Demo GUI was not ready.' }
    $process.Refresh()
    $rect = New-Object SplitEasyCapture+RECT
    if (-not [SplitEasyCapture]::GetWindowRect($process.MainWindowHandle,[ref]$rect)) { throw 'Window rectangle unavailable.' }
    $bitmap = New-Object System.Drawing.Bitmap ($rect.right-$rect.left),($rect.bottom-$rect.top)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $dc = $graphics.GetHdc()
    try {
        if (-not [SplitEasyCapture]::PrintWindow($process.MainWindowHandle,$dc,2)) { throw 'Native screenshot failed.' }
    } finally { $graphics.ReleaseHdc($dc) }
    $bitmap.Save((Join-Path (Get-Location) "dist/package/$($screen.Name).png"),[System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose();$bitmap.Dispose()
    Write-Host "PASS: native screenshot $($screen.Name) (synthetic ledger, no API key)"
} finally {
    if (-not $process.HasExited) {
        $null = $process.CloseMainWindow()
        if (-not $process.WaitForExit(10000)) { $process.Kill() }
    }
}
}
