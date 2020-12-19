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
;=======================================
; Fonctions externes
;=======================================

    extern MessageBoxA , ExitProcess, GetStdHandle, WriteFile,ReadConsoleA,GetLastError
    extern wsprintfA
    
