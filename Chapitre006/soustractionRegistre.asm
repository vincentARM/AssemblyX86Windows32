;---programme soustractionRegistre.asm 
; conversion d'un registre
; affichage d'un message dans la console avec reserve place sur pile

STD_OUTPUT_HANDLE equ -11
LONGUEUR equ 12
;=======================================
; segment des données initialisées
;=======================================
segment .data 
szTitre           db __?FILE?__, 0               ; titre de la fenêtre
szMessPause:      db "Pour continuer cliquer sur OK",0
szMessRegistre:   db 'Valeur du registre :', 0   ; message
szMessNegatif:    db "Résultat négatif",10,0
szMessPositif:    db "Résultat positif",10,0
szMessDep:        db "Dépassement",10,0
szMessPasDep:     db "Pas de dépassement",10,0
szRetourLigne:    db 10,0
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
                                ; addition valeurs
    mov ebx,20
    sub ebx,5
    push ebx                    ; valeur à convertir
    push sZoneConv              ; zone de réception
    call conversion10           ; conversion décimale
    push szMessRegistre         ; message à afficher
    call afficherConsole
    push sZoneConv              ; zone de conversion
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
                                ;addition registres
    mov eax,15
    mov ecx,25
    sub ecx,eax
    push ecx                    ; valeur à convertir
    push sZoneConv              ; zone de réception
    call conversion10           ; conversion décimale
    push szMessRegistre         ; message à afficher
    call afficherConsole
    push sZoneConv              ; zone de conversion
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
                                ;addition plus grande valeur
    mov eax,10
    mov ebx,50
    sub eax,ebx

    push eax                    ; valeur à convertir
    push sZoneConv              ; zone de réception
    call conversion10           ; conversion décimale
    push szMessRegistre         ; message à afficher
    call afficherConsole
    push sZoneConv              ; zone de conversion
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
                                    ;addition plus grande valeur      
    mov eax,10
    mov ebx,35
    sub eax,ebx
    js negatif
    push szMessPositif
    call afficherConsole
    jmp suite
negatif:
    push szMessNegatif
    call afficherConsole
suite:
    push eax                    ; valeur à convertir
    push sZoneConv              ; zone de réception
    call conversion10           ; conversion décimale
    push szMessRegistre         ; message à afficher
    call afficherConsole
    push sZoneConv              ; zone de conversion
    call afficherConsole
    push szRetourLigne
    call afficherConsole

    mov edx,5
    dec edx                     ; decrementation d'un registre
    push edx                    ; valeur à convertir
    push sZoneConv              ; zone de réception
    call conversion10           ; conversion décimale
    push szMessRegistre         ; message à afficher
    call afficherConsole
    push sZoneConv              ; zone de conversion
    call afficherConsole
    push szRetourLigne
    call afficherConsole
                                ;pour pause
                                
    mov eax,-2147483648
    sub eax,10  
    jo depassement
    push szMessPasDep
    call afficherConsole
    jmp suite1
depassement:
    push szMessDep
    call afficherConsole
suite1:
    push eax                    ; valeur à convertir
    push sZoneConv              ; zone de réception
    call conversion10           ; conversion décimale
    push szMessRegistre         ; message à afficher
    call afficherConsole
    push sZoneConv              ; zone de conversion
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
                                ;pour pause
    push szMessPause
    call afficherMessage

    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 
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
    push dword szTitre    ; Titre de la fenêtre
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
    sub esp,8             ; reserve 8 octets pour le nombre de caractères écrits
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

                          ; WriteFile( hstdOut, message, length(message), &bytes, 0);
    push    0
    lea eax,[ebp-8]
    push    eax            ; retour nb octets affiches ?
    push    ecx            ; longueur du message
    push    edx            ; adresse du message
    push    ebx            ; handle de la console
    call    WriteFile
    popf
    popa                   ; restaur des registres
    add esp,8              ; libère la place
    pop ebp
    ret 4                  ; alignement pile car 1 push