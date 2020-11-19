;programme 3 : affichage de l'adresse définie par Main

;=======================================
; segment des données initialisées
;=======================================
segment .data 
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern ExitProcess
Main:
    mov eax,Main       ; met l'adresse définie par Main dans le registre eax
    push eax           ; met le contenu du registre sur la pile
    call ExitProcess   ; et retourne au système d'exploitation
    ; le code retour peut être affiché dans PowerShell windows avec la commande echo $LASTEXITCODE


