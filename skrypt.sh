#!/bin/bash
 
check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
	echo "$1 is not installed. Exiting."
	exit 1
    fi
}
 
clean_directory() {
    directory=$1
    shift
    for ext in "$@"; do
	echo "Czyszczenie plików *.$ext z katalogu $directory..."
	rm -rf "$directory"/*.$ext
    done
    echo "Czyszczenie zakończone."
}
 
check_command zenity
check_command dialog
 
DIALOG=${DIALOG=dialog}
$DIALOG --title "Potwierdzenie czyszczenia" --clear \
  --yesno "Czy na pewno chcesz wyczyścić pliki z katalogów /tmp i /var/tmp?" 10 50
 
case $? in
  0)
    directory=$(zenity --file-selection --directory --title="Wybierz katalog do wyczyszczenia")
 
    if [ $? -eq 0 ]; then
    extensions=$(dialog --stdout --separate-output --checklist "Wybierz rozszerzenia plików do usunięcia:" 0 0 0 \
	tmp "Pliki tymczasowe" off \
	log "Pliki dzienników" off \
	cache "Pliki cache" off \
	bak "Pliki kopii zapasowych" off \
	txt "Pliki tekstowe" off \
	doc "Dokumenty" off \
	jpg "Obrazy jpg" off \
        custom "Wprowadź własne rozszerzenie" off)
 
      if [ $? -eq 0 ]; then
        selected_extensions=()
        IFS=$'\n' read -r -a ext_array <<< "$extensions"
        for ext in "${ext_array[@]}"; do
          if [ "$ext" = "custom" ]; then
	    custom_ext=$(zenity --entry --title="Wprowadź własne rozszerzenie" --text="Wprowadź własne rozszerzenie:")
	    selected_extensions+=("$custom_ext")
          else
	    selected_extensions+=("$ext")
          fi
        done
	clean_directory "$directory" "${selected_extensions[@]}"
	zenity --info --title="Wynik czyszczenia" --text="Czyszczenie zakończone pomyślnie."
      else
        zenity --info --title="Wynik czyszczenia" --text="Czyszczenie zostało anulowane przez użytkownika."
      fi
    else
      zenity --info --title="Wynik czyszczenia" --text="Czyszczenie zostało anulowane przez użytkownika."
    fi
    ;;
  1)
    zenity --info --title="Wynik czyszczenia" --text="Czyszczenie zostało anulowane przez użytkownika."
    ;;
esac
exit 0