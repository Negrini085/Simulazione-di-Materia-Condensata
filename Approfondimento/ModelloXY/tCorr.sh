#!/bin/bash

input_file="input.dat"      		          # Nome del file di input
tempXY=(0.25 0.5 0.75 1.0 1.25 1.5)               # Temperature a cui simulo il modello
deltaXY=(0.8 1.1 1.4 1.7 2.5 3.2)                 # Rotazione angolare degli spin
sizeXY=(100 200 300 400 500)                      # Dimensioni del modello di Ising



#--------------------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a vari stati del pcg       #
#--------------------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione (e di conseguenza il numero di mosse da fare)
for ((i=0; i<${#sizeXY[@]}; i++)); do
    sed -i "2s/.*/"${sizeXY[i]}"/" "$input_file"

    for ((j=0; j<${#tempXY[@]}; j++)); do
        sed -i "1s/.*/"${tempXY[j]}"/" "$input_file"
        sed -i "6s/.*/"${deltaXY[j]}"/" "$input_file"

        for ((k=1; k<=4; k++)); do
            # Eseguo programma e faccio analisi su termalizzazione
            ./modelXY input.dat > analisi/tcorr/tcorr_t${tempXY[j]}_size${sizeXY[i]}_seed$k.out
        done
    
    done

    dim=${sizeXY[i]}
    echo "Eseguito studio termalizzazione per dimensione fissata $dim."    
done

echo "Studio della termalizzazione terminato."
