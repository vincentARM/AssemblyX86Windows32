Rem lancement compilation nasm
Rem cd D:\Developpement\Windows\Assembleur32\Projets\projetTuto\Chapitre1
cd .

D:\Logiciels\NASM\nasm.exe -f win32  pgmCh1_1.asm

D:\Logiciels\Golink\GoLink.exe pgmCh1_1.obj  /console Kernel32.dll User32.dll Gdi32.dll Comdlg32.dll  /entry:Main 
pause
pgmCh1_1.exe
echo %ErrorLevel%
pause