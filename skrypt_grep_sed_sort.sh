#!/bin/bash
reverse=false
num=""
sort_order=""
log_file=""

show_help() {
    echo "Użycie: $0 -f <ścieżka_do_pliku_z_logami> -n <liczba_zdarzeń> [-r (malejąco/rosnąco)]"
    echo
    echo "Opcje:"
    echo "  -f <ścieżka_do_pliku_z_logami>  Ścieżka do pliku z logami"
    echo "  -n <liczba_zdarzeń>             Określa liczbę zdarzeń do wyświetlenia (od 1 do nieskończoności)"
    echo "  -r                               Opcjonalnie, sortowanie malejąco"
    echo "  -h                               Wyświetla tę pomoc i kończy działanie"
}

while getopts ":f:n:rh" opt; do
  case $opt in
    f) 
        log_file="$OPTARG";;
    n) 
        if ! [[ "$OPTARG" =~ ^[1-9][0-9]*$ ]]; 
	 then
            echo "Błąd: Liczba zdarzeń musi być liczbą całkowitą większą od zera." >&2
            exit 1
        fi
        num="$OPTARG"
        ;;
    r) 
       reverse=true
       ;;
    h) 
       show_help
       exit 0
       ;;
    \?)
       echo "Błędna opcja: -$OPTARG wymaga argumentu." >&2
       exit 1
       ;;
  esac
done

if [ -z "$log_file" ]; 
 then
  echo "Błąd: Podaj ścieżkę do pliku z logami: -f <ścieżka_do_pliku_z_logami>" >&2
  exit 1
fi

if [ ! -f "$log_file" ]; 
 then
  echo "Błąd: Plik $log_file nie istnieje." >&2
  exit 1
fi

if [ -z "$num" ]; 
 then
  echo "Błąd: Podaj liczbę zdarzeń do wyświetlenia: -n <liczba_zdarzeń>" >&2
  exit 1
fi

if [ "$reverse" = true ]; 
 then
    sort_order="-r"
fi

grep ".*kernel.*" "$log_file" | \
tail -n "$num" | \
sed -E 's/^([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]+[+-][0-9]+:[0-9]+) .*kernel.*: (.*)/Data: \1, Opis: \2/' | \
sort $sort_order