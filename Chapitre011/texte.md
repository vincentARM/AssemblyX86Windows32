Chapitre 11 : la mémoire
Le système d’exploitation donne à notre programme assembleur une certaine quantité de mémoire que nous pouvons utiliser de différentes manières. La plus petite partie que nous pouvons adresser est l’octet soit 8 bits et nous essairons de voir combien Windows nous donne d’octets. <br>
Cette mémoire disponible est divisée en segment (ou sections) avec chacun un usage particulier. <br>
Nous trouvons le segment .data qui contient les données qui seront initialisés par notre programme à l’aides des pseudo instructions db (data byte = 1 octet), dw (data word = 2 octets), dd (double word = 4 octets) et dq (quadruple word = 8 octets) et d’autres définitions concernant les nombres en virgule flottante que nous verrons plus tard. <br>
Avec nasm, il est possible de définir plusieurs zones de même type en les séparant par une virgule. Voir les exemples dans le programme accesMemoire.asm. <br>
Il est aussi possible de laisser au compilateur le soin de calculer la longueur d’une zone en effectuant la différence entre l’adresse courante donnée par le symbole $ et le début de la zone.  Voir un exemple dans le programme cité plus haut.<br> 
<br>
Notre programme peut lire et écrire dans ce segment. <br>
Ensuite nous trouvons le segment .BSS (Block Started by Symbol ) qui contient les données qui seront initialisées à zéro binaire par le système d’exploitation avant l’exécution du programme. Pour définir les données il est possible d’utiliser les pseudo instructions db, dw, etc mais il existe les pseudo instructions de réservation de place comme resb 10 (réserve 10 octets), resw 5 (réserve 5 mots soit 10 octets) resd 20 (réserve 20 double mot soit 80 octetsà et resq 1. <br>
Notre programme peut aussi lire et écrire dans ce segment. <br>

Puis nous trouvons le segment .text qui contient les instructions exécutables du programme. Notre programme ne peut lire que les zones de ce segment, il ne peut pas écrire.<br>

Cet ordre est l’ordre habituel des segments lors de l’écriture du programme source mais le chargement réel en mémoire sera indiqué par les directives du linker. Avec golink, il ne nous est pas possible de connaître cet ordre mais en affichant les adresses de chaque zone commençant un segment, nous arriverons à trouver l’ordre de chargement.<br>
<br>
Ensuite nous trouvons la pile qui est situé à la fin de la mémoire qui nous est attribuée et comme nous l’avons déjà vu lors de l’appel de routine, nous pouvons lire et écrire des données.<br>

Puis il reste toute la mémoire comprise entre les 3 premiers segments et la pile : cette zone est appelée le tas et elle nous servira à réserver de la place de manière dynamique lors de l’execution du programme gràace à des fonctions de l »Api Windows. <br>

Pour charger (lire) une donnée de la mémoire dans un registre, il faut utiliser l’instruction mov et en indiquant l’origine de la donnée entre crochet comme ceci
mov eax,[qZone1] ; charge 4 octets de la mémoire à partir de  l’adresse qZone1
Rappel : mov eax,qZone1  charge dans le registre eax, l’adresse définie par qZone1
.<br>
Pour charger un octet, il faut utiliser comme registre destinataire les parties basses ou hautes d’un registre (al ou ah, bl ou bh etc). Attention comme le montre l’exemple dans le programme le reste du registre est inchangé, ce qui peut entraîner des erreurs (par exemple en testant tout le registre à zéro cmp eax,0 au lieu de tester cmp al,0 après le chargement.).<br>
En utilisant comme registre destinataire la partie 16 bits d’un registre comme ax,bx,cx ou dx, nous pouvons charger 2 octets de la mémoire et en utilisant le registre complet comme eax,ebx ecx ou edx, 4 octets. <br>

L’adresse à charger peut donc être une étiquette comme base mais aussi un registre comme mov eax,[ebx], un registre de base plus un déplacement comme mov eax,[ebx+4], avec une constante mov eax,[ebx+DIX], un registre de base plus un déplacement contenu dans un registre plus une constante comme mov eax,[ebx+ecx+4] et enfin le plus complexe , un registre de base un registre de déplacement multiplié par un ratio plus une constante. Mais le ratio ne peut prendre que les valeurs 2 4 et 8. <br>
Cette dernière possibilité permet d’accéder à un élément d’un tableau. Par exemple dans le programme, nous avons défini un tableau de 10 entiers (double mot de 4 octets) dont l’adresse de début  est dTableau1.Cette adresse peut être mis dans le registre ebx par mov ebx,dTableau1. Le premier poste sera lu avec l’instruction mov eax,[ebx] et le 5ième poste en ajoutant l’instruction mov ecx,5 puis la lecture par mov eax,[ebx+ecx*4).<br>

Puis nous passons à l’écriture des zones en mémoire. C’est très simple c’est l’inverse de la lecture par exemple mov [dReserve2],eax pour mettre le contenu du registre eax dans les 4 octets de la zone mémoire qui commence à l’adresse dReserve2. Ici nous testons l’écriture de 2 octets et 4 octets dans les zones situées dans le segment BSS et nous vérifions par une lecture la réalité du stockage!!<br>
Mais ce serait bien d’avoir un affichage des données de la mémoire de manière brute pour voir comment sont stockées les données. <br>
C’est l’objet du programme afficherMémoire.asm dans lequel nous trouvons la routine AfficherMem qui attend 2 paramètres : l’adresse de début des zones mémoire, et le nombre de blocs de 16 octets  que nous voulons afficher. <br>
Dans la routine nous commençons par récupérer ces 2 paramètres et nous affichons un titre avec le rappel de l’adresse de début. Puis nous calculons un début de bloc de 16 octets de telle façon que le bloc commence à une adresse multiple de 16 et précédent l’adresse demandée. <br>
Ensuite nous effectuons 2 boucles ; la première lit chacun des 16 octets du bloc, le convertir en 2 caractères hexadécimal et les positionne à la bonne place sur la ligne d’affichage. <br>
La seconde recommence la lecture des mêmes 16 octets, vérifie s’ils sont affichables en ascii sinon met un ? À la place et les positionne les uns à la suite des autres sur la ligne d’affichage. Puis cette ligne est affichée et si le nombre de bloc demandé n’est pas atteint, la routine boucle sur le bloc de 16 octets suivant. <br>
Pour faciliter la lecture de l’affichage en hexadécimal une étoile est affichée devant le premier caractère de l’adresse demandée (sauf si celle ci est déjà un début de bloc).
Tout cela paraît compliqué mais voici le résultat de l’affichage de 2 bloc à partir de l’adresse sZtitrte , zone qui se trouve au début de la .data. <br>

```
Affichage mémoire : adresse :00402000
00402000 57 69 6E 33 32 00 56 61 6C 65 75 72 20 64 75 20  "Win32?Valeur du "
00402010 72 65 67 69 73 74 72 65 20 3A 00 0A 00 41 66 66  "registre :???Aff"
```

Sur la première ligne, nous retrouvons la valeur de l’adresse demandée en hexadécimal puis sur la deuxième et troisième ligne, l’adresse en hexa des débuts des blocs puis les valeurs en hexa des 16 octets et enfin la conversion en ascii des mêmes octets. <br>
Nous retrouvons bien le titre de la fenêtre sur 5 octets suivi du point d’interrogation qui représente donc un caractère non ascii. Si nous regarsons dans la première partie nous trouvons 5 valeurs hexa correspondant à la valeur des codes ascii et le zéro binaire final qui caractérise la fin de chaîne.Puis nous trouvons les caractères du message suivant. Donc nous voyons bien comment sont stockées les données dans la mémoire.<br>
Maintenant demandons l’affichage à partir de la donnée szMsg qui se trouve à l’adresse 402006h qui n’est pas un début de bloc. Nous voyons une étoile affichée devant le premier caractère de cette zone ce qui permet de bien la déchiffrer.<br>
Continuons en demandant l’affichage à partir de la zone Main du segment .text. Il n’ya pas beaucoup de caractères ascii ce qui est normal puisque ce sont les instructions de notre programme qui y figurent. Mais si nous regardons le fichier du listing de compilation produit par nasm, nous trouvons que la première instruction push esp correspond au code machine 54 que nous retrouvons dans le 1er octet en hexa de l’affichage. Vous pouvez retrouver ici toutes les instructions et vous pouvez remarquer que les instructions qui font appel à des adresses ont été renseignées par le linker. <br>
Maintenant dans le programme copieTableau.asm, nous allons copier les 10 postes d’un tableau d’entiers se trouvant dans la .data dans un second tableau se trouvant dans la .bss puis nous afficherons ce dernier avec notre dernière routine.<br> 
Voici le résultat : <br>

```
+1703796
Affichage mémoire : adresse :004023A7
004023A0 00 00 00 00 00 00 00*01 00 00 00 02 00 00 00 03  "????????????????"
004023B0 00 00 00 04 00 00 00 05 00 00 00 06 00 00 00 07  "????????????????"
004023C0 00 00 00 08 00 00 00 09 00 00 00 0A 00 00 00 00  "????????????????"
004023D0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  "????????????????"
004023E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  "????????????????"
+1703796
```

Nous retrouvons bien les valeurs de 1 à 10 stockés sur 4 octets avec quand même une bizarrerie : l’octet de poids faible est stocké dans le premier octet. En effet les processeurs peuvent stocker les données en mémoire comme cela , c’est le mode petitboutiste (little-endian ) ou à l’inverse l’octet de poids fort est stocké en premier, c’est le mode grosboutiste (big-endian ) . Voir sur Wikipedia l’origine de ces noms c’est amusant.<br>
Il faut le retenir si vous stockez un registre sur 4 octets en mémoire  puis si vous traitez un à un les octets qui le composent. <br>
Vous remarquez aussi que le tableau commence à une adresse qui n ‘est pas alignée sur une frontière de 4 octets comme 0,4,8,12. Mais il est recommandé de toujours aligner en mémoire les zones en fonction de leur type : les quadruples mots sur une frontière de 8 octets, les doubles mots comme ici sur une frontière de 4 octets, les mots sur une frontière de 2 octets et bien sur les simples octets sont libres!!<br> 
Pour cela nous disposons de la pseudo instruction .align 8 ou 4 ou 2. Nous le vérifions avec la zone iZoneAlignee qui se trouve bien alignée sur une frontière de 4 octets et nous remarquons que c’est le code 90h qui est utilisé pour l’alignement. <br>
