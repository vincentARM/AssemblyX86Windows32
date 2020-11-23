;---programme afficheConsole.asm 
; affichage d'un message dans la console
; et affichage message avec bouton ok pour blocage execution

STD_OUTPUT_HANDLE equ -11
;=======================================
; segment des données initialisées
;=======================================
segment .data 
szMsg:     db 'Bonjour console', 0       ; message
szMessPause:    db "Cliquer sur OK pour continuer",0
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
iCaractèresAff     resq 1       ; réserve un mot de 8 octets
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern ExitProcess, GetStdHandle, WriteFile, MessageBoxA
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
    
    push szMessPause
    call afficherMessage

    mov eax,[iCaractèresAff]  ; nombre d'octets affichés dans code retour
    push eax                  ; met le code retour sur la pile
    call ExitProcess          ; fin du programme 
;**************************************
;affichage d'un message
;**************************************
; tous les registres sont sauvés mais le code retour de MessageBoxA est perdu
afficherMessage:
    push    ebp           ; sauve le registre de base de la pile
    mov ebp, esp          ; met le registre de pile dans la pile de base
    pusha                 ; sauvegarde des registres
    mov edx, [ebp + 8]    ; recup de la valeur a afficher
    push 0                ; uType = MB_OK
    push dword szTitre    ; Titre de la fenêtre
    push edx              ; message a afficher
    push 0                ; hWnd = HWND_DESKTOP
    call MessageBoxA
    popa                  ; restaur des registres
    pop ebp               ; restaur la pile de base
    ret 4                 ; retourne au programme appelant et réaligne
                          ; la pile de 4 octets car un push effectué avant l'appel
szTitre    db __?FILE?__, 0          ; titre de la fenêtre                          