#!/bin/bash
help() {
    echo "Użycie: $0 [-d katalog] [-e rozszerzenia] [-h]"
    echo "  -d katalog      Określ katalog do wyczyszczenia"
    echo "  -e rozszerzenia Określ rozszerzenia plików do usunięcia (rozdzielone przecinkami)"
    echo "  -h              Wyświetl pomoc"
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
directory=""
extensions=()
while getopts ":hd:e:" opt; do
    case $opt in
        h)
            help
            exit 0;;
        d)
            directory=$OPTARG;;
        e)
            IFS=',' read -r -a extensions <<< "$OPTARG";;
        \?)
            echo "Nieznana opcja: -$OPTARG" >&2
            help
            exit 1;;
        :)
            echo "Opcja -$OPTARG wymaga argumentu." >&2
            help
            exit 1;;
    esac
done
if [ -n "$directory" ] && [ ${#extensions[@]} -gt 0 ]; then
    clean_directory "$directory" "${extensions[@]}"
    zenity --info --title="Wynik czyszczenia" --text="Czyszczenie zakończone pomyślnie."
    exit 0
fi
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
        fi;;
    1)
        zenity --info --title="Wynik czyszczenia" --text="Czyszczenie zostało anulowane przez użytkownika.";;
esac
exit 0

