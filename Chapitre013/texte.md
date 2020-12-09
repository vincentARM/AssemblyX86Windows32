# Chapitre 13 : les chaînes de caractères.

Au fil de ces premiers programmes nous avons définit et affiché des chaines de caractères. Dans le programme traitChaine.asm nous allons voir d’autres manipulations. <br>
Une chaîne de caractère est définie comme une suite de caractères terminé par un octet d’une valeur de zéro binaire.
Si la chaîne est statique sa longueur peut être définie par la pseudoinstruction :

```asm
      LGCHAINE equ $ - adressedebutdechaine
```

Si la chaîne est dynamique ou saisie il peut être nécessaire de calculer sa longueur en comptant le nombre de caractère jusqu »au 0 final. Voir un exemple dans la routine afficherConsole.<br>

Dans le programme [traitChaine.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre013/traitChaine.asm), nous commençons par écrire une copie d’une chaîne du segment .data vers le segment .bss d’une manière classique. Une première fois avec recopie du zéro final, un deuxième exemple sans recopie du zéro final.<br>

Mais l’assembleur x86 offre d’autres possibilités. D’abord il existe 2 registres plus spécialement dédiés aux traitements des chaînes : esi et edi (s pour source et d pour destination). <br>

Nous écrivons une 3ième copie en mettant l’adresse de la chaîne source dans esi, l’adresse de la chaîne destinataire dans edi et nous utilisons les instructions lodsb (pour load string byte) et stosb (pour store string byte),l’une chargeant un octet de l’adresse mémoire contenue dans esi dans le registre al et l’autre le chargeant à l’adresse contenue dans edi et aussi elles incrémentent les 2 registres pour traiter l’octet suivant. Il ne reste plus qu’ à tester à zéro le registre al pour arrêter la copie.<br>
Mais ces 2 instructions incrémentent ou décrémentent les 2 registres esi et edi en fonction de l’indicateur de direction que nous avons aperçu avec le registre d’état. Les 2 instructions CLD et STD permettent de changer le sens de la copie mais attention il faudra modifier aussi le test du registre al pour arrêter la boucle et remettre l’indicateur de direction à son état d’origine après utilisation sinon vous risquez d’avoir de drôles de résultats par la suite et même peut être de perturber le Système d’exploitation.<br>
Enfin nous effectuons une dernière copie en copiant un certain nombre de caractères mis dans le registre ecx. Nous utilisons toujours les 2 instructions lodsb et stosb mais nous testons la fin de la boucle avec l’instruction loopne qui l’arrêtera si le compteur ecx passe à zéro ou si le registre al est à zéro. Cela permet d’arrêter la boucle si une chaîne a une longueur inférieure au nombre de caractères à copier. Super, l’assembleur non !!! <br>
Évidemment ces instructions ne traitent pas que les octets, il est aussi possible de travailler sur les mots de 16 bits avec lodsw et stosb et sur les entiers de 4 octets avec lodsd et stosd mais dans ces cas, il faudra tester soit le registre ax soit le registre eax. <br>

Puis dans le programme nous effectuons une recherche d’un caractère dans une chaîne de manière classique : avec un indice situé dans le registre ecx, nous comparons chaque octet de la chaîne avec la valeur à chercher. Si nous trouvons le zéro binaire c’est la fin et la recherche a échoué. <br>
Puis nous utilisons l’instruction spéciale scasb qui compare le caractère du registre al avec le caractère se trouvant à l’adresse contenue dans le registre edi. Et pour boucler sur toute la chaîne, nous mettons la longueur dans le registre ecx et nous ajoutons devant l’instruction scasb, l’instruction repnz qui va la répéter autant de fois que la valeur contenue dans ecx (et bien sûr tant qu’il n’y a pas égalité avec le caractère recherché.<br>
Pour les autres types de données, il existe les instructions scasw, scasd et scasq qui fonctionnent de la même manière.<br>

Nous terminons ce programme avec le test d’une routine de comparaison de chaîne. <br>
