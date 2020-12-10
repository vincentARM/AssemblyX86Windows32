;---programme rechinsertChaine.asm 
; exemples de recherche et d'insertion de  chaines de caract�res

; Pense b�te :
; codes caract�res page code 850 pour affichage console correct
; � 83h � 82h � 8Ah � 88h � 96h
;====================================
; constantes
;====================================
CHARPOS equ '@'                       ; caract�re d'insertion dans une chaine
TAILLEMAXITAS equ 5000                ; taille du tas 
;======================================
; fichier des sous routines 
;======================================
%include "../includeRoutines.asm"

;=======================================
; segment des donn�es initialis�es
;=======================================
segment .data
szMsgRegHexa:    db "Valeur de l'adresse : ",0 
szMsgReg:        db "Valeur du registre : @ ", 10,0       ; message avec caract�re d'insertion
szMessNontrouve: db "Chaine non trouv",82h,"e.",10,0
szMessTrouve:    db "Chaine trouv",82h,"e.",10,0 

szChaine1:     db "beau",0
szChaine2:     db "il fait beau aujourd'hui",0
LGCHAINE2       equ $ - szChaine2       ; calcul de la longueur de la chaine
szChaine3:     db "",0
LGCHAINE3       equ $ - szChaine3       ; calcul de la longueur de la chaine

align 4
iptTas:        dd sTas                 ; pointeur d�but du tas
;=======================================
; segment des donn�es non initialis�es
;=======================================
segment .bss
sZoneConv:         resb LONGUEUR      ; reserve LONGUEUR octets

szChaineRec:         resb 80
sTas:                resb TAILLEMAXITAS        ; r�serve tas
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern MessageBoxA , ExitProcess, GetStdHandle, WriteFile
Main:
    push esp                 ; pour verifier que la pile est toujours bien align�e
    call afficherHexa

                             ; recherche d'une chaine dans une chaine
    push szChaine1           ; adresse sous chaine  � rechercher
    push szChaine2           ; adresse chaine 
    call rechercherChaine
    cmp eax,-1               ; non trouv� ?
    jne .A1                  ;
    push szMessNontrouve
    call afficherConsole
    jmp .A2
.A1:                          ; chaine trouv�e
    mov ebx,eax               ; save position
    push szMessTrouve
    call afficherConsole

    push ebx                  ; et affichage de la position trouv�e
    push sZoneConv
    call conversion10         ; conversion decimale
    push sZoneConv
    push szMsgReg
    call insererChaine        ; insertion du r�sultat de la conversion
    push eax                  ; dans le corps du message � l'emplacement de @
    call afficherConsole
.A2:

.Fin:
    push esp                 ; pour verifier que la pile est toujours bien align�e
    call afficherHexa

    call afficherAttente
    
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 
;**************************************
;mise � jour d'un poste du tableau
;**************************************
;parametre 1 = adresse de la chaine � chercher
;parametre 2 = adresse de la chaine dans laquelle chercher
rechercherChaine:
    enter 4,0                ;prologue
    push ebx                 ;sauvegarde des registres
    push ecx
    push edx
    push edi
    push esi
    pushf
    mov edi, [ebp + 12]      ; recup adresse chaine � chercher
    mov esi, [ebp + 8]       ; recup adresse chaine
    mov ecx,0                ; indice caract�re sous chaine
    mov ebx,0                ; indice chaine
    mov DWORD[ebp-4],-1      ; index  derni�re position chaine
.A1:
    mov al,[edi+ecx]         ; charge un caract�re sous chaine
    cmp al,0
    je .A5                   ; fin sous chaine donc sous-chaine trouv�e
    mov dl,[esi+ebx]         ; charge un caractere de la chaine
    cmp dl,0
    je .A4                   ; din chaine donc sous chaine non trouv�e
    cmp al,dl 
    jne .A3
    cmp  DWORD[ebp-4],-1     ; premi�re position �gale ?
    jne .A2
    mov  [ebp-4],ebx         ; oui alors stocke la position sur la pile
.A2:
    inc ebx                  ; �galit�, incremente l'indice chaine
    inc ecx                  ; incremente l'indice sous chaine
    jmp .A1                  ; et boucle 
.A3:                         ; in�galit�
    mov ecx,0                ; r�analyse depuis le d�but de la sous chaine
    cmp  DWORD[ebp-4],-1     ; mais as-t-on stock� un debut d'�galit� de la chaine
    je .A31
    mov ebx, [ebp-4]         ; oui alors maj du pointeur chaine
.A31:
    inc ebx                  ; et increment du pointeur pour recommencer l'analyse
    mov  DWORD[ebp-4],-1     ; et remise � neutre de l'indicateur de d�but d'�galit�
    jmp .A1                  ; et boucle
.A4:
    mov eax,-1               ; chaine non trouv�e
    jmp .Fin
.A5:
    mov eax,[ebp-4]          ; chaine trouv�e et retour de la position d�but d'egalit�
.Fin:
    popf                     ; restaur des registres
    pop esi
    pop edi
    pop edx
    pop ecx
    pop ebx
    leave                     ; epilogue
    ret 8                     ; car 2 push
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
;************************************************************
;      insertion chaine dans autre chaine au d�limiteur @
;************************************************************
; le param�tre 1 contient l'adresse de la zone � inserer
; le parametre 2 contient l'adresse de la chaine r�ceptrice
; retourne dans eax l'adresse de la nouvelle chaine (sur le tas)
insererChaine:
    enter 4,0              ; prologue
%define pos1 [ebp-4]       ; position d'insertion
    push ebx               ; save registres g�n�raux
    push ecx
    push edx
    push edi
    push esi
    pushf                  ; save indicateurs

    mov edi,[iptTas]       ; adresse du tas pour stockage chaine finale
    mov eax,[ebp + 12]     ; recup adresse de la chaine 1
    mov ecx,0
.A1:                       ; boucle de calcul de la longueur
    cmp byte[eax+ecx],0
    je .A2                 ; z�ro final ?
    inc ecx
    jmp .A1
.A2:
    mov ebx,ecx            ; save longueur chaine 1
    mov eax,[ebp + 8]      ; recup de l'adresse chaine 2
    mov ecx,0
.A3:                       ; boucle de calcul de la longueur chaine 2
    cmp byte[eax+ecx],0
    je .A4                 ; z�ro final ?
    inc ecx
    jmp .A3
.A4:
    add ebx,ecx           ; + longueur chaine 2
    cmp ebx,TAILLEMAXITAS ; verification si pas d�passement de la taille
    jge .A99              ; tas trop petit
    add ebx,edi           ; + adresse d�but tas
    inc ebx               ; pour le z�ro final
    mov [iptTas],ebx      ; maj nouvelle adresse du tas
                         ; copie d�but chaine jusqu'au caract�re insertion
    mov esi,[ebp + 8]    ; recup de l'adresse chaine 2    
    mov ecx,0
.A5:                     ; boucle de copie
    mov al,[esi+ecx]
    cmp al,0             ; z�ro final ?
    je .A98              ; si oui -> erreur
    cmp al,CHARPOS       ; caract�re d'insertion ?
    je .A6               ; oui -> suite
    mov [edi+ecx],al     ; sinon copie
    inc ecx
    jmp .A5              ; et boucle
.A6:
    mov ebx,ecx          ; position d�part insertion
    mov pos1,ecx         ; et on garde la position pour copie de la fin
    mov ecx,0
    mov esi,[ebp + 12]   ; recup de l'adresse chaine 1
.A7:                     ; boucle de copie de la chaine � inserer 
    mov al,[esi+ecx]
    cmp al,0             ; zero final ?
    je .A8
    mov [edi+ebx],al     ; copie caract�re
    inc ebx
    inc ecx
    jmp .A7              ; et boucle
.A8:                     ; insertion fin chaine 2
    mov ecx,pos1         ; r�cup�ration position 
    inc ecx              ; pour sauter le caract�re d'insertion
    mov esi,[ebp + 8]    ; recup de l'adresse chaine 2     
.A9:                     ; boucle de copie
    mov al,[esi+ecx]
    mov [edi+ebx],al
    cmp al,0             ; zero final ?
    je .A10
    inc ebx
    inc ecx
    jmp .A9              ; et boucle
.A10:
    mov eax,edi          ; retourne l'adresse d�but de zone du tas
    jmp .A100
.A98:                    ; caract�re d'insertion non trouv�
    push szMessPBCarIns
    call afficherConsole
    mov eax,0
    jmp .A100
.A99:                    ; erreur d'allocation tas trop petit !!
    push szMessPBAlloc
    call afficherConsole
    mov eax,0
.A100:    
    popf                 ; restaur indicateurs
    pop esi              ; restaur registres g�n�raux
    pop edi  
    pop edx
    pop ecx
    pop ebx
    leave                ; epilogue
    ret 8                ; car 2 param�tres en entr�e
szMessPBCarIns:  db "Caract",8Ah,"re d'insertion non trouv",82h," !!",10,0
szMessPBAlloc:   db "Probl",8Ah,"me d'allocation !!",10,0

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