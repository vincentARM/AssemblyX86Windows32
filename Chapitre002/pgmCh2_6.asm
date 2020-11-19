; exemple de boucle de totalisation
; 

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
    mov eax,0          ; init total
    mov ecx,1          ; init compteur de boucle
.A1:                   ; etiquette de d�but de boucle
    add eax,ecx        ; ajout du compteur au total
    inc ecx            ; incremente le compteur
    cmp ecx,5          ; compare le compteur � 5
    jle .A1            ; si plus petit ou �gal boucle au label .A1
    push eax           ; si plus grand met le r�sultat total sur la pile
    call ExitProcess   ; et retourne au syst�me d'exploitation
    ; le code retour peut �tre affich� dans PowerShell windows avec la commande echo $LASTEXITCODE
