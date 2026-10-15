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
 [DllImport("user32.dll")] private static extern bool EnumWindows(EnumWindow callback,IntPtr data);
 [DllImport("user32.dll")] private static extern uint GetWindowThreadProcessId(IntPtr window,out uint process);
 [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr window,uint message,IntPtr w,IntPtr l);
 private delegate bool EnumWindow(IntPtr window,IntPtr data);
 public static IntPtr WindowForProcess(int process) {
   IntPtr found=IntPtr.Zero;
   EnumWindows((window,data)=>{uint owner;GetWindowThreadProcessId(window,out owner);if(owner==(uint)process){found=window;return false;}return true;},IntPtr.Zero);
   return found;
 }
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
    # Process.MainWindowHandle excludes hidden windows; target this process explicitly.
    $window = [SplitEasyCapture]::WindowForProcess($process.Id)
    if ($window -eq [IntPtr]::Zero) { throw 'Demo window unavailable.' }
    $rect = New-Object SplitEasyCapture+RECT
    if (-not [SplitEasyCapture]::GetWindowRect($window,[ref]$rect)) { throw 'Window rectangle unavailable.' }
    $bitmap = New-Object System.Drawing.Bitmap ($rect.right-$rect.left),($rect.bottom-$rect.top)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $dc = $graphics.GetHdc()
    try {
        if (-not [SplitEasyCapture]::PrintWindow($window,$dc,2)) { throw 'Native screenshot failed.' }
    } finally { $graphics.ReleaseHdc($dc) }
    $bitmap.Save((Join-Path (Get-Location) "dist/package/$($screen.Name).png"),[System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose();$bitmap.Dispose()
    Write-Host "PASS: native screenshot $($screen.Name) (synthetic ledger, no API key)"
} finally {
    if (-not $process.HasExited) {
        $null = [SplitEasyCapture]::PostMessage($window,0x0010,[IntPtr]::Zero,[IntPtr]::Zero)
        if (-not $process.WaitForExit(10000)) { $process.Kill() }
    }
}
}
