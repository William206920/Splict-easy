#include "moonbit.h"
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#define UNICODE
#define _UNICODE
#include <windows.h>
#include <commdlg.h>
#include <wchar.h>
#ifdef _MSC_VER
#pragma comment(lib, "user32.lib")
#pragma comment(lib, "gdi32.lib")
#pragma comment(lib, "comdlg32.lib")
#endif

static HWND se_window;
static HFONT se_font;
static int32_t se_event;
static int se_dpi=96, se_scroll=0;
static int se_scaled(int n){return MulDiv(n,se_dpi,96);}
#include "theme.h"

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
    if(message==WM_DRAWITEM)return se_draw((DRAWITEMSTRUCT*)l);
    if(message==WM_MEASUREITEM){MEASUREITEMSTRUCT *m=(MEASUREITEMSTRUCT*)l;m->itemHeight=se_scaled(m->CtlID==10?58:68);return TRUE;}
    if(message==WM_ERASEBKGND){RECT r;GetClientRect(window,&r);se_fill((HDC)w,r,SE_CANVAS);return 1;}
    if(message==WM_CTLCOLORSTATIC || message==WM_CTLCOLOREDIT || message==WM_CTLCOLORLISTBOX || message==WM_CTLCOLORBTN){
        HDC dc=(HDC)w;SetTextColor(dc,SE_INK);SetBkColor(dc,SE_WHITE);return (LRESULT)se_white_brush;
    }
    if (message == WM_COMMAND && (HIWORD(w) == BN_CLICKED || HIWORD(w)==EN_CHANGE || HIWORD(w)==CBN_SELCHANGE || HIWORD(w)==LBN_SELCHANGE)) {
        se_event = (int32_t)LOWORD(w);
        return 0;
    }
    if(message==WM_TIMER){se_event=9100;return 0;}
    if(message==WM_CLOSE){se_event=9002;return 0;}
    if(message==WM_SIZE){if(w!=SIZE_MINIMIZED)se_event=9000;return 0;}
    if(message==WM_GETMINMAXINFO){MINMAXINFO *info=(MINMAXINFO*)l;info->ptMinTrackSize.x=se_scaled(780);info->ptMinTrackSize.y=se_scaled(620);return 0;}
    if(message==WM_VSCROLL || message==WM_MOUSEWHEEL){
      SCROLLINFO si={sizeof(si),SIF_ALL};GetScrollInfo(window,SB_VERT,&si);int old=si.nPos;
      if(message==WM_MOUSEWHEEL)si.nPos-=GET_WHEEL_DELTA_WPARAM(w)/WHEEL_DELTA*se_scaled(60);
      else switch(LOWORD(w)){case SB_LINEUP:si.nPos-=se_scaled(30);break;case SB_LINEDOWN:si.nPos+=se_scaled(30);break;case SB_PAGEUP:si.nPos-=(int)si.nPage;break;case SB_PAGEDOWN:si.nPos+=(int)si.nPage;break;case SB_THUMBTRACK:si.nPos=si.nTrackPos;break;}
      si.fMask=SIF_POS;SetScrollInfo(window,SB_VERT,&si,TRUE);GetScrollInfo(window,SB_VERT,&si);
      ScrollWindowEx(window,0,old-si.nPos,NULL,NULL,NULL,NULL,SW_SCROLLCHILDREN|SW_INVALIDATE|SW_ERASE);se_scroll=si.nPos;UpdateWindow(window);return 0;
    }
    if (message == WM_DESTROY) {
        se_window = NULL;
        if (se_font) { DeleteObject(se_font); se_font = NULL; }
        se_theme_free();
        PostQuitMessage(0);
        return 0;
    }
    return DefWindowProcW(window, message, w, l);
}

int32_t se_win_supported(void) { return 1; }

int32_t se_win_create(moonbit_string_t title, int32_t visible) {
    SetProcessDPIAware();
    HDC screen=GetDC(NULL);se_dpi=GetDeviceCaps(screen,LOGPIXELSX);ReleaseDC(NULL,screen);
    HINSTANCE instance = GetModuleHandleW(NULL);
    INITCOMMONCONTROLSEX common={sizeof(common),ICC_STANDARD_CLASSES};InitCommonControlsEx(&common);
    se_theme_init();
    WNDCLASSW wc = {0};
    wc.lpfnWndProc = se_proc;
    wc.hInstance = instance;
    wc.lpszClassName = L"SplitEasyNativeStage1";
    wc.hCursor = LoadCursorW(NULL, IDC_ARROW);
    wc.hbrBackground = NULL;
    if (!RegisterClassW(&wc) && GetLastError() != ERROR_CLASS_ALREADY_EXISTS) return 0;
    WCHAR *name = se_wide(title);
    if (!name) return 0;
    se_window = CreateWindowExW(0, wc.lpszClassName, name,
        WS_OVERLAPPEDWINDOW | WS_VSCROLL | WS_CLIPCHILDREN, CW_USEDEFAULT, CW_USEDEFAULT, se_scaled(1320), se_scaled(900),
        NULL, NULL, instance, NULL);
    free(name);
    if (!se_window) return 0;
    se_font = CreateFontW(-se_scaled(18), 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
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
    DWORD style=WS_CHILD|WS_VISIBLE|WS_CLIPSIBLINGS;
    const WCHAR *cls=L"STATIC";
    if(kind==1||kind==13||kind==14||kind==17){cls=L"BUTTON";style|=WS_TABSTOP|BS_OWNERDRAW;}
    else if(kind==2||kind==8){cls=L"EDIT";style|=WS_TABSTOP|WS_BORDER|ES_AUTOHSCROLL|(kind==8?ES_PASSWORD:0);}
    else if(kind==3||kind==7){cls=L"EDIT";style|=WS_TABSTOP|WS_BORDER|ES_MULTILINE|ES_AUTOVSCROLL|WS_VSCROLL|(kind==7?ES_READONLY:ES_WANTRETURN);}
    else if(kind==4){cls=L"BUTTON";style|=WS_TABSTOP|BS_AUTOCHECKBOX;}
    else if(kind==5){cls=L"COMBOBOX";style|=WS_TABSTOP|CBS_DROPDOWNLIST|WS_VSCROLL;}
    else if(kind==6){cls=L"LISTBOX";style|=WS_TABSTOP|LBS_NOTIFY|LBS_HASSTRINGS|LBS_OWNERDRAWFIXED|WS_VSCROLL|LBS_NOINTEGRALHEIGHT;}
    else if(kind>=9){style|=SS_OWNERDRAW;}
    HWND control=CreateWindowExW(0,cls,label,style,se_scaled(x),se_scaled(y)-se_scroll,se_scaled(width),se_scaled(height),se_window,(HMENU)(INT_PTR)id,GetModuleHandleW(NULL),NULL);
    if(control && (kind==2||kind==3))SendMessageW(control,EM_SETLIMITTEXT,2000000,0);
    free(label);
    if(control){
        SetPropW(control,L"se.kind",(HANDLE)(INT_PTR)kind);
        SendMessageW(control,WM_SETFONT,(WPARAM)se_fonts[0],TRUE);
        if(kind==1||kind==13||kind==14||kind==17)SetWindowSubclass(control,se_button_proc,1,0);
        if(kind==2||kind==3||kind==7||kind==8){SendMessageW(control,EM_SETMARGINS,EC_LEFTMARGIN|EC_RIGHTMARGIN,MAKELPARAM(se_scaled(10),se_scaled(10)));}
        if(kind==4||kind==5||kind==6)SetWindowTheme(control,L"Explorer",NULL);
    }
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

static moonbit_string_t se_string(const WCHAR *s){int n=(int)wcslen(s);moonbit_string_t result=moonbit_make_string_raw(n);memcpy(result,s,(size_t)n*sizeof(WCHAR));return result;}
static BOOL CALLBACK se_destroy_child(HWND child,LPARAM ignored){(void)ignored;DestroyWindow(child);return TRUE;}
void se_win_clear(void){if(se_window){EnumChildWindows(se_window,se_destroy_child,0);se_scroll=0;SetScrollPos(se_window,SB_VERT,0,TRUE);}}
int32_t se_win_width(void){RECT r;if(!se_window||!GetClientRect(se_window,&r))return 1000;return MulDiv(r.right,96,se_dpi?se_dpi:96);}
int32_t se_win_height(void){RECT r;if(!se_window||!GetClientRect(se_window,&r))return 800;return MulDiv(r.bottom,96,se_dpi?se_dpi:96);}
void se_win_resize(int32_t width,int32_t height){if(se_window)SetWindowPos(se_window,NULL,0,0,se_scaled(width),se_scaled(height),SWP_NOMOVE|SWP_NOZORDER|SWP_NOACTIVATE);}
void se_win_content(int32_t height){RECT r;GetClientRect(se_window,&r);SCROLLINFO si={sizeof(si),SIF_RANGE|SIF_PAGE|SIF_POS,0,se_scaled(height)-1,r.bottom,0,0};SetScrollInfo(se_window,SB_VERT,&si,TRUE);}
int32_t se_win_add_control(int32_t kind,int32_t id,moonbit_string_t text,int32_t x,int32_t y,int32_t w,int32_t h){return se_win_add(kind,id,text,x,y,w,h);}
int32_t se_win_flag(int32_t id,int32_t op,int32_t value){
 HWND c=GetDlgItem(se_window,id);if(!c)return -1;
 WCHAR cls[30];GetClassNameW(c,cls,30);int combo=wcscmp(cls,L"ComboBox")==0;
 if(op==0)return (int32_t)SendMessageW(c,BM_GETCHECK,0,0);
 if(op==1){SendMessageW(c,BM_SETCHECK,value?BST_CHECKED:BST_UNCHECKED,0);return 1;}
 if(op==2)return (int32_t)SendMessageW(c,combo?CB_GETCURSEL:LB_GETCURSEL,0,0);
 if(op==3)return (int32_t)SendMessageW(c,combo?CB_SETCURSEL:LB_SETCURSEL,value,0);
 if(op==4){EnableWindow(c,value);return 1;}
 if(op==5)return IsWindowEnabled(c);
 if(op==6)return (int32_t)SendMessageW(c,EM_GETPASSWORDCHAR,0,0);
 if(op==7){SetFocus(c);return 1;}
 if(op==8){RECT r;GetWindowRect(c,&r);return r.right-r.left>0&&r.bottom-r.top>0;}
 if(op==9){RECT r,client;GetWindowRect(c,&r);MapWindowPoints(NULL,se_window,(POINT*)&r,2);GetClientRect(se_window,&client);return r.left>=0&&r.right<=client.right&&r.right>r.left;}
 return -1;
}
int32_t se_win_list_add(int32_t id,moonbit_string_t text){
 HWND c=GetDlgItem(se_window,id);WCHAR cls[30];GetClassNameW(c,cls,30);WCHAR *s=se_wide(text);if(!s)return -1;
 LRESULT v=SendMessageW(c,wcscmp(cls,L"ComboBox")==0?CB_ADDSTRING:LB_ADDSTRING,0,(LPARAM)s);free(s);return (int32_t)v;
}
int32_t se_win_message(moonbit_string_t text,int32_t kind){WCHAR *s=se_wide(text);if(!s)return 0;int result=MessageBoxW(se_window,s,L"SplitEasy",kind?MB_YESNOCANCEL|MB_ICONQUESTION:MB_OK|MB_ICONINFORMATION);free(s);return result;}
moonbit_string_t se_win_file_dialog(int32_t save){
 WCHAR path[32768]=L"";OPENFILENAMEW ofn={0};ofn.lStructSize=sizeof(ofn);ofn.hwndOwner=se_window;ofn.lpstrFile=path;ofn.nMaxFile=32768;
 ofn.lpstrFilter=L"JSON / Text\0*.json;*.txt;*.md\0All files\0*.*\0";ofn.nFilterIndex=1;
 ofn.Flags=OFN_EXPLORER|OFN_PATHMUSTEXIST|(save?OFN_OVERWRITEPROMPT:OFN_FILEMUSTEXIST);ofn.lpstrDefExt=L"json";
 BOOL ok=save?GetSaveFileNameW(&ofn):GetOpenFileNameW(&ofn);if(!ok)path[0]=0;
 return se_string(path);
}
moonbit_string_t se_win_draft_path(void){
 WCHAR root[32768];DWORD n=GetEnvironmentVariableW(L"LOCALAPPDATA",root,32000);if(n==0||n>=32000)return se_string(L"");
 wcscat_s(root,32768,L"\\SplitEasy");if(!CreateDirectoryW(root,NULL)&&GetLastError()!=ERROR_ALREADY_EXISTS)return se_string(L"");
 wcscat_s(root,32768,L"\\draft.json");return se_string(root);
}
int32_t se_win_clipboard(moonbit_string_t text){
 WCHAR *s=se_wide(text);if(!s)return 0;size_t size=(wcslen(s)+1)*sizeof(WCHAR);
 HGLOBAL mem=GlobalAlloc(GMEM_MOVEABLE,size);if(!mem){free(s);return 0;}void *target=GlobalLock(mem);if(!target){GlobalFree(mem);free(s);return 0;}
 memcpy(target,s,size);GlobalUnlock(mem);free(s);if(!OpenClipboard(se_window)){GlobalFree(mem);return 0;}
 int ok=EmptyClipboard()&&SetClipboardData(CF_UNICODETEXT,mem)!=NULL;CloseClipboard();if(!ok)GlobalFree(mem);return ok;
}

void se_win_timer(int32_t enabled){if(enabled)SetTimer(se_window,7,200,NULL);else KillTimer(se_window,7);}
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
void se_win_clear(void){}
int32_t se_win_width(void){return 1000;}
int32_t se_win_height(void){return 800;}
void se_win_resize(int32_t w,int32_t h){(void)w;(void)h;}
void se_win_content(int32_t h){(void)h;}
int32_t se_win_add_control(int32_t k,int32_t i,moonbit_string_t t,int32_t x,int32_t y,int32_t w,int32_t h){return se_win_add(k,i,t,x,y,w,h);}
int32_t se_win_flag(int32_t id,int32_t op,int32_t value){(void)id;(void)op;(void)value;return -1;}
int32_t se_win_list_add(int32_t id,moonbit_string_t text){(void)id;(void)text;return -1;}
int32_t se_win_message(moonbit_string_t text,int32_t kind){(void)text;(void)kind;return 0;}
moonbit_string_t se_win_file_dialog(int32_t save){(void)save;return moonbit_make_string_raw(0);}
moonbit_string_t se_win_draft_path(void){return moonbit_make_string_raw(0);}
int32_t se_win_clipboard(moonbit_string_t text){(void)text;return 0;}

void se_win_timer(int32_t enabled){(void)enabled;}
#endif

void se_process_exit(int32_t code) { exit(code); }
