/* Native presentation only. Ledger data and every money calculation stay in MoonBit. */
#include <commctrl.h>
#include <uxtheme.h>
#ifdef _MSC_VER
#pragma comment(lib, "comctl32.lib")
#pragma comment(lib, "uxtheme.lib")
#pragma comment(linker,"/manifestdependency:\"type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")
#endif

#define SE_CANVAS RGB(245,247,251)
#define SE_INK RGB(28,39,60)
#define SE_MUTED RGB(108,122,144)
#define SE_BLUE RGB(54,101,235)
#define SE_NAV RGB(24,35,57)
#define SE_LINE RGB(228,233,241)
#define SE_WHITE RGB(255,255,255)
#define SE_SOFT RGB(237,243,255)
static HFONT se_fonts[5];
static HBRUSH se_canvas_brush, se_white_brush;

static void se_theme_free(void) {
    for(int i=0;i<5;i++)if(se_fonts[i]){DeleteObject(se_fonts[i]);se_fonts[i]=NULL;}
    if(se_canvas_brush){DeleteObject(se_canvas_brush);se_canvas_brush=NULL;}
    if(se_white_brush){DeleteObject(se_white_brush);se_white_brush=NULL;}
}
static void se_theme_init(void) {
    se_theme_free();
    int sizes[]={16,13,20,30,25};
    for(int i=0;i<5;i++)se_fonts[i]=CreateFontW(-se_scaled(sizes[i]),0,0,0,
        i>=2?FW_SEMIBOLD:FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,
        OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,DEFAULT_PITCH,L"Microsoft YaHei UI");
    se_canvas_brush=CreateSolidBrush(SE_CANVAS);
    se_white_brush=CreateSolidBrush(SE_WHITE);
}
static int se_kind(HWND c){return (int)(INT_PTR)GetPropW(c,L"se.kind");}
static void se_fill(HDC dc, RECT r, COLORREF color) {
    HBRUSH brush=CreateSolidBrush(color);FillRect(dc,&r,brush);DeleteObject(brush);
}
static void se_round(HDC dc, RECT r, COLORREF color, COLORREF line, int radius) {
    HBRUSH b=CreateSolidBrush(color);HPEN p=CreatePen(PS_SOLID,1,line);
    HGDIOBJ oldb=SelectObject(dc,b),oldp=SelectObject(dc,p);
    RoundRect(dc,r.left,r.top,r.right,r.bottom,se_scaled(radius),se_scaled(radius));
    SelectObject(dc,oldb);SelectObject(dc,oldp);DeleteObject(b);DeleteObject(p);
}
static void se_text(HDC dc,LPCWSTR s,RECT r,int font,COLORREF color,UINT align) {
    HGDIOBJ old=SelectObject(dc,se_fonts[font]);SetBkMode(dc,TRANSPARENT);SetTextColor(dc,color);
    DrawTextW(dc,s,-1,&r,align|DT_NOPREFIX);SelectObject(dc,old);
}
static LRESULT CALLBACK se_button_proc(HWND c,UINT m,WPARAM w,LPARAM l,UINT_PTR id,DWORD_PTR data) {
    (void)id;(void)data;
    if(m==WM_MOUSEMOVE && !GetPropW(c,L"se.hover")) {
        TRACKMOUSEEVENT track={sizeof(track),TME_LEAVE,c,0};TrackMouseEvent(&track);
        SetPropW(c,L"se.hover",(HANDLE)1);InvalidateRect(c,NULL,FALSE);
    }
    if(m==WM_MOUSELEAVE){RemovePropW(c,L"se.hover");InvalidateRect(c,NULL,FALSE);}
    if(m==WM_NCDESTROY){RemovePropW(c,L"se.kind");RemovePropW(c,L"se.hover");RemoveWindowSubclass(c,se_button_proc,1);}
    return DefSubclassProc(c,m,w,l);
}

static void se_draw_list(const DRAWITEMSTRUCT *d) {
    RECT r=d->rcItem;
    se_fill(d->hDC,r,SE_WHITE);
    if(d->itemID==(UINT)-1)return;
    int length=(int)SendMessageW(d->hwndItem,LB_GETTEXTLEN,d->itemID,0);
    if(length<0)return;
    WCHAR *s=(WCHAR*)calloc((size_t)length+1,sizeof(WCHAR));if(!s)return;
    SendMessageW(d->hwndItem,LB_GETTEXT,d->itemID,(LPARAM)s);
    RECT inside=r;InflateRect(&inside,-se_scaled(4),-se_scaled(3));
    if(d->itemState&ODS_SELECTED)se_round(d->hDC,inside,SE_SOFT,SE_SOFT,10);
    WCHAR *meta=wcschr(s,L'\t'),*amount=NULL;
    if(meta){*meta++=0;amount=wcschr(meta,L'\t');if(amount)*amount++=0;}
    RECT avatar={r.left+se_scaled(12),r.top+se_scaled(14),r.left+se_scaled(46),r.top+se_scaled(48)};
    se_round(d->hDC,avatar,SE_SOFT,SE_SOFT,16);
    WCHAR mark[3]={s[0],0,0};if(s[0]>=0xd800 && s[0]<=0xdbff)mark[1]=s[1];
    se_text(d->hDC,mark,avatar,0,SE_BLUE,DT_CENTER|DT_VCENTER|DT_SINGLELINE);
    RECT title={r.left+se_scaled(60),r.top+se_scaled(10),r.right-se_scaled(12),r.top+se_scaled(34)};
    int transfer=d->CtlID==41;
    if(amount && !transfer)title.right-=se_scaled(150);
    if(!meta){title.top=r.top;title.bottom=r.bottom;}
    se_text(d->hDC,s,title,0,SE_INK,DT_LEFT|DT_VCENTER|DT_SINGLELINE|DT_END_ELLIPSIS);
    if(meta){RECT sub={title.left,r.top+se_scaled(36),r.right-se_scaled(12),r.bottom-se_scaled(6)};
        se_text(d->hDC,meta,sub,1,SE_MUTED,DT_SINGLELINE|DT_END_ELLIPSIS);}
    if(amount){RECT money={transfer?title.left:title.right,r.top+se_scaled(transfer?36:12),r.right-se_scaled(14),r.top+se_scaled(transfer?60:36)};
        /* Never truncate a financial amount: use the full row's second line for long Int64 values. */
        SIZE size;HGDIOBJ old=SelectObject(d->hDC,se_fonts[0]);GetTextExtentPoint32W(d->hDC,amount,(int)wcslen(amount),&size);SelectObject(d->hDC,old);
        if(size.cx>money.right-money.left){money.left=title.left;money.top=r.top+se_scaled(35);money.bottom=r.bottom-se_scaled(5);}
        se_text(d->hDC,amount,money,0,SE_INK,DT_RIGHT|DT_SINGLELINE);}
    if((d->itemState&ODS_FOCUS)&&!(d->itemState&ODS_NOFOCUSRECT))DrawFocusRect(d->hDC,&inside);
    free(s);
}
static LRESULT se_draw(const DRAWITEMSTRUCT *d) {
    if(d->CtlType==ODT_LISTBOX){se_draw_list(d);return TRUE;}
    int k=se_kind(d->hwndItem),button=d->CtlType==ODT_BUTTON;
    RECT r=d->rcItem;int saved=SaveDC(d->hDC);
    WCHAR s[2048];GetWindowTextW(d->hwndItem,s,2048);
    COLORREF bg=SE_WHITE,fg=SE_INK;int font=0;
    if(button) {
        int nav=k==13||k==17;
        se_fill(d->hDC,r,nav?SE_NAV:SE_WHITE);
        bg=nav?SE_NAV:SE_WHITE;
        if(k==17){bg=RGB(44,65,105);fg=SE_WHITE;}
        else if(k==13)fg=RGB(182,195,215);
        else if(k==14){bg=SE_BLUE;fg=SE_WHITE;}
        if(!IsWindowEnabled(d->hwndItem)){bg=nav?SE_NAV:RGB(238,241,246);fg=RGB(151,162,180);}
        else if(d->itemState&ODS_SELECTED)bg=nav?RGB(49,71,111):RGB(222,232,255);
        else if(GetPropW(d->hwndItem,L"se.hover"))bg=k==14?RGB(41,84,210):nav?RGB(40,56,84):SE_SOFT;
        if(k==14 && (d->itemState&ODS_SELECTED))fg=SE_BLUE;
        InflateRect(&r,-1,-1);
        se_round(d->hDC,r,bg,nav||k==14?bg:SE_LINE,12);
        if(nav)r.left+=se_scaled(16);
        se_text(d->hDC,s,r,0,fg,(nav?DT_LEFT:DT_CENTER)|DT_VCENTER|DT_SINGLELINE|DT_END_ELLIPSIS);
        if((d->itemState&ODS_FOCUS)&&!(d->itemState&ODS_NOFOCUSRECT)){InflateRect(&r,-4,-4);DrawFocusRect(d->hDC,&r);}
    } else if(k==9 || k==15 || k==25) {
        se_fill(d->hDC,r,SE_CANVAS);
        if(k==15)se_fill(d->hDC,r,SE_NAV);
        else se_round(d->hDC,r,k==25?SE_BLUE:SE_WHITE,k==25?SE_BLUE:SE_LINE,18);
    } else {
        if(k==10||k==20||k==28)bg=SE_CANVAS;
        if(k==21||k==22){bg=SE_NAV;fg=k==22?SE_WHITE:RGB(143,161,187);}
        if(k==26||k==27){bg=SE_BLUE;fg=k==26?SE_WHITE:RGB(219,230,255);}
        if(k==11||k==20)fg=SE_MUTED;
        if(k==18)fg=SE_BLUE;
        if(k==10)font=4;
        if(k==12||k==26)font=3;
        if(k==19||k==22)font=2;
        if(k==11||k==20||k==21||k==27||k==28)font=1;
        if(k==28)fg=SE_MUTED;
        se_fill(d->hDC,r,bg);
        if(k==16){se_round(d->hDC,r,SE_SOFT,SE_SOFT,12);fg=SE_BLUE;font=1;}
        se_text(d->hDC,s,r,font,fg,(k==16?DT_CENTER:DT_LEFT)|DT_WORDBREAK);
    }
    RestoreDC(d->hDC,saved);return TRUE;
}
