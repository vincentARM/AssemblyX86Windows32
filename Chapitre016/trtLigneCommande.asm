;---programme trtLigneCommande.asm 
; exemple extraction paramètre ligne de commande

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

CP_ACP   equ 0h
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
struc bufferSaisie           ; 
   .taille:   resd 1      ; un entier de 4 octets
   .carlus:   resd 1      ; 2 octets
   .buffer:   resb 100     ; 100 octets
   .fin:                 ; permt d'avoir la taille de la structure
endstruc

;=======================================
; segment des données initialisées
;=======================================
segment .data


;affichage message d'erreur
szTitreErreur db "ERREUR",0
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
szMessComplet:      resb 80
sBuffer:            resb 80
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern ReadConsoleA,GetLastError,wsprintfA,GetCommandLineW,CommandLineToArgvW,WideCharToMultiByte
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
    afficherUnReg "ecx=",ecx          ; et affichage
    mov ebx,[eax+4]                  ; récupération adresse du 2ième argument
    afficherMemoire "Argument 2 ",ebx,2 ; pour affichage brut
    
                              ; puis conversion 
    push 0                    ; voir doc winapi
    push 0                    ; voir doc winapi
    push 80                   ; taille de la zone de reception
    push sBuffer              ; buffer de réception
    push -1                   ; indique la conversion de la chaine entière
    push ebx                  ; adresse de la chaîne à convertir
    push 0                    ; flags de conversion voir doc winapi
    push CP_ACP               ; system default Windows ANSI code page
    call WideCharToMultiByte  ; conversion ANSI
    mov ebx,__LINE__
    cmp eax,0
    je .A99
    afficherMemoire "Buffer ",sBuffer,2   ; afficher 2ième argument
    
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