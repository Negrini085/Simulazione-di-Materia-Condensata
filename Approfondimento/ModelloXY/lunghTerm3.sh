#!/bin/bash

input_file="input3.dat"      		          # Nome del file di input
tempXY=(2.5 3.0)               # Temperature a cui simulo il modello
deltaXY=(4.0 4.0)                 # Rotazione angolare degli spin
sizeXY=(50 100 200)                      		  # Dimensioni del modello di Ising



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
            ./modelXY input3.dat analisi/conf/conf_t${tempXY[j]}_size${sizeXY[i]}.out | tee analisi/term/term_t${tempXY[j]}_size${sizeXY[i]}_seed$k.out
            echo "Eseguito studio con: N = "${sizeXY[i]}", T = "${tempXY[j]}", seed = $k"
    	done
    done
done

echo "Studio della termalizzazione terminato."
