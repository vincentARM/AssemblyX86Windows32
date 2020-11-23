;---programme afficheMessage1.asm 
; affichage d'un message par une routine
; passage de l'adresse du message par la pile

%define STD_OUTPUT_HANDLE -11
;=======================================
; segment des données initialisées
;=======================================
segment .data 
szTitre   db __?FILE?__, 0           ; titre de la fenêtre
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

    push szMsg            ; message à afficher
    call afficherMessage  ; appel de la routine
    
    push eax              ; met le code retour sur la pile
    call ExitProcess      ; fin du programme 
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
