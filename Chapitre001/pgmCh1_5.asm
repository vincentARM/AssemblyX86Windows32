;programme 3 : affichage de la taille d'une instruction

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
et1:
    mov ebx,et1        ; met l'adresse définie par et1 dans le registre ebx
    sub ebx,eax        ; calcule la différence
    push ebx           ; met le contenu du registre sur la pile
    call ExitProcess   ; et retourne au système d'exploitation
    ; le code retour peut être affiché dans PowerShell windows avec la commande echo $LASTEXITCODE


