# Chapitre 4 : affichage d’un message dans la console.

L’affichage dans la console de type powerShell est intéressant pour pouvoir tracer l’exécution d’un programme et lorsqu’il n’est pas nécessaire d’avoir des fenêtres windows. <br>
C’est un peu plus compliqué que l’affichage d’un message tel que nous l’avons vu au chapitre précédent car il faut utiliser la fonction WriteFile pour écrire dans la console et il faut utiliser la fonction GetStdHandle pour récupérer la référence de la console dans le système Windows. <br>

Dans le programme affConsole.asm, nous commençons par définir la constante STD_OUTPUT_HANDLE qui sert de code fonction lors de l’appel de  GetStdHandle. <br>
Nous réservons aussi dans le segment mémoire BSS une zone de 8 octets qui recevra le nombre d’octets écrits par la fonction WriteFile.  Ces informations nous sont données dans la documentation de Windows en cherchant winapi WriteFile<br>
Dans le segment de code, nous appelons la fonction getStdHandle en lui passant en paramètre la constante STD_OUTPUT_HANDLE pour récupèrer la référence (handle) de la console dans le registre eax.<br>
Ensuite nous renseignons tous les paramètres nécessaires à la fonction WriteFile : <br>
0 pour le paramétre overlapped car nous n’utilisons pas cette fonctionalité,<br>
le label de la zone qui va recevoir le nombre de caractères écrits ici iCaractèreAff<br>
la longueur du message <br>
le label du message <br>
la référence de la console issue de la fonction précédente.<br>
Au retour de l’appel, nous ne testons pas le code retour mais nous passons la valeur contenue dans la zone iCaractèresAff pour vérification.<br>
Hourra, le message est bien affiché dans la console de powerShell. <br>
Si vous cliquer directement sur l’exécutable rien ne se passe !!! En effet, comme le programme se termine de suite après l’affichage, on ne voit rien . Il nous faut ajouter un message de pause avec le bouton ok pour bloquer l’exécution (programme affConsole2.asm)et voir la console de commande window s’ouvrir et le message apparaître bien comme ici :<br>

Au fait, avez vous remarquez que la définition de la zone titre de la fenêtre est dans la partie code. Et cela fonctionne ! <br>

Nous allons améliorer ce programme dans affconsole1.asm en calculant la longueur du message plutôt que de passer sa valeur en paramètre de WriteFile. Pour cela il nous faut compter tous les caractères du message jusqu’à rencontrer un octet avec la valeur 0 qui est la fin de chaîne.<br>
Nous initialisons donc le registre ecx qui servira de compteur.  Puis nous chargeons dans le registre al un octet de la chaîne. S’il est nul nous avons fini et ecx contient la longueur de la chaîne. Sinon nous incrémentons le compteur ecx et nous bouclons pour continuer.<br>
Et le registre ecx sera passé en paramètre de la fonction d’écriture.<br>
Stop !! et c’est quoi al dans l’instruction mov al,[szMsg,ecx] ? Nous le verrons un peu plus tard mais pour des raisons de compatibilité avec les anciens programmes, le registre eac de 32 bits est divisé en 2 parties de 16 bits dont la partie basse est accessible avec pour nom de registre ax. Et cette partie est elle même divisée en 2 parties de 8 bits (soit un octet)  appelées ah (higt) pour la partie haute et al (low) pour la parie basse. Ainsi si nous voulons charger un seul octet de la mémoire, il faut utiliser le nom al et non pas eax qui va indiquer au compilateur de générer une instruction de chargement de 4 octets. <br>
La deuxième partie de cette instruction indique que l’origine de l’octet est l’adresse du début de message (szMsg) + la valeur contenue dans le registre ecx . Comme cette valeur est incrementée à chaque tour de boucle, nous allons charger successivement l’octat se trouvant à l’adresse szMsg+0 , szMsg + 1, szMsg + 2 etc. <br>


Maintenant dans le programme afficheConsole.asm, nous allons mettre ces instructions dans une routine pour afficher si nécessaire plusieurs messages avec les mêmes instructions.  Et pour éviter d’avoir à réserver 8 octets dans le segment BSS pour le nombre de caractères écrits, nous allons les réserver sur la pile. <br>
De plus, dans le corps du message pour la console, nous mettons des octets avec la valeur 10 qui correspond au code ascii pour le retour de ligne.<br>

Dans le sement code, nous passons l’adresse du message par un push sur la pile et nous appelons la routine afficherConsole. Celle ci reprend les principes de récupération du paramètre comme lors de la rotine d’affiche du message dans une fenêtre. Mais en plus nous ajoutons l’instruction sub esp,8 qui va décrementer la pile de 8 octets et donc réserver une place pour stocker la zone de retour des caractères ecrits.<br>
Le reste de la routine reprend les instructions précédentes pour calculer la longueur du message puis appeler les fonctions GetStdHandle et WriteFile. Pour passer l’adresse de la zone reservée sur la pile, nous utilisons l’instruction lea qui met dans le registre eax, l’adresse qui serait accèder par la formule entre crochet donc ici l’adresse représentée par ebp – 8.  -8 parceque nous avons réservé 8 octets par l’instruction sub esp,8 placée après la copie du registre de pile dans le registre de base.
En fin de routine nous libérons la place réservée par l’instruction add esp,8 placée avant la restauration du registre ebp.<br>
