;---programme structureTableau.asm 
; exemples d'accès mémoire

;======================================
; fichier des sous routines 
;======================================
%include "../includeRoutines.asm"

;=======================================
; structures
;=======================================
struc posteTab           ; description d'un poste du tableau
   .zone1:   resd 1      ; un entier de 4 octets
   .zone2:   resw 1      ; 2 octets
   .zone3:   resb 1      ; 1 octet
   .fin:                 ; permt d'avoir la taille de la structure
endstruc

struc testInst           ; autre description pour tester une instance
    .zone1:  resd 1
    .zone2:  resb 20
    .zone3:  resw 1
    .fin:
endstruc
;=======================================
; segment des données initialisées
;=======================================
segment .data 
szTitre        db "Win32", 0             ; titre de la fenêtre
szMsgReg:      db 'Valeur du registre :', 0       ; message
LGMSGREG       equ $ - szMsgReg       ; calcul de la longueur du message

align 4

exempleInst:
   istruc testInst
    at testInst.zone1, dd 0x22223333
    at testInst.zone2, db "Test instance",0
    at testInst.zone3, dw 0x8888
   iend

;=======================================
; segment des données non initialisées
;=======================================
segment .bss
sZoneConv:         resb LONGUEUR      ; reserve LONGUEUR octets

dTableau3:         resb posteTab.fin * 10     ; reserve un tableau de 10 postes

;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern MessageBoxA , ExitProcess, GetStdHandle, WriteFile
Main:
    push esp                 ; pour verifier que la pile est toujours bien alignée
    push sZoneConv
    call conversion16        ;
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    push 0                   ; mise à jour du poste 0
    push 0x12345678
    push 0x4321
    push 0xFF
    call majPoste
   
    push 5                   ; mise à jour du poste 5
    push 0x11112222
    push 0x3333
    push 0x44
    call majPoste
    
    push dTableau3           ; affichage du contenu mémoire 
    push 5                   ; sur 5 bloc de 16 octets
    call afficherMem
    
                             ; recup de la zone 3  du 5ieme poste
    mov eax,5
    mov ebx,posteTab.fin
    mul ebx
    xor ebx,ebx
    mov bl,[dTableau3+eax+posteTab.zone3]
    push ebx                 ; affichage pour vérifier la valeur
    push sZoneConv
    call conversion16        ; conversion hexa 
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    xor eax,eax              ; affichage d'une zone d'une instance de structure
    mov ax,[exempleInst+testInst.zone3]
    push eax                 ; affichage pour vérifier la valeur
    push sZoneConv
    call conversion16        ; conversion hexa 
    push szMsgReg
    call afficherConsole
    push sZoneConv
    call afficherConsole
    push szRetourLigne
    call afficherConsole
    
    
    

    push esp                 ; pour verifier que la pile est toujours bien alignée
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
;mise à jour d'un poste du tableau
;**************************************
;parametre 1 = numero du poste (commence à zéro)
;parametre 2 = valeur 1   4 octets
;parametre 3 = valeur 2   2 octets 
;parametre 4 = valeur 3   1 octet
majPoste:
    enter 0,0                              ;prologue
    pusha                                  ;sauvegarde des registres
    pushf
    mov eax, [ebp + 20]                    ; recup numéro de poste
    mov ebx,posteTab.fin                   ; longueur d'un poste
    mul ebx                                ; calcul du déplacement 
    mov ebx, [ebp + 16]                    ; recup valeur 1
    mov [dTableau3+eax+posteTab.zone1],ebx ; et stockage dans zone 1
    mov ebx, [ebp + 12]                    ; recup de la valeur 2
    mov [dTableau3+eax+posteTab.zone2],bx  ; et stockage dans zone 2
    mov ebx, [ebp + 8]                     ; recup de la valeur 3
    mov [dTableau3+eax+posteTab.zone3],bl  ; et stockage dans zone 3
    
    popf                                   ; restau des registres
    popa
    leave                                  ; epilogue
    ret 16                                 ; car 4 push