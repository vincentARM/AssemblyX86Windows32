# Chapitre 8 : Opérations sur les bits d'un registre. <br>

A partir de la routine qui convertit le contenu d’un registre en base 10, nous la modifions pour afficher les 32 positions d’un registre sous la forme de 0 et de 1 c’est à dire effectuer une conversion en base 2.  Nous remplaçons la division par 10 par une division par 2. Nous verrons ultérieurement comment améliorer cette routine. <br>
Dans le programme [afficherRegistreBinaire.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre008/afficherRegistreBinaire.asm), nous utilisons cette routine pour afficher le nombre 7 soit 111 en binaire puis le nombre -1. Dans ce dernier cas vous voyez que les 32 bits du registre sont à 1 et donc que -1 est égal à 2 puissance 32 – 1 et représente la plus grande valeur d’un registre 32 bits. <br>
Maintenant dans le programme [operationsBinaires.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre008/operationsBinaire.asm), nous utilisons la routine pour voir les opérations logiques sur les bits. Pour cela nous mettons 4 bits du registre eax avec la valeur 0b1100 et 4 bits du registre ebx avec la valeur binaire 0b0101. Remarquez que nous utilisons la syntaxe Ob pour indiquer au compilateur que nous voulons mettre dans le registe la valeur binaire et pas la valeur décimale. <br>
Ensuite nous combinons les 2 registres avec l’operateur ET : and et vous remarquez que seule la position où les 2 bits sont à 1 est affichée à 1. Cet opérateur est donc interessant pour extraire 1 ou plusieurs bits d’un registre. Par exemple si nous voulons extraire  les 4 bits du registre eax à partir du 3 ième bit, il suffit de faire un and du registre avec la valeur 0b1111000. <br>
Puis nous effectuons l’opération avec le OR, le XOR, le NOT et le NEG.<br> 
L’opérateur xor effectué sur le même registre permet de mettre à zéro tous les bits du registre. Il est souvent utilisé pour initialiser à zéro un registre. <br>
Ces opérations binaires mettent aussi à jour les indicateurs. <br>
Nous pouvons ainsi tester la valeur d’un bit particulier avec l’instruction test. Par exemple test eax,0b1000   teste le bit qui est en 4ième position. Cette instruction effectue un and logique mais sans modifier la valeur du registre, elle met à jour les indicateurs. Si la valeur du bit du registre est 0, alors l’indicateur de zéro sera positionné et si le bit est à 1, l’indicateur de zéro sera mis à zéro. <br>


Dans le programme [deplaBinaire.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre008/deplaBinaire.asm), nous allons tester les déplacements de bits. Tout d’abord avec l’instruction shl (shift left) nous déplaçons tous les bits du registre eax de 5 positions sur la gauche. <br>
Puis avec l’instruction shr (shift right) nous déplaçons tous les bits de 2 positions sur la droite.<br>
Pour des déplacements à droite ou à gauche d’un bit, il est possible de récupérer la valeur du bit éjecté. En effet celui ci est stocké dans l’indicateur de retenue (carry) et il suffit d’utiliser les instructions de saut jc ou jnc pour connaître sa valeur. <br>
Si nous regardons l’impact de ces déplacements sur des valeurs décimales, vous remarquerez qu’un déplacement sur la gauche correspond à une multiplication par 2 et un déplacement sur la droite aà une division par 2. Par exemple un déplacement de 3 positions sur la droite  correspond à une division par 8 du contenu du registre pour des valeurs non signées.<br>
Nous pouvons aussi effectuer des rotations de tous les bits à droite ou à gauche avec les instructions rol et ror.  Il existe aussi les instructions sal et sar qui permette de réinjecter le bit contenu dans le carry. Je vous laisse le soin de les tester.<br>

Enfin dans le programme [modificationBits.asm],(https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre008/modificationBits.asm), nous allons tester différentes instructions de modifications de bits.<br>
La première bt eax,3 met le 3ième bit du registre eax dans le carry ce qui permet de le tester.<br>
La 2ième btc eax,1 met le bit 1 dans le carry et inverse celui du registre : s’il y avait zéro, le bit passe à 1 sinon c’est le contraire.<br>
La 3ième btr eax,2 met le bit 2 dans le carry et remet celui du registre à zéro.<br>
La 4ième bts eax,4 met le bit 4 dans le carry et met le bit du registre à 1.<br>

Enfin les 2 dernières bsf eax,ebx et bsr eax,ebx, analyse les bits du registre ebx et mettent la position du premier bit à 1 trouvé dans le registre eax. Bsf part de la droite et bsr de la gauche.<br>

voici les résultats :

```
+1703796
Zero : 0 Signe: 0 Carry: 1 Offset: 0
Zero : 0 Signe: 0 Carry: 0 Offset: 0
Valeur du registre :00000000000000000000000000001110
Zero : 0 Signe: 0 Carry: 1 Offset: 0
Valeur du registre :00000000000000000000000000001010
Zero : 0 Signe: 0 Carry: 0 Offset: 0
Valeur du registre :00000000000000000000000000011010
Valeur du registre :+7
Valeur du registre :+9
+1703796

```
Au vu de ces instructions, nous pouvons maintenant améliorer la routine d’affichage en base 2. Nous pouvons remplacer l’instruction de division par 2 par l’instruction shr eax,1 mais il nous faut aussi calculer le reste donc il faut multiplier le résultat précédent par 2 avec l’instruction shl eax,1 et soustraire le résultat de la valeur de départ soit la séquence suivante :<br>

```asm
mov edx,eax ; sauve le dividende de départ
shr eax,1       ; nouveau dividende = dividende / 2
mov ebx,eax ; copie le dividende
shl ebx,1       ; multiplie par 2
sub edx,ebx ; pour calculer le reste

```

Mais il y a mieux à faire : il suffit de déplacer la valeur de départ d’une position à gauche avec l’instruction shl eax,1 et qui va mettre le bit 31 dans le carry puis de tester celui ci avec l’instruction jc pour positionner soit le caractère 0 soit le caractère 1.<br>
C’est ce que fait la nouvelle routine dans le programme : [afficherRegistreNouBin.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre008/afficherRegistreNouBin.asm). Et pour éviter d’avoir à mettre des étiquettes je teste les instructions de copie contitionnelle cmocc et cmovnc qui ne feront les instructions mov que si le carry est ou non positionné. Mais cela pert de son intérêt car l’opérande source ne peu être qu’un registre ou une zone mémoire.
