;---programme squelX86.asm 
; exemples de recherche et d'insertion de  chaines de caractères

; Pense bête :
; codes caractères page code 850 pour affichage console correct
; à 83h é 82h è 8Ah ê 88h ù 96h
;====================================
; constantes
;====================================
%include "./src/includeConstantes.inc"

;====================================
; Macros
;====================================
%include "./src/includeMacros.inc"

;=======================================
; segment des données initialisées
;=======================================
segment .data
szChaine1:     db "Exemple de chaine",0
LGCHAINE1       equ $ - szChaine1       ; calcul de la longueur de la chaine

align 4
iptTas:        dd sTas                 ; pointeur début du tas

;=======================================
; segment des données non initialisées
;=======================================
segment .bss
sZoneConv:         resb 24      ; reserve 24 octets

sBuffer:           resb 80
sTas:              resb TAILLEMAXITAS        ; réserve tas
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern afficherAttente,afficherErreur
Main:
    afficherUnReg "esp= ", esp  ; pour verifier que la pile est toujours bien alignée
    
    afficherLib "Debut programme"
    push 5
    push 10
    call appelFonction
    
    afficherMemoire "Exemple memoire",szChaine1,2

    push __?LINE?__
    call afficherErreur

.Fin:
    afficherUnReg "esp= ", esp                ; pour verifier que la pile est toujours bien alignée

    call afficherAttente
    
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 
;**************************************
;exemple de fonction 
;**************************************
;parametre 1 = valeur 1
;parametre 2 = valeur 2
appelFonction:
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
    afficherRegistres "Fonction"
.Fin:
    popf                     ; restaur des registres
    pop esi
    pop edi
    pop edx
    pop ecx
    pop ebx
    leave                     ; epilogue
    ret 8                     ; car 2 push


