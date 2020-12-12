# Chapitre 15 Macros instructions. Affichage de tous les registres.

Répeter toujours les mêmes instructions devient vite lassant en assembleur. Heureusement il y a la possibilité d’utiliser des macros instructions.<br> Dans le programme [trtMacros.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre015/trtMacros.asm), nous allons voir l’utilisation de plusieurs macros qui vont surtout nous servir à effectuer des affichages avec une macro instruction sur une seule ligne. <br>
Nous commençons par afficher un simple libelle grâce à l’instruction afficherLib "Exemple de titre" qui ne ressemble en rien à une instruction assembleur. <br> 
Cet instruction sert à remplacer plusieurs instructions assembleur et qui sont décrites dans la définition de la macro dont le nom est afficherLib. Cette macro commence par le mot clé%macro suivi du nom de la macro et du nombre de paramètres acceptés par la macro. Elle se termine par le mot clé %endmacro.<br>
Ici le paramètre transmis est une chaîne de caractères qui ne peut être utilisée par une instruction assembleur que si elle est stockée en mémoire avec un label. C’est le rôle de la pseudo instruction : %%str: db %1,10,0 qui assigne au label%%str le parametre 1 soit une chaîne de caractère suivie d’un retour chariot (code 10) et du zéro final. Un label dans une macro doit être précédé des caractères %% qui seront remplacés par un numéro séquentiel par le compilateur. En effet une macro peut être appelée plusieurs fois dans le même programme et donc chaque label doit être distinct. <br>
Comme cette description est stockée dans le code, il faut la sauter lors de l’exécution, c’est le rôle de la première instruction jmp %%endstr.<br>
ensuite il nous suffit de passer l’adresse de la chaîne par un push à notre routine d’affichage dans la console. <br>

Puis nous écrivons une macro pour afficher le contenu d’un registre suivant le même principe sauf que nous passons 2 paramètres à la macro : un libellé sous la forme d »une chaîne de caractères et le nom du registre dont nous voulons afficher le contenu en hexadécimal.<br>

Nous adaptons aussi la routine d’affichage des zones mémoire pour pouvoir affichir un titre et nous créons la macro afficher mémoire avec 3 paramètres : un libellé, l’adresse de début à afficher et le nombre de blocs. <br>
Enfin nous créons une routine pour afficher la totalité des registres pour faciliter la recherche d’anomalies. La valeur de chaque registre est convertie en caractère hexa et positionnée sur les lignes d’affichage. Cette routine est appelée dans la macro afficherRegistres avec un seul paramètre : un libelle. <br>
Voici le résultat :

```
affichage registres : avant Fin
eax = 00000001  ebx = 00000002  ecx = 00000003  edx = 00000004
esi = 00000005  edi = 00000006  ebp = 00000007  esp = 0019FF74
 cs = 00000023   ds = 0000002B   ss = 0000002B   es = 0000002B
```

Et je me rends compte que je n’ai pas encore décrits les registres de selection de segments : cs,ds,ss et es. Cela fera l’objet du prochain chapitre.<br>
La routine d’affichage des registres sera intégrée dans le fichier des includes avec les autres routines générales.<br>
