;---programme trtMacros.asm 
; exemples de macros instructions

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


IDABORT    equ 3   ; The Abort button was selected.
IDCANCEL   equ 2   ; The Cancel button was selected.
IDCONTINUE equ 11  ; The Continue button was selected.
IDIGNORE   equ 5   ; The Ignore button was selected.
IDNO       equ 7   ; The No button was selected.
IDOK       equ 1   ; The OK button was selected.
IDRETRY    equ 4   ; The Retry button was selected.
IDTRYAGAIN equ 10  ; The Try Again button was selected.
IDYES      equ 6   ;The Yes button was selected. 
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

szMessOUINON:   db "Répondre par oui ou par non !!",0
szMessOUI:      db "Vous avez cliqu",82h," sur oui.",10,0
szMessNON:      db "Vous avez cliqu",82h," sur non.",10,0
szMessANNUL:    db "Vous avez cliqu",82h," sur annulation.",10,0
;affichage message d'erreur
szTitreErreur   db "ERREUR",0
szFormMessErr   db "Une erreur a été rencontrée code : %d à la ligne %d",0 
 
align 4
stSaisieClavier:
    istruc bufferSaisie
      at bufferSaisie.taille, dd 100
    iend
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
;sZoneConv:         resb 24 
iNbarg:             resd 1
szMessComplet       resb 80
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern ReadConsoleA,GetLastError,wsprintfA,GetCommandLineA,CommandLineToArgvW
Main:
    afficherUnReg "registre esp :", esp  ; pour verifier que la pile est toujours bien alignée
                                         ; saisie d'un texte 
    afficherLib "Veuillez saisir un texte :"
    push stSaisieClavier
    call lectureClavier

    afficherMemoire "zone structure saisie retour ",stSaisieClavier,3

    call GetCommandLineA
    afficherMemoire "Ligne de commande ",eax,8
    ;TODO: analyse ligne de commande
    push eax
    call analyserCommande
    
    push MB_YESNOCANCEL|MB_ICONWARNING   ; 
    push dword szTitreErreur  ; titre de la fenetre
    push dword szMessOUINON  ; message à  afficher
    push 0                    ; hWnd = HWND_DESKTOP
    call MessageBoxA
    afficherUnReg "Retour message :", eax
    cmp eax,IDYES
    jne .A1
    push szMessOUI
    call afficherConsole
.A1:
    cmp eax,IDNO
    jne .A2
    push szMessNON
    call afficherConsole
.A2:
    cmp eax,IDCANCEL
    jne .A3
    push szMessANNUL
    call afficherConsole
.A3:
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
    
;============================================================   
;analyse de la ligne de commande
;============================================================
;parametre 1 : adresse ligne de commande
analyserCommande:
    enter  0,0
    pusha                  ;sauvegarde des registres
    pushf
    mov esi, [ebp + 8]     ; recup adresse de la ligne de commande
    mov ecx,0              ; indice caractère
    mov edx,0              ; top guillements
    mov edi,0              ; debut d'un parametre
.A1:
    mov al,[esi+ecx]       ; charge un caractère
    cmp al,0               ; fin de chaine ?
    je .A6
    cmp al,' '             ; séparateur de paramètre ?
    je .A4
    cmp al,'"'             ; guillemet ?
    jne .A5
    cmp dl,0               ; bascule du top guillemet
    sete dl
    jmp .A5
.A4:                       ; blanc = séparateur de paramètre
    cmp dl,1               ; mais il est entre des guillements
    je .A5                 ; donc on n'en tient pas compte
    mov byte [esi+ecx],0   ; sinon remplacement par un zéro final
    add edi,esi            ; ajout du début paramètre au début ligne commande
    push edi
    call afficherConsole   ; pour l'afficher
    push szRetourLigne
    call afficherConsole
    mov edi,ecx            ; puis mise à jour du nouveau début de paramètre
    inc edi
.A5:                       ; boucle autre caractère
    inc ecx
    jmp .A1
.A6:                       ; fin de la ligne de commande
    add edi,esi
    push edi               ; affichage du dernier paramètre
    call afficherConsole
    push szRetourLigne
    call afficherConsole
.Fin:   
    popf
    popa                   ; restaur des registres
    leave
    ret 4                  ; car un push
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