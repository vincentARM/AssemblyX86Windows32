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
Dans cette syntaxe, mov représente le mnémonique du code opération, et eax le nom du registre destnataire. <br>
Puis nous trouvons l ‘instruction push eax, qui place le contenu du registre eax (soit 5) sur la pile. Nous verrons plus tard ce qu’est la pile. <br>
Puis nous appelons la fonction de l’Api windows qui termine proprement le programme. Elle va en particulier récupérer la valeur se trouvant sur la pile et la passer au système d’exploitation ce qui permet d’afficher sa valeur avec la commande echo.  <br>
Je dis terminer proprement, car cette fonction va aussi nettoyer tous les gravats que nos futurs programmes peuvent laisser derrière eux (fichiers non fermés par exemple).
Plutôt que d’utiliser cette fonction, nous pouvons aussi utiliser l’instruction ret pour rendre la main au système d’exploitation. Mais cela est très dangereux car notre programme peut laisser une situation instable au système d’exploitation qui peut se comporter bizarrement après l’exécution de notre programme.  <br>

Dans le répertoire de compilation, nous trouvons aussi le fichier pgmCh1₁.txt qui contient la liste de compilation crée par l’option -l pgmch1₁.txt de nasm.  <br>
Si nous regardons son contenu, nous voyons 2 parties : une à gauche qui ne contient que des chiffres hexadécimaux en face des instructions assembleur (ce sont les instructions en langage machine, les seules compréhensibles par le microprocesseur) et une partie à droite qui reprend les lignes de notre programme.  <br>
Vous constatez que les commentaires et les pseudo instructions n’ont aucune correspondance avec du code machine.

Nous pouvons aussi remplacer la valeur 5 par un nom de constante. Dans le programme pgmCh2_2.asm nous définissons la valeur 5 avec le nom CINQ avec la pseudo instruction : <br>
```asm 
%define  CINQ    5
```
et nous remplaçons l'instruction mov eax,5 par mov eax,CINQ. <br>
Attention, il n'ya pas de stockage de 5 quelque part, simplement le compilateur dans une première phase remplace le nom CINQ par la valeur 5.

Je vous ai indiqué aussi que l'étiquette Main: représentait l'adresse du début du programme. Dans le programme pgmCh2_3. asm, nous mettons cettte adresse dans le registre eax comme ceci :
```asm 
    mov eax,Main         ; sans le : 
```
Et si nous examinons le résultat après exécution du programme nous trouvons un nombre comme : 4198400 qui dépend de votre environnement de travail. <br> Donc les instructions de notre programme commencent à l'octet 4198400 de la mémoire de l'ordinateur. <br>

Nous pouvons aussi effectuer des calculs : par exemple des additions est des soustractions  comme dans le programme pgmCh2-3.asm <br>
```asm
    mov eax,12
    add eax,15         ; ajoute 15 au registre eax
    sub eax,3          ; enleve 3 au registre eax
```
Et nous pouvons en combinant cela calculer la taille d’une instruction comme dans le programme pgmCh2_5.asm :<br>
```asm
Main:
    mov eax,Main       ; met l'adresse définie par Main dans le registre eax
et1:
    mov ebx,et1        ; met l'adresse définie par et1 dans le registre ebx
    sub ebx,eax        ; calcule la différence
    push ebx           ; met le contenu du registre sur la pile
```
Vous remarquerez que nous utilisons un deuxième registre ebx pour effectuer la soustraction. Après compilation et exécution, le résultat trouvé est 5 soit une longueur de 5 octets pour l’instruction mov eax,Main. <br>
Et si vous regardez le résultat de la compilation dans le fichier pgmch2-5.txt vous trouvez qu’en effet l’instruction machine à bien une longueur de 5 : <br>
```asm
18 00000000 B8[00000000]                mov eax,Main       ; met l'adresse définie par Main dans le registre eax
19                                  et1:
20 00000005 BB[05000000]                mov ebx,et1        ; met l'adresse définie par et1 dans le registre ebx
``` 
<br>
Voyons maintenant comment écrire une boucle. Dans le programme pgmCh2_6.asm, nous allons calculer la somme des nombres de 1 à 5 : <br>
Le registre eax servira de totalisateur et nous l’initialisons à 0. Nous devons à chaque utilisation d’un registre, et si necessaire l’initialiser à la valeur que nous souhaitons car il peut contenir n’importe quoi.<br>
Le registre ebc servira de compteur de boucle de 1 à 5. Nous l’initialisons à 1 et il sera incrementé de 1 dans la boucle avec l’instruction <br>
```asm
    inc ebx
```
Pour terminer la boucle nous comparons la valeur du registre ebx avec la valeur 5 avec l’instruction <br>
```asm
cmp ebx,5 
```
et nous bouclons à l’étiquette .A1 : si le compteur est plus petit ou egal avec l’instruction <br>
```asm
jle .A1
```
j pour jump en anglais c’est à dire saut l pour less (plus petit) et e pour égal.<br>
Nous verrons dans un autre chapitre toutes les autres possibilités des sauts .<br>
Après compilation et exécution, l’affichage du code retour du programme donne bien la valeur 15 (1+2+3+4+5).<br>

Enfin un dernier exemple  avec le programme pgmCh2_7.asm qui va afficher la valeur entière stockée dans une zone de la mémoire. <br>
Pour cela nous déclarons dans le segment .data une étiquette  zone1 : pour réserver une zone de 4 octets contenant la valeur 12 avec la pseudo instruction : <br>
```asm
zone1:      dw 12
```
DW signifiant Data Word (Déclaration d’un Word (un mot)) cad 4 octets. Mais pourquoi 4 octets ? Parce qu’un entier est contenu dans un registre 32 bits soit 4 octets.<br>
>Rappel : un octet (ou byte) contient 8 bits. Un demi-mot (Half Word) contient 2 octets. Un mot contient 4 octets. Un double mot contient 8 octets.

Ensuite dans le segment code nous mettons le contenu de la zone dans le registre eax avec l’instruction : <br>
```asm
    mov  eax,[zone1]
```
Cette fois ci, l’étiquette est entre crochet car nous voulons charger son contenu et non pas sa valeur comme nous l’avons fait avec mov eax,Main. Je vous ai laissé en commentaire dans le programme l’instruction mov eax,zone1 qui va mettre l’adresse dans eax.<br>
Vous pouvez compiler les 2 versions et vous verrez que la première vous donne le résultat 12 et la seconde une valeur dans les 4200000 ce qui est très différent. <br>
