;---programme afficheConsole.asm 
; affichage d'un message dans la console

STD_OUTPUT_HANDLE equ -11
;=======================================
; segment des données initialisées
;=======================================
segment .data 
szMsg:     db 'Bonjour console', 0       ; message
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
iCaractèresAff     resq 1       ; réserve un double mot de 8 octets
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern ExitProcess, GetStdHandle, WriteFile
Main:
    push    STD_OUTPUT_HANDLE ; code pour la réference de la console de sortie
    call    GetStdHandle      ; recherche la réference (handle) 
                              ; elle est retournée dans eax 
    push    0
    push    iCaractèresAff    ; retour nb octets affiches ?
    push    15                ; longueur du message
    push    szMsg             ; adresse du message
    push    eax               ; réference (handle) de la console
    call    WriteFile

    mov eax,[iCaractèresAff]  ; nombre d'octets affichés dans code retour
    push eax                  ; met le code retour sur la pile
    call ExitProcess          ; fin du programme 
