#!/bin/bash

tempXY=(0.5 1.0 1.5 2.0 2.5 3.0)              # Temperature a cui simulo il modello
sizeXY=(50 100 200)	                      # Dimensioni del modello di Ising



#--------------------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a vari stati del pcg       #
#--------------------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione (e di conseguenza il numero di mosse da fare)
for ((i=0; i<${#sizeXY[@]}; i++)); do
    for ((j=0; j<${#tempXY[@]}; j++)); do
        for ((k=1; k<=4; k++)); do
            # Eseguo programma e faccio analisi su termalizzazione
            LC_NUMERIC=C awk 'NR==19{print "#Sweep   Energia    Magn X    Magn Y"}NR>19{print $1,   $2,    $3,  $4}' term_t${tempXY[j]}_size${sizeXY[i]}_seed$k.out > appo_t${tempXY[j]}_size${sizeXY[i]}_seed$k.out
            rm term_t${tempXY[j]}_size${sizeXY[i]}_seed$k.out
            mv appo_t${tempXY[j]}_size${sizeXY[i]}_seed$k.out term_t${tempXY[j]}_size${sizeXY[i]}_seed$k.out
    	done
    done
    echo "Eseguito studio per: ${sizeXY[i]}"
done
