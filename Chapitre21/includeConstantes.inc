;=======================================
; Constantes
;=======================================
LONGUEUR equ 33
CHARPOS equ '@'                       ; caractère d'insertion dans une chaine
TAILLEMAXITAS equ 5000                ; taille du tas 

;=======================================
; Constantes API Windows
;=======================================
STD_OUTPUT_HANDLE equ -11
STD_INPUT_HANDLE  equ -10

MB_OK               equ 000h
MB_OKCANCEL         equ 001h
MB_ABORTRETRYIGNORE equ 002h
MB_YESNOCANCEL      equ 003h
MB_YESNO            equ 004h
MB_RETRYCANCEL      equ 005h
MB_ICONERROR        equ 010h
MB_ICONWARNING      equ 030h
MB_ICONINFORMATION  equ 040h

CP_ACP              equ 0h

FILE_ATTRIBUTE_READONLY   equ    0001h
FILE_ATTRIBUTE_HIDDEN     equ    0002h
FILE_ATTRIBUTE_SYSTEM     equ    0004h
FILE_ATTRIBUTE_DIRECTORY  equ    0010h
FILE_ATTRIBUTE_ARCHIVE    equ    0020h
FILE_ATTRIBUTE_NORMAL     equ    0080h
FILE_ATTRIBUTE_TEMPORARY  equ    0100h
FILE_ATTRIBUTE_COMPRESSED equ    0800h

GENERIC_READ              equ    080000000h
GENERIC_WRITE             equ    040000000h
GENERIC_EXECUTE           equ    020000000h
GENERIC_ALL               equ    010000000h

CREATE_NEW                equ    01h
CREATE_ALWAYS             equ    02h
OPEN_EXISTING             equ    03h
OPEN_ALWAYS               equ    04h
TRUNCATE_EXISTING         equ    05h

LOCALE_CUSTOM_DEFAULT     equ 0x0C00 
LOCALE_USER_DEFAULT       equ  0x400
LOCALE_NOUSEROVERRIDE     equ 2147483648

MB_COMPOSITE              equ 2
WC_COMPOSITECHECK         equ 200h

NULL    equ 0
FALSE   equ 0
TRUE    equ 1
; constantes de l'API windows pour la gestion des fenêtres
CS_VREDRAW            equ    00001h
CS_HREDRAW            equ    00002h
CS_REDRAW             equ CS_VREDRAW | CS_HREDRAW
CS_PARENTDC           equ    00080h
CS_BYTEALIGNWINDOW    equ    02000h

COLOR_BACKGROUND      equ    001h
COLOR_WINDOW          equ    005h
COLOR_3DFACE          equ    00Fh
COLOR_3DSHADOW        equ    010h
COLOR_APPWORKSPACE    equ    00Ch
COLOR_3DLIGHT         equ    016h

ES_LEFT               equ    000h
ES_MULTILINE          equ    004h
ES_AUTOVSCROLL        equ    040h

ID_EDITCHILD          equ 100

IDC_ARROW             equ    07f00h

IMAGE_BITMAP          equ 0h
IMAGE_ICON            equ 1h
LR_LOADFROMFILE       equ 10h
LR_DEFAULTSIZE        equ 40h

SM_CXSCREEN           equ    000h
SM_CYSCREEN           equ    001h
SM_CXFULLSCREEN       equ    010h
SM_CYFULLSCREEN       equ    011h

SS_LEFT               equ    00h
SS_CENTER             equ    01h
SS_RIGHT              equ    02h
SS_ICON               equ    03h
SS_BLACKFRAME         equ    07h

SW_HIDE               equ    00h
SW_SHOWNORMAL         equ    01h
SW_SHOWMINIMIZED      equ    02h
SW_SHOWMAXIMIZED      equ    03h
SW_SHOW               equ    05h
SW_RESTORE            equ    09h
SW_SHOWDEFAULT        equ    0Ah

SWP_NOSIZE            equ    001h
SWP_NOMOVE            equ    002h
SWP_NOZORDER          equ    004h
SWP_FRAMECHANGED      equ    020h
SWP_DRAWFRAME         equ    SWP_FRAMECHANGED
HWND_TOP              equ    000h

WM_CREATE             equ    0001h
WM_DESTROY            equ    0002h
WM_SIZE               equ    0005h
WM_SETTEXT            equ    000Ch
WM_PAINT              equ    000Fh
WM_CLOSE              equ    0010h
WM_QUIT               equ    0012h
WM_ERASEBKGND         equ    0014h
WM_GETMINMAXINFO      equ    0x0024
WM_NOTIFY             equ    004Eh
WM_HELP               equ    0053h
WM_NCCREATE           equ    0x0081
WM_CHAR               equ    0102h
WM_INITDIALOG         equ    0110h
WM_COMMAND            equ    0111h
WM_TIMER              equ    0113h
WM_HSCROLL            equ    0114h
WM_VSCROLL            equ    0115h
WM_MENUSELECT         equ    011Fh
WM_CTLCOLORDLG        equ    0136h
WM_MOUSEMOVE          equ    0200h
WM_LBUTTONDOWN        equ    0201h
WM_LBUTTONUP          equ    0202h
WM_LBUTTONDBLCLK      equ    0203h
WM_RBUTTONDOWN        equ    0204h
WM_RBUTTONUP          equ    0205h
WM_RBUTTONDBLCLK      equ    0206h
WM_CUT                equ    0300h
WM_COPY               equ    0301h
WM_PASTE              equ    0302h
WM_CLEAR              equ    0303h
WM_UNDO               equ    0304h
WM_USER               equ    0400h

WS_POPUP              equ    080000000h
WS_CHILD              equ    040000000h
WS_MINIMIZE           equ    020000000h
WS_VISIBLE            equ    010000000h
WS_MAXIMIZE           equ    001000000h
WS_CAPTION            equ    000C00000h
WS_BORDER             equ    000800000h
WS_DLGFRAME           equ    000400000h
WS_VSCROLL            equ    000200000h
WS_HSCROLL            equ    000100000h
WS_SYSMENU            equ    000080000h
WS_SIZEBOX            equ    000040000h
WS_TABSTOP            equ    000010000h
WS_MINIMIZEBOX        equ    000020000h
WS_MAXIMIZEBOX        equ    000010000h
WS_OVERLAPPEDWINDOW   equ    000CF0000h
WS_EX_NOPARENTNOTIFY  equ    000000004h
WS_EX_WINDOWEDGE      equ    000000100h
WS_EX_CLIENTEDGE      equ    000000200h
WS_EX_OVERLAPPEDWINDOW  equ    WS_EX_WINDOWEDGE + WS_EX_CLIENTEDGE

WS_EX_DLGMODALFRAME   equ    1


;=======================================
; Fonctions externes
;=======================================

    extern MessageBoxA , ExitProcess, GetStdHandle, WriteFile,ReadConsoleA,GetLastError
    extern wsprintfA
    
