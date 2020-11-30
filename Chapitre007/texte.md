# Chapitre 7 : multiplication et division de nombres entiers
Dans le programme [multiplicationReg.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre007/multiplicationReg.asm), nous commençons par afficher la valeur du registre esp pointeur de pile. A la fin du programme nous ré affichons ce registre pour vérifier qu’il contient bien la même valeur et donc que nous routines ne déphasent pas la pile. <br>
Ensuite, nous effectuons une multiplication simple non signée en mettant le 1er opérande dans le registre eax et le second dans un des autres registres généraux. En effet l’instruction mul n’agit que sur le registre eax comme 1er opérande et met le résultat dans les registres eax et edx. Donc attention, le contenu du registre edx est perdu lors d’une multiplication mais l’avantage c’est que nous pouvons multiplier 2 valeurs maxi de 32 bits.<br>
Remarque : la multiplication de 66000 par 66000 donne le résultat 61032704 dans eax et 1 dans edx  et il faut se rappeler que ce 1 signifie 1 * 2 puissance 32 soit 4 294 967 296 auquel on ajoute la valeur du registre eax  ce qui donne : 4 356 000 000  ce qui est exact.<br>
Ensuite nous multiplions un nombre négatif par un nombre positif avec l’instruction mul et le résultat contenu dans eax semble correct. Mais si on regarde le contenu du registre edx, celui contient une valeur erronée. Pour les nombres signés il faut utiliser l’instruction imul qui donne pour eax le même résultat et pour edx, la valeur -1 et cette valeur est correcte bien que cela peut paraître bizarre. Car ici il faut raisonner comme si nous étions en 64 bits (2 registres de 32 bits) et le complément à deux doit être calculé par rapport à 2 puissance 64.<br>

Curieusement imul peut accepter un registre source et un registre destination et même une valeur immédiate (voir les exemples dans le programme). Mais attention dans ce cas, le résultat de la multiplication ne peut être qu’un registre de 32 bits et donc une valeur résultat maxi de  4 294 967 295. <br>

Ces 2 instructions de multiplication activent suivant les cas, les indicateurs de Carry et d’Overflow (et toujours les 2 simultanément) . Elles ne mettent pas à jour les indicateurs de signe ou de Zéro.<br>
Dans le programme [multiplicationRegInd.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre007/multiplicationRegInd.asm), j’ai ajouté une petite routine qui adffiche le contenu des 4 indicateurs et nous allons l’appeler après chaque multiplication (dont les opérandes seront identiques au premier programme).<br>
Voici les résultats :

``` +1703796
Zero : 0 Signe: 0 Carry: 0 Offset: 0
50
0
Zero : 0 Signe: 0 Carry: 1 Offset: 1
61032704
1
Zero : 0 Signe: 0 Carry: 1 Offset: 1
-350
+34

Zero : 0 Signe: 0 Carry: 0 Offset: 0
-350
-1

Zero : 0 Signe: 0 Carry: 0 Offset: 0
+9900
-1

Zero : 0 Signe: 0 Carry: 1 Offset: 1
+61032704
+314

Zero : 0 Signe: 0 Carry: 1 Offset: 1
3800301568
2095475792

+1703796 
```


Maintenant voyons la division dans le programme [divisionReg.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre007/divisionReg.asm):<br>

L’instruction de division div effectue la division non signée des 2 registres edx:eax par le diviseur contenue dans un des 2 autres registres ebx ou ecx. Le quotient sera mis dans le registre eax et le reste dans edx. Donc attention : ne pas oublier cela et ne pas oublier de mettre zéro dans le registre edx lorsque la division se fait sur un nombre de 32 bits sinon vous aurez un résultat aberrant et vous pouvez mettre un certain temps à comprendre pourquoi !! De plus comme le quotient ne peut être que contenu dans un registre 32 bits, le dividende ne peut pas prendre n’importe quelle valeur. Par exemple la division 50 000 000 000 par 2 n’est pas possible car le résultat est plus grand que 2 puissance 32 -1. Dans ce cas, le programme s’arrête net !!  <br>
Pour la division aucun des indicateurs n’est positionné.<br>


Pour les nombres signés il faut utiliser l’instruction idiv qui divise la paire edx:eax par ebx ou ecx.
Mais attention si le dividende (contenu dans eax) est un nombre négatif il faut mettre -1 dans le registre edx pour avoir un complément à 2 correct.<br>
Ici aussi, aucun indicateur n’est positionné quelque soit les cas traités.<br>
Et cette division n’accepte aussi que la possibilité d’un registre (donc ebx ou ecx).<br>
