#!/bin/sh
# Author            : Norbert Zakrzewski (nozakrze@gmail.com)
# Created On	    : 13.05.2023
# Last Modified By  : Norbert Zakrzewski (nozakrze@gmail.com)
# Last Modified On  : 15.05.2023
# Version           : 1.0
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact the Free Software Foundation for a copy)
TYP="PLIKI"
TRYB="GENEROWANIE"
DANA_1=""
DANA_2=""
HASH=""
AUTOR="./autor.txt"
POMOC="./help.txt"
KONIEC=0
function WyborHasha
{
WYBOR2=$(zenity --list --text "Wybierz jedną z opcji:" --column "Opcje" "SUMMD5" "SHA-1" "SHA-256" --width 300 --height 200)
case $WYBOR2 in
	"SUMMD5")
		HASH="md5sum";;
	"SHA-1")
		HASH="sha1sum";;
	"SHA-256")
		HASH="sha256sum";;
esac
}
function PorownajPliki
{
HASH1=$($HASH $DANA_1 | cut -d' ' -f1)
HASH2=$($HASH $DANA_2 | cut -d' ' -f1)
if [ "$HASH1" == "$HASH2" ]; then 
		zenity --info --text="Pilki sa identyczne"
	else 
		zenity --info --text="Pilki nie sa identyczne"
	fi
WYBOR3=$(zenity --list --text "Czy zachowac wygenerowane hashe?" --column "Opcje" "TAK" "NIE" --width 300 --height 200)
case $WYBOR3 in
	"TAK")
		PLIK_1=`zenity --file-selection --directory --title="Wybierz folder"`
		PLIK_2=`zenity --file-selection --directory --title="Wybierz folder"`
		echo $HASH1 > $PLIK_1/hash1.txt
		echo $HASH2 > $PLIK_2/hash2.txt;;
	"NIE")
	continue;;
esac		
}
function PorownajFoldery
{
find $DANA_1 -type f -exec $HASH {} + | cut -d' ' -f1 > tmpl/wyniki1.txt
find $DANA_2 -type f -exec $HASH {} + | cut -d' ' -f1 > tmpl/wyniki2.txt
sort tmpl/wyniki1.txt > tmpl/wyniki3.txt
sort tmpl/wyniki2.txt > tmpl/wyniki4.txt
if cmp -s tmpl/wyniki3.txt tmpl/wyniki4.txt; then
	zenity --info --text="Foldery sa identyczne"
else
	zenity --info --text="Foldery nie sa identyczne"
fi
WYBOR4=$(zenity --list --text "Czy zachowac wygenerowane hashe?" --column "Opcje" "TAK" "NIE" --width 300 --height 200)
case $WYBOR4 in
	"TAK")
		PLIK_1=`zenity --file-selection --directory --title="Wybierz folder"`
		PLIK_2=`zenity --file-selection --directory --title="Wybierz folder"`
		cat tmpl/wyniki3.txt > $PLIK_1/hash1.txt
		cat tmpl/wyniki4.txt > $PLIK_2/hash2.txt;;
	"NIE")
	continue;;
esac
rm tmpl/wyniki1.txt
rm tmpl/wyniki2.txt
rm tmpl/wyniki3.txt
rm tmpl/wyniki4.txt
}
function Porownaj
{
if [ $TRYB == "GENEROWANIE" ]; then
	POPRAWNE=1
	D1=""
	D2=""
	if [ -n "$DANA_1" ] && [ -n "$DANA_2" ]; then
		if [ "$HASH" == "" ]; then 
			zenity --info --text="Wybierz rodzaj hasha"
			return;
		else 
			POPRAWNE=1 
		fi
		if [ -d "$DANA_1" ]; then
				TEMP="FOLDER"
			elif [ -f "$DANA_1" ]; then
				TEMP="PLIK"
			else
				TEMP="BLAD"
			fi
			D1=$TEMP
		if [ -d "$DANA_2" ]; then
				TEMP="FOLDER"
			elif [ -f "$DANA_2" ]; then
				TEMP="PLIK"
			else
				TEMP="BLAD"
			fi
			D2=$TEMP
		if [ "$D1" == "$D2" ] && [ "$D1" == "PLIK" ]; then
			PorownajPliki
		elif [ "$D1" == "$D2" ] && [ "$D1" == "FOLDER" ]; then
			PorownajFoldery
		else
			zenity --info --text="Zle formaty plikow. Oba musza byc plikami lub folderami"
		fi
	else
		zenity --info --text="Podaj obie sciezki"
	fi
else
	if [ -n "$DANA_1" ] && [ -n "$DANA_2" ]; then
		if [ -f "$DANA_1" ] && [ -f "$DANA_2" ]; then
			if cmp -s $DANA_1 $DANA_2; then
				zenity --info --text="Pliki sa identyczne"
			else
				zenity --info --text="Pliki nie sa identyczne"
			fi
		else
			zenity --info --text="Zle formaty plikow. Oba musza byc plikami"
		fi
	else
		zenity --info --text="Podaj obie sciezki"
	fi
fi
}


while [ $KONIEC -eq 0 ]
do
menu=("Tryb pracy: $TRYB hashy" "Wybierz co chcesz porownywac: $TYP" "Wybierz funkcje hashujaca: $HASH" "Wybierz pierwsza sciezke: $DANA_1" "Wybierz druga sciezke: $DANA_2" "Porownaj pliki/foldery" "Informacje o Autorze:" "Pomoc" "Zakoncz program")
WYBOR=`zenity --list --text "Wybierz dane i porownaj pliki lub foldery:" --column=Menu "${menu[@]}" --width 800 --height 600`
case $WYBOR in
"Tryb pracy:"*)
if [ $TRYB == "GENEROWANIE" ]; then
	TRYB="WCZYTYWANIE"
else
	TRYB="GENEROWANIE"
fi;;
"Wybierz co chcesz porownywac:"*)
if [ $TYP == "PLIKI" ]; then
	TYP="FOLDERY"
else
	TYP="PLIKI"
fi;;
"Wybierz funkcje hashujaca:"*)
WyborHasha;;
"Wybierz pierwsza sciezke:"*)
if [ $TRYB == "GENEROWANIE" ]; then
	if [ $TYP == "FOLDERY" ]; then
		DANA_1=`zenity --file-selection --directory --title="Wybierz folder"`
	else
		DANA_1=`zenity --file-selection --title="Wybierz plik"`
	fi
else
	DANA_1=`zenity --file-selection --file-filter='Text files (txt) | *.txt' --title="Wybierz plik"`
fi;;
"Wybierz druga sciezke:"*)
if [ $TRYB == "GENEROWANIE" ]; then
	if [ $TYP == "FOLDERY" ]; then
		DANA_2=`zenity --file-selection --directory --title="Wybierz folder"`
	else
		DANA_2=`zenity --file-selection --title="Wybierz plik"`
	fi
else
	DANA_2=`zenity --file-selection --file-filter='Text files (txt) | *.txt' --title="Wybierz plik"`
fi;;
"Porownaj pliki/foldery")
Porownaj;;
"Informacje o Autorze:")
zenity --text-info --title="Dane o Autorze Skryptu" --filename=$AUTOR;;
"Pomoc")
zenity --text-info --title="Pomoc" --width 1000 --height 600 --filename=$POMOC;;
"Zakoncz program") KONIEC=1;;
esac
done
