#!/bin/bash

input_file="param1.in"                                     # Nome del file di input
tempIsing=(1.0 1.5 2.0 2.5 3.0 3.5)                       # Temperature a cui simulo il modello
sizeIsing=(100 200 500)                                   # Dimensioni del modello di Ising


#---------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a varie t       #
#---------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione
for ((i=0; i<${#sizeIsing[@]}; i++)); do
    sed -i "s/^nspin\s\+.*/nspin\t\t"${sizeIsing[i]}"/" "$input_file"

    for t in "${tempIsing[@]}"; do
        sed -i "s/^temp\s\+.*/temp\t\t"$t"/" "$input_file"

        # Eseguo programma per determinazione osservabili
        ./Ising1D sim param1.in analisi/obs/obs_size${sizeIsing[i]}_t${t}.out
    
    done

    dim=${sizeIsing[i]}
    echo "Eseguito studio termalizzazione per dimensione fissata $dim."    
done

echo "Studio della termalizzazione terminato."
