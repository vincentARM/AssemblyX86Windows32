;programme 3 : affichage de la taille d'une instruction

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
    mov eax,Main       ; met l'adresse d�finie par Main dans le registre eax
et1:
    mov ebx,et1        ; met l'adresse d�finie par et1 dans le registre ebx
    sub ebx,eax        ; calcule la diff�rence
    push ebx           ; met le contenu du registre sur la pile
    call ExitProcess   ; et retourne au syst�me d'exploitation
    ; le code retour peut �tre affich� dans PowerShell windows avec la commande echo $LASTEXITCODE


