;---programme resolDich.asm 
; resolution approch�e de l"equation x=x2-2 par dichotomie.
; Pense b�te :
; codes caract�res page code 850 pour affichage console correct
; � 83h � 82h � 8Ah � 88h � 96h
;====================================
; constantes
;====================================
STD_INPUT_HANDLE  equ -10

MB_OK               equ 000h
MB_OKCANCEL         equ 001h
MB_ABORTRETRYIGNORE equ 002h
MB_YESNOCANCEL      equ 003h
MB_YESNO            equ 004h
MB_RETRYCANCEL      equ 005h
MB_ICONERROR        equ 010h
MB_ICONWARNING      equ 030h
MB_ICONINFORMATION  equ 040h

CP_ACP              equ 0h

FILE_ATTRIBUTE_READONLY   equ    0001h
FILE_ATTRIBUTE_HIDDEN     equ    0002h
FILE_ATTRIBUTE_SYSTEM     equ    0004h
FILE_ATTRIBUTE_DIRECTORY  equ    0010h
FILE_ATTRIBUTE_ARCHIVE    equ    0020h
FILE_ATTRIBUTE_NORMAL     equ    0080h
FILE_ATTRIBUTE_TEMPORARY  equ    0100h
FILE_ATTRIBUTE_COMPRESSED equ    0800h

GENERIC_READ              equ    080000000h
GENERIC_WRITE             equ    040000000h
GENERIC_EXECUTE           equ    020000000h
GENERIC_ALL               equ    010000000h

CREATE_NEW                equ    01h
CREATE_ALWAYS             equ    02h
OPEN_EXISTING             equ    03h
OPEN_ALWAYS               equ    04h
TRUNCATE_EXISTING         equ    05h

LOCALE_CUSTOM_DEFAULT     equ 0x0C00 
LOCALE_USER_DEFAULT       equ  0x400
LOCALE_NOUSEROVERRIDE     equ 2147483648

WC_COMPOSITECHECK equ 200h
;====================================
; macros instructions 
;====================================
; affichage d'un libell�
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
; segment des donn�es initialis�es
;=======================================
segment .data
;affichage message d'erreur
szTitreErreur    db "ERREUR",0
szFormMessErr    db "Une erreur a �t� rencontr�e code : %d � la ligne %d",0 

szMessResultat:  db "Resultat = @ ",10,0

dRayonEntier     dd 4
qRayon:          dq 6.5
;constantes en virgule flottante sur 8 octets
Pi               dq  3.14159265359
Deux             dq  2.0
Zero             dq  0.0
Precision:       dq  0.00001
qVarG:           dq 0.0
qVarD:           dq 2.0
qVarM:           dq 0
dAdrqVarM:       dd qVarM
dAdrqIntM:       dd qIntM
;=======================================
; segment des donn�es non initialis�es
;=======================================
segment .bss
qResult:           resq 1
ptResult           resq 1
qIntM:             resq 1
qIntG:             resq 1
sBuffer:           resb 100
szMessComplet:     resb 80
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern ReadConsoleA,GetLastError,wsprintfA,GetCommandLineW,CommandLineToArgvW,WideCharToMultiByte
    extern VarBstrFromR8
Main:
    afficherUnReg "registre esp :", esp  ; pour verifier que la pile est toujours bien align�e
    
    
    mov ecx,0
    finit                      ; initialise tous les registres � NAN
.A1:
    fld qword [qVarG]          ; charge la borne gauche (st0)
    fadd qword [qVarD]         ; ajoute la boene droite (st0)
    fdiv qword [Deux]          ; divise par 2   (st0)
    fst qword [qVarM]          ; stocke la moyenne  en m�moire mais elle reste dans st0
    push qVarM                 ; adresse valeur pass�e � la fonction
    push qIntM                 ; adresse r�sultat pass�e � la fonction
    call calculFct             ; calcul fonction pour la moyenne
    push qVarG                 
    push qIntG
    call calculFct             ; calcul fonction pour la borne gauche
    fld qword [qIntM]          ; charge le r�sultat de la fonction pour la moyenne (qui passe en st1)
    fmul qword [qIntG]         ; multiplie par le r�sultat de la fonction pour la borne gauche
    fld qword [Zero]           ; charge 0 dans st0 et met le r�sultat pr�cedent dans st1 (et donc la moyenne dans st2)
    fcomip                     ; compare st0 et st1 et met � jour les indicateurs standards
                               ; et st1 devient st0 et st2 (la moyenne) devient st1
    fstp st0                   ; astuce pour d�piler donc st1(la moyenne) devient st0
    ja .A2                     ; si plus petit que z�ro
    fstp qword [qVarG]         ; stocke st0 (la moyenne ) dans la borne gauche (la pile est vide)
    jmp .A3
.A2:
    fstp qword [qVarD]         ; sinon stocke st0 (la moyenne ) dans la borne droite (la pile est vide)
.A3:
    fld qword [qVarD]          ; charge la borne droite  (st0)
    fsub qword [qVarG]         ; soustrait la borne gauche (st0)
    fld qword [Precision]      ; charge la pr�cision dans st0 et le r�sultat pr�cedent devient st1
    inc ecx                    ; compteur s�curit�
    cmp ecx,500                 ; arr�t si boucle anormale
    jg .A4
    fcomip                     ; compare st0 et st1 et met � jour les indicateurs standards
    fstp st0                   ; ces 2 instructions d�pilent donc la pile est vide
    jb .A1                     ; boucle si pr�cision pas atteinte
    
.A4:
    fld qword [qVarG]          ; charge la borne gauche
    fstp qword [qResult]       ; et la stoche dans le r�sultat
                               ; pour l'afficher
                               ; convertir float en caract�res unicode
    push ptResult              ; adresse du pointeur du r�sultat
    push LOCALE_NOUSEROVERRIDE
    push LOCALE_CUSTOM_DEFAULT
    push dword [qResult+4]     ; pour passer les 4 derniers octets par la pile
    push dword[qResult]        ; puis les 4 premiers octets  
    call VarBstrFromR8
                               ; conversion unicode ==> Ansi
    push 0
    push 0
    push 100                   ; taille du buffer
    push sBuffer               ; buffer du r�sultat ansi
    push -1
    push dword[ptResult]       ; pointeur vers zone resultat unicode
    push WC_COMPOSITECHECK
    push CP_ACP
    call WideCharToMultiByte
    mov ebx,__LINE__ - 1       ; identification de la ligne de la proc�dure en erreur
    cmp eax,0                  ; test si erreur
    jle .A99                   ; oui
                           
    push sBuffer               ; affichage du r�sultat
    push szMessResultat
    call insererChaine
    push eax
    call afficherConsole

    jmp .Fin
.A99:
    call afficherErreur        ; affiche les erreurs 
    
.Fin:
    afficherUnReg "registre esp :", esp   ; affichage de la pile 

    call afficherAttente
    
    push eax           ; met le code retour sur la pile
    call ExitProcess   ; fin du programme 

;======================================================
; affichage du code erreur 
; ebx contient le N� de ligne
;======================================================
afficherErreur:
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
    push dword szTitreErreur  ; titre de la fenetre
    push dword szMessComplet  ; message �  afficher
    push 0                    ; hWnd = HWND_DESKTOP
    call MessageBoxA
    ret 
;**************************************
; calcul de la fonction x au carr� - 2
;**************************************
; param�tre 1   adresse valeur x
; parametre 2   adresse r�sultat
calculFct:
    enter 0,0             ; prologue
    push eax              ;sauvegarde des registres
    push ebx
    mov ebx,[ebp + 8]     ; recup de l'adresse du resultat
    mov eax,[ebp + 12]    ; recup de l'adresse valeur
    fld qword [eax]       ; charge la valeur de x
    fmul qword [eax]      ; la multiplie par -> donc x au carr�
    fsub qword[Deux]      ; enl�ve 2
    fstp qword [ebx]      ; stocke le r�sultat � l'adresse du r�sultat
    pop ebx
    pop eax
    leave                 ; epilogue
    ret 8                 ; alignement pile car 2 push