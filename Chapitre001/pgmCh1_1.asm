;programme 1 sert � verifier le bon fonctionnement 
; du compilateur et du linker

;=======================================
; segment des donn�es initialis�es
;=======================================
segment .data 
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
    mov eax,5          ; met la valeur 25 dans le registre eax
    push eax           ; met le contenu du registre sur la pile
    call ExitProcess   ; et retourne au syst�me d'exploitation
    ; le code retour peut �tre affich� dans PowerShell windows avec la commande echo $LASTEXITCODE


