;programme 1 sert à  verifier le bon fonctionnement 
; du compilateur et du linker

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
    mov eax,12
    add eax,15         ; ajoute 15 au registre eax
    sub eax,3          ; enleve 3 au registre eax
    push eax           ; met le contenu du registre sur la pile
    call ExitProcess   ; et retourne au système d'exploitation
    ; le code retour peut être affiché dans PowerShell windows avec la commande echo $LASTEXITCODE


