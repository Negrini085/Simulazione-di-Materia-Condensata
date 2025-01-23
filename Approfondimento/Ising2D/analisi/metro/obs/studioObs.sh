#!/bin/bash

tempIsing=(1.0 1.5 2.0 2.5 3.0 3.5)		     # Temperature a cui simulo il modello
sizeIsing=(100 200 300 400 500)              # Dimensioni del modello di Ising


#---------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a varie t       #
#---------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione
for dim in "${sizeIsing[@]}"; do

    for t in "${tempIsing[@]}"; do
        # Eseguo programma per filtrare gli osservabili
        LC_NUMERIC=C awk -v d="$dim" 'NR==1{print "Simulazione modello di Ising2D"}NR==2{print "# mossa   Energia    Magnetizzazione"}NR>2{print $1, $2/d, $3/d}' obs_size${dim}_t${t}.out > appo_size${dim}_t${t}.out
    done

    echo "Eseguito studio termalizzazione per dimensione fissata $dim."    
done

echo "Studio della termalizzazione terminato."
