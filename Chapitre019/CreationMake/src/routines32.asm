;=======================================
;fichier include des constantes
;=======================================
%include "./src/includeConstantes.inc"

;=======================================
;Structures 
;=======================================
struc bufferSaisie
   .taille:   resd 1      ; un entier de 4 octets
   .carlus:   resd 1      ; 2 octets
   .buffer:   resb 100    ; 100 octets
   .fin:                  ; permet d'avoir la taille de la structure
endstruc


;=======================================
; segment des donn�es initialis�es
;=======================================
segment .data 
szTitre:       db __?FILE?__,0
global szRetourLigne
szRetourLigne: db 10,0
szFormMessErr   db "Une erreur a �t� rencontr�e code : %d � la ligne %d",0 
;zones pour l'affichage m�moire
szTitreAffMem: db "Affichage m",82h,"moire : adresse :"
sAdr:          db "00000000  ",0
               
szBloc:        db "00000000 "
zMem:          times 16 db "00 "
               db " ",34   
zDec           times 16 db"0"
               db 34,10,13,0  
               
; message pour les indicateurs d'�tat
szMessIndicateurs:  db "Zero : "
bPos0:              db " "
                    db " Signe: "
bPosS:              db " "
                    db " Carry: "
bPosC:              db " "
                    db " Offset: "
bPosO:              db " "
                    db 10,0
; messages pour l'affichage des registres
szTitreReg:  db "affichage registres : ",0
szTexteReg: db 'eax = ' 
 valr1:    db '00000000  '
           db 'ebx = '
 valr2       db '00000000  '
           db 'ecx = '
 valr3       db '00000000  '
           db 'edx = '
 valr4       db '00000000  '
           db 10,13  ;retour ligne pour les 4 suivants
           db 'esi = '
 valr5       db '00000000  '
           db 'edi = '
 valr6       db '00000000  '
           db 'ebp = '
 valr7       db '00000000  '
           db 'esp = '
 valr8       db '00000000  '
           db 10,13
           db ' cs = '
 valr9       db '00000000  '
           db ' ds = '
 valr10       db '00000000  '
           db ' ss = '
 valr11       db '00000000  '
           db ' es = '
 valr12       db '00000000  '
 ;           db 10,13
 ;           db 'eip = '
 ;valr13       db '00000000  '
           db 10,13, 0
align 4
iptTas:             dd sTas                 ; pointeur d�but du tas
;=======================================
; segment des donn�es non initialis�es
;=======================================
segment .bss
sZoneConv:           resb 24              ; reserve octets
szMessComplet:       resb 80
sTas:                resb TAILLEMAXITAS        ; r�serve tas
;=======================================
; segment de code
;=======================================
segment .text
    ;extern MessageBoxA , ExitProcess, GetStdHandle, WriteFile
;**************************************
;affichage Message
;**************************************
afficherMessage:
    push  ebp
    mov ebp, esp
    pusha                 ;sauvegarde des registres
    pushf
    mov edx, [ebp + 8]    ; recup de la valeur a afficher
    push 0                ; uType = MB_OK
    push dword szTitre    ; Titre de la fen�tre
    push edx              ; message a afficher
    push 0                ; hWnd = HWND_DESKTOP
    call MessageBoxA
    popf
    popa                  ; restaur des registres
    pop ebp
    ret 4                 ;alignement pile car 1 push
;**************************************
;affichage console
;**************************************
afficherConsole:
    push    ebp
    mov ebp, esp
    sub esp,8             ; reserve 8 octets pour le nombre de caract�res �crits
    pusha                 ;sauvegarde des registres
    pushf
    mov edx, [ebp + 8]    ; recup de la valeur a afficher
    
    mov ecx,0             ; compteur de caract�res
.B1:                      ; boucle de calcul de la longueur
    mov al,[edx,ecx]      ; charge un caract�re de la chaine
    cmp al,0              ; si z�ro c'est la fin de la chaine
    je .B2
    inc ecx               ; sinon incremente le compteur
    jmp .B1               ; et boucle 
.B2:
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle  ; recherche du handle de la console
    mov     ebx, eax      ; sauv� dans ebx

    push    0
    mov    eax,ebp
    sub     eax,8
    push    eax            ; retour nb octets affiches ?
    push    ecx            ; longueur du message
    push    edx            ; adresse du message
    push    ebx            ; handle de la console
    call    WriteFile
    popf
    popa                   ; restaur des registres
    add esp,8              ; lib�re la place
    pop ebp
    ret 4                  ; alignement pile car 1 push
;***************************************************
;conversion en base 2 d'un registre en une chaine
;**************************************************
; parametre 1 le registre 
; parametre 2 l'adresse de la zone receptrice
TAILLEBIN equ 32
conversion2:
    push    ebp
    mov ebp, esp
    pusha                  ;sauvegarde des registres
    pushf
    mov eax,[ebp + 12]     ; recup de la valeur a afficher
    mov edi,[ebp + 8]      ; recup adresse zone de conversion
    mov ecx,0
.A1:                       ; boucle d'extraction des bits un � un
    xor edx,edx            ; raz du registre
    shl eax,1              ; extraction bit de gauche
    setc dl                ; si carry met 1 dans le registre dl 
    add dl,'0'             ; conversion ascii
    mov byte  [edi,ecx],dl ; et on place le caractere en position debut + 8
    inc ecx
    cmp ecx,TAILLEBIN      ; si pas taille atteinte on boucle
    jl .A1
    mov byte [edi+TAILLEBIN],0 ;sinon on ajoute 0 en 32 ieme position pour terminer la chaine
    popf                   ; fin routine
    popa                   ; restaur des registres
    pop ebp
    ret 8                 ; alignement pile car 2 push
;***************************************************
;conversion en base 10 sign�e
;avec suppression des zeros inutiles
;****************************************************
; parametre 1  valeur � convertir
; parametre 2  zone de conversion longueur > 11
conversion10S:
    enter 0,0              ; prologue
    pusha                  ;sauvegarde des registres
    pushf
    mov edi,[ebp+8]        ;recup adresse de la zone de conversion
    mov BYTE [edi+LONGUEUR],0 ; stockage 0 final
    mov eax, [ebp + 12]   ; recup de la valeur a afficher
    cmp eax,0             ; compare � z�ro
    jl .A1                ; plus petit
    mov dl,'+'            ; signe positif
    jmp .A2
.A1:
    mov dl,'-'            ; signe n�gatif
    neg eax               ; transforme en nombre positif
.A2:    
    mov byte [edi],dl     ; met le signe en position 0 de la zone
    mov ecx,LONGUEUR-1
    mov ebx ,10           ; diviseur
.A3:
    mov edx,0              ; division par 10
    div ebx
    add edx,'0'            ; conversion ascii du reste
    mov byte  [edi,ecx],dl ; et mise en place dans zone de conversion
    dec ecx
    cmp eax,0              ;si division encore a faire
    jne  .A3
    inc ecx
    mov eax,1
.A4:                         ; recopie du r�sultat en d�but de zone de conversion
    mov dl,[edi,ecx]
    mov byte [edi,eax],dl
    inc ecx
    inc eax
    cmp ecx,LONGUEUR         ; boucle jusqu'au 0 final
    jle .A4
                             ;fin
    popf
    popa                     ; restaur des registres
    leave                    ; epilogue
    ret  8
;***************************************************
;conversion hexa d'un registre en une chaine
;**************************************************
; parametre 1 le registre 
; parametre 2 l'adresse de la zone receptrice
TAILLEHEXA equ 8
conversion16:
    push    ebp
    mov ebp, esp
    pusha                  ;sauvegarde des registres
    pushf
    mov eax, [ebp + 12]    ; recup de la valeur a afficher
    mov edi,[ebp + 8]      ; recup adresse zone de conversion
    mov ecx,TAILLEHEXA-1
    mov ebx ,16
.A1:                       ; boucle de division par 16
    mov edx,0
    div ebx
    cmp edx,9              ; si le reste est inferieur � 10 c'est un chiffre
    jg  .A2
    add edx,'0'            ; ajout de '0' pour conversion ascii
    jmp  .A3
.A2:                       ;sinon c'est une lettre
    add edx,'A'-10 
.A3:      
    mov byte  [edi,ecx],dl ;et on place le caractere en position debut + 8
    dec ecx
    cmp ecx,0              ;si pas taille atteinte on boucle
    jge .A1
    mov byte [edi+TAILLEHEXA],0 ;sinon on ajoute 0 � la 9ieme position pour terminer la chaine
    popf                  ; fin routine
    popa                  ; restaur des registres
    pop ebp
    ret 8                 ; alignement pile car 2 push
;***************************************************
;affichage des zones m�moire
;**************************************************
; parametre 1 libelle 
; parametre 2 adresse de d�but de la zone m�moire � afficher
; parametre 3 le nombre de blocs
afficherMem:
    enter 0,0            ; prologue
    pusha                ; sauvegarde des registres
    pushf                ; sauvegarde du registre d'�tat
    mov esi, [ebp + 16]  ; recup de l'adresse du libell�
    mov ebx, [ebp + 12]  ; recup de l'adresse memoire.
    mov ecx, [ebp + 8]   ; recup nombre de blocs
    push ebx
    push sAdr            ; conversion de l'adresse m�moire demand�e
    call conversion16
    mov edi,sAdr
    mov byte [edi+TAILLEHEXA],' '  ; pour �craser le 0 final
    push szTitreAffMem     ; pour afficher le titre
    call afficherConsole
    push esi 
    call afficherConsole
    ;push szRetourLigne
    ;call afficherConsole
    
    mov    esi,ebx            ; copie adresse m�moire
    and    esi, 0FFFFFFF0h    ; calcul adresse de d�but d'un bloc de 16 octets
    mov eax,ebx               ; copie de l'adresse m�moire
    sub eax,esi               ; calcul du d�placement
    mov edi,eax               ; sauvegarde pour l'effacement 
    mov  byte [zMem-1+(eax*3)],'*' ; mise en place * devant l'adresse
.A1:                          ; d�but de boucle d'affichage des blocs
    push ecx                  ; sauvegarde nb de bloc
    push esi
    push szBloc               ; conversion de l'adresse d�but du bloc 
    call conversion16
    mov byte [szBloc+TAILLEHEXA],' '  ; pour �craser le 0 final
 
    xor    ecx,ecx
.A2:                           ; d�but de la boucle de conversion des octets
    xor eax,eax;               ; raz eax
    mov    al, [esi+ecx]       ; charge un caract�re
    ;mov ebx,0                  ; compteur caract�res
;.A3:
    ;push ebx                   ; save compteur caract�res
    mov edx,eax
    shr eax,4                  ; divise par 16
    mov ebx,eax
    shl ebx,4
    sub edx,ebx                ; calcule le reste de la division par 16
    cmp eax,9                  ; si le quotient est inferieur � 10 c'est un chiffre
    jg  .A3
    add eax,'0'                ; donc on ajoute la valeur ascii de '0'
    jmp  .A4
.A3:                           ; sinon c'est une lettre de A � F
    add eax,'A'-10 
.A4:   
    mov [zMem+(ecx*3)],al      ; on place le caractere en position 0 tous les 3 octets
    
    cmp edx,9                  ; si le reste est inferieur � 10 c'est un chiffre
    jg  .A5
    add edx,'0'                ; donc on ajoute la valeur ascii de '0'
    ;
    jmp  .A6
.A5:                           ; sinon c'est une lettre de A � F
    add edx,'A'-10 
.A6:   
    mov byte [zMem+(ecx*3)+1],dl ; on place le caractere en position 1 tous les 3 octets

    inc ecx
    cmp ecx, 16
    jl .A2   
    
    xor    ebx, ebx          ; raz compteur
.A7:                         ;debut de boucle d'affichage en ascii
    xor    eax, eax
    mov    al, [esi+ebx]     ; lecture un caract�re
    cmp    al, 32            ; caract�re affichable en ascii ?
    jl    .A8
    cmp    al, 126
    jle   .A9
.A8:                         ; non donc on met ? � la place
    mov    eax, '?'
.A9:
    mov byte [zDec+ebx],al    ; et on le met � la bonne place sur la ligne
    inc    ebx               ; incremente le compteur
    cmp    ebx, 16           ; fin de bloc ?
    jl    .A7                ; non alors boucle
    push szBloc              ; sinon affichage du bloc
    call afficherConsole
    pop ecx                  ; recupere le nombre de bloc a afficher
    dec ecx                  ; le d�cremente
    jz .A10                  ; et si nul alors fin
    mov eax,edi
    mov byte [zMem-1+(eax*3)],' ' ; efface la place de l'�toile sur les autres blocs
    add esi,16               ; augmente l'adresse du nouveau bloc de 16 octets
    jmp .A1                  ; et boucle au d�but

.A10:                        ; fin de la routine
    popf
    popa                     ; restaur des registres
    leave                    ; epilogue
    ret 12                    ; alignement pile car 3 push
;**************************************
;        affichage message d'attente
;**************************************
; attention le contenu de eax est perdu
afficherAttente:
    push 0                ; uType = MB_OK
    push .szTitre         ; Titre de la fen�tre
    push .szMsgAttente    ; message � afficher
    push 0                ; hWnd = HWND_DESKTOP
    call MessageBoxA
    ret                   ; retourne au programme appelant
.szTitre:     db "Pause",0
.szMsgAttente db "Pour continuer, cliquer sur OK",0
;***************************************************
;   Affichage etat indicateurs Z S C et O 
;****************************************************

verifierIndicateurs:
    pusha                      ;sauvegarde des registres
    pushf
    jz .A1
    mov BYTE [bPos0],'0'
    jmp .A2
.A1:
    mov BYTE [bPos0],'1'
.A2:
    js .A3
    mov BYTE [bPosS],'0'
    jmp .A4
.A3:
    mov BYTE [bPosS],'1'
.A4:
    jc .A5
    mov BYTE [bPosC],'0'
    jmp .A6
.A5:
    mov BYTE [bPosC],'1'
.A6:
    jo .A7
    mov BYTE [bPosO],'0'
    jmp .A8
.A7:
    mov BYTE [bPosO],'1'
.A8:
    push szMessIndicateurs
    call afficherConsole
    popf
    popa                       ; restaur des registres
    ret 
;***************************************************
;conversion en base 10 non sign�e
;avec suppression des zeros inutiles
;et cadrage � gauche
;****************************************************
; parametre 1  valeur � convertir
; parametre 2  zone de conversion longueur > 11
LONGUEUR equ 33
conversion10:
    enter 0,0
    pusha                      ;sauvegarde des registres
    pushf
    mov edi,[ebp+8]            ;recup adresse de la zone de conversion
    mov BYTE [edi+LONGUEUR],0  ; 0 final dans zone de conversion
    mov eax, [ebp + 12]        ; recup de la valeur a afficher
    mov ecx,LONGUEUR-1
    mov ebx ,10
.A1:                           ; d�but de boucle de calcul des restes successifs
    mov edx,0                  ; division eax par 10
    ;mov ebx ,10
    div ebx
    add edx,'0'                ; conversion ascii du reste
    mov byte  [edi,ecx],dl
    dec ecx
    cmp eax,0                  ;si division encore a faire
    jne  .A1
    xor eax,eax                ; raz indice
    inc ecx
.A5:                           ; boucle de copie du r�sultat de ecx � LONGUEUR
    mov dl,[edi,ecx]           ; charge un caract�re du r�sultat
    mov byte [edi,eax],dl      ; et le met au debut de la zone de conversion
    inc ecx                    ; incremente le pointeur du r�sultat
    inc eax                    ; incremente l'indice de reception
    cmp ecx,LONGUEUR           ; boucle jusqu'au 0 final
    jle .A5
                               ; fin
    popf
    popa                       ; restaur des registres
    leave
    ret  8                     ;alignement pile car 2 push
;**************************************
;recherche d'une sous chaine dans une chaine
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
;affichage de tous les registres
;**************************************
afficherTousRegistres:
    push    ebp
    mov ebp, esp
    pusha
    pushf
    push    eax            ; push du registre eax avant utilisation
    mov eax, [ebp + 8]     ; recup libelle 
    push  szTitreReg         ; push du message
    call  afficherConsole
    push eax
    call  afficherConsole
                           ;conversion de chaque registre
                           ; donc eax deja push�
     push    valr1 ; push de l'adresse de la zone qui recuperera la conversion sans zero terminal
     call    convreg16
     push    ebx ; push du registre a convertir
     push    valr2 ; push de l'adresse de la zone qui recuperera la conversion
     call    convreg16
     push    ecx ; push du registre a convertir
     push    valr3 ; push de l'adresse de la zone qui recuperera la conversion
     call    convreg16
     push    edx ; push du registre a convertir
     push    valr4 ; push de l'adresse de la zone qui recuperera la conversion
     call    convreg16
     push    esi ; push du registre a convertir
     push    valr5 ; push de l'adresse de la zone qui recuperera la conversion
     call    convreg16
     push    edi ; push du registre a convertir
     push    valr6 ; push de l'adresse de la zone qui recuperera la conversion
     call    convreg16
     push    dword [ebp]     ; original EBP
    ; push    ebp ; push du registre a convertir
     push    valr7 ; push de l'adresse de la zone qui recuperera la conversion
     call    convreg16
     lea     eax, [ebp+12]
     push    eax             ; original ESP
     ;push    esp ; push du registre a convertir
     push    valr8 ; push de l'adresse de la zone qui recuperera la conversion
     call    convreg16
     push    cs ; push du registre a convertir
     push    valr9 ; push de l'adresse de la zone qui recuperera la conversion
     call    convreg16
     push    ds ; push du registre a convertir
     push    valr10 ; push de l'adresse de la zone qui recuperera la conversion
     call    convreg16
      push    ss ; push du registre a convertir
     push    valr11 ; push de l'adresse de la zone qui recuperera la conversion
     call    convreg16
      push    es ; push du registre a convertir
     push    valr12 ; push de l'adresse de la zone qui recuperera la conversion
     call    convreg16
    ; mov    eax, [ebp]
    ; add    eax, 4         ; EIP on stack
    ; push    WORD[eax] ; push du registre a convertir
    ; push    valr13 ; push de l'adresse de la zone qui recuperera la conversion
    ; call    convreg16
     ; affichage
     push  szTexteReg  ; push du message
     call  afficherConsole
    ; et on termine    
    popf
    popa
    pop ebp
    ret 4
;*************************************************************
;conversion base 16 valeur registre dans une zone sans 0 terminal
;**************************************************************
; parametre 1 le registre 
; parametre 2 l'adresse de la zone receptrice
TAILLE equ 8
convreg16:
    enter 0,0
    mov ebp, esp
    pusha                    ;sauvegarde des registres
    pushf
    mov eax,[ebp + 12]      ; recup de la valeur a afficher
    mov edi,[ebp + 8]       ; recup de l'adresse de la zone de reception
    mov ecx,TAILLE-1
    mov ebx ,16
.A1:                        ; boucle de division par 16
    mov edx,0
    div ebx
    cmp edx,9               ; si le reste est inferieur � 10 c'est un chiffre
    jg  .A2
    add edx,'0'             ; donc on ajoute '0' pour conversion en ascii
    ;
    jmp  .A3
.A2:                        ;sinon c'est une lettre
    add edx,'A'-10 
.A3:   
    ;et on place le caractere en position debut + 8
    ;mov ebx,[ebp + 8]
    ;add ebx,ecx
    ;dec ebx    
    mov byte  [edi,ecx],dl
    dec ecx
    cmp ecx,0                 ; si pas taille atteinte on boucle
    jge  .A1
    popf                      ; fin routine
    popa                      ; restaur des registres
    leave
    ret  8
;============================================================   
;lecture chaine du clavier
;============================================================
;parametre 1 : adresse structure de saisie
lectureClavier:
    enter  0,0
    push ebx                                ;sauvegarde des registres
    push ecx
    pushf
    push    STD_INPUT_HANDLE
    call    GetStdHandle                    ; recup de handle ( STD_INPUT_HANDLE)
    mov ebx,__LINE__ - 1
    cmp eax,0
    je .A99
    push   0
    mov ebx, [ebp + 8]                      ; recup de la structure saisie
    mov ecx,ebx
    add ecx,bufferSaisie.carlus
    push ecx                                ; adresse nb octets lus
    push   dword [ebx+bufferSaisie.taille]  ; taille du buffer  
    mov ecx,ebx
    add  ecx,bufferSaisie.buffer
    push   ecx                              ; adresse du buffer
    push   eax                              ; handle r�cup�r�e plus haut 
    call   ReadConsoleA 
    mov ebx,__LINE__ - 1
    cmp eax,0
    jne .Fin
.A99:
    push ebx
    call afficherErreur                      ; affiche les erreurs 
    mov eax,-1                               ; code retour erreur
.Fin:   
    popf
    pop ecx
    pop ebx                                  ; restaur des registres
    leave
    ret 4
    

;======================================================
; affichage du code erreur 
; param�tre 1 contient le N� de ligne
;======================================================
afficherErreur:
    enter  0,0
    push ebx                   ;sauvegarde des registres
    mov ebx, [ebp + 8]         ; recup du N� de ligne
    call GetLastError          ; recherche numero erreur
                               ;conversion du code erreur en d�cimal
    push ebx
    push eax
    push szFormMessErr
    push szMessComplet
    call wsprintfA
    add   esp, 16             ; d�pile les  4 param�tres
                              ; affichage du message d'erreur
    push MB_OK|MB_ICONERROR   ; uType = MB_OK et icone d'erreur
    push dword .szTitreErreur  ; titre de la fenetre
    push dword szMessComplet  ; message �  afficher
    push 0                    ; hWnd = HWND_DESKTOP
    call MessageBoxA
    pop ebx
    leave
    ret 4
.szTitreErreur: db "Erreur",0