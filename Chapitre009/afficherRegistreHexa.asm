;---programme afficherRegistreHexa.asm 
; conversion d'un registre en hexa

STD_OUTPUT_HANDLE equ -11
LONGUEUR equ 12
;=======================================
; segment des données initialisées
;=======================================
segment .data 
szTitre        db "Win32", 0             ; titre de la fenêtre
szMsg:         db 'Valeur du registre :', 0       ; message
szRetourLigne: db 10,0
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
sZoneConv:         resb LONGUEUR
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern MessageBoxA , ExitProcess, GetStdHandle, WriteFile
Main:

    push esp
    call afficherHexa
    
    mov eax,1
    push eax
    call afficherHexa

    mov ebx,15
    push ebx
    call afficherHexa
    
    mov eax,-1
    push eax
    call afficherHexa
    
    push esp
    call afficherHexa

    
    push 0           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 
;**************************************
;affichage hexadecimal
;**************************************
afficherHexa:
    enter 0,0              ; prologue
    push eax                 ;sauvegarde des registres
    pushf
    mov eax, [ebp + 8]    ; recup de la valeur a afficher
    push eax
    push sZoneConv
    call conversion16
    push szMsg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    popf
    pop eax
    leave                    ; epilogue
    ret 4                    ; alignement pile car 1 push
;**************************************
;affichage console
;**************************************
afficherConsole:
    enter 8,0             ; reserve 8 octets pour le nombre de caractères écrits
    pusha                 ;sauvegarde des registres
    pushf
    mov edx, [ebp + 8]    ; recup de la valeur a afficher
    
    mov ecx,0             ; compteur de caractères
.B1:                      ; boucle de calcul de la longueur
    mov al,[edx,ecx]      ; charge un caractère de la chaine
    cmp al,0              ; si zéro c'est la fin de la chaine
    je .B2
    inc ecx               ; sinon incremente le compteur
    jmp .B1               ; et boucle 
.B2:
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle  ; recherche du handle de la console
    mov     ebx, eax      ; sauvé dans ebx
    push    0
    mov    eax,ebp
    sub     eax,8
    push    eax            ; retour nb octets affiches ?
    push    ecx            ; longueur du message
    push    edx            ; adresse du message
    push    ebx            ; handle de la console
    call    WriteFile
    popf
    popa                   ; restaur des registres
    leave                  ; epilogue
    ret 4                  ; alignement pile car 1 push
;***************************************************
;conversion hexa d'un registre en une chaine
;**************************************************
; parametre 1 le registre 
; parametre 2 l'adresse de la zone receptrice
TAILLE equ 8
conversion16:
    push    ebp
    mov ebp, esp
    pusha                  ;sauvegarde des registres
    pushf
    mov eax, [ebp + 12]    ; recup de la valeur a afficher
    mov edi,[ebp + 8]      ; recup adresse zone de conversion
    mov ecx,TAILLE-1
    mov ebx ,16
.A1:                       ; boucle de division par 16
    mov edx,0
    div ebx
    cmp edx,9              ; si le reste est inferieur à 10 c'est un chiffre
    jg  .A2
    add edx,'0'            ; ajout de '0' pour conversion ascii
    jmp  .A3
.A2:                       ;sinon c'est une lettre
    add edx,'A'-10 
.A3:      
    mov byte  [edi,ecx],dl ;et on place le caractere en position debut + 8
    dec ecx
    cmp ecx,0              ;si pas taille atteinte on boucle
    jge .A1
    mov byte [edi+TAILLE],0 ;sinon on ajoute 0 à la 9ieme position pour terminer la chaine
    popf                  ; fin routine
    popa                  ; restaur des registres
    pop ebp
    ret 8                 ; alignement pile car 2 push