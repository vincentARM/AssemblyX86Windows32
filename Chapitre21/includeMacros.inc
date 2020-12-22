;---fichier des includes  macros

    extern afficherConsole,afficherMem,afficherTousRegistres,conversion16
    extern szRetourLigne
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
