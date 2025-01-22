#!/bin/bash

input_file="param.in"                           # Nome del file di input
output_file="dimClusterWolff.dat"               # Nome del file di output dove salvare i risultati
temp_val=(1.0 1.15 1.3 1.45 1.6 1.75 1.9 2.05 2.2 2.35 2.5 2.65 2.8 2.95 3.1 3.25 3.4 3.55 3.7 3.85 4.0)


> "$output_file"

#-------------------------------------#
#       Ciclo sulle temperature       #
#-------------------------------------#

for t in "${temp_val[@]}"; do
    sed -i "s/^temp\s\+.*/temp\t\t"$t"/" "$input_file"

    # Eseguo programma e faccio analisi su termalizzazione
    ./Ising2D wolff param.in
    
    sum=$(LC_NUMERIC=C awk 'NR>1{a=a+$6; n++;}END{print a/n}' obs.out)

    if [[ -n "$sum" ]]; then
        result="$sum "
    else
        result="$result0 "
    fi

    # Stampo valori a file e a terminale
    echo "Studio a T = $t completato."
    echo "$result" >> "$output_file"

done
