#!/bin/bash

input_file="param.in"                                            # Nome del file di input
tempIsing=(1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0)     	      	 # Temperature a cui simulo il modello
sizeIsing=(6000)   	                                     	 # Dimensioni del modello di Ising


#---------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a varie t       #
#---------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione
for ((i=0; i<${#sizeIsing[@]}; i++)); do
    sed -i "s/^nspin\s\+.*/nspin\t\t"${sizeIsing[i]}"/" "$input_file"

    for t in "${tempIsing[@]}"; do
        sed -i "s/^temp\s\+.*/temp\t\t"$t"/" "$input_file"

        # Eseguo programma per determinazione osservabili
        ./Ising1D sim param.in analisi/magn0.0/obs/obs_lc_size${sizeIsing[i]}_t${t}.out
    
    done

    dim=${sizeIsing[i]}
    echo "Eseguito studio termalizzazione per dimensione fissata $dim."    
done

echo "Studio della termalizzazione terminato."
