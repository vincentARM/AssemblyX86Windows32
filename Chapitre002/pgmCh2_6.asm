; exemple de boucle de totalisation
; 

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
    mov eax,0          ; init total
    mov ecx,1          ; init compteur de boucle
.A1:                   ; etiquette de début de boucle
    add eax,ecx        ; ajout du compteur au total
    inc ecx            ; incremente le compteur
    cmp ecx,5          ; compare le compteur à 5
    jle .A1            ; si plus petit ou égal boucle au label .A1
    push eax           ; si plus grand met le résultat total sur la pile
    call ExitProcess   ; et retourne au système d'exploitation
    ; le code retour peut être affiché dans PowerShell windows avec la commande echo $LASTEXITCODE
