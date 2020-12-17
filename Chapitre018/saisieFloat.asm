;---programme saisieFloat.asm 
; exemples de saisie d'un nombre en virgule flottante

; Pense bête :
; codes caractères page code 850 pour affichage console correct
; à 83h é 82h è 8Ah ê 88h ù 96h
;====================================
; constantes
;====================================
PUISSANCE   equ 5
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


IDABORT    equ 3   ; The Abort button was selected.
IDCANCEL   equ 2   ; The Cancel button was selected.
IDCONTINUE equ 11  ; The Continue button was selected.
IDIGNORE   equ 5   ; The Ignore button was selected.
IDNO       equ 7   ; The No button was selected.
IDOK       equ 1   ; The OK button was selected.
IDRETRY    equ 4   ; The Retry button was selected.
IDTRYAGAIN equ 10  ; The Try Again button was selected.
IDYES      equ 6   ;The Yes button was selected. 

LOCALE_CUSTOM_DEFAULT     equ 0x0C00 
LOCALE_USER_DEFAULT       equ  0x400
LOCALE_NOUSEROVERRIDE     equ 2147483648

CP_ACP              equ 0h

MB_COMPOSITE        equ 2
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

;=================================
; structures 
;=================================
struc bufferSaisie
   .taille:   resd 1      ; un entier de 4 octets
   .carlus:   resd 1      ; 2 octets
   .buffer:   resb 100    ; 100 octets
   .fin:                  ; permet d'avoir la taille de la structure
endstruc

;=======================================
; segment des données initialisées
;=======================================
segment .data
;affichage message d'erreur
szTitreErreur   db "ERREUR",0
szFormMessErr   db "Une erreur a été rencontrée code : %d à la ligne %d",0 
szFormMessResult db "Valeur : @ ",10,0
 
align 4
stSaisieClavier:
    istruc bufferSaisie
      at bufferSaisie.taille, dd 100
    iend
;constantes en virgule flottante sur 8 octets
Pi               dq  3.14159265359
Cinq             dq  5.0
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
sBuffer:            resb 100
ptResult            resq 1
iNbarg:             resd 1
qValeur:            resq 1
szMessComplet       resb 80
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern ReadConsoleA,GetLastError,wsprintfA,MultiByteToWideChar,VarR8FromStr,WideCharToMultiByte
    extern VarBstrFromR8
Main:
    afficherUnReg "registre esp :", esp  ; pour verifier que la pile est toujours bien alignée
                                         ; saisie nombre virgule flottante
    afficherLib "Veuillez saisir un nombre (exemple 5,345) :"
    push stSaisieClavier
    call lectureClavier
    mov eax,[stSaisieClavier+bufferSaisie.carlus] ; recup du nombre de caractères saisis
    sub eax,2                                     ; pour enlever le 0D0A final
    mov byte [stSaisieClavier+bufferSaisie.buffer+eax],0 ; et mettre un 0 final
    
    push 0                     ; conversion en caractère unicode
    push 0
    push 100                   ; taille du buffer
    push sBuffer               ; buffer du résultat 
    push -1
    push stSaisieClavier+bufferSaisie.buffer   ; pointeur vers zone saisie
    push MB_COMPOSITE
    push CP_ACP
    call MultiByteToWideChar
    mov ebx,__LINE__ - 1       ; identification de la ligne de la procédure en erreur
    cmp eax,0                  ; test si erreur
    jle .A99                   ; oui
                               ; conversion en float
    push qValeur               ; resultats sur 8 octets
    push LOCALE_NOUSEROVERRIDE
    push LOCALE_CUSTOM_DEFAULT   ; permet de gerer la , décimale automatiquement
    push sBuffer                ; contient la chaine a convertir
    call VarR8FromStr

    ; calcul de puissance
    mov ecx,1                   ; compteur
    fld qword [qValeur]         ; charge la valeur dans st0
.A1:
    fmul  qword [qValeur]       ; multiplication du registre st0 et résultat dans st0
    
    inc ecx                     ; incrementer compteur
    cmp ecx,PUISSANCE           ; fin ?
    jl .A1                      ; non alors boucle
    fstp qword [qValeur]
 
                                ; convertir float en caractères unicode
    push ptResult               ; adresse du pointeur du résultat
    push LOCALE_NOUSEROVERRIDE
    push LOCALE_CUSTOM_DEFAULT
    push dword [qValeur+4]      ; pour passer les 4 derniers octets par la pile
    push dword[qValeur]         ; puis les 4 premiers octets  
    call VarBstrFromR8
                                ; conversion unicode ==> Ansi
    push 0
    push 0
    push 100                    ; taille du buffer
    push sBuffer                ; buffer du résultat ansi
    push -1
    push dword[ptResult]       ; pointeur vers zone resultat unicode
    push WC_COMPOSITECHECK
    push CP_ACP
    call WideCharToMultiByte
    mov ebx,__LINE__ - 1       ; identification de la ligne de la procédure en erreur
    cmp eax,0                  ; test si erreur
    jle .A99                   ; oui
                           
    push sBuffer               ; insertion du résultat dans message du résultat
    push szFormMessResult
    call insererChaine
    push eax                   ; et affichage message
    call afficherConsole
    
 
    jmp .Fin
.A99:
    call afficherErreur                   ; affiche les erreurs 
    
.Fin:
    afficherUnReg "registre esp :", esp   ; affichage de la pile 

    call afficherAttente
    
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 


;============================================================   
;lecture chaine du clavier
;============================================================
;parametre 1 : adresse structure de saisie
lectureClavier:
    enter  0,0
    push ebx                                ;sauvegarde des registres
    push ecx
    pushf
    push    STD_INPUT_HANDLE
    call    GetStdHandle                    ; recup de handle ( STD_INPUT_HANDLE)
    mov ebx,__LINE__ - 1
    cmp eax,0
    je .A99
    push   0
    mov ebx, [ebp + 8]                      ; recup de la structure saisie
    mov ecx,ebx
    add ecx,bufferSaisie.carlus
    push ecx                                ; adresse nb octets lus
    push   dword [ebx+bufferSaisie.taille]  ; taille du buffer  
    mov ecx,ebx
    add  ecx,bufferSaisie.buffer
    push   ecx                              ; adresse du buffer
    push   eax                              ; handle récupérée plus haut 
    call   ReadConsoleA 
    mov ebx,__LINE__ - 1
    cmp eax,0
    jne .Fin
.A99:
    call afficherErreur                      ; affiche les erreurs 
    mov eax,-1                               ; code retour erreur
.Fin:   
    popf
    pop ecx
    pop ebx                                  ; restaur des registres
    leave
    ret 4
    

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