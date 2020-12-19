;---programme squelX86.asm 
; exemples de recherche et d'insertion de  chaines de caract�res

; Pense b�te :
; codes caract�res page code 850 pour affichage console correct
; � 83h � 82h � 8Ah � 88h � 96h
;====================================
; constantes
;====================================
%include "./src/includeConstantes.inc"

;====================================
; Macros
;====================================
%include "./src/includeMacros.inc"

;=======================================
; segment des donn�es initialis�es
;=======================================
segment .data
szChaine1:     db "Exemple de chaine",0
LGCHAINE1       equ $ - szChaine1       ; calcul de la longueur de la chaine

align 4
iptTas:        dd sTas                 ; pointeur d�but du tas

;=======================================
; segment des donn�es non initialis�es
;=======================================
segment .bss
sZoneConv:         resb 24      ; reserve 24 octets

sBuffer:           resb 80
sTas:              resb TAILLEMAXITAS        ; r�serve tas
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern afficherAttente,afficherErreur
Main:
    afficherUnReg "esp= ", esp  ; pour verifier que la pile est toujours bien align�e
    
    afficherLib "Debut programme"
    push 5
    push 10
    call appelFonction
    
    afficherMemoire "Exemple memoire",szChaine1,2

    push __?LINE?__
    call afficherErreur

.Fin:
    afficherUnReg "esp= ", esp                ; pour verifier que la pile est toujours bien align�e

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
    mov edi, [ebp + 12]      ; recup adresse chaine � chercher
    mov esi, [ebp + 8]       ; recup adresse chaine
    mov ecx,0                ; indice caract�re sous chaine
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


