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
