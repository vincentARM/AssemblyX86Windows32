;---programme afficherMemoire.asm 
; afficher les zones de la mémoire par bloc

STD_OUTPUT_HANDLE equ -11
LONGUEUR equ 12
;=======================================
; segment des données initialisées
;=======================================
segment .data 
szTitre        db "Win32", 0             ; titre de la fenêtre
szMsg:         db 'Valeur du registre :', 0       ; message
szRetourLigne: db 10,0

szTitreAffMem: db "Affichage m",82h,"moire : adresse :"
sAdr:          db "00000000  "
               db 10,13,0
szBloc:        db "00000000 "
zMem:          times 16 db "00 "
               db " ",34   
zDec           times 16 db"0"
               db 34,10,13,0  
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
sZoneConv:         resb LONGUEUR
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern MessageBoxA , ExitProcess, GetStdHandle, WriteFile
Main:

    push esp
    call afficherHexa
    
    push szTitre
    push 2
    call afficherMem
    
    push sZoneConv
    push 3
    call afficherMem

    push szMsg
    push 4
    call afficherMem

    push Main
    push 4
    call afficherMem

    push esp
    call afficherHexa

    
    push 0           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 
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
    push szMsg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    popf
    pop eax
    leave                    ; epilogue
    ret 4                    ; alignement pile car 1 push
;**************************************
;affichage console
;**************************************
afficherConsole:
    enter 8,0             ; reserve 8 octets pour le nombre de caractères écrits
    pusha                 ;sauvegarde des registres
    pushf
    mov edx, [ebp + 8]    ; recup de la valeur a afficher
    
    mov ecx,0             ; compteur de caractères
.B1:                      ; boucle de calcul de la longueur
    mov al,[edx,ecx]      ; charge un caractère de la chaine
    cmp al,0              ; si zéro c'est la fin de la chaine
    je .B2
    inc ecx               ; sinon incremente le compteur
    jmp .B1               ; et boucle 
.B2:
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle  ; recherche du handle de la console
    mov     ebx, eax      ; sauvé dans ebx
    push    0
    mov    eax,ebp
    sub     eax,8
    push    eax            ; retour nb octets affichés ?
    push    ecx            ; longueur du message
    push    edx            ; adresse du message
    push    ebx            ; handle de la console
    call    WriteFile
    popf
    popa                   ; restaur des registres
    leave                  ; epilogue
    ret 4                  ; alignement pile car 1 push
;***************************************************
;conversion hexa d'un registre en une chaine
;**************************************************
; parametre 1 le registre 
; parametre 2 l'adresse de la zone receptrice
TAILLE equ 8
conversion16:
    push    ebp
    mov ebp, esp
    pusha                  ;sauvegarde des registres
    pushf
    mov eax, [ebp + 12]    ; recup de la valeur a afficher
    mov edi,[ebp + 8]      ; recup adresse zone de conversion
    mov ecx,TAILLE-1
    mov ebx ,16
.A1:                       ; boucle de division par 16
    mov edx,0
    div ebx
    cmp edx,9              ; si le reste est inferieur à 10 c'est un chiffre
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
    mov byte [edi+TAILLE],0 ;sinon on ajoute 0 à la 9ieme position pour terminer la chaine
    popf                  ; fin routine
    popa                  ; restaur des registres
    pop ebp
    ret 8                 ; alignement pile car 2 push
;***************************************************
;affichage des zones mémoire
;**************************************************
; parametre 1 adresse de début de la zone mémoire à afficher
; parametre 2 le nombre de blocs
afficherMem:
    enter 0,0            ; prologue
    pusha                ; sauvegarde des registres
    pushf                ; sauvegarde du registre d'état
    mov ebx, [ebp + 12]  ; recup de l'adresse memoire.
    mov ecx, [ebp + 8]   ; recup nombre de blocs
    push ebx
    push sAdr            ; conversion de l'adresse mémoire demandée
    call conversion16
    mov edi,sAdr
    mov byte [edi+TAILLE],' '  ; pour écraser le 0 final
    push szTitreAffMem     ; pour afficher le titre
    call afficherConsole
  
    mov    esi,ebx            ; copie adresse mémoire
    and    esi, 0FFFFFFF0h    ; calcul adresse de début d'un bloc de 16 octets
    mov eax,ebx               ; copie de l'adresse mémoire
    sub eax,esi               ; calcul du déplacement
    mov edi,eax               ; sauvegarde pour l'effacement 
    mov  byte [zMem-1+(eax*3)],'*' ; mise en place * devant l'adresse
.A1:                          ; début de boucle d'affichage des blocs
    push ecx                  ; sauvegarde nb de bloc
    push esi
    push szBloc               ; conversion de l'adresse début du bloc 
    call conversion16
    mov byte [szBloc+TAILLE],' '  ; pour écraser le 0 final
 
    xor    ecx,ecx
.A2:                           ; début de la boucle de conversion des octets
    xor eax,eax;               ; raz eax
    mov    al, [esi+ecx]       ; charge un caractère
    ;mov ebx,0                  ; compteur caracteres
;.A3:
    ;push ebx                   ; save compteur caractères
    mov edx,eax
    shr eax,4                  ; divise par 16
    mov ebx,eax
    shl ebx,4
    sub edx,ebx                ; calcule le reste de la division par 16
    cmp eax,9                  ; si le quotient est inferieur à 10 c'est un chiffre
    jg  .A3
    add eax,'0'                ; donc on ajoute la valeur ascii de '0'
    jmp  .A4
.A3:                           ; sinon c'est une lettre de A à F
    add eax,'A'-10 
.A4:   
    mov [zMem+(ecx*3)],al      ; on place le caractere en position 0 tous les 3 octets
    
    cmp edx,9                  ; si le reste est inferieur à 10 c'est un chiffre
    jg  .A5
    add edx,'0'                ; donc on ajoute la valeur ascii de '0'
    ;
    jmp  .A6
.A5:                           ; sinon c'est une lettre de A à F
    add edx,'A'-10 
.A6:   
    mov byte [zMem+(ecx*3)+1],dl ; on place le caractere en position 1 tous les 3 octets

    inc ecx
    cmp ecx, 16
    jl .A2   
    
    xor    ebx, ebx          ; raz compteur
.A7:                         ;debut de boucle d'affichage en ascii
    xor    eax, eax
    mov    al, [esi+ebx]     ; lecture un caractère
    cmp    al, 32            ; caractère affichable en ascii ?
    jl    .A8
    cmp    al, 126
    jle   .A9
.A8:                         ; non donc on met ? à la place
    mov    eax, '?'
.A9:
    mov byte [zDec+ebx],al    ; et on le met à la bonne place sur la ligne
    inc    ebx               ; incremente le compteur
    cmp    ebx, 16           ; fin de bloc ?
    jl    .A7                ; non alors boucle
    push szBloc              ; sinon affichage du bloc
    call afficherConsole
    pop ecx                  ; recupere le nombre de bloc a afficher
    dec ecx                  ; le décremente
    jz .A10                  ; et si nul alors fin
    mov eax,edi
    mov byte [zMem-1+(eax*3)],' ' ; efface la place de l'étoile sur les autres blocs
    add esi,16               ; augmente l'adresse du nouveau bloc de 16 octets
    jmp .A1                  ; et boucle au début

.A10:                        ; fin de la routine
    popf
    popa                     ; restaur des registres
    leave                    ; epilogue
    ret 8                    ; alignement pile car 2 push
;***************************************************
;conversion en base 10 non signée
;avec suppression des zeros inutiles
;et cadrage à gauche
;****************************************************
; parametre 1  valeur à convertir
; parametre 2  zone de conversion longueur > 11
conversion10:
    enter 0,0
    pusha                      ;sauvegarde des registres
    pushf
    mov edi,[ebp+8]            ;recup adresse de la zone de conversion
    mov BYTE [edi+LONGUEUR],0  ; 0 final dans zone de conversion
    mov eax, [ebp + 12]        ; recup de la valeur a afficher
    mov ecx,LONGUEUR-1
    mov ebx ,10
.A1:                           ; début de boucle de calcul des restes successifs
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
.A5:                           ; boucle de copie du résultat de ecx à LONGUEUR
    mov dl,[edi,ecx]           ; charge un caractère du résultat
    mov byte [edi,eax],dl      ; et le met au debut de la zone de conversion
    inc ecx                    ; incremente le pointeur du résultat
    inc eax                    ; incremente l'indice de reception
    cmp ecx,LONGUEUR           ; boucle jusqu'au 0 final
    jle .A5
                               ; fin
    popf
    popa                       ; restaur des registres
    leave
    ret  8                     ;alignement pile car 2 push