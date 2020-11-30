;---programme multiplicationReg.asm 
; exemple de multiplication 

STD_OUTPUT_HANDLE equ  -11
LONGUEUR          equ 12
;=======================================
; segment des données initialisées
;=======================================
segment .data 
szTitre   db __?FILE?__, 0                         ; titre de la fenêtre
szMessRegistre:     db 'Valeur du registre :', 0   ; message
szRetourLigne:  db 10,0
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
    
    mov eax,5               ; multiplication simple non signée
    mov ebx,10
    mov edx,100
    mul ebx
    push eax
    push sZoneConv
    call conversion10        ; conversion nombre non signé
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    push edx                 ; que contient edx ?
    push sZoneConv
    call conversion10
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
                             ; élévation au carré d'un grand nombre !!
    mov eax,66000
    mul eax
    push eax
    push sZoneConv
    call conversion10        ; conversion nombre non signé
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    push edx                 ; que contient edx ?
    push sZoneConv
    call conversion10          ; conversion nombre non signé
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    mov eax,-10             ; test multiplication nombre négatif
    mov ebx,35
    mul ebx                 ; multiplication non signée
    push eax
    push sZoneConv
    call conversion10S       ; conversion nombre signé
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    push edx                 ;  que contient edx ?
    push sZoneConv
    call conversion10S       ; conversion nombre signé
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    mov eax,-10             ; multiplication nombre négatif
    mov ebx,35
    imul ebx                ; mais avec multiplication signée
    push eax
    push sZoneConv
    call conversion10S
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    push edx                 ; que contient edx ?
    push sZoneConv
    call conversion10S       ; conversion nombre signé
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    mov ecx,100             ; multiplication nombre 
    mov ebx,99
    imul ecx,ebx                ; imul accepte 2 registres
    push ecx
    push sZoneConv
    call conversion10S
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    push edx                 ; que contient edx ?
    push sZoneConv
    call conversion10S       ; conversion nombre signé
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    mov edx,314             ; multiplication nombre 
    mov eax,99
    imul ebx,eax,30         ; imul accepte 2 registres et 1 valeur immediate
    push ebx
    push sZoneConv
    call conversion10S
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    push edx                 ; que contient edx ?
    push sZoneConv
    call conversion10S       ; conversion nombre signé
    push sZoneConv
    call afficherConsole
    push szRetourLigne
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
.Fin:
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 
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
    push dword szTitre    ; Titre de la fenÃªtre
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
    sub esp,8             ; rÃ©serve 8 octets sur la pile 
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
    lea eax,[ebp-8]        ; rÃ©cupÃ¨re l'adresse de la zone rÃ©servÃ©e sur la pile
    push    eax            ; retour nb octets affiches ?
    push    ecx            ; longueur du message
    push    edx            ; adresse du message
    push    ebx            ; handle de la console
    call    WriteFile
    popf
    popa                   ; restaur des registres
    add esp,8              ; libÃ©re la place rÃ©servÃ©e sur la pile
    pop ebp
    ret 4                  ; aligne la pile car 1 push avant l'appel
    ;***************************************************
;conversion en base 10 non signée
;avec suppression des zeros inutiles
;et cadrage à gauche
;****************************************************
; parametre 1  valeur à convertir
; parametre 2  zone de conversion longueur > 11
conversion10:
    enter 0,0
    pusha                      ;sauvegarde des registres
    pushf
    mov edi,[ebp+8]            ;recup adresse de la zone de conversion
    mov BYTE [edi+LONGUEUR],0  ; 0 final dans zone de conversion
    mov eax, [ebp + 12]        ; recup de la valeur a afficher
    mov ecx,LONGUEUR-1
    mov ebx ,10
.A1:                           ; début de boucle de calcul des restes successifs
    mov edx,0                  ; division eax par 10
    ;mov ebx ,10
    div ebx
    add edx,'0'                ; conversion ascii du reste
    mov byte  [edi,ecx],dl
    dec ecx
    cmp eax,0                  ;si division encore a faire
    jne  .A1
    xor eax,eax                ; raz indice
    inc ecx
.A5:                           ; boucle de copie du résultat de ecx à LONGUEUR
    mov dl,[edi,ecx]           ; charge un caractère du résultat
    mov byte [edi,eax],dl      ; et le met au debut de la zone de conversion
    inc ecx                    ; incremente le pointeur du résultat
    inc eax                    ; incremente l'indice de reception
    cmp ecx,LONGUEUR           ; boucle jusqu'au 0 final
    jle .A5
                               ; fin
    popf
    popa                       ; restaur des registres
    leave
    ret  8                     ;alignement pile car 2 push