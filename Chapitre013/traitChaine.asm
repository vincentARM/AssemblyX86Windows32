;---programme traitChaine.asm 
; traitement des chaines de caract�res

; Pense b�te :
; codes caract�res page code 850 pour affichage console correct
; � 83h � 82h � 8Ah � 88h � 96h
;======================================
; fichier des sous routines 
;======================================
%include "../includeRoutines.asm"

;=======================================
; segment des donn�es initialis�es
;=======================================
segment .data 
szMsgReg:        db 'Valeur du registre :', 0       ; message
LGMSGREG         equ $ - szMsgReg                   ; calcul de la longueur du message
szMessNontrouve: db "Caract",8Ah,"re non trouv",82h,".",10,0
szMessTrouve:    db "Caract",8Ah,"re trouv",82h,".",10,0
align 4

szChaine1:     db "ABCDEFGHIJKLMNO",0
szChaine2:     db "il fait beau aujourd'hui",0
LGCHAINE2       equ $ - szChaine2       ; calcul de la longueur de la chaine
szChaine3:     db "Non il fait tr�s froid",0
LGCHAINE3       equ $ - szChaine3       ; calcul de la longueur de la chaine
;=======================================
; segment des donn�es non initialis�es
;=======================================
segment .bss
sZoneConv:         resb LONGUEUR      ; reserve LONGUEUR octets

szChaineRec:         resb 80

;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern MessageBoxA , ExitProcess, GetStdHandle, WriteFile
Main:
    push esp                 ; pour verifier que la pile est toujours bien align�e
    push sZoneConv
    call conversion16        ;
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
                             ; copie d'une chaine avec le zero final
    mov ebx,szChaine1        ; adresse chaine 1
    mov edx,szChaineRec        ; adresse chaine 2
    mov ecx,0                ; indice caract�re
.A1:
    mov al,[ebx+ecx]         ; charge un caract�re
    mov [edx+ecx],al         ; stocke le caractere
    inc ecx                  ; incremente l'indice
    cmp al,0                 ; fin de chaine ?
    jne .A1                  ; non alors boucle

    push szChaineRec           ; affichage du contenu m�moire 
    push 2                   ; sur 2 bloc de 16 octets
    call afficherMem
    
                             ; copie d'une chaine sans le zero final
    mov ebx,szChaine1        ; adresse chaine 1
    mov edx,szChaineRec        ; adresse chaine 2
    mov ecx,0                ; indice caract�re
.A2:
    mov al,[ebx+ecx]         ; charge un caract�re
    cmp al,0                 ; fin de chaine ?
    je .A3                   ; oui alors fin boucle
    mov [edx+ecx],al         ; stocke le caractere
    inc ecx                  ; incremente l'indice
    jmp .A2                  ; et boucle
.A3:
                             ; autre copie de chaine
    mov esi,szChaine2        ; adresse chaine 1
    mov edi,szChaineRec      ; adresse chaine 2
.A4:
    lodsb                    ; lit un octet et incremente esi
    stosb                    ; stocke un octet et incremente edi
    cmp al,0                 ; fin de cha�ne ?
    jne .A4                  ; non alors boucle
    
    push szChaineRec           ; affichage du contenu m�moire 
    push 2                   ; sur 2 bloc de 16 octets
    call afficherMem
    
    mov esi,szChaine3        ; adresse chaine 1
    mov edi,szChaineRec      ; adresse chaine 2
    ;mov ecx,50               ; copie jusqu'a la fin
    mov ecx,5                ; copie de 5 caract�res (ou fin de chaine)
.A5:
    lodsb                    ; lit un octet et incremente esi
    stosb                    ; stocke un octet et incremente edi
    cmp al,0                 ; pour tester la fin de la chaine
    loopne .A5               ; ou loopnz possible 
    
    push szChaineRec           ; affichage du contenu m�moire 
    push 2                   ; sur 2 bloc de 16 octets
    call afficherMem
    
                             ; recherche d'un caract�re 
    mov esi,szChaine2        ; adresse chaine
    mov ecx,0                ; indice
    mov ebx,'a'              ; caract�re � rechercher
.A6:
    mov al,[esi+ecx]         ; charge un caract�re
    cmp al,bl                ; caract�re cherch� ?
    je .A7                   ; oui
    inc ecx                  ; caract�re suivant
    cmp al,0                 ; mais fin de cha�ne ?
    jne .A6                  ; non alors boucle
    push szMessNontrouve
    call afficherConsole
    jmp .A8
.A7:                          ; cract�re trouv�
    push szMessTrouve
    call afficherConsole
.A8:
                             ; autre recherche de caract�re
    mov edi,szChaine2        ; adresse chaine  attention c'est le registre edi
    ;mov eax,'z'              ; pour tester le cas non trouv�
    mov eax,'i'              ; caract�re � rechercher dans le registre eax
    mov ecx,LGCHAINE2        ; longueur chaine

    repnz scasb              ; repete la recherche tant que ecx <> 0 
    je .A9                   ; et tant que caract�re lu non �gal � al
    push szMessNontrouve
    call afficherConsole
    jmp .A10
.A9:                          ; cract�re trouv�
    push szMessTrouve
    call afficherConsole
    mov eax,LGCHAINE2
    sub eax,ecx               ; doit contenir la position du caract�re + 1
    sub eax,1
    push eax
    push sZoneConv
    call conversion10         ; conversion decimale
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
.A10:

    push szChaine1
    push szChaine2
    call comparerChaines
    push eax
    push sZoneConv
    call conversion10S         ; conversion decimale sign�e
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole

.Fin:
    push esp                 ; pour verifier que la pile est toujours bien align�e
    push sZoneConv
    call conversion16        ;
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole

    call afficherAttente
    
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 
;**************************************
;mise � jour d'un poste du tableau
;**************************************
;parametre 1 = numero du poste (commence � z�ro)
;parametre 2 = valeur 1   4 octets
;parametre 3 = valeur 2   2 octets 
;parametre 4 = valeur 3   1 octet
majPoste:
    enter 0,0                              ;prologue
    pusha                                  ;sauvegarde des registres
    pushf
    mov eax, [ebp + 20]                    ; recup num�ro de poste

    
    popf                                   ; restau des registres
    popa
    leave                                  ; epilogue
    ret 16                                 ; car 4 push
;************************************************************
;     comparaison de 2 chaines (dans l'ordre des caract�res ascii)
;************************************************************
; param�tre1  : adresse chaine 1
; param�tre2  : adresse chaine 2
; retourne 0 dans eax si �galit� -1 si chaine 1 inferieure ou +1 
comparerChaines:
    enter 0,0                 ; prologue
    push edi                  ;sauvegarde des registres
    push ecx
    push esi
    pushf
    mov edi,[ebp+12]          ; r�cuperation adresse chaine 1
    mov esi,[ebp+8]           ; r�cuperation adresse chaine 2
    xor ecx,ecx               ; raz indice
    xor eax,eax               ; raz retour
.A1:
    mov al,[edi,ecx]          ; lecture 1 caract�re chaine1
    cmp byte al,[esi,ecx]     ; comparaison avec caract�re chaine 2
    jl .A2                    ; plus petit ?
    jg .A3                    ; plus grand ?
    cmp al,0                  ; fin de chaine
    je .A100                  ; oui �galit� eax = 0
    inc ecx                   ; caract�re suivant
    jmp .A1                   ; et boucle
.A2:
    mov eax,-1                ; plus petit
    jmp .A100
.A3:
    mov eax,1                 ; plus grand
.A100:
    popf
    pop esi
    pop ecx
    pop edi                   ; restaur des registres
    leave                     ; epilogue
    ret 8                     ; 2 param�tres
