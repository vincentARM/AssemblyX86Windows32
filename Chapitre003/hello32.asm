;---programme hello32.asm 
; affichage d'un message

;=======================================
; segment des données initialisées
;=======================================
segment .data 
szTitre  db 'Win32', 0
szTitre1 db __?FILE?__ ,0
szMsg    db 'Hello World', 0

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
    push 0              ; uType = MB_OK
    push dword szTitre1 ; Titre de la fenêtre
    push dword szMsg    ; message a afficher
    push 0              ; hWnd = HWND_DESKTOP
    call MessageBoxA
    push eax            ; met le code retour sur la pile
    call ExitProcess    ; fin du programme 

