# Assembleur X86 32 bits pour windows avec le compilateur nasm.<br>
# Introduction : <br>
Pendant ce deuxième confinement, je décide de me replonger dans la programmation en assembleur X86 32 bits avec windows10 pour essayer d’écrire un petit tutoriel.<br>
La difficulté avec windows 10 et ceci depuis windows XP, est que ce système d’exploitation n’autorise pas l’appel des interruptions ni les appels système pour programmer les fonctions d’entrées sorties. Il va nous obliger à utiliser les appels à l’API windows.<br>
Mais les avantages sont aussi très grands : les fonctions de l’API sont très nombreuses et bien documentées et il est inutile d’installer un émulateur pour faire fonctionner les programmes.<br>
Ceci implique que les programmes développés seront aussi utilisables sous Windows 7 et 8. <br>
<br>
Et pourquoi le 32 bits ? : parce que c’est un début ! Et il y a encore des ordinateurs qui fonctionnent en 32 bits sous windows. Je verrais plus tard les adaptations pour l’assembleur X86-64 bits. <br>

Dans ce cours, je détaillerais les instructions élémentaires de l’assembleur X86 en donnant des exemples de petits programmes et au fur et à mesure des besoins, je ferais appel aux fonctions de l’API windows. Pour chaque chapitre, vous trouverez les commentaires dans le fichier texte.md. <br>
<br>
Pour les débutants qui n’ont jamais programmé, je déconseille de commencer par l’assembleur, il est préférable de commencer par un langage évolué comme le C ou Python pour apprendre les bases d’un langage compilé ou interprété.<br>
Les prérequis nécessaires à l’assembleur sont de connaître la composition matérielle d’un ordinateur, les notion de base d’algorithmique (boucles, alternatives, structures de données) et les bases de la numération (binaire hexadécimale, décimale).<br>

Pour la documentation (hélas le plus souvent en anglais), vous trouverez toute la documentation des processeurs Intel ici :  <a href="https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html">documentation Intel. </a> Je vous conseille de télécharger les premiers volumes pour les avoir à disposition facilement. <br>

Vous trouverez une description des instructions X86 sur <a href="https://www.gladir.com/LEXIQUE/ASM/DICTIONN.HTM">le site de gladir</a> avec des exemples plus adaptés pour le 8 bits et 16 bits.<br>
vous trouverez aussi sur de nombreux sites d'université des cours (souvent en pdf) en français qui exposent de manière détaillée les principes de l'assembleur X86. <br>

Sur Internet, il existe de nombreux tutoriels mais qui datent un peu, et qui sont souvent orientés vers la programmation en 8 et 16 bits et qui necessitent l’utilisation d’un émulateur pour faire fonctionner les programmes sous Windows. Vous en trouverez sur le site [devellopez.com](https://asm.developpez.com/cours/)<br>

Vous me pardonnerez, toutes les erreurs, bêtises et mauvaises interprétations que j’ai commises dans ce modeste tutoriel. <br>

Remarque 1 : lorsque vous écrivez, compilez et testez les programmes en assembleur, pensez à fermer toutes les autres applications ou enregistrez vos données. <br>
Remarque 2 : ne vous contentez pas de recopier les exemples de programmes, mais modifier les pour voir les consèquences bonnes ou mauvaises de vos modifications. <br>
Remarque 3 : les exemples de programmes ont été testés sur un système windows10 64 bits. <br>

[Chapitre 1 : Les outils](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre001) <br>

[Chapitre 2 : Les bases : premiers programmes](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre002)

[Chapitre 3 : La pile, affichage d'un message, premières routines](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre003)

[Chapitre 4 : affichage d'un message dans la console](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre004)

[Chapitre 5 : affichage décimal d'un registre](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre005)

[Chapitre 6 : addition et soustraction de nombres entiers](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre006)

[Chapitre 7 : multiplication et division de nombres entiers](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre007)

[Chapitre 8 : opérations binaires](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre008)

[Chapitre 9 : affichage d'un registre en hexadécimal](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre009)

[Chapitre 10 : le registre d'état](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre010)

[Chapitre 11 : les accés mémoire](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre011)

[Chapitre 12 : fichier include. Les structures](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre012)

[Chapitre 13 : traitement des chaînes de caractères](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre013)

[Chapitre 14 : structures de traitement](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre014)

[Chapitre 15 : Macros instructions. Affichage de tous les registres](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre015)

[Chapitre 16 : Saisie de données](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre016)

[Chapitre 17 : Lecture écriture de fichiers](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre017)

[Chapitre 18 : calculs avec des nombres en virgule flottante](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre018)

[Chapitre 19 : les fichiers objets](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre019)

[Chapitre 20 : création d'une simple fenêtre Windows](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre020)

[Chapitre 21 : exemple d'une fenêtre de saisie Windows](https://github.com/vincentARM/AssemblyX86Windows32/tree/main/Chapitre21)
