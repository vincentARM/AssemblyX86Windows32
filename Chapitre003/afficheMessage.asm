;---programme afficheMessage.asm 
; affichage d'un message par une routine
; passage du paramètre par registre

;=======================================
; segment des données initialisées
;=======================================
segment .data 
szTitre    db __?FILE?__, 0          ; titre de la fenêtre
szMsg:     db 'Hello World', 0       ; message
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern MessageBoxA , ExitProcess
Main:

    mov eax,szMsg         ; message à afficher
    call afficherMessage

    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 
;**************************************
;        affichage message
;**************************************
; attention le contenu de eax est perdu
afficherMessage:
    push 0                ; uType = MB_OK
    push dword szTitre    ; Titre de la fenêtre
    push eax              ; message a afficher
    push 0                ; hWnd = HWND_DESKTOP
    call MessageBoxA
    ret                   ; retourne au programme appelant
