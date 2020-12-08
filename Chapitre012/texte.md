# Chapitre 12 : Structures. Includes

Vous avez remarqué : chaque programme reprend toujours les mêmes routines. Il serait donc plus simple de regrouper ces routines dans un fichier annexe puis de les appeler dans les programmes maitres. <br>
Nous allons voir une première méthode qui consiste à insérer le fichier qui les contient dans le programme maître grâce à l’instruction %include. <br>
Nous créeons donc un fichier includeRoutines.asm dans le quel nous mettons les déclarations de constantes, les déclaration des zones utilisées par les routines et le code de chaque routine.<br>
Dans le programme principal [structureTableau.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre012/structureTableau.asm), nous supprimons toutes ces données et nous les remplaçons par l’instruction%include « ./includeRoutines.asm » si le fichier des routines se trouvent dans le même répertoire que le programme principal. Mais il est plus judicieux de mettre les routines dans un répertoire d’un niveau supérieur et de les appeler avec l’instruction%include « ../includeRoutines.asm ». <br>

Maintenant notre programme principal est simplifié. <br>
Dans le chapitre précédent, nous avons vu la lecture et l ‘écriture dans un tableau simple (une seule zone de 4 octets). Nous allons voir un tableau un peu plus compliqué avec 3 zones de taille différente. <br>
Pour décrire ce type de donnée, nasm propose des instructions de description de structure : struc et endstruc entre lequel nous insérons le définition de chaque zone (voir le programme). Les zones peuvent avoir un nom unique spécifique à la structure ou des noms déjà utilisées en les faisant commencer par un point. Le point signifie que le nom est local à la structure et sera donc référencé lors de son utilisation par nomstructure.nomzone.<br>
Nous terminons par un label de fin qui nous permettra d’avoir la taille totale des zones.<br>

Ensuite dans la .bss nous réservons de la place pour 10 postes du tableau en multipliant la taille de chaque poste par 10.<br>
Ensuite pour faciliter la mise à jour de chaque poste, nous écrivons une routine qui va prendre en entrée le N° de poste à mettre à jour et les valeurs des 3 zones du poste. Pour calculer l’adresse de chaque poste, il nous faut multiplier son ° par la longueur de chaque poste telle que déclarée par la structure et l’écriture d »une zone  s’effectue par : <br>

```asm
mov [dTableau3+eax+posteTab.zone1],ebx
```

avec dTableau3 représentant l’adresse de début du tableau,<br>
avec eax qui contient le déplacement d’un poste tel que calculé précédemment<br>
avec  posteTab.zone1 le déplacement de la zone donnée par la description de la structure.<br>

Et ça marche !!! voir l’exemple et sa vérification dans le programme. <br>

Une autre manière d’utiliser les structures, c’est de créer une instance de la structure pour y déclarer directement des valeurs. C’est l’exemple de la structure testInst du programme [structureTableau.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre012/structureTableau.asm).<br> 

Apr-s création de la définition de la structure, l’instance est créee forcément dans la .data avec les instructions istruc et iend. La syntaxe des instructions pour fixer les valeurs et un peu complexe :

```asm
    at testInst.zone1, dd 0x22223333
```

L’utilisation de la zone s’effectue plus simplement :

```asm
     mov ax,[exempleInst+testInst.zone3]
```

Nous verrons l’utilité des structures pour alimenter les données de certaines fonctions de l’Api Windows.
