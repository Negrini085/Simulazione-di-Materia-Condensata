#!/bin/bash

input_file="param2.in"               			     # Nome del file di input
tempIsing=(2.2 2.25 2.26 2.27 2.28 2.29)        	     # Temperature a cui simulo il modello
sizeIsing=(100 200 300)                 		     # Dimensioni del modello di Ising


#---------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a varie t       #
#---------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione
for ((i=0; i<${#sizeIsing[@]}; i++)); do
    sed -i "s/^nspin\s\+.*/nspin\t\t"${sizeIsing[i]}"/" "$input_file"

    for t in "${tempIsing[@]}"; do
        sed -i "s/^temp\s\+.*/temp\t\t"$t"/" "$input_file"

        # Eseguo programma per determinazione osservabili
        ./stObs wolff param2.in analisi/pcrit/zCrit/obs_size${sizeIsing[i]}_t${t}.out
    
    done

    dim=${sizeIsing[i]}
    echo "Eseguito studio termalizzazione per dimensione fissata $dim."    
done

echo "Studio della termalizzazione terminato."
