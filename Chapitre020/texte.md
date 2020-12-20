# Chapitre 20 : création d »une simple fenêtre Windows. <br>

 Puisque Windows gère tout dans des fenêtres, nous allons créer notre première fenêtre simple. Il y a une documentation importante sur Internet sur le système de fenêtrage de Windows. Je vous conseille de la lire.<br>
Dans le programme ceatFen1.asm, nous allons d'abord créer une classe des fenêtres par la fonction RegisterClassExA et dont l'unique paramètre à passer est une structure (WNDCLASSEX). Il nous faut donc d'abord décrire cette structure  puis créer l'instance (wcex) de la structure dans le programme par istruc. Pour faciliter le travail nous reprenons les mêmes noms des éléments de la structure que ceux de la documentation Microsoft : <br>

```asm
; classe des fenetres
struc WNDCLASSEX
.cbSize: resd 1
.style: resd 1
.lpfnWndProc: resd 1
.cbClsExtra: resd 1
.cbWndExtra: resd 1
.hInstance: resd 1
.hIcon: resd 1
.hCursor: resd 1
.hbrBackground: resd 1
.lpszMenuName: resd 1
.lpszClassName: resd 1
.hIconSm: resd 1
.fin :
endstruc
```

Tous les éléments sont des doubles mots. Dans le programme avant l'appel de la fonction il faut alimenter chaque donnée. <br>
La première cbSize est la taille de la structure. Elle est donnée par le label .fin placé en fin de description de la structure. Mais nous pouvons la calculer à la main :il y a 12 doubles mots de 4 octets donc la taille est de 48.<br>
Ensuite nous indiquons le style de la fenêtre : ici nous demandons le ré affichage complet de la fenêtre suite à un agrandissement horizontal et vertical. Ensuite il faut indiquer le nom de la procédure qui va gérer les événements de la fenêtre. Cette procédure sera écrite plus bas dans le programme. Et donc à chaque fenêtre que vous créerez par la suite il faudra y associer une procédure de gestion (ici WndProc).<br>
Les 2 autres données seront mises à zéro puis la donnée hInstance sera initialisée avec le handle du programme récupéré au tout début. Dans le cas de création d'une fenêtre fille, cette zone sera alimentée avec le handle de la fenêtre mère.<br>
Ensuite hIcon sera mise à null ici mais cela sert à insérer une image d’icône dans la fenêtre.
Puis on récupère une image standard du pointeur de la souris par LoadCursorA et on met le résultat dans hCursor. On définit ensuite la couleur de l'arrière plan de la fenetre dans .hbrBackground:.
On met lpszMenuName à NULL car on ne récupérera pas de menu par défaut depuis un fichier ressources Windows. ( en effet la création d'un fichier ressources Windows nécessite des logiciels supplémentairement et propriétaires).<br>
On termine par l'attribution d'un nom à cette classe (classe1).<br>
Après l'appel de la fonction RegisterClassExA, on vérifie s'il n'y a pas d'erreur et on empile tous les paramètres pour créer la fenêtre par CreateWindowExA.<br>
Le premier paramètre est mis à NULL car inutilisé ici. Ensuite il faut passer le handle du programme récupéré au tout début puis l'identifiant de la fenêtre que l'on met à NULL pour simplifier puis le handle de la fenêtre parent, ici à NULL puisque c'est la fenêtré principale.<br>
Ensuite on définit la hauteur et la largeur de la fenêtre, et sa position verticale et horizontale sur l'écran. Puis le style de la fenêtre qui permet d'avoir les menus système standard : WS_OVERLAPPEDWINDOW (voir la documentation Microsoft pour toutes les autres options).<br>
On passe ensuite l'adresse du titre de la fenêtre et sa classe dont le nom doit être identique au nom crée par RegisterClassExA. Et nous mettons le dernier paramètre à NULL pour avoir une simple fenêtre ; Ouf !! on appelle la fonction CreateWindowExA et on vérifie s'il n ‘y a pas d ‘erreur.<br>
Dans le registre eax, on récupère le handle de la fenêtre créee que l'on conserve dans une zone mémoire. Ensuite on va appeler 2 fonctions standards pour afficher la fenêtre : ShowWindow et pour dessiner éventuellement le contenu de la celle ci : UpdateWindow.<br>
Mais ce n'est pas encore terminé car le programme doit gérer les événements liés à cette fenêtre. Windows utilise un système de messages envoyés par chaque élément et qui devront être traités.<br>
C'est pourquoi, nous trouvons une boucle dans laquelle une fonction récupère les messages GetMessageA et les traite par TranslateMessage et DispatchMessageA. On sort de la boucle lorsque le code retour de GetMessageA sera à 0 et le programme se terminera. Ici on affiche un message de bonne fin pour vérifier que le programme se termine bien un jour !! (en fait à la fermeture de la fenêtre crée).<br>
GetMessageA nécessite une structure de type MSG que nous avons décrit à la suite de la structureWNDCLASSEX.<br>
Tout est prêt pour compiler ce programme ? Et non, lors de la création de la classe de la fenêtre, je vous dit qu'il fallait donner un nom de procédure (WndProc) pour gérer les événements de la fenêtre et qu'il faudrait écrire son contenu.<br>
Cette routine est un peu particulière car c'est Windows qui va l'appeler et lui passer 4 paramètres. De plus nous n'aurons pas besoin de dépiler les paramètres en fin d'appel. Ces routines sont appelées  callback dans la documentation.  Il faut bien regarder quels sont les paramètres à récupérer et la valeur de retour à renvoyer dans le registre eax en fin de routines.<br>
Pour cela nous utilisons la pseudo-instruction enter 0,0 qui va recopier l'adresse de la  pile dans  le registre ebp, ce qui  nous permet de récupérer le handle de la fenêtre (hwnd en ebp+8 ) puis le type de message (umsg en ebp+12) et 2 paramètres (wparam en ebp+16 et lparam en eb‌p + 20 )dont le contenu sera variable suivant le type de message.<br>
Ici nous allons tester 3 types de messages : WM_DESTROY envoyé lors de la fermeture de la fenêtre par l'utilisateur, WM_CREATE envoyé par Windows lors de la création de la fenêtre et WM_PAINT envoyé par la fonction UpdateWindows que nous avons appelée après la création de la fenêtre. Par la suite, nous serons amenés à tester d'autres types de message .<br>
Pour WM-DESTROY, on se contente d'appeler la fonction PostQuitMessage qui terminera la boucle de gestion des messages que nous avons vu plus haut. Pour vos programmes c'est ici qu'il faudra ajouter les traitements de fin (sauver des données par exemple).<br>
Pour WM_CREATE, Nous allons écrire une zone de texte dans le corps de la fenêtre. En fait c'est une fenêtre fille de la fenêtre principale.<br>
Comme pour cette dernière on renseigne tous les paramètres en précisant le handle de la fenêtre mère, en mettant WS_CHILD | WS_VISIBLE | SS_LEFT dans le style de la fenêtre, puis l'adresse du texte à afficher et surtout en donnant comme classe static pour indiquer qu'il s'agit d'un libellé.<br>
Pour WM_PAINT, on écrira aussi du texte dans le corps de la fenêtre pour montrer la méthode à suivre. Il faut commencer par appeler la fonction BeginPaint à laquelle il faut passer en paramètre une structure de type PAINTBRUSH qui contiendra les informations en retour et le handle de la fenêtre. Ici comme la structure ne servira pas, nous nous contentons de passer une adresse d'une zone de 20 double mots. En retour nous récupérons dans eax, un handle vers le contexte de dessin de la fenêtre (display device context ) qui nous servira pour toutes les fonctions d'affichage.<br>
Ensuite nous préparons l'affichage du texte en appelant la fonction TextOutA et en lui passant la longueur du texte, l'adresse du texte, sa position dans la fenêtre et le handle précédent.<br>
Nous terminons l'affichage en appelant la fonction EndPaint avec les mêmes paramètres que BeginPaint.<br>
Un dernier point : comme il peut y avoir d'autres messages que nous n'avons pas gérés, nous terminons la procédure en appelant la fonction DefWindowProcA en lui passant les 4 paramètres reçus en entrée. <br>
Bien entendu, toutes les fonctions citées doivent être renseignées en début du programme avec le mot clé extern.<br>
Après la compilation, exécutons notre programme : une belle fenêtre s'affiche avec en haut les menus systèmes, le titre de la fenêtre et dans le corps les textes que nous avons préparés. Vous pouvez avec la souris déplacez la fenêtre et la redimensionner (mais nos textes ne bougent pas!!!). Pour la fermer, vous n'avez que la croix en haut à droite.<br>
Et voici notre première fenêtre terminée. Cela paraît compliqué au premier abord, mais vous verrez que la plupart de ces fonctions seront identiques d'un programme à l'autre.<br>
Vous pouvez vous amuser à modifier les emplacements des fenêtres et du texte ou de tester les différents styles possibles.<br>
