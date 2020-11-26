;---programme afficherRegistreS.asm 
; affichage dÈcimal signÈ du contenu d'un registre

STD_OUTPUT_HANDLE equ  -11
LONGUEUR          equ 12
;=======================================
; segment des donnÈes initialisÈes
;=======================================
segment .data 
szTitre   db __?FILE?__, 0                         ; titre de la fenÍtre
szMessRegistre:     db 'Valeur du registre :', 0   ; message
szRetourLigne:  db 10,0
;=======================================
; segment des donnÈes non initialisÈes
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
    push +5                 ; conversion nombre positif
    push sZoneConv
    call conversion10S
    push sZoneConv         ; message ‡ afficher
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    mov eax,2147483653
    ;mov eax,-1             ; conversion nombre negatif
    push eax
    push sZoneConv
    call conversion10S
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    mov eax,10             ; test du cas de la soustraction
    mov ebx,35             ; du programme prÈcÈdent
    sub eax,ebx
    push eax
    push sZoneConv
    call conversion10S
    push sZoneConv
    call afficherConsole
    
    
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 
;***************************************************
;conversion en base 10 signÈe
;avec suppression des zeros inutiles
;****************************************************
; parametre 1  valeur ‡ convertir
; parametre 2  zone de conversion longueur > 11
conversion10S:
    enter 0,0              ; prologue
    pusha                  ;sauvegarde des registres
    pushf
    mov edi,[ebp+8]        ;recup adresse de la zone de conversion
    mov BYTE [edi+LONGUEUR],0 ; stockage 0 final
    mov eax, [ebp + 12]   ; recup de la valeur a afficher
    cmp eax,0             ; compare ‡ zÈro
    jl .A1                ; plus petit
    mov dl,'+'            ; signe positif
    jmp .A2
.A1:
    mov dl,'-'            ; signe nÈgatif
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
.A4:                         ; recopie du rÈsultat en dÈbut de zone de conversion
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
;**************************************
;affichage console
;**************************************
afficherMessage:
    push    ebp
    mov ebp, esp
    pusha                 ;sauvegarde des registres
    pushf
    mov edx, [ebp + 8]    ; recup de la valeur a afficher
    push 0                ; uType = MB_OK
    push dword szTitre    ; Titre de la fen√™tre
    push edx              ; message a afficher
    push 0                ; hWnd = HWND_DESKTOP
    call MessageBoxA
    popf
    popa                  ; restaur des registres
    pop ebp
    ret 4
;**************************************
;affichage console
;**************************************
afficherConsole:
    push    ebp
    mov ebp, esp
    sub esp,8             ; r√©serve 8 octets sur la pile 
    pusha                 ;sauvegarde des registres
    pushf
    mov edx, [ebp + 8]    ; recup de la valeur a afficher
    
    mov ecx,0             ; compteur de caract√®res
.B1:                      ; boucle de calcul de la longueur
    mov al,[edx,ecx]      ; charge un caract√®re de la chaine
    cmp al,0              ; si z√©ro c'est la fin de la chaine
    je .B2
    inc ecx               ; sinon incremente le compteur
    jmp .B1               ; et boucle 
.B2:
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle  ; recherche du handle de la console
    mov     ebx, eax      ; sauv√© dans ebx

                          ; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea eax,[ebp-8]        ; r√©cup√®re l'adresse de la zone r√©serv√©e sur la pile
    push    eax            ; retour nb octets affiches ?
    push    ecx            ; longueur du message
    push    edx            ; adresse du message
    push    ebx            ; handle de la console
    call    WriteFile
    popf
    popa                   ; restaur des registres
    add esp,8              ; lib√©re la place r√©serv√©e sur la pile
    pop ebp
    ret 4                  ; aligne la pile car 1 push avant l'appel