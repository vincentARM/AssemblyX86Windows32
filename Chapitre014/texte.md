# Chapitre 14 : structures de traitement. <br>
Au cours des programmes précédents, nous avons utilisées plusieurs structures algorithmiques pour effectuer des tâches diverses. Nous allons effectuer un récapitulatif des structures utiles pour la programmation en assembleur.<br>

Nous avons déjà utilisées l’appel de routines pour décomposer un programme en tâches plus petites ou appelées plusieurs fois. L’appel s’effectue avec l’instruction call et le retour à l’instruction qui suit le call se fait avec l’instruction ret. <br>

Pour des sauts à l’intérieur d’un bloc d’instructions, nous avons l’instruction de saut inconditionnelle jmp label et toute la série des instructions conditionnelles : <br>
instructions  <br>

```
JC                  saut si carry = 1 <br>
JCXZ                saut si registre cx est égal à zéro <br>
JE                  saut si égal <br>
JECXZ               saut si registre ecx est égal à zéro <br>
JNC                 saut si carry = 0 <br>
JNE                 saut si pas égal <br>
JNO                 saut si pas de dépassement <br>
JNP                 saut si pas de parité <br>
JNZ                 saut si différent de zéro <br>
JO                  saut si dépassement <br>
JP                  saut si parité <br>
JPE                 saut si parité est paire <br>
JPO                 saut si parité est impaire <br>
JZ                  saut si égal à zéro <br>

instructions signées : <br>
JG                  saut si plus grand <br>
JGE                 saut si plus grand ou égal <br>
JL                  saut si plus petit <br>
JLE                 saut si plus petit ou égal <br>
JNG                 saut si pas plus grand <br>
JNGE                saut si pas plus grand ou egal <br>
JNL                 saut si pas plus petit  <br>
JNLE                saut si pas plus petit ou égal <br>
JNS                 saut si positif <br>
JS                  saut si négatif <br>

Instructions non signées <br>
JA                  saut si plus grand  <br>
JAE                 saut si plus grand ou égal <br>
JB                  saut si plus petit <br>
JBE                 saut si plus petit ou égal <br>
JNA                 saut si pas plus grand <br>
JNAE                saut si pas plus grand ou égal <br>
JNB                 saut si pas plus petit  <br>
```

Avec ces instructions nous pouvons programmer des structures alternatives :

```asm
cmp eax,0
je .A1
  ; traitement si inégal
  jmp .A2
A1 :
  ; traitement si egal 

.A2 :
```

(remarque : un point devant un label indique que le label est local cad rattaché à un label précedent non local).

Ou programmer des boucles :

```asm
       mov ecx,0
.A1 :
  : traitement interne à la boucle
   inc ecx
   cmp ecx,MAXI
   jne .A1
```
ou 

```asm
      mov ecx,0
.A1 :
    cmp ecx ,MAXI
    jge .A2
  ; instructions internes à la boucle
   inc ecx
   jmp .A1
.A2 :
```
Attention, ne jamais insérer un call entre une instruction qui positionne les indicateurs et le test des indicateurs. En effet on sait rarement si la fonction appelée sauve et restaure le registre d’état. <br>

Mais il y a quelques instructions spécifiques pour éviter l’emploi d’étiquettes et de sauts :
par exemple des mov conditionnels <br>

```asm
sub eax,20
cmovs eax,ebx   ; met le contenu de ebx dans eax si le résultat est negatif
cmovns eax,ecx ; met le contenu de ecx dans eax si le résultat est positif
```
qui peuvent être utilisées avec des adresses mémoires. <br>

L’instruction set

```asm
cmp eax,100
setg bl ; met la valeur 1 dans le registre bl si eax est plus grand que 100 sinon met zéro <br>
```

Pour les boucles nous avons  les instructions suivantes:
```
LOOP label    décrémente ecx et boucle au label tant que ecx est différent de zéro
LOOPE label   décrémente ecx et boucle au label tant que ecx est différent de zéro et si l’indicateur de zéro est différent de 1
LOOPNE label  décrémente ecx et boucle au label tant que ecx est différent de zéro et si l’indicateur de zéro est différent de 0
LOOPNZ label  décrémente ecx et boucle au label tant que ecx est différent de zéro et l’indicateur de zéro vaut 0.  
LOOPZ label   décrémente ecx et boucle au label tant que ecx est différent de zéro et l’indicateur de zéro vaut 1.
```
En assembleur, il est aussi possible d'effectuer des appels récursifs. En fin du programme nous calculons la factorielle d'un nombre en appelant une fonction de manière récursive. Attention, il n'est pas controlé le dépassement de taille d'un registre lors du calcul. <br> 

Voir le programme [strucTraitement.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre014/strucTraitement.asm)
