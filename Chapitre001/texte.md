# Chapitre 1 : les outils <br>
Que nous faut-il tout d’abord,pour commencer à programmer en assembleur ?  il nous faut un éditeur de texte pour saisir le programme source : cela peut donc aller du bloc-notes, à notepad++ , et à des edi plus complexes. Choisissez celui qui vous convient le mieux sachant qu’un éditeur avec coloration syntaxique pour l’assembleur serait un plus.
 <br>
Ensuite il nous faut un compilateur pour traduire le sources assembleur en un module objet. Dans ce tutoriel, je vais donc utiliser nasm disponible gratuitement sur le site https://www.nasm.us/ et dont l’utilisation et l’apprentissage est assez facile. Il utilise la syntaxe Intel pour la prise en compte des sources.
Il vous faut le télécharger et l’installer dans un répertoire de votre ordinateur. Téléchargez aussi la documentation de nasm au format pdf (et lisez là plusieurs fois mais elle est en anglais).
Il est lancé dans une console batch windows ou dans une fenêtre powerShell par la commande  <br>
`
répertoire\nasm.exe -f win32 nomprogramme.asm -l nomprogramme.txt
` <br>
>avec repertoire le nom du dossier contenant l’exécutable de nasm  <br>
l’option -f win32 qui va créer un objet au format windows 32 bits <br>
avec nomprogramme.asm le nom de votre source assembleur <br>
l’option -l nomprogramme.txt qui récupérera le listing de compilation. <br>

L’objet résultat sera stocké sur le répertoire de lancement avec le nom  <nomprogramme>.obj  <br>

Il nous faut aussi un éditeur de lien ou linker qui va créer un programme exécutable à partir de l’objet issu de la compilation. Nous allons utiliser le programme goLink disponible sur le site  http://www.godevtool.com/  . Vous devez le télécharger ainsi que la documentation (en anglais) et l’installer dans le même répertoire que nasm (ou un autre répertoire).
Il se lance avec la commande : <br>

`répertoire\GoLink.exe  nomprogramme.obj /console Kernel32.dll User32.dll Gdi32.dll /entry:Main ` <br>

>avec repertoire le nom du dossier contenant l’exécutable de GoLink  <br>
nomprogramme.obj  le nom de l’objet crée par la compilation <br>
/console  une option demandant l’affichage de la  console batch  <br>
 Kernel32.dll User32.dll Gdi32.dll : les dll nécessaires à la exécution des fonctions de l’API Windows  <br>
/entry Main : l’option précisant quelle instruction du programme doit être exécutée en premier.  <br>

Voici un exemple de script  <A href="https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre001/compil32pgm1.bat"> ici </a> sous la forme d’un .bat.  <br>



Pour tester tout cela, nous écrivons <a href="https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre001/pgmCh1_1.asm">ce petit programme pgmCh1_1.asm</a> avec notre éditeur, nous le sauvegardons puis nous exécutons le script. Nous corrigeons au fur et à mesure les erreurs éventuelles : nom des répertoire erronés, nom du programme source, erreur de saisie etc.
 <br>
Vous devez obtenir un exécutable avec le nom **nomduprogramme.exe** et il suffit de cliquer dessus pour l'exécuter. Remarque : **aucun émulateur n’est nécessaire !!!** c’est parfait. <br>
Mais rien ne se passe : pas d’erreur, pas d’affichage, rien !!   Mais ceci est normal. <br>
Vous pouvez quand même vérifier la bonne exécution du programme en affichant le code retour soit en ajoutant dans un .bat l’instruction batch echo %ErrorLevel% soit l’instruction echo $LASTEXITCODE si vous lancez le programme dans le powerShell de Windows. <br>Vous devoir voir la valeur 5.<br><br>
Dans le chapitre suivant nous allons décortiquer ce programme. <br>
