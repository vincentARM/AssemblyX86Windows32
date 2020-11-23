Avant de voir comment afficher un message dans une fenêtre windows, nous allons prendre connaissance de la pile. <br>
La pile est une région de la mémoire souvent située à la fin de la mémoire qui vous est généreusement octroyée par le système d’exploitation. L’adresse de cette zone est initialisée par celui ci dans un registre particulier : le registre de pile esp. <br> 
Cette zone permet de stocker des données (contenus de registres, valeurs immédiates) dont la durée de vie est temporaire à l’aide d’instructions plus simples que des accés à la mémoire. <br>
Mais elle a aussi des contraintes : les données qui sont empilées sur la pile ne peuvent être que des valeurs de 32 bits, soit 4 octets ou leurs multiples et doivent être dépilées dans l ‘ordre inverse.<br>
 Les instructions utilisées sont des push pour empiler et des pop pour dépiler.<br>
L’adresse de la pile va décroître à chaque empilement et croître à chaque dépilement puisque la pile est située en fond de mémoire.<br>
L’adresse de la pile doit toujours rester un multiple de 4 octets. <br> 
Voyons un exemple :  <br> 
supposons que l’adresse de la zone stockée dans le registre de pile esp soit 10000
empilons les registres eax et ebx : 

```asm
push eax
push ebx
```

Le premier push va décrémenter l’adresse du registre de pile de 4 soit 9996 puis va mettre le contenu de eax à l’adresse stockée dans le registre de pile soit 9996  et ce contenu va occuper les adresses jusqu’à  9999.
Le deuxième push va décrémenter l’adresse du registre de pile de 4 soit 9992 puis va mettre le contenu du registre ebx  dans les adresses 9992 à 9995.
Maintenant dépilons les valeurs avec les instructions pop :

```asm
pop ebx
pop eax
```

Le premier pop va commencer par transférer les 4 octets situés aux adresses 9992,9993,9994,9995 dans le registre ebx  puis va incrémenter le registre de pile de 4 octets soit 9992+4 = 9996.<br>
Le deuxième pop va transférer les 4 octets à partir de cette adresse dans le registre eax puis va incrémenter le registre de pile de 4 octets soit 9996 + 4 = 10000.
Et nous retrouvons les bonnes valeurs dans les bons registres et le registre de pile avec la même adresse qu’au départ. Nous voyons que nous pouvons utiliser ce mécanisme pour sauvegarder puis restaurer des registres suivant le besoin. Mais rien n’oblige à utiliser les mêmes registres entre les push et les pop, et donc nous pouvons échanger des valeurs dans les registres !! Bon ce n’est pas la meilleure solution !!<br>
Mais la pile sert aussi à passer des paramètres aux fonctions et routines. Nous en avons eu un exemple avec la terminaison d’un programme :<br>

```asm
push eax
call ExitProcess
```

Ici nous passons le code retour contenu dans le registre eax à la fonction de l’Api windows ExitProcess.

Voyons maintenant l’affichage d’un message dans une petite fenêtre windows. <br>
Nous n’avons pas d’autre solution avec windows10 que d’utiliser une fonction de l’API : MessageBoxA <br>
Pour commencer nous allons aller chercher sur Internet la documentation de cette fonction :<br>
en tapant dans google documentation MessageBoxA <br>
Le premier lien donne accès en anglais à la doc de la fonction sous docs.microsoft.com .
Nous trouvons la syntaxe pour le C++, la description des paramètres et leurs valeurs éventuelles
et les valeurs du code retour. <br>
Super !! nous avons tout pour programmer en assembleur l’appel à cette fonction dans le programme hello32.asm : Il suffit de lui passer 4 paramètres en entrée et comme nous allons lui passer par la pile en utilisant des push, il nous faut les mettre dans l’ordre inverse de la documentation. <br>
En premier un code fonction  0 indique que la fenêtre aura un bouton Ok et 4 une fenêtre avec des boutons OUI/NON et il existe d’autres valeurs pour d’autres types de boutons. Nous allons mettre 0.<br>
Ensuite l’adresse d’une chaîne de caractère pour le titre de la fenêtre et puis l’adresse de la chaîne de caractère du message et enfin la référence de la fenêtre windows principale. Comme nous l’ignorons nous allons mettre 0.<br>

Mais il reste un problème à résoudre : qu’est ce qu’une chaîne de caractères en assembleur ? <br>
C’est une suite d’octets représentant des caractères codés en ascii (ou unicode) stockée dans une zone mémoire et terminée par un octet avec la valeur 0 (comme en C). Pour nous cette chaîne sera stockée dans le segment .data avec la pseudo instruction :

```asm
szMsg :   db 'Hello World', 0       ; message
```

Nous trouvons l’étiquette de la chaîne, db pour Data Byte le contenu de la chaîne entre quotes (simples ou doubles) puis la valeur 0 qui indique la fin de la chaîne.

Nous créons de la même façon une chaîne pour le titre qui sera affiché en haut de la fenêtre du message. Nasm donne la possibilité d’utiliser le nom du fichier source avec la pseudo instruction  __?FILE ?__. Nous créons un deuxième titre pour tester cette option, ce qui donne : <br>

```asm
szTitre  db 'Win32', 0
szTitre1 db __?FILE?__ , 0
```

Le programme hello32.asm se résume donc au passage des paramètres à l’appel de la fonction puis à la terminaison du programme. Le code retour ou une donnée d’une fonction de l’API s ‘effectue toujours dans le registre eax. La documentation précise que si la fonction échoue elle retourne 0 sinon elle retourne quelque chose. <br>
Dans notre programme nous passons le contenu de eax à la fonction ExitProcess pour voir le contenu de ce code retour. <br>
L’exécution affiche bien le message et l’affichage du code retour donne la valeur 1. <br>

Mais pour nous permettre d’afficher  plusieurs messages avec les mêmes instructions, nous allons écrire une routine (ou une fonction, ou une sous procédure ou un sous programme) qui pourra être appelée plusieurs fois.<br>
Et dans ce premier exemple nous allons passer l’adresse du message à la routine en la mettant dans le registre eax : voir le programme afficheMessage.asm.
L’appel s’effectue comme pour les fonctions de l’Api avec l’instruction call et une étiquette. <br>
La routine est située après les instructions de fin de programme et commence par l’étiquette de son nom. Nous trouvons exactement les mêmes instructions que le programme précédent sauf que l’adresse du  message est récupéré dans le registre eax et que la routine se termine par l’instruction ret qui va renvoyer l’exécution au programme appelant.<br>
Voyons en détail le mécanisme :<br>
Le système d’exploitation va initialiser le registre d’instruction (registre eip) avec l’adresse de l’étiquette Main qui correspond à la première instruction de notre programme qui est  mov eax,szMsg qui va être exécutée par le processeur.  Puis le processeur va exécuter le call, il va d’abord stocker l’adresse de l ‘instruction qui suit le call (push eax) sur la pile qui va donc être décrémenter de 4 octets. Puis il va mettre dans le registre d’instruction, l’adresse de la routine afficherMessage pour aller exécuter la première instruction de la routine.<br>
Le processeur va exécuter toutes les instructions de la routine jusqu’à rencontrer l’instruction ret. Celle ci va dépiler l’adresse de retour stockée sur la pile, et la mettre dans le registre pointeur d’instructions et le processeur reviendra exécuter l’instruction qui suivait le call. <br>
Vous comprenez l’importance que la pile soit toujours en phase lors des push et pop successifs sinon le processeur peut récupérer une adresse de retour erronée et effectuer n’importe quoi !!!
Vous voyez aussi que les fonctions de l’Api windows remettent la pile en ordre puisque nous avons passé les paramètres d’entrée avec 4 push. Ce ne sera pas toujours le cas avec d’autres librairies particulières. Ce sera à nous dans le programme appelant à remettre la pile en phase.

Il y a une autre manière de passer l’adresse du message à notre routine : c’est d’utiliser la pile comme le font les fonctions de l’Api.
Dans le programme afficheMessage1.asm, nous effectuons un push szMsg pour stocker l’adresse du message sur la pile puis nous appelons la routine d’affichage. Ces 2 instructions ont pour effet de décrémenter la pile de 8 octets.
Dans le routine d’affichage nous commençons par sauver sur la pile, le registre ebp pour registre de pile de base car nous allons l’utiliser. Cela a pour effet de décrémenter à nouveau la pile (registre esp) de 4 octets. Nous conservons cet état de la pile en copiant le registre esp dans le registre de base ebp.
Nous sauvegardons maintenant tous les registres avec l’instruction pusha qui remplace les instructions push eax, push ebx etc et nous récupérons dans le registre edx l’adresse du message sur la pile avec l’instruction mov edx,[ebp +8].
Oui, nous récupérons la valeur se trouvant à l’adresse contenue dans le registre de base + 8 octets , voyons cela :
Le registre de base contient l’état du registre de pile tel qu’il était en début de routine et après la sauvegarde de ebp et qui a décrémenté la pile de 4 octets. Et l’instruction call d’appel de la routine a aussi décrémenté de 4 octets la pile, ce qui fait un total de 8 octets pour retrouver l’adresse du message que nous avons « pushé » sur la pile juste avant l’appel.
Ensuite nous retrouvons les instructions d’appel à la fonction MessageBoxA puis nous terminons la routine en restaurant tous les registres avec l’instruction popa puis en restaurant le registre de base et en retournant au programme appelant.
Il ne nous reste plus qu’à réaligner la pile pour inhiber le push de l’adresse du message dans le programme appelant. Nous pouvons incrémenter la pile de 4 octets avec l’instruction add esp,4 mais ici nous utilisons une simplification en mettant la valeur 4 à l’instruction ret. C’est le processeur qui fera l’opération automatiquement.

J’ai détaillé ce mécanisme car nous l’utiliserons à chaque passage de paramètre à une routine et il faudra bien se souvenir de l’ordre des push pour récupérer les bonnes valeurs.
Cette solution est plus satisfaisante que le passage des paramètres par les registres car elle ne les utilise pas, et les registres sont rares !!!
