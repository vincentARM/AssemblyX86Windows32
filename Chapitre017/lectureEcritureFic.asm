;---programme lectureEcritureFic.asm 
; exemple de lecture et d'écriture d'un fichier

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
szMessErrCmdE:   db "Nom du fichier entrée absent ligne de commande !!",10,0
szMessErrCmdS:   db "Nom du fichier sortie absent ligne de commande !!",10,0
szMessEcart:     db "Nombre d'octets écrits différent du nombre d'octets lus !!",10,0
szMessEcritOK:   db "Ecriture OK.",10,0
;affichage message d'erreur
szTitreErreur    db "ERREUR",0
szFormMessErr    db "Une erreur a été rencontrée code : %d à la ligne %d",0 

sBuffer:      TIMES 100  db '*'  ; buffer initialisé avec 100 * pour vérifier la fin des données lues
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
hFichierE:           resd 1
hFichierS:           resd 1
iNbarg:              resd 1
iNbByteLu:           resd 1
iNbByteEcr:          resd 1
szMessComplet:       resb 80
sNomFichierEntree:   resb 80
sNomFichierSortie:   resb 80
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern ReadConsoleA,GetLastError,wsprintfA,GetCommandLineW,CommandLineToArgvW,WideCharToMultiByte
    extern CreateFileA,ReadFile,CloseHandle
Main:
    afficherUnReg "registre esp :", esp  ; pour verifier que la pile est toujours bien alignée
                                         ; saisie d'un texte 

    call GetCommandLineW             ; recup ligne de commande brute
    
    push iNbarg                      ; contiendra le nombre d'arguments
    push eax                         ; adresse de la ligne de commande
    call CommandLineToArgvW          ; extraction arguments (ajouter au linker la lib Shell32.dll
    cmp eax,0                        ; erreur ?
    je .A99
    mov ecx,[iNbarg]                 ; récupération nombre d'arguments
    cmp ecx,3
    jge .A2
    cmp ecx,2
    jge .A1
    push szMessErrCmdE
    call afficherConsole
    jmp .Fin
.A1:
    push szMessErrCmdS
    call afficherConsole
    jmp .Fin
.A2:
    afficherUnReg "ecx=",ecx          ; et affichage
    mov ebx,[eax+4]           ; récupération adresse du 2ième argument
    mov edi,[eax+8]           ; récupération adresse du 3ième argument
                              ; puis conversion 
    push 0                    ; voir doc winapi
    push 0                    ; voir doc winapi
    push 80                   ; taille de la zone de reception
    push sNomFichierEntree    ; buffer de réception
    push -1                   ; indique la conversion de la chaine entière
    push ebx                  ; adresse de la chaîne à convertir
    push 0                    ; flags de conversion voir doc winapi
    push CP_ACP               ; system default Windows ANSI code page
    call WideCharToMultiByte  ; conversion ANSI
    mov ebx,__LINE__
    cmp eax,0                 ; erreur ?
    je .A99
    afficherMemoire "Nom du fichier ",sNomFichierEntree,2   ; afficher 2ième argument
    
    push 0
    push FILE_ATTRIBUTE_NORMAL
    push OPEN_EXISTING         ; erreur si le fichier est inexistant
    push 0
    push 0
    push GENERIC_READ
    push  sNomFichierEntree    ; nom du fichier à lire
    call  CreateFileA          ; ouverture fichier
    mov ebx,__LINE__
    cmp eax,0                  ; erreur ?
    jle .A99
    mov [hFichierE],eax        ; save du handle du fichier
    push 0                     ; voir doc winapi
    push iNbByteLu             ; nombre d'octets lus
    push 100                   ; taille du buffer
    push sBuffer               ; adresse du buffer
    push eax                   ; handle du fichier
    call  ReadFile
    mov ebx,__LINE__
    cmp eax,0                  ; erreur ?
    jle .A99
    afficherMemoire "Buffer fichier ",sBuffer,4   ; afficher buffer de lecture
    
                               ;fermeture du fichier
    push dword[hFichierE]
    call CloseHandle
    mov ebx,__LINE__
    cmp eax,0
    jle .A99
;====================================================
;**************** Ecriture **************************
; edi contient l'adresse du 3ième paramètre de la ligne de commande
                              ; puis conversion 
    push 0                    ; voir doc winapi
    push 0                    ; voir doc winapi
    push 80                   ; taille de la zone de reception
    push sNomFichierSortie    ; zone de réception
    push -1                   ; indique la conversion de la chaine entière
    push edi                  ; adresse de la chaîne à convertir
    push 0                    ; flags de conversion voir doc winapi
    push CP_ACP               ; system default Windows ANSI code page
    call WideCharToMultiByte  ; conversion ANSI
    mov ebx,__LINE__
    cmp eax,0                 ; erreur ?
    je .A99
    push 0
    push FILE_ATTRIBUTE_NORMAL
    push CREATE_ALWAYS         ; 
    push 0
    push 0
    push GENERIC_WRITE
    push  sNomFichierSortie    ; nom du fichier
    call  CreateFileA          ; ouverture fichier
    mov ebx,__LINE__
    cmp eax,0                  ; erreur ?
    jle .A99
    mov [hFichierS],eax        ; save du handle du fichier
    
    push 0
    push iNbByteEcr            ; compteur octets écrits
    push dword[iNbByteLu]      ; nombre d'octets à écrire
    push sBuffer               ; buffer
    push dword[hFichierS]      ; handle du fichier crée
    call WriteFile             ; écriture fichier
    cmp eax,0
    jle .A99
    mov eax,[iNbByteEcr]
    cmp eax,[iNbByteLu]
    je .A3                     ; ecart ?
    push szMessEcart           ; oui -> message d'érreur
    call afficherConsole
    jmp .Fin
.A3:
                               ;fermeture du fichier
    push dword[hFichierS]
    call CloseHandle
    mov ebx,__LINE__
    cmp eax,0                  ; erreur ?
    jle .A99
    
    push szMessEcritOK         ; pas d'erreur
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