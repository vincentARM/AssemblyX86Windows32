;---programme accesMemoire.asm 
; exemple d'acces mémoire

STD_OUTPUT_HANDLE equ -11
LONGUEUR equ 33
;=======================================
; segment des données initialisées
;=======================================
segment .data 
szTitre        db "Win32", 0             ; titre de la fenêtre
szMsgReg:      db 'Valeur du registre :', 0       ; message
LGMSGREG       equ $ - szMsgReg       ; calcul de la longueur du message
szRetourLigne: db 10,0
bByte:         db 0x10              ;définit une zone d'un octet avec la valeur hexa 10
wWord:         dw 1234h             ; definit 2 octets valeur hexa 1234
dDoubleWord    dd 0x12345678        ; definit 4 octets
qQuadrupleWord dq 0x1234567812345678 ; définit 8 octets
dTableau1      dd 1,2,3,4,5,6,7,8,9,10  ; definit un tableau de 10 valeurs
iAdresseCourante dd $                ; contiendra l'adresse courante
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
sZoneConv:         resb LONGUEUR      ; reserve LONGUEUR octets
wReserve1:         resw 1             ; reserve un mot soit 2 octets
dReserve2:         resd 1             ; reserve un double mot soit 4 octets
qReserve3:         resq 1             ; reserve un quadruple mot soit 8 octets

dTableau2:         resd 10            ; reserve un tableau de 10 doubles mots

;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern MessageBoxA , ExitProcess, GetStdHandle, WriteFile
Main:
    mov eax,-1
    mov al,[bByte]            ; lecture 1 octet
    ;mov BYTE eax, [bByte]    ; non admis
    push eax
    push sZoneConv
    call conversion16
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    mov eax,-1
    mov ax,[wWord]           ; lecture 2 octets
    push eax
    push sZoneConv
    call conversion16
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    mov ebx,dDoubleWord     ; lecture 4 octets (donc 1 registre)
    mov eax,[ebx]
    push eax
    push sZoneConv
    call conversion16
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole

    mov ebx,dTableau1
    mov eax,[ebx+4]         ; lecture poste 2 du tableau
    push eax
    push sZoneConv
    call conversion16
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    mov ecx,6
    ;mov eax,[ebx+ecx*4]           ; lecture poste 6 du tableau
    ;mov eax,[ebx+(ecx*4)+4]       ; lecture poste 7 du tableau
    mov eax,[dTableau1+(ecx*4)+4]  ; ou idem mais à partir du label
    push eax
    push sZoneConv
    call conversion16
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole

    push LGMSGREG                  ; longueur d'une zone calculée par le compilateur
    push sZoneConv
    call conversion10S
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    mov eax,[iextraZone]          ; lecture Ok
    ; mov [iextraZone],eax        ; écriture interdite
    push eax
    push sZoneConv
    call conversion10S
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    mov ax, 1000
    mov [wReserve1],ax           ; ecriture de 2 octets en mémoire
    
    mov eax,0x43214321
    mov [dReserve2],eax          ; écriture de 4 octets en mémoire
    
    mov eax,[dReserve2]          ; pour vérification écriture
    push eax
    push sZoneConv
    call conversion16
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    
    mov eax,[iAdresseCourante]   ; affichage de l'adresse contenue dans iAdresseCourante
    push eax
    push sZoneConv
    call conversion16
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
.Fin:
    push esp                 ; pour verifier que la pile est toujours bien alignée
    push sZoneConv
    call conversion10S       ; conversion nombre signé
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 

iextraZone:  dd  5
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
    push dword szTitre    ; Titre de la fenÃªtre
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
    sub esp,8             ; reserve 8 octets pour le nombre de caractères écrits
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
    push    eax            ; retour nb octets affiches ?
    push    ecx            ; longueur du message
    push    edx            ; adresse du message
    push    ebx            ; handle de la console
    call    WriteFile
    popf
    popa                   ; restaur des registres
    add esp,8              ; libère la place
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
.A1:                       ; boucle d'extraction des bits un à un
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
;conversion en base 10 signée
;avec suppression des zeros inutiles
;****************************************************
; parametre 1  valeur à convertir
; parametre 2  zone de conversion longueur > 11
conversion10S:
    enter 0,0              ; prologue
    pusha                  ;sauvegarde des registres
    pushf
    mov edi,[ebp+8]        ;recup adresse de la zone de conversion
    mov BYTE [edi+LONGUEUR],0 ; stockage 0 final
    mov eax, [ebp + 12]   ; recup de la valeur a afficher
    cmp eax,0             ; compare à zéro
    jl .A1                ; plus petit
    mov dl,'+'            ; signe positif
    jmp .A2
.A1:
    mov dl,'-'            ; signe négatif
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
.A4:                         ; recopie du résultat en début de zone de conversion
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
    mov byte [edi+TAILLEHEXA],0 ;sinon on ajoute 0 à la 9ieme position pour terminer la chaine
    popf                  ; fin routine
    popa                  ; restaur des registres
    pop ebp
    ret 8                 ; alignement pile car 2 push