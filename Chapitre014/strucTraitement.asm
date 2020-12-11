;---programme strucTraitement.asm 
; exemples de structures de traitement

; Pense bête :
; codes caractères page code 850 pour affichage console correct
; à 83h é 82h è 8Ah ê 88h ù 96h
;====================================
; constantes
;====================================

;======================================
; fichier des sous routines 
;======================================
%include "./includeRoutines.asm"

;=======================================
; segment des données initialisées
;=======================================
segment .data
szMsgRegHexa:    db "Valeur de l'adresse : ",0 
szMsgReg:        db "Valeur du registre : @ ", 10,0       ; message avec caractère d'insertion
szMessPetit:     db "Plus petit.",10,0
szMessGrand:     db "Plus grand",10,0 
szMessEgal:      db "Egal",10,0 


align 4
iCent:         dd 100
;=======================================
; segment des données non initialisées
;=======================================
segment .bss

;=======================================
; segment de code
;=======================================
segment .text
    global Main
Main:
    push esp                 ; pour verifier que la pile est toujours bien alignée
    call afficherHexa
                             ; alternative
    mov eax,5
    ;mov eax 10              ; pour test égal
    ;mov eax,20              ; pour test plus grand
    cmp eax,10               ; pour test plus petit
    jl .A1
    je .A2
    push szMessGrand         ; message si plus grand
    call afficherConsole
    jmp .A3
.A1:
    push szMessPetit          ; message si plus petit
    call afficherConsole
    jmp .A3
.A2:
    push szMessEgal           ; message si égal
    call afficherConsole
.A3:
                             ; alternative simplifié
    ;mov eax,5
    ;mov eax 10              ; pour test égal
    mov eax,20              ; pour test plus grand
    mov ebx,eax              ; pour montrer une incrementation de eax ou pas
    inc ebx
    cmp eax,10
    cmovl eax,ebx            ; si plus petit alors eax = ebx donc = eax + 1
    cmovg eax,[iCent]        ; si plus grand eax = 100 
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push szMsgReg
    call insererChaine
    push eax
    call afficherConsole
    
    ;mov eax,5
    ;mov eax 10              ; pour test égal
    mov eax,20               ; pour test plus grand
    xor ebx,ebx              ; pour raz de tout le registre
    cmp eax,10
    setge bl                 ; si plus grand ou egal alors bl = 1 sinon bl = 0
    push ebx
    push sZoneConv
    call conversion10
    push sZoneConv
    push szMsgReg
    call insererChaine
    push eax
    call afficherConsole
    
                            ; exemple de boucle
    mov eax,0               ; compteur pour verifier
    mov ecx,10              ; nombre de boucles 
.A4:
    inc eax
    loop .A4
    push eax                ; affichage du compteur
    push sZoneConv
    call conversion10
    push sZoneConv
    push szMsgReg
    call insererChaine
    push eax
    call afficherConsole
    
    
                            ; autre boucle
    mov eax,0               ; compteur pour verifier
    mov ecx,100              ; nombre de boucles 
.A5:
    inc eax
    cmp eax,25
    loopne .A5              ; arrêt si ecx = 0 ou si eax = 25
    push eax                ; affichage du compteur
    push sZoneConv
    call conversion10
    push sZoneConv
    push szMsgReg
    call insererChaine
    push eax
    call afficherConsole
    
;====================================
; exemple récursion 
;=====================================
    push 10
    call calculerFactorielle 
    push eax                ; affichage du compteur
    push sZoneConv
    call conversion10
    push sZoneConv
    push szMsgReg
    call insererChaine
    push eax
    call afficherConsole
.Fin:
    push esp                 ; pour verifier que la pile est toujours bien alignée
    call afficherHexa

    call afficherAttente
    
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 
;**************************************
; calcul factorielle
;**************************************
calculerFactorielle:
    enter 0,0             ; prologue
    push ebx              ;sauvegarde des registres
    pushf
    mov eax, [ebp + 8]    ; recup de la valeur à calculer
    cmp eax,0             ; si zéro alors fin
    je .A99
    cmp eax,1             ; si égal à 1 alors fin
    je .A99
    mov ebx,eax           ; multiplicateur
    dec eax
    push eax              ; et calcul factorielle - 1
    call calculerFactorielle
    mul ebx               ; multiplication par le nombre courant
    jmp .A100
.A99:
    mov eax,1             ; premier calcul
.A100:
    popf
    pop ebx
    leave                 ; epilogue
    ret 4                 ; alignement pile car 1 push
;**************************************
;affichage hexadecimal
;**************************************
afficherHexa:
    enter 0,0              ; prologue
    push eax                 ;sauvegarde des registres
    pushf
    mov eax, [ebp + 8]    ; recup de la valeur a afficher
    push eax
    push sZoneConv
    call conversion16
    push szMsgRegHexa
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    popf
    pop eax
    leave                    ; epilogue
    ret 4                    ; alignement pile car 1 push