#!/bin/bash

tempXY=(0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0 3.25)                  # Temperature a cui simulo il modello
sizeXY=(50 100 200)                   		  # Dimensioni del modello di Ising



#--------------------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a vari stati del pcg       #
#--------------------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione (e di conseguenza il numero di mosse da fare)
for ((i=0; i<${#sizeXY[@]}; i++)); do
    for ((j=0; j<${#tempXY[@]}; j++)); do
        # Eseguo programma e faccio analisi su termalizzazione
        LC_NUMERIC=C awk 'NR==19{print "#Sweep   Energia    Magn X    Magn Y"}NR>19{print $1,   $2,    $3,  $4}' obs_t${tempXY[j]}_size${sizeXY[i]}.out > appo_t${tempXY[j]}_size${sizeXY[i]}.out
        rm obs_t${tempXY[j]}_size${sizeXY[i]}.out
        mv appo_t${tempXY[j]}_size${sizeXY[i]}.out obs_t${tempXY[j]}_size${sizeXY[i]}.out
    done
done
