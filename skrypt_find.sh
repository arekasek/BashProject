#!/bin/bash

while true; 
 do
    echo "Wybierz typ elementu do wyszukania:"
    echo "1. Plik"
    echo "2. Katalog"
    read -p "Wybór (1 lub 2): " choice

    if [ "$choice" -eq 1 ];
    then
        filter="-type f"
        break
    elif [ "$choice" -eq 2 ];
    then
        filter="-type d"
        break
    else
        echo "Niepoprawny wybór. Wybierz 1 lub 2"
    fi
done

while true; 
 do
    read -p "Podaj ścieżkę do lokalizacji, w której chcesz szukać: " location

    if [ ! -d "$location" ];
    then
        echo "Podana lokalizacja nie istnieje"
    else
        break
    fi
done

if [ ! -r "$location" ];
then
    echo "Nie masz uprawnień do tej lokalizacji"
    exit 1
fi

validateDate() {
    local date="$1"
    date -d "$date" "+%Y-%m-%d" &> /dev/null
    if [ $? -ne 0 ]; 
    then
        echo "Niepoprawny format daty: $date"
        exit 1
    fi

    dateP=$(date -d "$date" "+%Y-%m-%d")
    if [ "$date" != "$dateP" ];
    then
        echo "Niepoprawna data: $date"
        exit 1
    fi
}

read -p "Podaj początkową datę (format YYYY-MM-DD): " start_date
validateDate "$start_date"

read -p "Podaj końcową datę (format YYYY-MM-DD): " end_date
validateDate "$end_date"

if [[ "$end_date" < "$start_date" ]];
then
    echo "Data końcowa musi być większa niż data początkowa"
    exit 1
fi

echo "Wyniki wyszukiwania:"
find "$location" $filter -newermt "$start_date" ! -newermt "$end_date" -exec stat --format='%Y :%y %n' {} \; | sort -n | cut -d: -f2-
exit 0