;---programme nombreFloat.asm 
; exemple de calculs avec des nombres en virgule flottante

; Pense bête :
; codes caractères page code 850 pour affichage console correct
; à 83h é 82h è 8Ah ê 88h ù 96h
;====================================
; constantes
;====================================
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

WC_COMPOSITECHECK equ 200h
;====================================
; macros instructions 
;====================================
; affichage d'un libellé
%macro afficherLib 1        
    jmp %%endstr
%%str: db %1,10,0
%%endstr:
    push %%str
    call afficherConsole
%endmacro
;=========================
;affichage d'un registre
%macro afficherUnReg 2
    jmp %%endstr1
%%str1: db %1,0
%%endstr1:
    push %%str1
    call afficherConsole
    push %2
    push sZoneConv
    call conversion16
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
%endmacro
;=========================
;affichage memoire
%macro afficherMemoire 3
    jmp %%endstr2
%%str2: db %1,10,0
%%endstr2:
    push %%str2
    push %2
    push %3
    call afficherMem
%endmacro
;=========================
;affichage de tous les registres
%macro afficherRegistres 1
    jmp %%endstr3
%%str3: db %1,10,0
%%endstr3:
    push %%str3
    call afficherTousRegistres
%endmacro
;======================================
; fichier des sous routines 
;======================================
%include "./includeRoutines.asm"

;=======================================
; segment des données initialisées
;=======================================
segment .data
;affichage message d'erreur
szTitreErreur    db "ERREUR",0
szFormMessErr    db "Une erreur a été rencontrée code : %d à la ligne %d",0 

szMessResultat:  db "Resultat = @ ",10,0

dRayonEntier     dd 4
qRayon:          dq 6.5
;constantes en virgule flottante sur 8 octets
Pi               dq  3.14159265359
Deux             dq  2.0

;=======================================
; segment des données non initialisées
;=======================================
segment .bss
qResult:           resq 1
ptResult           resq 1
sBuffer:           resb 100
szMessComplet:     resb 80
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern ReadConsoleA,GetLastError,wsprintfA,GetCommandLineW,CommandLineToArgvW,WideCharToMultiByte
    extern VarBstrFromR8
Main:
    afficherUnReg "registre esp :", esp  ; pour verifier que la pile est toujours bien alignée
    
    afficherMemoire "affichage float ", Pi,2
                               ; calculer la circonférence
    finit                      ; initialise à zéro tous les registres
    ;fild   dword [dRayonEntier] ; chargement d'un rayon entier
    fld    qword [qRayon]      ;  ou chargement float dans le premier registre st0
    fmul    qword [Pi]         ; multiplication du registre st0 et résultat dans st0
    fmul    qword [Deux]       ; multiplication du registre st0 et résultat dans st0
    fstp    qword [qResult]    ; stockage du registre st0 dans la zone mémoire
                               ; et dépile le résultat
    ;fst    qword [qResult]    ; stockage du registre st0 dans la zone mémoire sans dépiler
    afficherMemoire "affichage resultat ", qResult,2
    
                               ; convertir float en caractères unicode
    push ptResult              ; adresse du pointeur du résultat
    push LOCALE_NOUSEROVERRIDE
    push LOCALE_CUSTOM_DEFAULT
    push dword [qResult+4]     ; pour passer les 4 derniers octets par la pile
    push dword[qResult]        ; puis les 4 premiers octets  
    call VarBstrFromR8
                               ; conversion unicode ==> Ansi
    push 0
    push 0
    push 100                   ; taille du buffer
    push sBuffer               ; buffer du résultat ansi
    push -1
    push dword[ptResult]       ; pointeur vers zone resultat unicode
    push WC_COMPOSITECHECK
    push CP_ACP
    call WideCharToMultiByte
    mov ebx,__LINE__ - 1       ; identification de la ligne de la procédure en erreur
    cmp eax,0                  ; test si erreur
    jle .A99                   ; oui
                           
    push sBuffer               ; affichage du résultat
    push szMessResultat
    call insererChaine
    push eax
    call afficherConsole
                               ; pour voir ce que contient le registre st0
    fstp    qword [qResult]    ; stockage du registre st0 dans la zone mémoire
    afficherMemoire "affichage resultat 2 ", qResult,2
    
                               ; convertir float en caractères unicode
    push ptResult              ; adresse du pointeur du résultat
    push LOCALE_NOUSEROVERRIDE
    push LOCALE_CUSTOM_DEFAULT
    push dword [qResult+4]     ; pour passer les 4 derniers octets par la pile
    push dword[qResult]        ; puis les 4 premiers octets  
    call VarBstrFromR8
                               ; conversion unicode ==> Ansi
    push 0
    push 0
    push 100                   ; taille du buffer
    push sBuffer               ; buffer du résultat ansi
    push -1
    push dword[ptResult]       ; pointeur vers zone resultat unicode
    push WC_COMPOSITECHECK
    push CP_ACP
    call WideCharToMultiByte
    mov ebx,__LINE__ - 1       ; identification de la ligne de la procédure en erreur
    cmp eax,0                  ; test si erreur
    jle .A99                   ; oui
                           
    push sBuffer               ; affichage du résultat
    push szMessResultat
    call insererChaine
    push eax
    call afficherConsole

    jmp .Fin
.A99:
    call afficherErreur        ; affiche les erreurs 
    
.Fin:
    afficherUnReg "registre esp :", esp   ; affichage de la pile 

    call afficherAttente
    
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 

;======================================================
; affichage du code erreur 
; ebx contient le N° de ligne
;======================================================
afficherErreur:
    call GetLastError          ; recherche numero erreur
                               ;conversion du code erreur en décimal
    push ebx
    push eax
    push szFormMessErr
    push szMessComplet
    call wsprintfA
    add   esp, 16             ; dépile les  4 paramétres
                              ; affichage du message d'erreur
    push MB_OK|MB_ICONERROR   ; uType = MB_OK et icone d'erreur
    push dword szTitreErreur  ; titre de la fenetre
    push dword szMessComplet  ; message à  afficher
    push 0                    ; hWnd = HWND_DESKTOP
    call MessageBoxA
    ret 