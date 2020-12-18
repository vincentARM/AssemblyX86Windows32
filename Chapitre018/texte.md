# Chapitre 18 : calculs avec des nombres en virgule flottante.

Jusqu’ici nous avons vu des manipulations de nombres entiers sur 4 octets. Dans ce chapitre nous allons effectuer des calculs avec des nombres avec une virgule (des réels ) (en anglais float) . Avec les processeurs X86 il est possible d’effectuer des calculs sur des zones de 4 octets et des zones de 8 octets. Ici nous utiliserons des zones de 8 octets pour avoir une meilleure précision. <br>
Les nombres en virgule flottante sont codifiés très précisément avec une norme, la norme IEEE754 (voir wikipédia) et la trans codification d’une chaîne de caractères en float ou son inverse en respectant cette norme est une tâche extrêmement complexe en assembleur. Nous utiliserons donc les fonctions de l’API window pour effectuer les conversions.<br>

Les opérations sur ces nombres font appel à un coprocesseur particulier (FPU), à des instructions spéciales et à une organisation des registres sous la forme d’une pile. 

Une synthèse des instructions peut être consulté ici : https://en.wikibooks.org/wiki/X86_Assembly/Floating_Point

Le FPU possède 8 registres de 80 bits chacun (1 bit pour le signe, 15 bits pour l'exposant, 64 bits pour la mantisse). Ces 8 registres ne sont pas adressables directement comme dans le cas de l'unité d'arithmétique entière. Ils constituent une pile de registres, que l'on nommera st0, st1, ..., st7. st0 désigne le sommet de la pile (c'est à dire le dernier élément empilé) et sti désigne le i-ème élément de la pile de registres. <br>
Donc première difficulté, s »agissant d’une pile, il faut savoir à tout moment ce que contienne chaque registre de la pile  et chaque instruction peut faire évoluer ces registres.!! <br>
L’autre problème c’est qu’il n’a pas d’instruction pour transferer des données des registres généraux (eax ebx etc)  vers ces registres de la pile et vice versa et il n’est pas possible d’y mettre des valeurs immédiates (sauf quelques unes comme 1 ou 0 ou pi avec des instructions spéciales). Toutes les valeurs doivent être passées à partir de zones mémoire.<br> 
Bon voyons comment cela fonctionne. Dans le programme [nombreFloat.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre018/nombreFloat.asm) nous déclarons dans la .data quelques nombres en virgule flottante. Comme nous allons travailler sur 8 octets, nous utilisons le code dq (pour data quadruple  mot) et en mettant un point (notation anglo saxonne pour la place de la virgule) pour signaler à nasm qu’il doit les codifier en float. Si vous affichez ces zones, vous pouvez voir qu’elles sont illisibles pour nous !! <br>
Ensuite dans la partie code, nous allons utiliser quelques instructions pour calculer le périmètre d’un cercle à partir de son rayon. Tout d’abord, nous initialisons tous les registres de la pile avec l’instruction finit. Attention ils ne sont pas initialisées à zéro mais à une valeur particulière.<br>
Puis nous utilisons soit l’instruction fild dword [rayonEntier] pour mettre dans le registre st0 une valeur entière sur 4 octets soit l’instruction fld qword [qRayon] pour mettre un nombre float sur 8 octets dans le registre st0. Vous remarquez que le nom du registre n’est pas spécifié puisque s’agissant d’une pile, ces instructions stockent les valeurs sur le sommet de la pile.<br>
Ensuite nous utilisons l’instruction fmul qword [pi] pour multiplier le contenu de st0 par pi  et le résultat restera dans st0 puis l’instruction fmul qword [Deux] pour multiplier le registre st0 par 2 et laisser le résultat dans st0.<br>
Et nous transférons ce résultat en mémoire avec l’instruction fstp qword [qResult]. Mais attention, nous avons mis un p à l’instruction fst, ce qui indique au coprocesseur de dépiler les registres. Si nous n’avions pas mis le p, le résultat serait resté sur la pile après sa copie en mémoire.<br>
Donc en mémoire dans la zone qResult nous avons le résultat mais codé en float. Nous allons utiliser la fonction VarBstrFromR8 pour le convertir en caractère unicode (en effet il n’y a pas de fonctions de conversion en ascii) et il faudra utiliser la fonction WideCharToMultiByte pour convertir les caractères unicode en caractère ascii et afficher la chaîne résultat.

Pour vérifier le contenu du registre st0 nous refaisons les opérations de conversion et le résultat affiché est -1,#IND ce qui semble être un code erreur .<br>
Relancer le programme en enlevant le p de l’instruction fst et vous verrez que le résultat affiché est de nouveau correct ce qui montre qu’il n’a pas été dépilé.<br>

Maintenant voyons la saisie d’un nombre avec une virgule  dans le programme [saisieFloat.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre018/saisieFloat.asm). <br>
Nous reprenons notre routine de saisieClavier pour saisir une chaine de caractères représentant le nombre en virgule flottante. Attention ici, il doit être saisi avec une virgule (alors que défini dans la data, il faut un point). Puis cette chaîne de caractère ansi est convertie en caractère unicode grâce à la fonction MultiByteToWideChar car la fonction de conversion d’une chaîne vers un nombre en virgule flottante VarR8FromStr n’accepte que des caractères unicode en entrée. Cette fonction a aussi pour paramètre la constante LOCALE_CUSTOM_DEFAULT qui permet de prendre en compte la virgule à la place du point.<br>

Ensuite nous nous contentons d’effectuer une boucle pour calculer la 5ième puissance du nombre saisi puis nous affichons le résultat en utilisant la séquence vue dans le programme précedent : conversion du float vers caractères unicode, conversion de ces caractères en caractères ansi, insertion du résultat dans le message et enfin affichage.<br>

Dans le programme [resolDich.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre018/resolDich.asm), nous allons voir un calcul faisant intervenir une boucle. Il s’agit de la résolution par dichotomie de l’équation x=x au carré moins 2. <br>
Dans la partie .data nous décrivons les différentes variables necessaires. Dans la partie code, j’ai mis de nombreux commentaires pour expliquer les instructions et le mouvement des registres. J’ai beaucoup utilisé les mouvements avec la mémoire et je pense que l’on peut en économiser certains en analysant plus précisément les opérations à effectuer. <br>
Le calcul de la fonction est effectué par appel à la routine calculFct à laquelle nous passons l’adresse de la valeur et l’adresse de la zone résultat. <br>
La principale difficulté est le test des registres de la pile. En effet il faut utiliser l’instruction fcomip qui effectue la comparaison mais qui met à jour les indicateurs standards (Z,N et C) et il faut donc utiliser le tableau de la doc intel pour savoir quels indicateurs tester : <br>
voir le paragraphe 3.343 du volume 2 de la documentation Intel. <br>
J’ai aussi trouvé ce tableau qui montre mieux les sauts à effectuer :<br>
+--------------+---+---+-----+------------------------------------+
| Test         | Z | C | Jcc | Notes                              |
+--------------+---+---+-----+------------------------------------+
| ST0 < ST(i)  | X | 1 | JB  | ZF will never be set when CF = 1   |
| ST0 <= ST(i) | 1 | 1 | JBE | Either ZF or CF is ok              |
| ST0 == ST(i) | 1 | X | JE  | CF will never be set in this case  |
| ST0 != ST(i) | 0 | X | JNE |                                    |
| ST0 >= ST(i) | X | 0 | JAE | As long as CF is clear we are good |
<br>
Vous remarquerez que dans ce programme il y a aussi un test du registre ecx  qui limite le nombre de boucle du calcul. Ces instructions sont un exemple de sécurité à mettre en place car il n’est pas facile en cas de problème de trouver ce qui cloche dans la manipulation de la pile. <br>

Je vous laisse le soin de découvrir les autres instructions dans les différentes documentations sur Internet.<br>

