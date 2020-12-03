# Chapitre 9 : affichage d’un registre en hexadécimal. <br>
Nous modifions à nouveau la routine d’affichage en base 10 pour afficher le contenu d’un registre en base 16. Cet affichage est très utilisé à la place de l’affichage en binaire et surtout pour afficher des adresses mémoire. <br>
Le point positif est que l’affichage comportera toujours 8 chiffres. Le point négatif c’est que les restes successifs de la division par 16 donnent les chiffres de 0 à 9 et que les restes, 10,11,12,13,14 et 15 doivent être convertis en lettre A,B,C,D,E,F. <br>
Dans le programme [afficherRegistreHexa.asm](https://github.com/vincentARM/AssemblyX86Windows32/blob/main/Chapitre009/afficherRegistreHexa.asm), nous trouvons la routine et quelques exemples d’affichage : 1, 15, -1. <br>
Nous mettons aussi la séquence d’affichage (conversion, affichage du titre,affichage de la zone convertie, affichage du retour ligne) dans une même routine afficherHexa à laquelle nous passons le registre à afficher par un push. En début de cette routine nous remplaçons la sequence push epb mov ebp,esp par l’instruction enter 0,0 et à la fin nous mettons l’instruction leave qui remplace pop ebp. <br> 
Dans l’instruction enter, le premier nombre (ici 0) indique le nombre d’octets à réserver sur la pile et le deuxième définit un niveau d’appel de la routine. En assembleur, cette possibilité sera très peu utilisée. <br>
Dans la routine afficherConsole déjà utilisée, nous remplaçons les instructions de début par enter 8,0 ce qui va réserver 8 octets sur la pile pour le stockage du nombre d’octets écrits. <br>

Ensuite nous remplaçons l’affichage décimal  de l’adresse  la pile  par l »affichage hexa ce qui est plus habituel.<br>
Voilà c’est tout pour ce chapitre.
