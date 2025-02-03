#!/bin/bash

input_file="param1.in"               			# Nome del file di input
tempIsing=(2.315 2.325 2.335)		# Temperature a cui simulo il modello
sizeIsing=(6 12 25 50 100)		             			# Dimensioni del modello di Ising


#---------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a varie t       #
#---------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione
for ((i=0; i<${#sizeIsing[@]}; i++)); do
    sed -i "s/^nspin\s\+.*/nspin\t\t"${sizeIsing[i]}"/" "$input_file"

    for t in "${tempIsing[@]}"; do
        sed -i "s/^temp\s\+.*/temp\t\t"$t"/" "$input_file"

        # Eseguo programma per determinazione osservabili
        ./stObs metro param1.in analisi/pcrit/zCrit/obs_size${sizeIsing[i]}_t${t}.out
    
    done

    dim=${sizeIsing[i]}
    echo "Eseguito studio termalizzazione per dimensione fissata $dim."    
done

echo "Studio della termalizzazione terminato."
