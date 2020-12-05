;---programme afficherRegistreBinaire.asm 
; conversion d'un registre en base 2
; avec routine améliorée

STD_OUTPUT_HANDLE equ -11
LONGUEUR equ 33
;=======================================
; segment des données initialisées
;=======================================
segment .data 
szTitre        db "Win32", 0             ; titre de la fenêtre
szMsgReg:      db 'Valeur du registre :', 0       ; message
szRetourLigne: db 10,0
bUn:           dw '1'
bZero:         dw '0'
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
    push esp                 ; pour verifier que la pile est bien alignée en fin de programme
    push sZoneConv
    call conversion10S       ; conversion nombre signé
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole

    
    push 7
    push sZoneConv
    call conversion2
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    xor eax,eax
    bts eax,31
    push eax
    push sZoneConv
    call conversion2
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    push esp                 ; pour verifier que la pile est bien alignée
    push sZoneConv
    call conversion10S       ; conversion nombre signé
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 

;**************************************
;affichage console
;**************************************
afficherMessage:
    push  ebp
    mov ebp, esp
    pusha                 ;sauvegarde des registres
    pushf
    mov edx, [ebp + 8]    ; recup de la valeur a afficher
    push 0                ; uType = MB_OK
    push dword szTitre    ; Titre de la fenÃªtre
    push edx              ; message a afficher
    push 0                ; hWnd = HWND_DESKTOP
    call MessageBoxA
    popf
    popa                  ; restaur des registres
    pop ebp
    ret 4                 ;alignement pile car 1 push
;**************************************
;affichage console
;**************************************
afficherConsole:
    push    ebp
    mov ebp, esp
    sub esp,8             ; reserve 8 octets pour le nombre de caractÃ¨res Ã©crits
    pusha                 ;sauvegarde des registres
    pushf
    mov edx, [ebp + 8]    ; recup de la valeur a afficher
    
    mov ecx,0             ; compteur de caractÃ¨res
.B1:                      ; boucle de calcul de la longueur
    mov al,[edx,ecx]      ; charge un caractÃ¨re de la chaine
    cmp al,0              ; si zÃ©ro c'est la fin de la chaine
    je .B2
    inc ecx               ; sinon incremente le compteur
    jmp .B1               ; et boucle 
.B2:
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle  ; recherche du handle de la console
    mov     ebx, eax      ; sauvÃ© dans ebx

                          ; WriteFile( hstdOut, message, length(message), &bytes, 0);
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
    add esp,8              ; libÃ¨re la place
    pop ebp
    ret 4                  ; alignement pile car 1 push
;***************************************************
;conversion en base 2 d'un registre en une chaine
;**************************************************
; parametre 1 le registre 
; parametre 2 l'adresse de la zone receptrice
TAILLE equ 32
conversion2:
    push    ebp
    mov ebp, esp
    pusha                  ;sauvegarde des registres
    pushf
    mov eax, [ebp + 12]    ; recup de la valeur a afficher
    mov edi,[ebp + 8]      ; recup adresse zone de conversion
    mov ecx,0
    mov ebx ,2
.A1:                       ; boucle d'extraction des bits un à un
    shl eax,1
    cmovc edx,[bUn]
    cmovnc edx,[bZero]
    mov byte  [edi,ecx],dl ;et on place le caractere en position debut + 8
    inc ecx
    cmp ecx,TAILLE              ;si pas taille atteinte on boucle
    jl .A1
    mov byte [edi+TAILLE],0 ;sinon on ajoute 0 en 32 ieme position pour terminer la chaine
    popf                  ; fin routine
    popa                  ; restaur des registres
    pop ebp
    ret 8                 ; alignement pile car 2 push
;***************************************************
;conversion en base 10 signée
;avec suppression des zeros inutiles
;****************************************************
; parametre 1  valeur à convertir
; parametre 2  zone de conversion longueur > 11
conversion10S:
    enter 0,0              ; prologue
    pusha                  ;sauvegarde des registres
    pushf
    mov edi,[ebp+8]        ;recup adresse de la zone de conversion
    mov BYTE [edi+LONGUEUR],0 ; stockage 0 final
    mov eax, [ebp + 12]   ; recup de la valeur a afficher
    cmp eax,0             ; compare à zéro
    jl .A1                ; plus petit
    mov dl,'+'            ; signe positif
    jmp .A2
.A1:
    mov dl,'-'            ; signe négatif
    neg eax               ; transforme en nombre positif
.A2:    
    mov byte [edi],dl     ; met le signe en position 0 de la zone
    mov ecx,LONGUEUR-1
    mov ebx ,10           ; diviseur
.A3:
    mov edx,0              ; division par 10
    div ebx
    add edx,'0'            ; conversion ascii du reste
    mov byte  [edi,ecx],dl ; et mise en place dans zone de conversion
    dec ecx
    cmp eax,0              ;si division encore a faire
    jne  .A3
    inc ecx
    mov eax,1
.A4:                         ; recopie du résultat en début de zone de conversion
    mov dl,[edi,ecx]
    mov byte [edi,eax],dl
    inc ecx
    inc eax
    cmp ecx,LONGUEUR         ; boucle jusqu'au 0 final
    jle .A4
                             ;fin
    popf
    popa                     ; restaur des registres
    leave                    ; epilogue
    ret  8