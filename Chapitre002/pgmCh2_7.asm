;programme pgmCh2_7
; test acces � une zone m�moire

;=======================================
; segment des donn�es initialis�es
;=======================================
segment .data 
zone1:      dw 12
;=======================================
; segment des donn�es non initialis�es
;=======================================
segment .bss
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern ExitProcess
Main:
    ;mov  eax,[zone1]
    mov eax,zone1
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; et retourne au syst�me d'exploitation
    ; le code retour peut �tre affich� dans PowerShell windows avec la commande echo $LASTEXITCODE
