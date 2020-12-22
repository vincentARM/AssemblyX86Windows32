; programme : fenSaisie.asm
; fenêtre avec zone de saisie et de résultat
;
; Pense bête :
; codes caractères page code 850 pour affichage console correct
; à 83h é 82h è 8Ah ê 88h ù 96h
;====================================
; constantes
;====================================
%include "./includeConstantes.inc"

;====================================
; Macros
;====================================
%include "./includeMacros.inc"

;====================================
; Structures 
;====================================
; structure classe des fenetres
struc WNDCLASSEX
    .cbSize:        resd 1
    .style:         resd 1
    .lpfnWndProc:   resd 1        
    .cbClsExtra:    resd 1
    .cbWndExtra:    resd 1
    .hInstance:     resd 1
    .hIcon:         resd 1
    .hCursor:       resd 1
    .hbrBackground: resd 1
    .lpszMenuName:  resd 1
    .lpszClassName: resd 1
    .hIconSm:       resd 1
    .fin:
endstruc
; structure Message
struc MSG
    .hwnd:         resd 1
    .message:      resd 1
    .wParam:       resd 1
    .lParam:       resd 1
    .time:         resd 2
    .pt:           resd 2    
    .fin:          resb 5  ; marqueur de fin pour verification
endstruc
struc RECT
    .left:         resd 1
    .top:          resd 1
    .right:        resd 1
    .bottom:       resd 1
endstruc
;=======================================
; segment des données initialisées
;=======================================
segment .data
szTitre     db 'Message Fin', 0
szMsg       db 'Fin du programme', 0
szTitreFen  db "Fenêtre 1",0
szClasseFen db "Classe1",0
szTexte1    db "Saisir le texte : ",0
iLgTexte1   equ $ - szTexte1   ; longueur du texte précedent
szNomIcone  db "icone32_1.ico",0

szTitreBouton db "EXECUTION",0
szTypeBouton  db "button",0
BN_CLICKED    equ 1001h

szTexteSaisi times 50 db ' '       
szTypeSaisie db "Edit",0
szTitreAff   db  "Résultat:",0
szTexteInit  db " ",0   ; pour initialiser la zone resultat à la creation de la fenetre

;instance de la classe des fenetres
wcex:
   istruc WNDCLASSEX
   iend
lgwxex equ $ -     wcex

;instance rectangle fenetre parent
recfen:
   istruc RECT
   iend
;instance rectangle fenetre enfant  
recenf:
   istruc RECT
   iend

;instance message
msg: istruc MSG
     at MSG.fin,  db  "<<<  "
  iend
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
hInst         resd 1    ; handle instance programme
hMainWnd      resd 1    ; handle fenetre principale
hWnd          resd 1   
hwndedit      resd 1    ; handle de la zone de saisie
hInfoWin      resd 1
hWndAff       resd 1    ; handle de la zone d'affichage
hBouton       resd 1
hdc           resd 1
xNew          resd 1   
yNew          resd 1
ps            resd 20
szZoneResult  resb 2000
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern afficherErreur
    extern afficherErreur,TextOutA,GetModuleHandleA,LoadCursorA,RegisterClassExA,CreateWindowExA
    extern ShowWindow,GetMessageA,PostQuitMessage,DefWindowProcA,UpdateWindow,TranslateMessage
    extern DispatchMessageA,BeginPaint,EndPaint,LoadImageA,SendMessageA,GetDesktopWindow
    extern GetWindowRect,GetSystemMetrics,SetWindowPos
    extern TextOutA,GetWindowTextLengthA,GetWindowTextA,IsDlgButtonChecked,CheckDlgButton,GetWindowLongA,CharUpperA,MoveWindow
Main:
    push NULL
    call GetModuleHandleA  ; recup handle de l'instance du programme
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .gestionerreurs
    mov    [hInst], eax
                                                             ; creation de la classe des fenetres
    mov    dword[wcex+WNDCLASSEX.cbSize], lgwxex             ; taille de la structure de la classe de la fenetre
    mov dword[wcex+WNDCLASSEX.style],CS_REDRAW | CS_VREDRAW  ; style des fenetres
    mov    dword[wcex+WNDCLASSEX.lpfnWndProc], WndProc       ; nom de la procedure qui va gerer les évenements de la fenetre

    xor eax,eax
    mov    dword[wcex+WNDCLASSEX.cbClsExtra], eax            ; raz de ces zones
    mov    dword[wcex+WNDCLASSEX.cbWndExtra], eax

    mov    dword eax, [hInst]
    mov    dword[wcex+WNDCLASSEX.hInstance], eax             ; handle du parent
                                                             ; recuperation image de l'icone
    push LR_LOADFROMFILE|LR_DEFAULTSIZE
    push 0
    push 0
    push IMAGE_ICON
    push szNomIcone
    push NULL
    call  LoadImageA
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .gestionerreurs
    mov    dword[wcex+WNDCLASSEX.hIcon], eax
                                                             ;chargement image curseur souris
    push IDC_ARROW
    push NULL
    call LoadCursorA
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .gestionerreurs
    mov    dword[wcex+WNDCLASSEX.hCursor], eax
    mov    dword[wcex+WNDCLASSEX.hbrBackground], COLOR_WINDOW + 1 ; couleur d'arriÃ¨re plan
    mov    dword [wcex+WNDCLASSEX.lpszMenuName],  NULL
    mov    dword [wcex+WNDCLASSEX.lpszClassName], szClasseFen
                                                      ;creation de la classe de la fenetre (c'est obligatoire)
    push wcex
    call RegisterClassExA
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .gestionerreurs

                                         ; creation de la fenetre
    push NULL                            ; pas de données complémentaires
    push dword [hInst]                   ; handle de l'instance du programme
    push NULL                            ; fenetre non identifiée
    push NULL                            ; pas de fenetre parent
    push 180h                            ; hauteur de la fenetre
    push 1A0H                            ; largeur de la fenetre
    push 0                               ; position verticale de la fenetre
    push 0                               ; position horizontale de la fenetre
    push dword WS_OVERLAPPEDWINDOW       ; fenetre standard avec menu systÃ¨me
    push dword szTitreFen                ; titre de la fenetre
    push dword szClasseFen               ; classe de la fenetre doit être identique à la classe crée par RegisterClassExA
    push NULL                            ; pas de style complémentaire
    call CreateWindowExA
    mov ebx,__LINE__ - 1
    cmp  eax,NULL
    je   .gestionerreurs
    mov    [hMainWnd],eax                 ; recupere  le handle de la fenetre
    push SW_SHOWDEFAULT                   ; affichage de la fenetre
    push dword[hMainWnd]
    call ShowWindow
                                          ; ici on ne teste pas le code erreur (voir la doc microsoft)
    push dword[hMainWnd]
    call UpdateWindow                     ;genere le message WM_PAINT qui dessinera dans la fenêtre
    mov ebx,__LINE__ - 1
    cmp  eax,NULL
    je   .gestionerreurs
   
.boucle_commande:   
    push 0
    push 0
    push NULL
    push msg
    call GetMessageA
    cmp eax,0
    jz .fin_commande
    push msg
    call TranslateMessage
    push msg
    call DispatchMessageA
    jmp .boucle_commande
.fin_commande:   
                                             ;message de fin du programme
    push MB_OK|MB_ICONINFORMATION            ; uType = bouton ok et  icone information
    push dword szTitre                       ; Titre de la fenêtre
    push dword szMsg                         ; message a afficher
    push 0                                   ; hWnd = HWND_DESKTOP
    call MessageBoxA
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .gestionerreurs
    mov eax,TRUE
    jmp .main_fin
.gestionerreurs:
    push ebx
    call afficherErreur
    mov  eax,FALSE
.main_fin:   
    push eax                                  ; code retour
    call ExitProcess                          ; fin du programme
;===========================================================
;Procédure de gestion des évenements de la fenetre
;===========================================================   
WndProc:
    ;recuperation des parametres  handle de la fenetre, type du message, wparam, lparam
    enter 0,0
    mov eax,[ebp+8]                ; handle de la fenetre
    mov dword [hWnd],eax
    mov eax,[ebp+12]               ; type de message
    cmp eax,WM_DESTROY             ; fermeture de la fenêtre
    je .destroy
    cmp eax,WM_CREATE              ; création de la fenetre
    je .create
    cmp eax,WM_PAINT               ; dessin dans la fenetre
    je .paint
    cmp eax,WM_SIZE
    je .resize
    cmp eax,WM_COMMAND             ; traitement des evenements
    je .commande

    ; autre code à tester ici
    jmp .retourdefaut
.create:
    call ajout_saisie       ;ajout zone de saisie de texte
    call ajout_bouton       ;ajout d'un bouton
    call ajout_result       ;ajout d'une zone d'affichage des resultats
                            ;centrage de la fenetre au milieu de l'écran
    push  dword[ebp+8]      ; handle de la fenetre
    call Centrage_fenetre
    jmp .retourproc
.paint:                     ;affichage  du texte dans la fenetre
    push ps
    push dword[hWnd]
    call BeginPaint
    mov    [hdc], eax
    push iLgTexte1          ; longueur du texte a afficher
    push szTexte1
    push 10                 ; position du texte
    push 20
    push dword[hdc]
    call TextOutA
    push ps
    push dword[hWnd]
    call EndPaint       

    jmp .retourproc
 
.resize:                   ; modification taille fenetre
                           ; modification taille zone de saisie
    mov dword eax,[ebp+20] ; récupération de la nouvelle taille de la fenetre
    and eax,0FFFFh         ; largeur dans les bits faibles
    sub eax,50             ; pour les bords
    push TRUE              ; repaint de la fenetre
    push 20                ; hauteur zone edition
    push eax               ; longueur calculée précedement
    push 50                ; x
    push 10                ; y
    push  dword[hwndedit]
    call MoveWindow   
    mov ebx,__LINE__ - 1
    cmp eax,0
    je .erreurWP
                           ;deplacement du bouton
    mov dword ebx,[ebp+20] ; récupération de la nouvelle taille de la fenetre
    shr ebx,10h            ; hauteur dans les bits forts
    sub ebx,40             ; pour une marge basse
    mov dword eax,[ebp+20]
    and eax,0FFFFh         ; largeur dans les bits faibles
    sar eax,1              ;  à la moitie de la largeur
    sub eax,42             ; moins la moitié de la taille du bouton
    push TRUE
    push 25                ; largeur bouton
    push 85                ; longueur
    push ebx               ; x
    push eax               ; y
    push  dword[hBouton]
    call MoveWindow   
    mov ebx,__LINE__ - 1
    cmp eax,0
    je .erreurWP
                           ; deplacement résultats
    mov dword ebx,[ebp+20]
    shr ebx,10h            ; hauteur dans les bits forts
    sub ebx,150            ; faut garder de la place pour le bouton qui est en dessous
    mov dword eax,[ebp+20]
    and eax,0FFFFh         ; largeur dans les bits faibles
    sub eax,40             ; marge à droite
    push TRUE
    push ebx               ; largeur zone
    push eax               ; longueur zone
    push 100               ; x
    push 10                ; y
    push  dword[hWndAff]
    call MoveWindow   
    mov ebx,__LINE__ - 1
    cmp eax,0
    je .erreurWP
    jmp .retourproc   
.destroy:                  ; fermeture de la fenetre
    push 0
    call PostQuitMessage   
    jmp .retourproc   
.commande:   
    mov    eax,[ebp+16]    ;wParam **** Process Menu Commands ****
    and    eax,0FFFFh
    cmp eax,BN_CLICKED
    je .bouton
    jmp .retourproc       
.bouton:   
                                ; Recuperation de la zone saisie
    push dword [hwndedit]       ; zone de saisie
    call GetWindowTextLengthA   ; récuperation de la longueur saisie
    mov ebx,__LINE__ - 1
    cmp eax,0
    je .erreurWP
    add eax,1                   ; pour le zero terminal
    push eax                    ; donc longueur totale de la saisie à recuperer
    push szZoneResult           ; buffer
    push dword[hwndedit]        ; zone d'edition
    call GetWindowTextA         ; on récupere le texte saisi pour le mettre dans le buffer
    mov ebx,__LINE__ - 1
    cmp eax,0
    je .erreurWP

    ;=====================================
    ;ici il faut ajouter vos propres instructions 
    ;puis preparer les resultats dans la zone buffer
    ;pour les afficher par les instructions suivantes
    ;pour exemple on convertit le texte saisi en majuscule
    push szZoneResult           ; buffer à convertir
    call CharUpperA             ; appel de la conversion en place
    push szZoneResult           ; buffer à afficher
    push 0
    push WM_SETTEXT
    push dword[hWndAff]         ; handle de la zone d'affichage
    call SendMessageA           ; et envoi du message
    mov ebx,__LINE__ - 1
    cmp eax,0
    je .erreurWP
    jmp .retourproc       
.erreurWP:
    push ebx
    call afficherErreur
    jmp .retourproc   
.retourdefaut:   
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call DefWindowProcA
.retourproc:   
    leave
    ret
;=====================================================   
;centrage de la fenetre   
;=====================================================
Centrage_fenetre:
    enter 0,0
    call GetDesktopWindow       ; recherche handle fenetre bureau windows
    mov ebx,__LINE__ - 1
    cmp eax,0
    je .Centrage_fenetre_erreur
    push recfen                 ; adresse de la structure  parent
    push eax                    ; handle de l'écran complet récuperé plus haut
    call GetWindowRect
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .Centrage_fenetre_erreur
    push recenf                 ; adresse de la structure  enfant
    push dword [ebp+8]          ; handle de notre fenetre
    call GetWindowRect
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .Centrage_fenetre_erreur
    mov    eax, [recfen+RECT.right]   ; centrage horizontal
    sub    eax, [recfen+RECT.left]    ;x=Px+(Pdx-Cdx)/2
    sub    eax, [recenf+RECT.right]
    add    eax, [recenf+RECT.left]
    sar    eax, 1
    add    eax, [recfen+RECT.left]   
    cmp eax,0                         ; depassement gauche ecran
    jge .depok
    mov eax,0
.depok: mov    [xNew], eax
    push SM_CXFULLSCREEN
    call GetSystemMetrics
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .Centrage_fenetre_erreur
    sub    eax, [recenf+RECT.right]
    add    eax, [recenf+RECT.left]
    cmp eax,[xNew]
    jge .depok1
    mov    [xNew], eax
.depok1: mov    eax, [recfen+RECT.bottom]    ; center vertically
    sub    eax, [recfen+RECT.top]    ; y=Py+(Pdy-Cdy)/2
    sub    eax, [recenf+RECT.bottom]
    add    eax, [recenf+RECT.top]
    sar    eax, 1
    add    eax, [recfen+RECT.top]   
    cmp eax,0                          ; depassement haut ecran
    jge .depok2
    mov eax,0
.depok2: mov    [yNew], eax       
    push SM_CYFULLSCREEN
    call GetSystemMetrics
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .Centrage_fenetre_erreur
    sub    eax, [recenf+RECT.bottom]
    add    eax, [recenf+RECT.top]
    cmp eax,[yNew]
    jge .depok3
    mov    [yNew], eax
.depok3:
    push SWP_NOSIZE + SWP_NOZORDER
    push NULL
    push NULL
    push dword [yNew]
    push dword [xNew]
    push NULL
    push dword [ebp+8] ; hwnd enfant
    call    SetWindowPos
    mov ebx,__LINE__ - 1
    cmp eax,0
    jne .Centrage_fenetre_fin
.Centrage_fenetre_erreur:
    push ebx
    call afficherErreur
.Centrage_fenetre_fin:
    leave
    ret    4
   
;========================================================================
;ajout d'une zone de saisie
;=========================================================================
ajout_saisie:                 ;creation d'une zone de saisie,c'est une fenetre
    push NULL
    push NULL
    push NULL
    push  dword[hWnd]         ;handle de la fenetre
    push 20                   ; largeur de la zone
    push 340                  ; longueur de la zone
    push 50                   ; position verticale
    push 10                   ; position horizontale
    push  WS_CHILD | WS_VISIBLE | WS_BORDER
    push NULL
    push szTypeSaisie         ; type qui indique zone de saisie
    push NULL
    call CreateWindowExA
    mov ebx,__LINE__ - 1
    cmp eax,0
    je .erreurS
    mov [hwndedit],eax        ; on garde le handle pour récuperer le contenu de la zone
    jmp .fin
.erreurS:
    push ebx
    call afficherErreur
.fin:
    ret
;=======================================================
;ajout d'un bouton
;=======================================================   
ajout_bouton:                   ; creation d'un bouton  c'est aussi une fenetre
    push NULL                   ; pas de de données complémentaires
    push NULL
    push BN_CLICKED             ; identification de ce bouton
    push  dword[hWnd]           ; handle de la fenetre parent
    push 25                     ; hauteur du bouton
    push 85                     ; largeur du bouton
    push 310                    ; position verticale
    push 100                    ; position horizontale du bouton
    push  WS_CHILD | WS_VISIBLE ; styles de la fenêtre
    push szTitreBouton          ; texte à afficher
    push szTypeBouton           ; c'est la classe qui indique que c'est un bouton
    push NULL                   ; pas de style complémentaire
    call CreateWindowExA
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .erreurB
    mov [hBouton],eax
    jmp .fin
.erreurB:
    push ebx
    call afficherErreur
.fin:
    ret
;=======================================================
;ajout d'une zone de resultat
;=======================================================   
ajout_result:
                                ; creation d'une zone d'affichage
                                ; mais qui est une zone d'édition multiligne  et c'est aussi une fenêtre !! windows
    push NULL
    push dword[hWnd]            ; handle de la fenetre maitre
    push ID_EDITCHILD
    push  dword[hWnd]           ; hwnd
    push 200                    ; hauteur zone
    push 300                    ; largeur zone
    push 100                    ; haut de la zone
    push 10                     ; gauche de la zone
    ;parametre : c'est une fille, visible, multiligne avec des ascenseurs 
    push  WS_CHILD | WS_VISIBLE | WS_BORDER| WS_VSCROLL |  ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL
    push szTitreAff             ; titre mais ne sert pas ici
    push szTypeSaisie           ; zone modifiable
    push 0           
    call CreateWindowExA        ; création de la zone
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .erreurB
    mov [hWndAff],eax
    push szTexteInit            ; initialisation avec une zone vide
    push 0
    push WM_SETTEXT
    push eax                    ; handle de la zone d'affichage créee juste avant
    call SendMessageA           ; envoi d'un message avec le contenu du texte 
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .erreurB
    jmp .fin
.erreurB:
    push ebx
    call afficherErreur
.fin:
    ret