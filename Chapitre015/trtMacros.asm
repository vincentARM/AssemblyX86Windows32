;---programme trtMacros.asm 
; exemples de macros instructions

; Pense bête :
; codes caractères page code 850 pour affichage console correct
; à 83h é 82h è 8Ah ê 88h ù 96h
;====================================
; constantes
;====================================

;====================================
; macros instructions 
;====================================
; affichage d'un libellé
%macro afficherLib 1        
    jmp %%endstr
%%str: db %1,10,0
%%endstr:
    push %%str
    call afficherConsole
%endmacro
;=========================
;affichage d'un registre
%macro afficherUnReg 2
    jmp %%endstr1
%%str1: db %1,0
%%endstr1:
    push %%str1
    call afficherConsole
    push %2
    push sZoneConv
    call conversion16
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
%endmacro
;=========================
;affichage memoire
%macro afficherMemoire 3
    jmp %%endstr2
%%str2: db %1,10,0
%%endstr2:
    push %%str2
    push %2
    push %3
    call afficherMem
%endmacro
;=========================
;affichage de tous les registres
%macro afficherRegistres 1
    jmp %%endstr3
%%str3: db %1,10,0
%%endstr3:
    push %%str3
    call afficherTousRegistres
%endmacro
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


titrereg:  db "affichage registres : ",0
numvid     db "      ",10,13,0
lgti  equ $ - titrereg -1
 textereg: db 'eax = ' 
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

;=======================================
; segment des données non initialisées
;=======================================
segment .bss
;sZoneConv:         resb 24 
;=======================================
; segment de code
;=======================================
segment .text
    global Main
Main:
    push esp                 ; pour verifier que la pile est toujours bien alignée
    call afficherHexa
                             ; affichage d'un libellé avec une macro
    afficherLib "Exemple de titre"
                             ; affichage d'un registre 
    afficherUnReg "registre eax :", eax
                             ; affichage zones mémoire
    afficherMemoire "zone debut .data ",szMsgRegHexa,4
    mov eax,1                ; pour vérifier que la routine suivante 
    mov ebx,2                ; ne change pas la valeur des registres
    mov ecx,3
    mov edx,4
    mov esi,5
    mov edi,6
    mov ebp,7
    afficherRegistres "avant Fin"    ; affichage de tous les registres
    afficherRegistres "avant Fin 2"  ; et une 2ième fois pour vérifier si dégradation
    
 
.Fin:
    afficherUnReg "registre esp :", esp   ; affichage de la pile 

    call afficherAttente
    
    push eax           ; met le code retour sur la pile
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
    push  titrereg         ; push du message
    call  afficherConsole
    push eax
    call  afficherConsole
                           ;conversion de chaque registre
                           ; donc eax deja pushé
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
     push  textereg  ; push du message
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
    cmp edx,9               ; si le reste est inferieur à 10 c'est un chiffre
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