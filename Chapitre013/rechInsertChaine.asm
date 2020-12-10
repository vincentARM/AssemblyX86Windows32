;---programme rechinsertChaine.asm 
; exemples de recherche et d'insertion de  chaines de caractères

; Pense bête :
; codes caractères page code 850 pour affichage console correct
; à 83h é 82h è 8Ah ê 88h ù 96h
;====================================
; constantes
;====================================
CHARPOS equ '@'                       ; caractère d'insertion dans une chaine
TAILLEMAXITAS equ 5000                ; taille du tas 
;======================================
; fichier des sous routines 
;======================================
%include "../includeRoutines.asm"

;=======================================
; segment des données initialisées
;=======================================
segment .data
szMsgRegHexa:    db "Valeur de l'adresse : ",0 
szMsgReg:        db "Valeur du registre : @ ", 10,0       ; message avec caractère d'insertion
szMessNontrouve: db "Chaine non trouv",82h,"e.",10,0
szMessTrouve:    db "Chaine trouv",82h,"e.",10,0 

szChaine1:     db "beau",0
szChaine2:     db "il fait beau aujourd'hui",0
LGCHAINE2       equ $ - szChaine2       ; calcul de la longueur de la chaine
szChaine3:     db "",0
LGCHAINE3       equ $ - szChaine3       ; calcul de la longueur de la chaine

align 4
iptTas:        dd sTas                 ; pointeur début du tas
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
sZoneConv:         resb LONGUEUR      ; reserve LONGUEUR octets

szChaineRec:         resb 80
sTas:                resb TAILLEMAXITAS        ; réserve tas
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern MessageBoxA , ExitProcess, GetStdHandle, WriteFile
Main:
    push esp                 ; pour verifier que la pile est toujours bien alignée
    call afficherHexa

                             ; recherche d'une chaine dans une chaine
    push szChaine1           ; adresse sous chaine  à rechercher
    push szChaine2           ; adresse chaine 
    call rechercherChaine
    cmp eax,-1               ; non trouvé ?
    jne .A1                  ;
    push szMessNontrouve
    call afficherConsole
    jmp .A2
.A1:                          ; chaine trouvée
    mov ebx,eax               ; save position
    push szMessTrouve
    call afficherConsole

    push ebx                  ; et affichage de la position trouvée
    push sZoneConv
    call conversion10         ; conversion decimale
    push sZoneConv
    push szMsgReg
    call insererChaine        ; insertion du résultat de la conversion
    push eax                  ; dans le corps du message à l'emplacement de @
    call afficherConsole
.A2:

.Fin:
    push esp                 ; pour verifier que la pile est toujours bien alignée
    call afficherHexa

    call afficherAttente
    
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 
;**************************************
;mise à jour d'un poste du tableau
;**************************************
;parametre 1 = adresse de la chaine à chercher
;parametre 2 = adresse de la chaine dans laquelle chercher
rechercherChaine:
    enter 4,0                ;prologue
    push ebx                 ;sauvegarde des registres
    push ecx
    push edx
    push edi
    push esi
    pushf
    mov edi, [ebp + 12]      ; recup adresse chaine à chercher
    mov esi, [ebp + 8]       ; recup adresse chaine
    mov ecx,0                ; indice caractère sous chaine
    mov ebx,0                ; indice chaine
    mov DWORD[ebp-4],-1      ; index  dernière position chaine
.A1:
    mov al,[edi+ecx]         ; charge un caractère sous chaine
    cmp al,0
    je .A5                   ; fin sous chaine donc sous-chaine trouvée
    mov dl,[esi+ebx]         ; charge un caractere de la chaine
    cmp dl,0
    je .A4                   ; din chaine donc sous chaine non trouvée
    cmp al,dl 
    jne .A3
    cmp  DWORD[ebp-4],-1     ; première position égale ?
    jne .A2
    mov  [ebp-4],ebx         ; oui alors stocke la position sur la pile
.A2:
    inc ebx                  ; égalité, incremente l'indice chaine
    inc ecx                  ; incremente l'indice sous chaine
    jmp .A1                  ; et boucle 
.A3:                         ; inégalité
    mov ecx,0                ; réanalyse depuis le début de la sous chaine
    cmp  DWORD[ebp-4],-1     ; mais as-t-on stocké un debut d'égalité de la chaine
    je .A31
    mov ebx, [ebp-4]         ; oui alors maj du pointeur chaine
.A31:
    inc ebx                  ; et increment du pointeur pour recommencer l'analyse
    mov  DWORD[ebp-4],-1     ; et remise à neutre de l'indicateur de début d'égalité
    jmp .A1                  ; et boucle
.A4:
    mov eax,-1               ; chaine non trouvée
    jmp .Fin
.A5:
    mov eax,[ebp-4]          ; chaine trouvée et retour de la position début d'egalité
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
;     comparaison de 2 chaines (dans l'ordre des caractères ascii)
;************************************************************
; paramètre1  : adresse chaine 1
; paramètre2  : adresse chaine 2
; retourne 0 dans eax si égalité -1 si chaine 1 inferieure ou +1 
comparerChaines:
    enter 0,0                 ; prologue
    push edi                  ;sauvegarde des registres
    push ecx
    push esi
    pushf
    mov edi,[ebp+12]          ; récuperation adresse chaine 1
    mov esi,[ebp+8]           ; récuperation adresse chaine 2
    xor ecx,ecx               ; raz indice
    xor eax,eax               ; raz retour
.A1:
    mov al,[edi,ecx]          ; lecture 1 caractère chaine1
    cmp byte al,[esi,ecx]     ; comparaison avec caractère chaine 2
    jl .A2                    ; plus petit ?
    jg .A3                    ; plus grand ?
    cmp al,0                  ; fin de chaine
    je .A100                  ; oui égalité eax = 0
    inc ecx                   ; caractère suivant
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
    ret 8                     ; 2 paramètres
;************************************************************
;      insertion chaine dans autre chaine au délimiteur @
;************************************************************
; le paramètre 1 contient l'adresse de la zone à inserer
; le parametre 2 contient l'adresse de la chaine réceptrice
; retourne dans eax l'adresse de la nouvelle chaine (sur le tas)
insererChaine:
    enter 4,0              ; prologue
%define pos1 [ebp-4]       ; position d'insertion
    push ebx               ; save registres généraux
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
    je .A2                 ; zéro final ?
    inc ecx
    jmp .A1
.A2:
    mov ebx,ecx            ; save longueur chaine 1
    mov eax,[ebp + 8]      ; recup de l'adresse chaine 2
    mov ecx,0
.A3:                       ; boucle de calcul de la longueur chaine 2
    cmp byte[eax+ecx],0
    je .A4                 ; zéro final ?
    inc ecx
    jmp .A3
.A4:
    add ebx,ecx           ; + longueur chaine 2
    cmp ebx,TAILLEMAXITAS ; verification si pas dépassement de la taille
    jge .A99              ; tas trop petit
    add ebx,edi           ; + adresse début tas
    inc ebx               ; pour le zéro final
    mov [iptTas],ebx      ; maj nouvelle adresse du tas
                         ; copie début chaine jusqu'au caractère insertion
    mov esi,[ebp + 8]    ; recup de l'adresse chaine 2    
    mov ecx,0
.A5:                     ; boucle de copie
    mov al,[esi+ecx]
    cmp al,0             ; zéro final ?
    je .A98              ; si oui -> erreur
    cmp al,CHARPOS       ; caractère d'insertion ?
    je .A6               ; oui -> suite
    mov [edi+ecx],al     ; sinon copie
    inc ecx
    jmp .A5              ; et boucle
.A6:
    mov ebx,ecx          ; position départ insertion
    mov pos1,ecx         ; et on garde la position pour copie de la fin
    mov ecx,0
    mov esi,[ebp + 12]   ; recup de l'adresse chaine 1
.A7:                     ; boucle de copie de la chaine à inserer 
    mov al,[esi+ecx]
    cmp al,0             ; zero final ?
    je .A8
    mov [edi+ebx],al     ; copie caractère
    inc ebx
    inc ecx
    jmp .A7              ; et boucle
.A8:                     ; insertion fin chaine 2
    mov ecx,pos1         ; récupération position 
    inc ecx              ; pour sauter le caractère d'insertion
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
    mov eax,edi          ; retourne l'adresse début de zone du tas
    jmp .A100
.A98:                    ; caractère d'insertion non trouvé
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
    pop esi              ; restaur registres généraux
    pop edi  
    pop edx
    pop ecx
    pop ebx
    leave                ; epilogue
    ret 8                ; car 2 paramètres en entrée
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