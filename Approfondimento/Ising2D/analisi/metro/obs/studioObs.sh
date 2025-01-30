#!/bin/bash

tempIsing=(1.0 1.5 2.0 2.5 3.0 3.5)		 # Temperature a cui simulo il modello


#---------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a varie t       #
#---------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione

for t in "${tempIsing[@]}"; do

    # Eseguo programma per determinazione osservabili
    LC_NUMERIC=C awk 'NR<2{print}NR>=2 && $1<=100{print $1, $2, $3}' obs_size100_t${t}.out > ../../pcrit/dipJ/dipJ_t${t}_J1.0.out

done


echo "Studio della termalizzazione terminato."
