#!/bin/bash

tempIsing=(1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0)      # Temperature a cui simulo il modello
sizeIsing=(3000 6000)   	                                 # Dimensioni del modello di Ising


#---------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a varie t       #
#---------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione
for ((i=0; i<${#sizeIsing[@]}; i++)); do
    for t in "${tempIsing[@]}"; do

        # Eseguo programma per determinazione osservabili
        rm obs_size${sizeIsing[i]}_t${t}.out
        mv obs_lc_size${sizeIsing[i]}_t${t}.out obs_size${sizeIsing[i]}_t${t}.out

    done
done

echo "Studio della termalizzazione terminato."
