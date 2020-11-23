;---programme affConsole1.asm 
; affichage d'un message dans la console
; avec calcul de la longueur du message

%define STD_OUTPUT_HANDLE -11
;=======================================
; segment des données initialisées
;=======================================
segment .data 
szMsg:     db 'Bonjour console.', 0       ; message
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
iCaractèresAff     resw 1       ; réserve un double mot de 4 octets
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern ExitProcess, GetStdHandle, WriteFile
Main:
    mov ecx,0                 ; compteur de caractères
.B1:                          ; boucle de calcul de la longueur
    mov al,[szMsg,ecx]  ; charge un caractère de la chaine
    cmp al,0                 ; si zéro c'est la fin de la chaine
    je .B2
    inc ecx                   ; sinon incremente le compteur
    jmp .B1                   ; et boucle 
.B2:
    push    STD_OUTPUT_HANDLE ; code pour la réference de la console de sortie
    call    GetStdHandle      ; recherche la réference (handle) 

    push    0
    push    iCaractèresAff    ; retour nb octets affiches ?
    push    ecx                ; longueur du message
    push    szMsg             ; adresse du message
    push    eax               ; réference (handle) de la console
    call    WriteFile

    mov eax,[iCaractèresAff]  ; nombre d'octets affichés dans code retour
    push eax                  ; met le code retour sur la pile
    call ExitProcess          ; fin du programme 
