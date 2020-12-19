# lancement compilation nasm
cd .
$param1=$args[0]
#write-host $param1
D:\Logiciels\NASM\nasm.exe -f win32  $param1".asm" -l $param1".txt"

#pas de link pour les routines
#D:\Logiciels\Golink\GoLink.exe $param1".obj"  /console Kernel32.dll User32.dll Gdi32.dll Comdlg32.dll Shell32.dll OleAut32.dll /entry:Main 

#pause
