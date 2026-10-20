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
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr window,int show);
 [DllImport("user32.dll")] public static extern bool RedrawWindow(IntPtr window,IntPtr rect,IntPtr region,uint flags);
 [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr window,IntPtr after,int x,int y,int width,int height,uint flags);
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
    @{ Name='preview-members'; Argument='--demo-members' },
    @{ Name='preview-import'; Argument='--demo-import' },
    @{ Name='preview-review'; Argument='--demo-review' }
)) {
$process = Start-Process -FilePath (Resolve-Path dist/SplitEasy.exe) -ArgumentList $screen.Argument -WindowStyle Hidden -PassThru
try {
    if (-not $process.WaitForInputIdle(15000)) { throw 'Demo GUI was not ready.' }
    $process.Refresh()
    # Process.MainWindowHandle excludes hidden windows; target this process explicitly.
    $window = [SplitEasyCapture]::WindowForProcess($process.Id)
    if ($window -eq [IntPtr]::Zero) { throw 'Demo window unavailable.' }
    # A hidden native window has no painted surface. Show without activation only
    # for this CI capture, then force all standard controls to finish painting.
    $null = [SplitEasyCapture]::ShowWindow($window,4)
    # Capture a consistent desktop canvas even on the CI runner's small display.
    $null = [SplitEasyCapture]::SetWindowPos($window,[IntPtr]::Zero,0,0,1320,960,0x0016)
    Start-Sleep -Milliseconds 400
    $null = [SplitEasyCapture]::RedrawWindow($window,[IntPtr]::Zero,[IntPtr]::Zero,0x0185)
    $rect = New-Object SplitEasyCapture+RECT
    if (-not [SplitEasyCapture]::GetWindowRect($window,[ref]$rect)) { throw 'Window rectangle unavailable.' }
    $bitmap = New-Object System.Drawing.Bitmap ($rect.right-$rect.left),($rect.bottom-$rect.top)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $dc = $graphics.GetHdc()
    try {
        if (-not [SplitEasyCapture]::PrintWindow($window,$dc,2)) { throw 'Native screenshot failed.' }
    } finally { $graphics.ReleaseHdc($dc) }
    $colors = [System.Collections.Generic.HashSet[int]]::new()
    for ($py=20; $py -lt $bitmap.Height; $py+=30) {
        for ($px=20; $px -lt $bitmap.Width; $px+=30) {
            $null = $colors.Add($bitmap.GetPixel($px,$py).ToArgb())
        }
    }
    if ($colors.Count -lt 8) { throw 'Screenshot is blank or unpainted.' }
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
