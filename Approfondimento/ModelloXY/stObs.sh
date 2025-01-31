#!/bin/bash

input_file="input.dat"      		          			     # Nome del file di input
tempXY=(0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.3 2.35 2.4)               # Temperature a cui simulo il modello
deltaXY=(0.8 1.1 1.4 1.7 2.5 3.2 4.0 4.0 4.0 4.0 4.0 4.0)                    # Rotazione angolare degli spin
sizeXY=(50) 			                     			     # Dimensioni del modello di Ising



#--------------------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a vari stati del pcg       #
#--------------------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione (e di conseguenza il numero di mosse da fare)
for ((i=0; i<${#sizeXY[@]}; i++)); do
    sed -i "2s/.*/"${sizeXY[i]}"/" "$input_file"

    for ((j=0; j<${#tempXY[@]}; j++)); do
        sed -i "1s/.*/"${tempXY[j]}"/" "$input_file"
        sed -i "6s/.*/"${deltaXY[j]}"/" "$input_file"

        
        # Eseguo programma e faccio analisi su termalizzazione
       ./modelXY input.dat inutile > analisi/obs/obs_t${tempXY[j]}_size${sizeXY[i]}.out
        echo "Eseguito studio T = " ${tempXY[j]}    
    
    done

    dim=${sizeXY[i]}
done

echo "Studio della termalizzazione terminato."
