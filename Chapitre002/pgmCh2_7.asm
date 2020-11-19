;programme pgmCh2_7
; test acces à une zone mémoire

;=======================================
; segment des données initialisées
;=======================================
segment .data 
zone1:      dw 12
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
    mov  eax,[zone1]
    ;mov eax,zone1
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; et retourne au système d'exploitation
    ; le code retour peut être affiché dans PowerShell windows avec la commande echo $LASTEXITCODE
