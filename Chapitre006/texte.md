# Chapitre 6 : Addition et soustraction de nombres entiers
Je vous rappelle que les registres sont de minuscules composants du microprocesseur qui comportent 32 positions qui peuvent coder les valeurs entières de 0 à 2 puissance 32 -1.
Nous avons déjà parlé des registres eip (pointeur d’instructions), esp (pointeur de pile) ebp (pile de base) et entraperçu au fil des programmes précédents les registres dits généraux. <br>
Ils sont au nombre de 4 (ce qui est peu) eax,ebx,ecx et edx <br> 
Ces registres peuvent être divisés en 2 parties de 16 bits chacune et la partie basse (bits 0 à 15) est appelée respectivement ax, bx, cx et dx. Cette partie est elle même divisée en 2 sous parties de 8 bits (un octet) appelées al,bl,cl,dl pour la partie basse et ah,bh,ch,dh pour la partie haute. <br>
Les instructions assembleurs sont capables de manipuler toutes ces entités pour effectuer des calculs ou des manipulations. <br>
Nous allons commencer par l’addition 32 bits (voir le programme additionRegistre.asm). Dans ce programme nous commençons par additionner 2 valeurs immédiates par l’intermédiaire du registre eax puis nous additionnons 2 registres. Il faut se rappeler que le registre destinataire est le premier et donc que add eax,ebx n’est pas pareil que add ebx,eax.
Mais une question se pose : comme le nombre maximum codé dans un registre est 4 294 967 295, que se passe t’il si nous additionnons la valeur 5 à cette valeur maximum : le résultat affiché est 4 ce qui est bien gênant car faux. <br>
Heureusement, le microprocesseur le détecte et le signale en positionnant un indicateur de retenue (carry) à 1 et l’assembleur propose 2 instructions pour sauter à une étiquette suivant la valeur de la retenue jc et jnc.<br> 
Dans le programme nous effectuons le test et nous affichons un message suivant le cas. <br>
Il faudra donc dans vos futurs programmes, de faire attention lors de l’utilisation de grands nombres  et penser à tester ce dépassement possible.<br>
Enfin nous terminons ce programme avec l’instruction d’incrémentation (sur un autre registre pour changer) inc edx qui remplace l’instruction add edx,1.<br> 

Voyons maintenant la soustraction  dans le programme soustractionRegistre.asm. Nous effectuons la soustraction de valeurs, de registres et nous remarquons que la soustraction d’un nombre plus grand que le premier opérateur  est fausse. <br>
Mais là aussi, le processeur place un indicateur à 1 c’est l’indicateur de signe et nous avons 2 instructions pour tester sa valeur js et jns.<br>
Nous terminons le programme en testant l’instruction dec edx qui remplace l’instruction sub edx,1.<br>

Mais cela veut-il dire que nous ne pouvons effectuer des calculs que sur des nombres entiers positifs ? Non car les ingénieurs ont décidé que les nombres de 1 à 2 puissance 31 – 1  (2 147 483 647) seraient positifs et les nombres de 2 puissance 31(2 147 483 648) à 2 puissance 32 -1 (4 294 967 295 ) seraient des nombres négatifs et que ces derniers seraient codés en complément à 2 (en fait à 2 puissance 32). <br>
donc par exemple -1 sera codé comme le nombre  4 294 967 296 – 1 soit  4 294 967 295.<br>
comme cela l’opération 5 + (-1) sera égale à  5 + 4 294  967 295 dont le résultat comme nous l’avons vu dans le programme d’addition est 4. les calculs effectués par le processeur seront donc exacts. <br>
Remarque : cela aussi implique que le bit le plus à gauche (bit 31) est à 1 pour les nombres négatif et 0 pour les nombres positifs.<br>
Mais maintenant cela soulève un autre problème : l’addition de  2 147 483 647 et de 10 va donner  2 147 483 657 ce qui va donner le nombre négatif   4 294 967 296 -  2 147 483 657 = -2 147 483 638. <br> 
Heureusement la aussi, le processeur va positionner un indicateur ,celui de débordement (overflow) et nous avons 2 instructions pour le tester jo et jno.<br>
Mais nous devons aussi adapter notre routine de conversion et en écrire une seconde qui tient compte de cette codification et qui met en place le signe + ou – suivant le cas. <br>
Mais il reste encore un problème : comment le processeur sait-il que nous voulons manipuler des nombres positifs jusqu’à  4 294 967 295 ou des nombres positifs et négatifs ? Et bien il ne le sait pas !! c’est vous le programmeur qui savait ce que contient un registre et donc c’est à vous à prendre les mesures qui s’imposent !!!!<br>
Dans le programme afficherRegistreS.inc, nous écrivons et testons la routine d’affichage des nombres signés.<br>
Elle reprend les instructions de la routine pour les nombres non signés sauf que nous testons si le nombre est inférieur à 0 et dans ce cas nous mettons le signe – dans le registre dl et nous convertissons le nombre en nombre positif avec l’instruction neg eax ensuite nous effectuons les divisions successives par 10. <br>
Dans le programme nous testons une valeur positive, la valeur -1 et nous reprenons la soustraction qui posait problème pour montrer que maintenant nous affichons bien que 10 – 35 = -25.<br>
Mais il y a encore un problème à régler avec les nombres signés : comparer 2 nombres signés n’est pas la même chose que comparer 2 nombres non signés : en effet si nous voulons comparer 2 147 483 643 et 2 147 483 653   en non signé le premier nombre est inférieur au second tandis qu’en signé c’est le contraire car le deuxième nombre représente le nombre négatif -2147483643.<br>
Heureusement l’assembleur propose des sauts différents : <br>
- JA et JB pour les nombres non signés
- JG et JL pour les nombres signés<br>

Au passage, je remarque que l’affichage des libellés avec des accents est erroné. En cherchant, je vois que sur notepad++ l’encodage des sources est en UTF8. Je le modifie pour passer à l’encodage ANSI et l’affichage des caractères accentués devient correct. Il ne reste plus qu’a corriger tous les accents dans le programme source !!!!<br>
