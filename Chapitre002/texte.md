# Chapitre 2 : Les bases : premiers programmes : <br>
Dans le programme précédent qui nous a servi de test des outils, il y figure ;  <br>
- des commentaires  précédés par le caractère ; comme la ligne : <br>
`;programme 1 sert à  vérifier le bon fonctionnement `   <br>
- des pseudo instructions à destination du compilateur nasm pour préciser des éléments nécessaires à la compilation comme :  <br>
`segment data ou global Main `  <br>
- des instructions pour le processeur :  `mov eax, 5` <br>
- des appels à des fonctions de l’api windows : `call ExitProcess ` <br> 
- des labels ou étiquettes : ` Main: `   <br>
Les commentaires sont ignorés par le compilateur et ne servent qu’aux programmeurs.  <br>
En assembleur, ils sont essentiels pour comprendre ce que font les instructions. <br>

Les pseudo instructions segment indiquent l’organisation de la mémoire et son contenu. Nous verrons plus tard le rôle des différentes parties de la mémoire. <br>
Ici les segments data et bss sont vides. Seul le segment .text contient les instructions pour le microprocesseur.  <br>
La pseudo instruction global indique que le label Main pourra être vu par des processus extérieurs et en particulier par le linker.  <br>
C’est la même chose pour extern qui indique que la fonction ExitProcess se trouve ailleurs dans une librairie. <br>

Dans le segment .text, nous trouvons le label Main (un label ou étiquette est toujours suivi de : ) qui représente l’adresse du début des instructions.  En effet, il ne nous est pas possible de savoir à quelle adresse exacte, notre programme va être chargé en mémoire. Nous le marquons donc par une étiquette et nous laissons le soin au compilateur, puis au linker puis au système d’exploitation de déterminer cette adresse. Tout d’abord la pseudo instruction global va permettre au compilateur puis au linker de savoir où est cette etiquette.  <br>
Dans les directives du linker, nous avons indiqué l’option /entry :Main et c’est cela qui va indiquer à Windows où se trouve notre première instruction à exécuter. Bien sûr, nous pouvons changer le nom de ce label pour l’appeler Principal : par exemple mais il faudra aussi modifier ce nom dans la directive /entry du linker sinon il y aura signalement d’une erreur.  <br>

L’instruction mov eax,5 indique au processeur de mettre la valeur 5 dans le registre eax.
<br>
Un registre est un minuscule composant électronique qui contient 32 interrupteurs qui sont soit éteints soit allumés et qui représentent les données binaires 0 ou 1. Ces 32 données peuvent donc coder les nombres entiers de 0 à 2 puissance 32 -1 soit 4 294 967 295.   <br>
Ce nombre peut réprésenter tout ce que vous voulez : un nombre, un (ou plusieurs) caractère codé en ascii, le code couleur d’un pixel, une adresse de la mémoire, un nombre de carottes, etc etc. Seul vous programmeur saurez ce que le contenu représente !!  <br>
Ici nous demandons au processeur de mettre la valeur immédiate 5. Vous remarquerez que le registre de destination est placé avant la valeur origine. C’est une normalisation de la syntaxe pour l’assembleur des processeurs Intel.  <br>
Puis nous trouvons l ‘instruction push eax, qui place le contenu du registre (soit 5) sur la pile. Nous verrons plus tard ce qu’est la pile. <br>
Puis nous appelons la fonction de l’Api windows qui termine proprement le programme. Elle va en particulier récupérer la valeur se trouvant sur la pile et la passer au système d’exploitation ce qui permet d’afficher sa valeur avec la commande echo.  <br>
Je dis terminer proprement, car cette fonction va aussi nettoyer tous les gravats que nos futurs programmes peuvent laisser derrière eux (fichiers non fermés par exemple).
Plutôt que d’utiliser cette fonction, nous pouvons aussi utiliser l’instruction ret pour rendre la main au système d’exploitation. Mais cela est très dangereux car notre programme peut laisser une situation instable au système d’exploitation qui peut se comporter bizarrement après l’exécution de notre programme.  <br>

Dans le répertoire de compilation, nous trouvons aussi le fichier pgmCh1₁.txt qui contient la liste de compilation crée par l’option -l pgmch1₁.txt de nasm.  <br>
Si nous regardons son contenu, nous voyons 2 parties : une à gauche qui ne contient que des chiffres hexadécimaux en face des instructions assembleur (ce sont les instructions en langage machine, les seules compréhensibles par le microprocesseur) et une partie à droite qui reprend les lignes de notre programme.  <br>
Vous constatez que les commentaires et les pseudo instructions n’ont aucune correspondance avec du code machine.

Nous pouvons aussi remplacer la valeur 5 par un nom de constante. Dans le programme pgmCh2_2.asm nous définissons la valeur 5 avec le nom CINQ avec l'instruction <br>
```asm
%define  CINQ    5
```
et nous remplaçons l'instruction mov eax,5 par mov eax,CINQ. <br>
