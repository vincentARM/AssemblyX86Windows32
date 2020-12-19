# Chapitre 19 : Fichiers objets.

Maintenant que nous avons pratiquement vu tous les composants du langage assembleur, nous allons restructurer nos différents éléments pour simplifier le développement d’un nouveau programme.<br>
Nous allons mettre les définitions des constantes générales dans un fichier séparé que nous intégrerons avec la commande %include.<br>
Dans ce fichier nous mettrons aussi l’instruction extern avec toutes les fonctions windows.<br>
Nous allons mettre les macros dans un autre fichier séparé que nous intégrerons aussi avec la commande %include.<br>
Enfin, nous allons modifier le fichier des routines pour intégrer les fichiers includes ci dessus et effectuer la compilation avec nasm pour créer un fichier objet. Ce fichier objet sera lié aux futurs programmes principaux lors de l’appel du linker. Ainsi ces routines ne seront compilées qu’une fois.
Enfin nous écrivons un programme squelette qui nous servira de base pour l’écriture de nouveaux programmes. Ce qui donne :<br>
Fichier des constantes : [includeConstantes.inc](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre019/includeConstantes.inc) <br>
Fichier des macros instructions : {includeMacros.inc](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre019/includeMacros.inc) <br>
Fichier des routines : [routines32.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre019/routines32.asm) <br>
Fichier squelette : [squelX86.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre019/squelX86.asm)<br>

Script powerShell pour compiler les routines : compil32Routines.ps1  . Ce script n'utilise pas le linker car il faut juste créer un fichier objet.<br>

Script powerShell pour compiler les programmes : compil32.ps1. Ce script intègre dans le linker le fichier objet crée par le script précédent.<br>

J’en profite pour tester un programme planCharg.asm qui donne les adresses des différents segments : c’est un plan de chargement limité !! <br>
Exemple de résultat sur mon pc :
esp= 0019FF74
Plan de chargement
Adresse .data = 00402000
Adresse .bss = 004021D8
Adresse .text = 00401000

<br>
On remarque que le segment .text est situé avant le segment.data lui même situé avant le segment .bss. Que sa taille est de 0x1000 octets soit 4096. J’espère que le linker réadapte cette taille pour des programmes plus gros !!.<br>
<br>
Et je remarque un truc bizarre : l’adresse de la pile est inférieure aux adresses segments alors que je m’attendais à avoir une adresse supérieure et voir combien windows nous donnait de mémoire. Il va falloir que je creuse cette différence.<br>

Remarque : Chaque fois que nous utiliserons une nouvelle constante windows ou une fonction et que nous créerons une nouvelle routine, il faudra penser à l’ajouter dans le bon fichier et de recompiler les routines. <br>

Il existe une autre manière pour créer un exécutable à partir de plusieurs objets : c’est d’utiliser l’utilitaire make. Je n’ai pas trouvé sous windows cet utilitaire donc j’utilise le logiciel libre mingw32-make que vous téléchargez gratuitement.<br>
Vous trouverez dans le répertoire [CreationMake](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre019/CreationMake) toutes les structures et données pour générer l’exécutable. Celui ci se trouvera dans le répertoire  CreationMake/build. Pour utiliser les scripts powershell et le fichier Makefile, il faudra changer les répertoires des utilitaires avec vos propres répertoires.<br>
