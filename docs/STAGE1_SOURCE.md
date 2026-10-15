# Windows 阶段 1 完整源码汇编

完整方案及报告分别见 PROJECT_PLAN.md 和 STAGE1_REPORT.md。

## .github/workflows/native-windows.yml

```yaml
name: Native Windows stage 1

on:
  push:
    branches: [main]
    paths-ignore: ['docs/**', '*.md']
  pull_request:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  build:
    runs-on: windows-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      - name: Install pinned MoonBit stable
        shell: pwsh
        run: |
          $env:MOONBIT_INSTALL_VERSION = (Get-Content toolchain.version -Raw).Trim()
          Invoke-RestMethod https://cli.moonbitlang.com/install/powershell.ps1 | Invoke-Expression
          "$env:USERPROFILE\.moon\bin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append
      - name: Format, native build and Windows integration
        shell: pwsh
        run: |
          moon fmt --check
          if ($LASTEXITCODE -ne 0) { throw 'Format check failed.' }
          ./scripts/build-windows.ps1 -Smoke
      - uses: actions/upload-artifact@v4
        with:
          name: SplitEasy-Windows-stage1
          path: dist/SplitEasy.exe
          if-no-files-found: error
```

## .gitignore

```text
_build/
target/
.mooncakes/
dist/
*.mbti
*.exe
*.obj
*.pdb
```

## cmd/desktop/main.mbt

```moonbit
///|
extern "C" fn gui_subsystem() -> Unit = "se_use_gui_subsystem"

///|
fn main {
  gui_subsystem()
  if !@win32.supported() {
    println(
      "此原生界面仅支持 Windows，当前系统不能运行窗口。",
    )
    @win32.exit(1)
  }
  if !@win32.create(@shared.app_title(), true) {
    @win32.exit(1)
  }
  let label_ok = @win32.add_label(
    1000,
    @shared.ready_message(),
    24,
    28,
    690,
    68,
  )
  let button_ok = @win32.add_button(
    1001, "验证共享核心", 24, 116, 220, 44,
  )
  if !label_ok || !button_ok {
    @win32.close()
    @win32.exit(1)
  }
  let mut running = true
  while running {
    let event = @win32.next_event()
    if event == 0 {
      running = false
    } else if event < 0 {
      @win32.close()
      @win32.exit(1)
    } else if event == 1001 {
      if !@win32.set_text(1000, @shared.verified_message()) {
        @win32.close()
        @win32.exit(1)
      }
    }
  }
}
```

## cmd/desktop/moon.pkg

```text
import {
  "spliteasy/desktop/shared",
  "spliteasy/desktop/platform/win32",
}

pkgtype(kind: "executable")

supported_targets = "native"

options(
  "native-stub": [ "subsystem.c" ],
)
```

## cmd/desktop/subsystem.c

```c
#ifdef _MSC_VER
#pragma comment(linker, "/SUBSYSTEM:WINDOWS")
#pragma comment(linker, "/ENTRY:mainCRTStartup")
#endif

void se_use_gui_subsystem(void) {}
```

## cmd/smoke/main.mbt

```moonbit
///|
fn require(ok : Bool, message : String) -> Unit {
  if !ok {
    println("FAIL: " + message)
    @win32.close()
    @win32.exit(1)
  }
}

///|
fn main {
  require(@win32.supported(), "Windows required; no simulated GUI pass")
  require(
    @win32.create(@shared.app_title(), false),
    "create hidden native window",
  )
  require(
    @win32.add_label(1000, @shared.ready_message(), 24, 28, 690, 68),
    "create Unicode label",
  )
  require(
    @win32.add_button(1001, "验证共享核心", 24, 116, 220, 44),
    "create native button",
  )
  require(
    @win32.get_text(1000) == @shared.ready_message(),
    "Unicode initial roundtrip",
  )
  require(@win32.post_click(1001), "post button event")
  require(@win32.next_event() == 1001, "native event returns to MoonBit")
  require(
    @win32.set_text(1000, @shared.verified_message()),
    "MoonBit updates native text",
  )
  require(
    @win32.get_text(1000) == @shared.verified_message(),
    "Unicode updated roundtrip",
  )
  @win32.close()
  require(@win32.next_event() == 0, "window close exits message loop")
  println("PASS: Win32 Unicode + MoonBit event + shared core + close")
}
```

## cmd/smoke/moon.pkg

```text
import {
  "spliteasy/desktop/shared",
  "spliteasy/desktop/platform/win32",
}

pkgtype(kind: "executable")

supported_targets = "native"
```

## moon.mod

```text
name = "spliteasy/desktop"

version = "0.1.0"

readme = "README.md"

license = "MIT"

preferred_target = "native"

supported_targets = "+native+js"
```

## platform/win32/moon.pkg

```text
supported_targets = "native"

options(
  "native-stub": [ "win32.c" ],
)
```

## platform/win32/win32.c

```c
#include "moonbit.h"
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#define UNICODE
#define _UNICODE
#include <windows.h>
#ifdef _MSC_VER
#pragma comment(lib, "user32.lib")
#pragma comment(lib, "gdi32.lib")
#endif

static HWND se_window;
static HFONT se_font;
static int32_t se_event;

/* MoonBit strings have a length, not a guaranteed terminating NUL. */
static WCHAR *se_wide(moonbit_string_t text) {
    int32_t length = Moonbit_array_length(text);
    WCHAR *result = (WCHAR *)malloc(((size_t)length + 1) * sizeof(WCHAR));
    if (!result) return NULL;
    memcpy(result, text, (size_t)length * sizeof(WCHAR));
    result[length] = 0;
    return result;
}

static LRESULT CALLBACK se_proc(HWND window, UINT message, WPARAM w, LPARAM l) {
    if (message == WM_COMMAND && HIWORD(w) == BN_CLICKED) {
        se_event = (int32_t)LOWORD(w);
        return 0;
    }
    if (message == WM_DESTROY) {
        se_window = NULL;
        if (se_font) { DeleteObject(se_font); se_font = NULL; }
        PostQuitMessage(0);
        return 0;
    }
    return DefWindowProcW(window, message, w, l);
}

int32_t se_win_supported(void) { return 1; }

int32_t se_win_create(moonbit_string_t title, int32_t visible) {
    HINSTANCE instance = GetModuleHandleW(NULL);
    WNDCLASSW wc = {0};
    wc.lpfnWndProc = se_proc;
    wc.hInstance = instance;
    wc.lpszClassName = L"SplitEasyNativeStage1";
    wc.hCursor = LoadCursorW(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    if (!RegisterClassW(&wc) && GetLastError() != ERROR_CLASS_ALREADY_EXISTS) return 0;
    WCHAR *name = se_wide(title);
    if (!name) return 0;
    se_window = CreateWindowExW(0, wc.lpszClassName, name,
        WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 760, 360,
        NULL, NULL, instance, NULL);
    free(name);
    if (!se_window) return 0;
    se_font = CreateFontW(-18, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
        DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
        CLEARTYPE_QUALITY, DEFAULT_PITCH | FF_DONTCARE, L"Segoe UI");
    if (visible) { ShowWindow(se_window, SW_SHOW); UpdateWindow(se_window); }
    return 1;
}

int32_t se_win_add(int32_t kind, int32_t id, moonbit_string_t text,
    int32_t x, int32_t y, int32_t width, int32_t height) {
    if (!se_window) return 0;
    WCHAR *label = se_wide(text);
    if (!label) return 0;
    DWORD style = WS_CHILD | WS_VISIBLE | (kind ? WS_TABSTOP | BS_PUSHBUTTON : SS_LEFT);
    HWND control = CreateWindowExW(0, kind ? L"BUTTON" : L"STATIC", label,
        style, x, y, width, height, se_window, (HMENU)(INT_PTR)id,
        GetModuleHandleW(NULL), NULL);
    free(label);
    if (control && se_font) SendMessageW(control, WM_SETFONT, (WPARAM)se_font, TRUE);
    return control != NULL;
}

int32_t se_win_set_text(int32_t id, moonbit_string_t text) {
    if (!se_window) return 0;
    WCHAR *value = se_wide(text);
    if (!value) return 0;
    int32_t ok = SetDlgItemTextW(se_window, id, value) != 0;
    free(value);
    return ok;
}

moonbit_string_t se_win_get_text(int32_t id) {
    HWND control = se_window ? GetDlgItem(se_window, id) : NULL;
    int length = control ? GetWindowTextLengthW(control) : 0;
    WCHAR *buffer = (WCHAR *)calloc((size_t)length + 1, sizeof(WCHAR));
    if (!buffer) return moonbit_make_string_raw(0);
    int actual = control ? GetWindowTextW(control, buffer, length + 1) : 0;
    moonbit_string_t result = moonbit_make_string_raw(actual);
    memcpy(result, buffer, (size_t)actual * sizeof(WCHAR));
    free(buffer);
    return result;
}

int32_t se_win_next_event(void) {
    MSG message;
    se_event = 0;
    while (1) {
        BOOL state = GetMessageW(&message, NULL, 0, 0);
        if (state == 0) return 0;
        if (state == -1) return -1;
        if (se_window && IsDialogMessageW(se_window, &message)) {
            if (se_event) return se_event;
            continue;
        }
        TranslateMessage(&message);
        DispatchMessageW(&message);
        if (se_event) return se_event;
    }
}

int32_t se_win_post_click(int32_t id) {
    HWND control = se_window ? GetDlgItem(se_window, id) : NULL;
    return control && PostMessageW(se_window, WM_COMMAND,
        MAKEWPARAM(id, BN_CLICKED), (LPARAM)control);
}

void se_win_close(void) { if (se_window) DestroyWindow(se_window); }

#else
/* Allows compile/link checks on Linux; it deliberately does not fake a GUI. */
int32_t se_win_supported(void) { return 0; }
int32_t se_win_create(moonbit_string_t title, int32_t visible) {
    (void)title; (void)visible; return 0;
}
int32_t se_win_add(int32_t kind, int32_t id, moonbit_string_t text,
    int32_t x, int32_t y, int32_t width, int32_t height) {
    (void)kind; (void)id; (void)text; (void)x; (void)y; (void)width; (void)height;
    return 0;
}
int32_t se_win_set_text(int32_t id, moonbit_string_t text) {
    (void)id; (void)text; return 0;
}
moonbit_string_t se_win_get_text(int32_t id) {
    (void)id; return moonbit_make_string_raw(0);
}
int32_t se_win_next_event(void) { return -1; }
int32_t se_win_post_click(int32_t id) { (void)id; return 0; }
void se_win_close(void) {}
#endif

void se_process_exit(int32_t code) { exit(code); }
```

## platform/win32/win32.mbt

```moonbit
///|
extern "C" fn supported_ffi() -> Bool = "se_win_supported"

///|
#borrow(title)
extern "C" fn create_ffi(title : String, visible : Bool) -> Bool = "se_win_create"

///|
#borrow(text)
extern "C" fn add_ffi(
  kind : Int32,
  id : Int32,
  text : String,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> Bool = "se_win_add"

///|
#borrow(text)
extern "C" fn set_text_ffi(id : Int32, text : String) -> Bool = "se_win_set_text"

///|
extern "C" fn get_text_ffi(id : Int32) -> String = "se_win_get_text"

///|
extern "C" fn next_event_ffi() -> Int32 = "se_win_next_event"

///|
extern "C" fn post_click_ffi(id : Int32) -> Bool = "se_win_post_click"

///|
extern "C" fn close_ffi() -> Unit = "se_win_close"

///|
extern "C" fn exit_ffi(code : Int32) -> Unit = "se_process_exit"

///|
pub fn supported() -> Bool {
  supported_ffi()
}

///|
pub fn create(title : String, visible : Bool) -> Bool {
  create_ffi(title, visible)
}

///|
pub fn add_label(
  id : Int32,
  text : String,
  x : Int32,
  y : Int32,
  w : Int32,
  h : Int32,
) -> Bool {
  add_ffi(0, id, text, x, y, w, h)
}

///|
pub fn add_button(
  id : Int32,
  text : String,
  x : Int32,
  y : Int32,
  w : Int32,
  h : Int32,
) -> Bool {
  add_ffi(1, id, text, x, y, w, h)
}

///|
pub fn set_text(id : Int32, text : String) -> Bool {
  set_text_ffi(id, text)
}

///|
pub fn get_text(id : Int32) -> String {
  get_text_ffi(id)
}

///|
pub fn next_event() -> Int32 {
  next_event_ffi()
}

///|
pub fn post_click(id : Int32) -> Bool {
  post_click_ffi(id)
}

///|
pub fn close() -> Unit {
  close_ffi()
}

///|
pub fn exit(code : Int32) -> Unit {
  exit_ffi(code)
}
```

## scripts/build-windows.ps1

```powershell
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
& moon version --all
if ($LASTEXITCODE -ne 0) { throw 'MoonBit is not ready.' }
& moon check --target native
if ($LASTEXITCODE -ne 0) { throw 'Native check failed.' }
& moon build --target native --release
if ($LASTEXITCODE -ne 0) { throw 'Native build failed.' }
if ($Smoke) {
    & moon run cmd/smoke --target native --release
    if ($LASTEXITCODE -ne 0) { throw 'Win32 integration smoke failed.' }
}
New-Item -ItemType Directory -Force dist | Out-Null
Copy-Item '_build/native/release/build/cmd/desktop/desktop.exe' 'dist/SplitEasy.exe' -Force
Write-Host 'Built dist/SplitEasy.exe (stage 1 startup window only)'
```

## shared/moon.pkg

```text
supported_targets = "+native+js"
```

## shared/startup.mbt

```moonbit
///|
pub fn app_title() -> String {
  "SplitEasy · AA 分账器"
}

///|
pub fn ready_message() -> String {
  "MoonBit 共享核心已连接。阶段 1：原生 Windows 窗口。"
}

///|
pub fn verified_message() -> String {
  "验证成功：按钮事件已回到 MoonBit 共享核心。"
}
```

## toolchain.version

```text
0.10.15+943464bfa
```
