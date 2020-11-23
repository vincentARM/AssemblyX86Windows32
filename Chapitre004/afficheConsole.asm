;---programme afficheConsole.asm 
; affichage d'un message dans la console par une routine
; calcul de la longueur 
; reserve sur la pile

%define STD_OUTPUT_HANDLE -11
;=======================================
; segment des données initialisées
;=======================================
segment .data 
szTitre   db __?FILE?__, 0                             ; titre de la fenêtre
szMsg:     db 'Cliquer sur Ok pour continuer', 0       ; message
szMessConsole: db "Bonjour la console",10,"et test retour ligne",10,0
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern MessageBoxA , ExitProcess, GetStdHandle, WriteFile
Main:
    push szMessConsole         ; message à afficher
    call afficherConsole
    
    push szMsg         ; message à afficher
    call afficherMessage
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 
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
    push dword szTitre    ; Titre de la fenêtre
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
    push ebp              ; sauvegarde ebp
    mov ebp, esp          ; garde l'etat de la pile
    sub esp,8             ; reserve 8 octets sur la pile
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
    lea eax,[ebp - 8]      ; adresse de la zone réservée sur la pile
    push    eax            ; pour stocker le retour nb octets écrits 
    push    ecx            ; longueur du message
    push    edx            ; adresse du message
    push    ebx            ; handle de la console
    call    WriteFile
    popf
    popa                   ; restaur des registres
    add esp,8              ; libère la place réservée sur la pile
    pop ebp                ; restaure ebp
    ret 4                  ; aligne la pile car un push avant l'appel