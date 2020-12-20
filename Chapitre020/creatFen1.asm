; programme creatFen1.asm
; Programme :création d'une fenetre simple

;====================================
; constantes
;====================================
%include "./includeConstantes.inc"

NULL    equ 0
FALSE   equ 0
TRUE    equ 1
; constantes de l'API windows pour la gestion des fenêtres
CS_VREDRAW            equ    00001h
CS_HREDRAW            equ    00002h
CS_REDRAW             equ CS_VREDRAW | CS_HREDRAW
CS_PARENTDC           equ    00080h
CS_BYTEALIGNWINDOW    equ    02000h

COLOR_BACKGROUND      equ    001h
COLOR_WINDOW          equ    005h
COLOR_3DFACE          equ    00Fh
COLOR_3DSHADOW        equ    010h
COLOR_APPWORKSPACE    equ    00Ch
COLOR_3DLIGHT         equ    016h

IDC_ARROW             equ    07f00h

SS_LEFT               equ    00h
SS_CENTER             equ    01h
SS_RIGHT              equ    02h
SS_ICON               equ    03h
SS_BLACKFRAME         equ    07h

SW_HIDE               equ    00h
SW_SHOWNORMAL         equ    01h
SW_SHOWMINIMIZED      equ    02h
SW_SHOWMAXIMIZED      equ    03h
SW_SHOW               equ    05h
SW_RESTORE            equ    09h
SW_SHOWDEFAULT        equ    0Ah

WM_CREATE             equ    0001h
WM_DESTROY            equ    0002h
WM_SIZE               equ    0005h
WM_SETTEXT            equ    000Ch
WM_PAINT              equ    000Fh
WM_CLOSE              equ    0010h
WM_QUIT               equ    0012h
WM_ERASEBKGND         equ    0014h
WM_GETMINMAXINFO      equ    0x0024
WM_NOTIFY             equ    004Eh
WM_HELP               equ    0053h
WM_NCCREATE           equ    0x0081
WM_CHAR               equ    0102h
WM_INITDIALOG         equ    0110h
WM_COMMAND            equ    0111h
WM_TIMER              equ    0113h
WM_HSCROLL            equ    0114h
WM_VSCROLL            equ    0115h
WM_MENUSELECT         equ    011Fh
WM_CTLCOLORDLG        equ    0136h
WM_MOUSEMOVE          equ    0200h
WM_LBUTTONDOWN        equ    0201h
WM_LBUTTONUP          equ    0202h
WM_LBUTTONDBLCLK      equ    0203h
WM_RBUTTONDOWN        equ    0204h
WM_RBUTTONUP          equ    0205h
WM_RBUTTONDBLCLK      equ    0206h
WM_CUT                equ    0300h
WM_COPY               equ    0301h
WM_PASTE              equ    0302h
WM_CLEAR              equ    0303h
WM_UNDO               equ    0304h
WM_USER               equ    0400h

WS_POPUP              equ    080000000h
WS_CHILD              equ    040000000h
WS_MINIMIZE           equ    020000000h
WS_VISIBLE            equ    010000000h
WS_MAXIMIZE           equ    001000000h
WS_CAPTION            equ    000C00000h
WS_BORDER             equ    000800000h
WS_DLGFRAME           equ    000400000h
WS_VSCROLL            equ    000200000h
WS_HSCROLL            equ    000100000h
WS_SYSMENU            equ    000080000h
WS_SIZEBOX            equ    000040000h
WS_TABSTOP            equ    000010000h
WS_MINIMIZEBOX        equ    000020000h
WS_MAXIMIZEBOX        equ    000010000h
WS_OVERLAPPEDWINDOW   equ    000CF0000h
WS_EX_NOPARENTNOTIFY  equ    000000004h
WS_EX_WINDOWEDGE      equ    000000100h
WS_EX_CLIENTEDGE      equ    000000200h
WS_EX_OVERLAPPEDWINDOW  equ    WS_EX_WINDOWEDGE + WS_EX_CLIENTEDGE

WS_EX_DLGMODALFRAME   equ    1
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
;=======================================
; segment des données initialisées
;=======================================
segment .data 
szTitre     db 'Message Fin', 0
szMsg       db 'Fin du programme', 0
szTitreFen  db "Fenêtre 1",0
szClasseFen db "Classe1",0
szTexteAff  db "Exemple de texte ",10,13,"affiché dans la fenêtre",0
szTexte1    db "Autre exemple de texte",0
iLgTexte1 equ $ - szTexte1   ; longueur du texte précedent
szTypeStatic db "static",0
;instance de la classe des fenetres
wcex:
   istruc WNDCLASSEX
   iend
;lgwxex equ $ -     wcex

;instance message 
msg: istruc MSG
       at MSG.fin,  db  "<<<  "
     iend
;=======================================
; segment des données non initialisées
;=======================================
segment .bss
hInst    resd 1      ; handle programme
hMainWnd resd 1      ; handle fenêtre principale
hWnd     resd 1      ; handle fenêtre 
hdc      resd 1
ps       resd 20
;=======================================
; segment de code
;=======================================
segment .text
    global Main
    extern afficherErreur,TextOutA,GetModuleHandleA,LoadCursorA,RegisterClassExA,CreateWindowExA
    extern ShowWindow,GetMessageA,PostQuitMessage,DefWindowProcA,UpdateWindow,TranslateMessage
    extern DispatchMessageA,BeginPaint,EndPaint
Main:
    push NULL
    call GetModuleHandleA                                     ; recup handle de l'instance du programme
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .gestionerreurs
    mov [hInst], eax
                                                              ;creation de la classe des fenetres
    mov dword[wcex+WNDCLASSEX.cbSize], WNDCLASSEX.fin         ;taille de la structure de la classe de la fenetre
    mov dword[wcex+WNDCLASSEX.style],CS_HREDRAW | CS_VREDRAW  ; style des fenetres
    mov dword[wcex+WNDCLASSEX.lpfnWndProc], WndProc           ; nom de la procedure qui va gerer les évenements de la fenetre

    xor eax,eax
    mov    dword[wcex+WNDCLASSEX.cbClsExtra], eax             ;raz de ces zones
    mov    dword[wcex+WNDCLASSEX.cbWndExtra], eax

    mov    dword eax, [hInst]
    mov    dword[wcex+WNDCLASSEX.hInstance], eax              ;handle du parent
    mov    dword[wcex+WNDCLASSEX.hIcon], NULL
    ;chargement image curseur souris
    push IDC_ARROW
    push NULL
    call LoadCursorA
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .gestionerreurs
    mov    dword[wcex+WNDCLASSEX.hCursor], eax
    mov    dword[wcex+WNDCLASSEX.hbrBackground], COLOR_WINDOW + 1 ; couleur d'arrière plan
    mov    dword [wcex+WNDCLASSEX.lpszMenuName],  NULL
    mov    dword [wcex+WNDCLASSEX.lpszClassName], szClasseFen
                                                                  ;creation de la classe de la fenetre (c'est obligatoire)
    push wcex
    call RegisterClassExA
    mov ebx,__LINE__ - 1
    cmp eax,NULL
    je .gestionerreurs

                                    ; creation de la fenetre
    push NULL                       ; pas de données complémentaires
    push dword [hInst]              ; handle de l'instance du programme
    push NULL                       ; fenetre non identifiée
    push NULL                       ; pas de fenetre parent
    push 180h                       ; hauteur de la fenetre
    push 1A0H                       ; largeur de la fenetre
    push 0                          ; position verticale de la fenetre
    push 0                          ; position horizontale de la fenetre
    push dword WS_OVERLAPPEDWINDOW  ; fenetre standard avec menu système
    push dword szTitreFen           ; titre de la fenetre
    push dword szClasseFen          ; classe de la fenetre doit être identique à la classe crée par RegisterClassExA 
    push NULL                       ; pas de style complémentaire
    call CreateWindowExA
    mov ebx,__LINE__ - 1
    cmp  eax,NULL
    je   .gestionerreurs 
    mov    [hMainWnd],eax           ; conserve  le handle de la fenetre
    push SW_SHOWDEFAULT             ; affichage de la fenetre 
    push dword[hMainWnd]
    call ShowWindow
                                    ; ici on ne teste pas le code erreur (voir la doc microsoft)
    push dword[hMainWnd]
    call UpdateWindow               ;genere le message WM_PAINT qui dessinera dans la fenêtre
    mov ebx,__LINE__ - 1
    cmp  eax,NULL
    je   .gestionerreurs 
    
.boucle_commande:    
    push 0
    push 0
    push NULL
    push msg
    call GetMessageA                ;récuperation des messages 
    cmp eax,0                       ; fin de boucle l'utilisateur a fermé la fenetre
    jz .fin_commande
    push msg
    call TranslateMessage           ; convertit les actions clavier en message (voir la doc) 
    push msg
    call DispatchMessageA           ; envoie le message à la procédure de gestion de la fenetre 
    jmp .boucle_commande
.fin_commande:    
                                    ;message de fin du programme
    push MB_OK|MB_ICONINFORMATION   ; uType = bouton ok et  icone information
    push dword szTitre              ; Titre de la fenêtre
    push dword szMsg                ; message a afficher
    push 0                          ; hWnd = HWND_DESKTOP
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
    push eax                        ; code retour
    call ExitProcess                ; fin du programme
;===========================================================
;Procédure de gestion des évenements de la fenetre
;===========================================================    
WndProc:
                              ;recuperation des parametres  handle de la fenetre, type du message, wparam, lparam 
    enter 0,0
    mov eax,[ebp+8]           ; récup handle de la fenêtre
    mov dword [hWnd],eax      ; et save 
    mov eax,[ebp+12]          ; récup du type de message
    cmp eax,WM_DESTROY        ; fermeture de la fenêtre
    je .destroy
    cmp eax,WM_CREATE         ; création de la fenetre 
    je .create
    cmp eax,WM_PAINT          ; dessin du contenu de  la fenetre 
    je .paint
                              ; autre code à tester ici
    jmp .retourdefaut
.create:
                              ;ajout d'une zone texte dans la fenetre et c'est une fenetre !!!
    push NULL                 ; pas de de donnèes complémentaires 
    push dword [hInst]        ; handle de l'instance du programme
    push 1001                 ; identification de cette fenêtre
    push  dword[ebp+8]        ;  handle de la fenetre parent
    push 200                  ; hauteur de la fenetre 
    push 300                  ; largeur de la fenetre
    push 100                  ; position verticale
    push 60                   ; position horizontale de la fenetre
    push  WS_CHILD | WS_VISIBLE | SS_LEFT   ;styles de la fenêtre
    push szTexteAff           ; texte à afficher
    push szTypeStatic         ; c'est la classe qui indique que c'est un libellé
    push NULL                 ; pas de style complémentaire 
    call CreateWindowExA
    cmp eax,NULL
    je .erreurF
    
    jmp .retourproc
.paint:    
                              ; autre façon d'ecrire du texte dans la fenetre
    push ps
    push dword[hWnd]
    call BeginPaint           ; debut du dessin
    mov    [hdc], eax
    push iLgTexte1            ; longueur du texte à afficher
    push szTexte1
    push 10
    push 20
    push dword[hdc]
    call TextOutA
    push ps
    push dword[hWnd]
    call EndPaint             ; fin du dessin

    jmp .retourproc
.erreurF:
    call afficherErreur       ; affichage des erreurs
    mov eax,1
    jmp .retourproc
.destroy:
    push 0                    ; valeur de retour 
    call PostQuitMessage      ; envoie du message de fin (WM_QUIT)
    jmp .retourproc    
    
.retourdefaut:                ; appel par defaut pour tous les autres messages
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call DefWindowProcA
.retourproc:    
    leave
    ret
