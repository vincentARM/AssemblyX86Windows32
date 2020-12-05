# Chapitre 10 : le registre d’état

Dans les chapitres précédents, nous avons parlé des indicateurs qui étaient positionnés lors de certaines opérations. Vous trouverez dans le volume 1 de la documentation Intel, le détail des indicateurs positionnés par chaque instruction dans  Appendix A EFLAGS Cross-Reference. <br>
Les indicateurs Zero, Carry, Signe et Overflow sont en fait les bits d’un registre particulier : le registre d’état appelé eflag. Celui ci ne peut pas supporter les opérations arithmétiques ou binaires que nous avons vues mais il peut supporter des instructions bien particulières. <br>
Tout d’abord, nous allons l’afficher en binaire pour voir le contenu de tous les bits. Et à la place d’utiliser un push registre pour le passer en paramètre de la procédure de conversion nous utilisons l’instruction qui lui est réservée : pushf. Il a aussi son inverse popf. Ces 2 instructions sont très utilisées pour sauvegarder restaurer ce registre lors des appels de routine si nous voulons conserver ses valeurs. Attention ces instructions ne sauvent et restaurent que les 16 bits de poids faibles du registre. Si vous voulez tout sauvegarder il faut utiliser pushfd et popfd.<br>
Vous trouverez dans le tome 1 de la documentation Intel,dans le chapitre 3.4.3 la description complète de ce registre. Nous, nous allons nous intéresser aux indicateurs les  plus fréquemment utilisés.<br>
En position 0, nous trouvons l’indicateur de retenue (Carry). <br>
En position 2, l’indicateur de parité (PF). Nous ne l’avons pas rencontré mais il indique si le nombre de bits à 1 dans un registre est pair ou impair.<br>
En position 4, l’indicateur de retenue auxiliaire (AF). Nous verrons son usage lors d’opérations sur les octets. <br>
En position 6 l’indicateur de Zéro (ZF). <br>
En position 7 l’indicateur de signe (SF). <br>
En position 8 un indicateur de pas à pas le Trap Flag (TF) utilisé par les debuggers pour executer les instructions une à une. <br>
En position 9 l’indicateur d’interruption(IF). <br>
En position 10, l’indicateur de direction (DF) dont nous verrons l’usage lors des opérations sur les chaînes de caractères. <br>
Et en position 11 l’indicateur de dépassement (Overflow OF). <br>
Il reste de nombreux autres indicateurs pour des usages spéciaux. Vous le verrez quand vous serez expert en assembleur X86 et si vous en avez besoin. <br>

Nous pouvons transférer les indicateurs dans la partie haute des 16 bits de droite du registre eax donc dans AH avec l’instruction LAHF et inversement avec SAHF.<br>
Attention dans ces opérations, on perd les bits au-delà de 8. Ces instructions doivent avoir une raison historique car je ne vois pas d’utilisation actuelle.<br>

Nous avons aussi quelques instructions pour modifier directement certains indicateurs :
CLC pour mettre l’indicateur de retenue (Carry) à zéro.
STC pour mettre l’indicateur de retenue à Un.   Ces 2 instructions sont intéressantes pour faire remonter une erreur dans des routines en mettant le code erreur dans eax. Il suffit d’utiliser jc ou jnc pour traiter les cas après l’appel d’une routine.<br>

CMC  inverse l’indicateur de retenue (carry). <br>

CLD pour mettre l’indicateur de direction à 0.<br>
STD pour mettre l’indicateur de direction à 1.<br>

Le programme instructionsRegEtat.asm montre l'utilisation de ces instructions. <br>
