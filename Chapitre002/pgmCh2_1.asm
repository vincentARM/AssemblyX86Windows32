;programme 3 : utilisation d'une constante

%define  CINQ    5          ; definition de la constante 5
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
    mov eax,CINQ       ; utilisation de la constante
    push eax           ; met le contenu du registre sur la pile
    call ExitProcess   ; et retourne au syst�me d'exploitation
    ; le code retour peut �tre affich� dans PowerShell windows avec la commande echo $LASTEXITCODE


